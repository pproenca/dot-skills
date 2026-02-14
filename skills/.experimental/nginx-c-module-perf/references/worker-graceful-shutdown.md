---
title: Handle Worker Shutdown Signal Without Data Loss
impact: MEDIUM
impactDescription: prevents in-flight request data corruption during reload/restart
tags: worker, shutdown, graceful, drain
---

## Handle Worker Shutdown Signal Without Data Loss

When a worker process receives `SIGQUIT` (graceful shutdown) during `nginx -s reload` or `nginx -s quit`, nginx sets the `ngx_exiting` flag and begins draining connections. Module code that performs multi-step operations -- buffering writes, accumulating analytics, or flushing caches to disk -- must check `ngx_exiting` and complete or persist pending work before the process exits. Ignoring this flag causes silent data loss when writes are abandoned mid-operation.

**Incorrect (ignores shutdown signal, loses buffered data):**

```c
static void
ngx_http_mymodule_flush_timer(ngx_event_t *ev)
{
    ngx_http_mymodule_main_conf_t  *mmcf = ev->data;

    /* BUG: if ngx_exiting is set, the worker is shutting down and
     * this timer may never fire again — the batch buffer contents
     * are silently lost when the process exits */
    if (mmcf->batch_buf.pos == mmcf->batch_buf.start) {
        /* nothing to flush, reschedule */
        ngx_add_timer(ev, mmcf->flush_interval);
        return;
    }

    /* partial flush — writes only what fits in one syscall */
    ngx_write_fd(mmcf->log_fd, mmcf->batch_buf.start,
                 mmcf->batch_buf.pos - mmcf->batch_buf.start);

    mmcf->batch_buf.pos = mmcf->batch_buf.start;
    ngx_add_timer(ev, mmcf->flush_interval);
}
```

**Correct (checks ngx_exiting and drains all pending data before shutdown):**

```c
static void
ngx_http_mymodule_flush_timer(ngx_event_t *ev)
{
    ngx_http_mymodule_main_conf_t  *mmcf = ev->data;
    ssize_t                         n, remaining;
    u_char                         *p;

    remaining = mmcf->batch_buf.pos - mmcf->batch_buf.start;

    if (remaining == 0 && !ngx_exiting) {
        ngx_add_timer(ev, mmcf->flush_interval);
        return;
    }

    if (remaining > 0) {
        /* flush entire buffer — loop handles partial writes */
        p = mmcf->batch_buf.start;
        while (remaining > 0) {
            n = ngx_write_fd(mmcf->log_fd, p, remaining);
            if (n == -1) {
                ngx_log_error(NGX_LOG_ALERT, ev->log, ngx_errno,
                              "mymodule: failed to flush batch buffer");
                break;
            }
            p += n;
            remaining -= n;
        }

        mmcf->batch_buf.pos = mmcf->batch_buf.start;
    }

    if (ngx_exiting) {
        /* worker is shutting down — sync to disk and stop rescheduling;
         * the timer will not fire again after this return */
        if (mmcf->log_fd != NGX_INVALID_FILE) {
            ngx_log_error(NGX_LOG_NOTICE, ev->log, 0,
                          "mymodule: flushed pending data on worker exit");
        }
        return;
    }

    ngx_add_timer(ev, mmcf->flush_interval);
}
```

**Note:** `ngx_exiting` is a global `ngx_uint_t` flag set by the worker process signal handler. Always check it before rescheduling timers or deferring work. For modules using shared memory, also acquire the mutex and flush shared state before returning, since no future timer invocation is guaranteed.

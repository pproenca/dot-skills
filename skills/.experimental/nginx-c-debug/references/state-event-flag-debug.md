---
title: Inspect Event Flags to Debug Unexpected Handler Invocation
impact: MEDIUM
impactDescription: reveals why a handler runs at the wrong time
tags: state, event, flags, ready, active
---

## Inspect Event Flags to Debug Unexpected Handler Invocation

Event flags (`ev->ready`, `ev->active`, `ev->timedout`, `ev->eof`, `ev->error`) control when and why handlers are invoked. When a handler runs unexpectedly or processes data that is not actually available, the root cause is almost always an unchecked flag. The handler may have been called because the event timed out (not because data arrived), because the peer closed the connection (EOF), or because a write completed (not a read). Checking these flags at handler entry before processing data prevents subtle corruption from misinterpreting the invocation reason.

**Incorrect (assuming the handler is called because data is available):**

```c
static void
ngx_http_mymodule_read_handler(ngx_event_t *rev)
{
    ssize_t            n;
    ngx_connection_t  *c;
    ngx_buf_t         *b;

    c = rev->data;
    b = c->buffer;

    /* BAD: assuming the handler was called because data is ready.
     * The handler can be invoked for ANY of these reasons:
     * - rev->timedout: read timeout expired, no data available
     * - rev->eof: peer closed the connection
     * - rev->error: socket error occurred
     * - rev->ready: data is actually available to read
     *
     * Calling recv() without checking timedout/eof/error leads to:
     * - Reading 0 bytes and treating it as a valid empty response
     * - Getting EAGAIN and spinning in a busy loop
     * - Getting an error that overwrites the real timeout cause */
    n = c->recv(c, b->last, b->end - b->last);

    if (n <= 0) {
        /* Is this a timeout? EOF? Error? EAGAIN?
         * Without flag checks, you can't distinguish them. */
        ngx_log_error(NGX_LOG_ERR, c->log, 0,
                      "mymodule: read returned %z", n);
        ngx_http_mymodule_finalize(c, NGX_ERROR);
        return;
    }

    b->last += n;
    ngx_http_mymodule_process_data(c, b);
}
```

**Correct (checking event flags at handler entry to determine invocation reason):**

```c
static void
ngx_http_mymodule_read_handler(ngx_event_t *rev)
{
    ssize_t            n;
    ngx_connection_t  *c;
    ngx_buf_t         *b;

    c = rev->data;
    b = c->buffer;

    /* Log all flags at entry for debugging */
    ngx_log_debug5(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule read handler: ready=%d timedout=%d "
                   "eof=%d error=%d active=%d",
                   rev->ready, rev->timedout, rev->eof,
                   rev->error, rev->active);

    /* Check timeout FIRST — no data to read */
    if (rev->timedout) {
        ngx_log_error(NGX_LOG_INFO, c->log, NGX_ETIMEDOUT,
                      "mymodule: client read timed out");
        c->timedout = 1;
        ngx_http_mymodule_finalize(c, NGX_HTTP_REQUEST_TIME_OUT);
        return;
    }

    /* Check error flag — socket-level error */
    if (rev->error) {
        ngx_log_error(NGX_LOG_ERR, c->log, 0,
                      "mymodule: read event error flag set");
        ngx_http_mymodule_finalize(c, NGX_ERROR);
        return;
    }

    /* Now safe to attempt read — but still handle recv results */
    n = c->recv(c, b->last, b->end - b->last);

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: recv returned %z", n);

    if (n == NGX_AGAIN) {
        /* No data available yet — re-register for read events */
        if (ngx_handle_read_event(rev, 0) != NGX_OK) {
            ngx_http_mymodule_finalize(c, NGX_ERROR);
        }
        return;
    }

    if (n == 0) {
        /* Peer closed connection gracefully (EOF) */
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0,
                       "mymodule: peer closed connection (EOF)");
        ngx_http_mymodule_finalize(c, NGX_OK);
        return;
    }

    if (n == NGX_ERROR) {
        ngx_log_error(NGX_LOG_ERR, c->log, ngx_socket_errno,
                      "mymodule: recv() failed");
        ngx_http_mymodule_finalize(c, NGX_ERROR);
        return;
    }

    /* Data received — safe to process */
    b->last += n;
    ngx_http_mymodule_process_data(c, b);
}
```

Reference: [nginx Development Guide — Events](https://nginx.org/en/docs/dev/development_guide.html#events)

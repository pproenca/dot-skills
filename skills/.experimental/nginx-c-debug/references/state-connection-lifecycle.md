---
title: Track Connection State Transitions for Lifecycle Debugging
impact: MEDIUM
impactDescription: identifies where connection handling deviates from expected sequence
tags: state, connection, lifecycle, transitions
---

## Track Connection State Transitions for Lifecycle Debugging

An nginx connection progresses through a strict state sequence: accept, SSL handshake (if TLS), read request, process phases, send response, then keepalive or close. Each state installs specific read/write event handlers on the connection. Debugging connection issues requires knowing which state the connection is in when the problem occurs. The connection struct carries multiple flags (`c->destroyed`, `c->close`, `c->error`, `c->timedout`, `c->idle`) that collectively describe the current lifecycle stage. Checking only `c->fd` is unreliable because file descriptors are reused immediately after close.

**Incorrect (checking only c->fd to determine if connection is alive):**

```c
static void
ngx_http_mymodule_check_connection(ngx_event_t *ev)
{
    ngx_connection_t  *c;

    c = ev->data;

    /* BAD: fd can be reused by a completely different connection
     * after this one was closed. A positive fd does NOT mean
     * this connection is still valid. */
    if (c->fd == -1) {
        return;
    }

    /* BAD: proceeding without checking state flags.
     * The connection may be in error/close/timedout state
     * even though fd is valid. Writing to it will produce
     * confusing errors or corrupt another connection's data
     * if the fd was reused. */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: connection fd=%d is alive", c->fd);

    /* BAD: sending data without verifying connection state */
    ngx_http_mymodule_send_response(c);
}
```

**Correct (checking the full set of state flags and logging current handlers):**

```c
static void
ngx_http_mymodule_check_connection(ngx_event_t *ev)
{
    ngx_connection_t  *c;

    c = ev->data;

    /* Log the complete connection state for debugging */
    ngx_log_debug7(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: connection state check: "
                   "fd=%d destroyed=%d close=%d error=%d "
                   "timedout=%d idle=%d reusable=%d",
                   c->fd,
                   c->destroyed,
                   c->close,
                   c->error,
                   c->read->timedout,
                   c->idle,
                   c->reusable);

    /* Check destroyed first — connection struct is being freed */
    if (c->destroyed) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0,
                       "mymodule: connection already destroyed");
        return;
    }

    /* Check error and close flags before any I/O */
    if (c->error || c->close) {
        ngx_log_debug2(NGX_LOG_DEBUG_HTTP, c->log, 0,
                       "mymodule: connection error=%d close=%d, "
                       "aborting operation",
                       c->error, c->close);
        return;
    }

    /* Log current event handlers to identify lifecycle stage */
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: current handlers: "
                   "read=%p write=%p",
                   c->read->handler, c->write->handler);

    /* Check timeout separately — may need different handling */
    if (c->read->timedout) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0,
                       "mymodule: read timed out");
        c->timedout = 1;
        ngx_http_mymodule_finalize(c);
        return;
    }

    /* Safe to proceed — connection is in a valid active state */
    ngx_http_mymodule_send_response(c);
}
```

Reference: [nginx Development Guide — Connection](https://nginx.org/en/docs/dev/development_guide.html#connection)

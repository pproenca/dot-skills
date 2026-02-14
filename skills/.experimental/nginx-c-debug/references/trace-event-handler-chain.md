---
title: Trace Event Handler Execution for Connection Debugging
impact: HIGH
impactDescription: identifies which of 3-5 chained handlers misses or double-processes an event
tags: trace, event, handler, connection, read-write
---

## Trace Event Handler Execution for Connection Debugging

Each nginx connection has read and write event handlers (`c->read->handler`, `c->write->handler`) that change as the connection progresses through its lifecycle: from initial accept, through SSL handshake, to HTTP request reading, response writing, and keepalive waiting. A common bug is a handler that fails to set the next event handler before returning, causing the wrong handler to run when the next event fires. This produces intermittent failures that are extremely difficult to reproduce because they depend on event timing.

**Incorrect (assuming the event handler stays the same throughout the connection):**

```c
/*
 * Module sets up a custom read handler but never updates it
 * when transitioning to a different connection state.
 */
static void
ngx_http_mymodule_init_connection(ngx_connection_t *c)
{
    c->read->handler = ngx_http_mymodule_read_request;
    c->write->handler = ngx_http_mymodule_write_response;

    /* ... start reading request ... */
}

static void
ngx_http_mymodule_read_request(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;
    ssize_t            n;

    n = c->recv(c, buf, size);

    if (n == NGX_AGAIN) {
        return;  /* wait for next read event */
    }

    /* Request fully read — transition to upstream phase.
     *
     * BUG: developer does NOT update c->read->handler.
     * When upstream sends data back, the epoll read event
     * fires and calls ngx_http_mymodule_read_request again
     * instead of the upstream read handler. This either
     * reads upstream data as a new client request (garbled
     * response) or crashes on the wrong buffer pointers.
     */
    start_upstream_request(c);
}
```

**Correct (logging and updating event handlers at each state transition):**

```c
static void
ngx_http_mymodule_init_connection(ngx_connection_t *c)
{
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: init connection fd=%d, "
                   "setting handlers to read_request/write_response",
                   c->fd);

    c->read->handler = ngx_http_mymodule_read_request;
    c->write->handler = ngx_http_mymodule_write_response;
}

static void
ngx_http_mymodule_read_request(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;
    ssize_t            n;

    ngx_log_debug3(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: read_request event, fd=%d, "
                   "read_handler=%p, write_handler=%p",
                   c->fd, c->read->handler, c->write->handler);

    n = c->recv(c, buf, size);

    if (n == NGX_AGAIN) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0,
                       "mymodule: read_request NGX_AGAIN, "
                       "handlers unchanged");
        return;
    }

    if (n <= 0) {
        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, c->log, 0,
                       "mymodule: read_request recv=%z, "
                       "closing connection", n);
        ngx_close_connection(c);
        return;
    }

    /* Request fully read — transition handlers for upstream phase */
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: transitioning handlers, "
                   "read: read_request(%p) -> upstream_read(%p)",
                   c->read->handler,
                   ngx_http_mymodule_upstream_read);

    c->read->handler = ngx_http_mymodule_upstream_read;
    c->write->handler = ngx_http_mymodule_upstream_write;

    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: handlers updated, "
                   "read_handler=%p, write_handler=%p",
                   c->read->handler, c->write->handler);

    start_upstream_request(c);
}

static void
ngx_http_mymodule_upstream_read(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;

    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, c->log, 0,
                   "mymodule: upstream_read event, fd=%d, "
                   "read_handler=%p",
                   c->fd, c->read->handler);

    /* process upstream data correctly */
}

/*
 * Debug log output showing handler transitions:
 *
 *  mymodule: init connection fd=12, setting handlers to read_request/write_response
 *  mymodule: read_request event, fd=12, read_handler=0x4a1200, write_handler=0x4a1400
 *  mymodule: read_request NGX_AGAIN, handlers unchanged
 *  mymodule: read_request event, fd=12, read_handler=0x4a1200, write_handler=0x4a1400
 *  mymodule: transitioning handlers, read: read_request(0x4a1200) -> upstream_read(0x4a1600)
 *  mymodule: handlers updated, read_handler=0x4a1600, write_handler=0x4a1800
 *  mymodule: upstream_read event, fd=12, read_handler=0x4a1600
 */
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)

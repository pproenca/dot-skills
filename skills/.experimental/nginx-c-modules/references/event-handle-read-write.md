---
title: Call ngx_handle_read/write_event After I/O Operations
impact: MEDIUM
impactDescription: prevents missed events and stalled connections
tags: event, read, write, notification
---

## Call ngx_handle_read/write_event After I/O Operations

After processing an I/O event, call `ngx_handle_read_event` or `ngx_handle_write_event` to re-register for notifications on that file descriptor. On edge-triggered systems (epoll with `EPOLLET`), missing this call means the connection permanently stalls -- no further events are delivered even when data becomes available.

**Incorrect (processes data without re-registering for events):**

```c
static void
ngx_http_mymodule_read_handler(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;
    ngx_int_t          n;

    n = c->recv(c, c->buffer->last,
                c->buffer->end - c->buffer->last);

    if (n == NGX_AGAIN) {
        /* BUG: on epoll edge-triggered, no re-registration means
         * this connection will never receive another read event */
        return;
    }

    c->buffer->last += n;
    ngx_http_mymodule_process(c);
    /* BUG: no re-registration for next read */
}
```

**Correct (re-registers for events after I/O processing):**

```c
static void
ngx_http_mymodule_read_handler(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;
    ngx_int_t          n;

    n = c->recv(c, c->buffer->last,
                c->buffer->end - c->buffer->last);

    if (n == NGX_AGAIN) {
        if (ngx_handle_read_event(rev, 0) != NGX_OK) {
            ngx_http_mymodule_finalize(c);
        }
        return;
    }

    c->buffer->last += n;
    ngx_http_mymodule_process(c);

    /* re-register for next read event */
    if (ngx_handle_read_event(rev, 0) != NGX_OK) {
        ngx_http_mymodule_finalize(c);
    }
}
```

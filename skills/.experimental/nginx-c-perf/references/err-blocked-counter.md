---
title: Use Blocked Counter to Prevent Premature Request Destruction
impact: MEDIUM-HIGH
impactDescription: prevents use-after-free during concurrent async operations
tags: err, blocked, async, use-after-free
---

## Use Blocked Counter to Prevent Premature Request Destruction

When a handler initiates an asynchronous operation — AIO file read, cache lock wait, or thread task — the event loop may call `ngx_http_finalize_request` before the callback fires. If `r->blocked` is zero, nginx will free the request and its pool, and the callback will operate on freed memory. Incrementing `r->blocked` before dispatching the async operation tells nginx the request has outstanding work; decrementing it in the callback and re-running finalization lets nginx destroy the request only when all operations have completed.

**Incorrect (dispatches AIO without incrementing r->blocked, risks use-after-free):**

```c
static ngx_int_t
ngx_http_mymodule_read_async(ngx_http_request_t *r, ngx_file_t *file)
{
    ngx_buf_t  *b;

    b = ngx_create_temp_buf(r->pool, 4096);
    if (b == NULL) {
        return NGX_ERROR;
    }

    /* BUG: if client disconnects during AIO, nginx finalizes the request
     * and frees r->pool — callback will dereference freed memory */
    file->aio = r->connection->aio;

    return ngx_file_aio_read(file, b->pos, 4096, 0, r->pool);
}

static void
ngx_http_mymodule_aio_handler(ngx_event_t *ev)
{
    ngx_http_request_t  *r = ev->data;

    /* r may already be freed here — use-after-free */
    ngx_http_finalize_request(r, ngx_http_mymodule_send_response(r));
}
```

**Correct (increments r->blocked before AIO, decrements in callback before finalizing):**

```c
static ngx_int_t
ngx_http_mymodule_read_async(ngx_http_request_t *r, ngx_file_t *file)
{
    ngx_buf_t  *b;

    b = ngx_create_temp_buf(r->pool, 4096);
    if (b == NULL) {
        return NGX_ERROR;
    }

    file->aio = r->connection->aio;

    /* prevent nginx from destroying the request while AIO is in-flight */
    r->blocked++;
    r->aio = 1;

    return ngx_file_aio_read(file, b->pos, 4096, 0, r->pool);
}

static void
ngx_http_mymodule_aio_handler(ngx_event_t *ev)
{
    ngx_http_request_t  *r = ev->data;

    /* AIO complete — unblock the request so finalization can proceed */
    r->blocked--;
    r->aio = 0;

    if (r->blocked == 0) {
        /* safe to finalize now — no other async operations pending */
        ngx_http_finalize_request(r, ngx_http_mymodule_send_response(r));
    }
}
```

**See also:** The companion correctness skill's `req-count-reference` covers `r->main->count++` for general async operations (subrequests, timers). Use `r->blocked` specifically for AIO and thread pool tasks — it prevents `ngx_http_finalize_request` from destroying the request while the kernel-level async operation is in-flight.

---
title: Offload Blocking Operations to Thread Pool
impact: MEDIUM
impactDescription: prevents event loop stalls on CPU-intensive or blocking work
tags: event, thread-pool, offload, async
---

## Offload Blocking Operations to Thread Pool

CPU-intensive operations (cryptographic hashing, image transformation, compression) and unavoidable blocking calls (synchronous database queries, disk I/O on systems without AIO) block the event loop. Use `ngx_thread_task_post` to execute them in a thread pool, with a completion callback that runs back on the event loop thread to process results.

**Incorrect (CPU-intensive work directly in event handler):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    u_char   hash[32];
    u_char  *data;
    size_t   len;

    data = r->request_body->bufs->buf->pos;
    len = r->request_body->bufs->buf->last - data;

    /* BUG: blocks event loop for entire SHA-256 computation */
    ngx_http_mymodule_sha256(data, len, hash);

    return ngx_http_mymodule_send_response(r, hash, 32);
}
```

**Correct (offloads work to thread pool with completion callback):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_thread_task_t        *task;
    ngx_http_mymodule_ctx_t  *ctx;
    ngx_thread_pool_t        *tp;

    tp = ngx_thread_pool_get((ngx_cycle_t *) ngx_cycle, &pool_name);

    task = ngx_thread_task_alloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (task == NULL) {
        return NGX_ERROR;
    }

    ctx = task->ctx;
    ctx->request = r;
    ctx->data = r->request_body->bufs->buf->pos;
    ctx->len = r->request_body->bufs->buf->last - ctx->data;

    task->handler = ngx_http_mymodule_sha256_thread;  /* runs in thread */
    task->event.handler = ngx_http_mymodule_sha256_done; /* completion */
    task->event.data = r;

    r->main->count++;

    return ngx_thread_task_post(tp, task);
}
```

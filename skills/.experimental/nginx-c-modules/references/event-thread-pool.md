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
typedef struct {
    ngx_http_request_t  *request;
    u_char              *data;
    size_t               len;
    u_char               hash[32];
} ngx_http_mymodule_ctx_t;

/* runs in thread pool — must NOT access r or any nginx structures */
static void
ngx_http_mymodule_sha256_thread(void *data, ngx_log_t *log)
{
    ngx_http_mymodule_ctx_t  *ctx = data;

    /* safe: only accesses data copied into ctx before posting */
    ngx_http_mymodule_sha256(ctx->data, ctx->len, ctx->hash);
}

/* runs on event loop thread — safe to access request and finalize */
static void
ngx_http_mymodule_sha256_done(ngx_event_t *ev)
{
    ngx_http_mymodule_ctx_t  *ctx;
    ngx_http_request_t       *r;

    ctx = ev->data;
    r = ctx->request;

    /* finalize decrements r->main->count internally */
    ngx_http_finalize_request(r,
        ngx_http_mymodule_send_response(r, ctx->hash, 32));
}

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
    task->event.data = ctx;

    /* keep request alive while thread work is pending */
    r->main->count++;

    return ngx_thread_task_post(tp, task);
}
```

**Note:** The thread handler must NOT access `r` or any nginx structures directly — only data copied into the task context before posting. The completion callback runs on the event loop thread where it is safe to call `ngx_http_finalize_request`. Set `task->event.data` to the context (not `r`) so the completion handler can access both the results and the request.

---
title: Avoid Storing Long-Lived Pointers in Temporary Pools
impact: CRITICAL
impactDescription: crashes when temp pool freed — r->pool vs r->connection->pool lifetime mismatch
tags: memdbg, temp-pool, request-body, configuration
---

## Avoid Storing Long-Lived Pointers in Temporary Pools

nginx destroys temporary pools at specific lifecycle points: `r->pool` is reset during internal redirects, and request body temporary pools are freed after body processing completes. Saving pointers from these pools and accessing them after the lifecycle event causes use-after-free. This is especially dangerous with `r->request_body->temp_file` and with subrequests that share the parent request body.

**Incorrect (caches pointer to request body data from temp pool, reads it in a later phase):**

```c
typedef struct {
    u_char      *body_data;    /* dangling after body temp pool freed */
    size_t       body_len;
} my_ctx_t;

static void
ngx_http_mymodule_body_read(ngx_http_request_t *r)
{
    my_ctx_t     *ctx;
    ngx_chain_t  *cl;
    ngx_buf_t    *buf;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    cl = r->request_body->bufs;
    if (cl == NULL) {
        ngx_http_finalize_request(r, NGX_HTTP_BAD_REQUEST);
        return;
    }

    buf = cl->buf;

    /* BUG: body buffer may be in a temporary pool or temp file mapping
     * that is freed after this callback returns */
    ctx->body_data = buf->pos;
    ctx->body_len = buf->last - buf->pos;

    /* later phase reads ctx->body_data — use-after-free */
    ngx_http_finalize_request(r, ngx_http_mymodule_process(r));
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }
    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    r->request_body_in_single_buf = 1;
    r->request_body_in_persistent_file = 0;

    return ngx_http_read_client_request_body(r,
                                             ngx_http_mymodule_body_read);
}
```

**Correct (copies required data to stable pool before lifecycle boundary):**

```c
typedef struct {
    u_char      *body_data;    /* deep copy in r->pool */
    size_t       body_len;
} my_ctx_t;

static void
ngx_http_mymodule_body_read(ngx_http_request_t *r)
{
    my_ctx_t     *ctx;
    ngx_chain_t  *cl;
    ngx_buf_t    *buf;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    cl = r->request_body->bufs;
    if (cl == NULL) {
        ngx_http_finalize_request(r, NGX_HTTP_BAD_REQUEST);
        return;
    }

    buf = cl->buf;

    /* SAFE: deep-copy body into r->pool before the body temp pool is freed */
    ctx->body_len = buf->last - buf->pos;
    ctx->body_data = ngx_pnalloc(r->pool, ctx->body_len);
    if (ctx->body_data == NULL) {
        ngx_http_finalize_request(r, NGX_HTTP_INTERNAL_SERVER_ERROR);
        return;
    }
    ngx_memcpy(ctx->body_data, buf->pos, ctx->body_len);

    /* SAFE: ctx->body_data now lives in r->pool, independent of
     * the request body temporary pool lifecycle */
    ngx_http_finalize_request(r, ngx_http_mymodule_process(r));
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }
    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    r->request_body_in_single_buf = 1;
    r->request_body_in_persistent_file = 0;

    return ngx_http_read_client_request_body(r,
                                             ngx_http_mymodule_body_read);
}
```

Reference: [nginx Development Guide — HTTP Request Body](https://nginx.org/en/docs/dev/development_guide.html#http_request_body)

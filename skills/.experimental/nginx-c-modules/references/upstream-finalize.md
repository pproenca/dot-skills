---
title: Clean Up Resources in finalize_request Callback
impact: MEDIUM
impactDescription: prevents connection and memory leaks on upstream errors
tags: upstream, finalize, cleanup, resources
---

## Clean Up Resources in finalize_request Callback

The `finalize_request` callback is called when nginx finishes with the upstream connection, including error cases (timeouts, resets, protocol errors). Any module-specific resources allocated during the upstream exchange -- open file descriptors, heap memory, external connections -- must be released here. Without cleanup, every failed upstream request leaks resources until the worker restarts.

**Incorrect (allocates resources without cleanup in finalize):**

```c
static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    ngx_http_myproxy_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_myproxy_module);

    /* heap allocation for large temp buffer */
    ctx->work_buf = ngx_alloc(NGX_HTTP_MYPROXY_BUFSIZE, r->connection->log);

    ctx->temp_fd = ngx_open_tempfile(ctx->path.data, 0, 0);

    /* BUG: if upstream fails, work_buf and temp_fd are never cleaned up */
    return NGX_OK;
}

static void
ngx_http_myproxy_finalize_request(ngx_http_request_t *r, ngx_int_t rc)
{
    /* empty — resources leak on every upstream error */
}
```

**Correct (finalize_request releases all allocated resources):**

```c
static void
ngx_http_myproxy_finalize_request(ngx_http_request_t *r, ngx_int_t rc)
{
    ngx_http_myproxy_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_myproxy_module);
    if (ctx == NULL) {
        return;
    }

    if (ctx->work_buf != NULL) {
        ngx_free(ctx->work_buf);
        ctx->work_buf = NULL;
    }

    if (ctx->temp_fd != NGX_INVALID_FILE) {
        ngx_close_file(ctx->temp_fd);
        ctx->temp_fd = NGX_INVALID_FILE;
    }

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                    "myproxy finalize: rc=%d", rc);
}
```

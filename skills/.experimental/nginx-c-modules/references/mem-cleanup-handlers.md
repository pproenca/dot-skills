---
title: Register Pool Cleanup Handlers for External Resources
impact: HIGH
impactDescription: prevents file descriptor and resource leaks
tags: mem, cleanup, pool, resources
---

## Register Pool Cleanup Handlers for External Resources

Pool destruction only frees memory allocated from the pool itself. External resources such as file descriptors, library handles, shared memory mappings, and network sockets require explicit cleanup via `ngx_pool_cleanup_add`. Without a cleanup handler, error paths and abnormal request termination leak these resources, eventually exhausting system limits.

**Incorrect (file descriptor leaks on error paths):**

```c
static ngx_int_t
ngx_http_mymodule_open_db(ngx_http_request_t *r, my_ctx_t *ctx)
{
    ctx->db_fd = open("/var/lib/mymodule/data.db", O_RDONLY);
    if (ctx->db_fd == -1) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, ngx_errno,
                      "failed to open database");
        return NGX_ERROR;
    }

    /* BUG: if request finishes or errors out, db_fd is never closed */
    /* pool destruction frees ctx memory but does not close the fd */

    return NGX_OK;
}
```

**Correct (cleanup handler closes resource on pool destruction):**

```c
static void
ngx_http_mymodule_cleanup_db(void *data)
{
    my_ctx_t  *ctx = data;

    if (ctx->db_fd != -1) {
        close(ctx->db_fd);
        ctx->db_fd = -1;
    }
}

static ngx_int_t
ngx_http_mymodule_open_db(ngx_http_request_t *r, my_ctx_t *ctx)
{
    ngx_pool_cleanup_t  *cln;

    cln = ngx_pool_cleanup_add(r->pool, 0);
    if (cln == NULL) {
        return NGX_ERROR;
    }

    /* initialize sentinel BEFORE registering cleanup — ngx_pcalloc zeros
     * to 0 which is a valid fd on Unix, not our sentinel -1 */
    ctx->db_fd = -1;

    cln->handler = ngx_http_mymodule_cleanup_db;
    cln->data = ctx;

    ctx->db_fd = open("/var/lib/mymodule/data.db", O_RDONLY);
    if (ctx->db_fd == -1) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, ngx_errno,
                      "failed to open database");
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

**Note:** Initialize the sentinel value (`ctx->db_fd = -1`) explicitly before registering the cleanup handler. `ngx_pcalloc` zeros memory to `0`, which is a valid file descriptor on Unix — not a safe sentinel. Register the cleanup handler before `open()` so that if the pool is destroyed between the open and the return, the fd is still closed. This pattern is used throughout nginx core for temporary files (`ngx_pool_cleanup_file`).

---
title: Detect Resource Leaks from Missing Pool Cleanup Handlers
impact: CRITICAL
impactDescription: leaks file descriptors and external resources
tags: memdbg, cleanup, file-descriptor, resource-leak
---

## Detect Resource Leaks from Missing Pool Cleanup Handlers

nginx pool destruction frees memory but does NOT close file descriptors, network connections, or free external library resources. Without pool cleanup handlers, these resources leak on every request. Monitor open file descriptors per worker (`ls /proc/PID/fd | wc -l` on Linux, `lsof -p PID | wc -l` on macOS) — steady growth indicates missing cleanup handlers.

**Incorrect (opens a file in handler without registering a cleanup handler):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_fd_t    fd;
    ngx_str_t   path = ngx_string("/var/data/cache.dat");
    u_char      buf[4096];
    ssize_t     n;

    fd = ngx_open_file(path.data, NGX_FILE_RDONLY, NGX_FILE_OPEN, 0);
    if (fd == NGX_INVALID_FILE) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, ngx_errno,
                      ngx_open_file_n " \"%V\" failed", &path);
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    n = ngx_read_fd(fd, buf, sizeof(buf));

    /* BUG: if the code returns early or an error occurs below,
     * fd is never closed. Even on the normal path, fd leaks because
     * r->pool destruction only frees memory, not file descriptors. */

    /* ... process buf, may return NGX_ERROR early ... */

    return NGX_OK;
    /* fd leaked — pool cleanup would have caught this */
}
```

**Correct (registers ngx_pool_cleanup_add with a handler that calls ngx_close_file):**

```c
typedef struct {
    ngx_fd_t    fd;
} my_cleanup_ctx_t;

static void
ngx_http_mymodule_cleanup(void *data)
{
    my_cleanup_ctx_t  *ctx = data;

    if (ctx->fd != NGX_INVALID_FILE) {
        ngx_close_file(ctx->fd);
        ctx->fd = NGX_INVALID_FILE;
    }
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_fd_t             fd;
    ngx_str_t            path = ngx_string("/var/data/cache.dat");
    u_char               buf[4096];
    ssize_t              n;
    ngx_pool_cleanup_t  *cln;
    my_cleanup_ctx_t    *ctx;

    fd = ngx_open_file(path.data, NGX_FILE_RDONLY, NGX_FILE_OPEN, 0);
    if (fd == NGX_INVALID_FILE) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, ngx_errno,
                      ngx_open_file_n " \"%V\" failed", &path);
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* SAFE: register cleanup immediately after opening the resource */
    cln = ngx_pool_cleanup_add(r->pool, sizeof(my_cleanup_ctx_t));
    if (cln == NULL) {
        ngx_close_file(fd);
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    ctx = cln->data;
    ctx->fd = fd;
    cln->handler = ngx_http_mymodule_cleanup;

    n = ngx_read_fd(fd, buf, sizeof(buf));

    /* SAFE: even if we return NGX_ERROR, pool destruction calls
     * ngx_http_mymodule_cleanup which closes fd */

    /* ... process buf ... */

    return NGX_OK;
}
```

Reference: [nginx Development Guide — Pool Cleanup](https://nginx.org/en/docs/dev/development_guide.html#pool)

---
title: Cache ngx_errno Immediately to Prevent Overwrite
impact: HIGH
impactDescription: prevents silent misdiagnosis when intervening calls overwrite errno
tags: err, errno, cache, diagnosis
---

## Cache ngx_errno Immediately to Prevent Overwrite

The global `ngx_errno` (mapped to `errno` on POSIX) is overwritten by any subsequent syscall or library call, including `ngx_log_error` itself which may invoke `write()`. If you reference `ngx_errno` after calling any function, you log whatever error that function produced — not the error you intended to diagnose. Capture it into a local `ngx_err_t` variable on the very first line after the failing call.

**Incorrect (reads ngx_errno after intervening calls have overwritten it):**

```c
static ngx_int_t
ngx_http_mymodule_open_cache(ngx_http_request_t *r, ngx_str_t *path)
{
    ngx_fd_t  fd;

    fd = ngx_open_file(path->data, NGX_FILE_RDONLY, NGX_FILE_OPEN, 0);
    if (fd == NGX_INVALID_FILE) {
        /* BUG: ngx_close_file or internal log write overwrites ngx_errno */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, ngx_errno,
                      "failed to open cache file \"%V\"", path);
        return NGX_ERROR;
    }

    /* ... */
    ngx_close_file(fd);
    return NGX_OK;
}
```

**Correct (saves ngx_errno into a local variable before any other call):**

```c
static ngx_int_t
ngx_http_mymodule_open_cache(ngx_http_request_t *r, ngx_str_t *path)
{
    ngx_fd_t   fd;
    ngx_err_t  err;

    fd = ngx_open_file(path->data, NGX_FILE_RDONLY, NGX_FILE_OPEN, 0);
    if (fd == NGX_INVALID_FILE) {
        /* capture errno immediately — before any call can overwrite it */
        err = ngx_errno;

        ngx_log_error(NGX_LOG_ERR, r->connection->log, err,
                      "failed to open cache file \"%V\"", path);
        return NGX_ERROR;
    }

    /* ... */
    ngx_close_file(fd);
    return NGX_OK;
}
```

**Note:** This is primarily a diagnostic accuracy pattern, but it directly impacts reliability: misdiagnosed errors lead to wrong remediation, extending outage duration. Under incident conditions, accurate errno reporting is the difference between a 5-minute fix and a multi-hour investigation.

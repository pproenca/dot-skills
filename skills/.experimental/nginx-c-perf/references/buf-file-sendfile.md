---
title: Use File Buffers for Static Content Instead of Reading into Memory
impact: CRITICAL
impactDescription: zero-copy sendfile eliminates memory copy per response byte
tags: buf, sendfile, zero-copy, file
---

## Use File Buffers for Static Content Instead of Reading into Memory

When serving file-backed content, setting `in_file = 1` with `file_pos` and `file_last` on `ngx_buf_t` lets nginx use the kernel's `sendfile()` syscall to transfer data directly from the page cache to the socket — zero CPU copies. Reading the file into a memory buffer first doubles memory usage and forces an extra kernel-to-userspace-to-kernel copy on every byte, destroying throughput for large files.

**Incorrect (reads entire file into a memory buffer before sending):**

```c
static ngx_int_t
ngx_http_mymodule_send_file(ngx_http_request_t *r, ngx_str_t *path)
{
    ngx_buf_t         *b;
    ngx_chain_t        out;
    ngx_file_info_t    fi;
    ssize_t            n;
    ngx_fd_t           fd;
    size_t             size;

    fd = ngx_open_file(path->data, NGX_FILE_RDONLY, NGX_FILE_OPEN, 0);
    if (fd == NGX_INVALID_FILE) {
        return NGX_HTTP_NOT_FOUND;
    }

    ngx_fd_info(fd, &fi);
    size = (size_t) ngx_file_size(&fi);

    /* SLOW: allocates response-sized buffer and copies file into userspace */
    b = ngx_create_temp_buf(r->pool, size);
    if (b == NULL) {
        ngx_close_file(fd);
        return NGX_ERROR;
    }

    n = ngx_read_fd(fd, b->pos, size);
    ngx_close_file(fd);

    if (n == NGX_FILE_ERROR) {
        return NGX_ERROR;
    }

    b->last = b->pos + n;
    b->memory = 1;
    b->last_buf = 1;

    out.buf = b;
    out.next = NULL;

    return ngx_http_output_filter(r, &out);
}
```

**Correct (sets file buffer fields for kernel-level sendfile zero-copy):**

```c
static ngx_int_t
ngx_http_mymodule_send_file(ngx_http_request_t *r, ngx_str_t *path)
{
    ngx_buf_t         *b;
    ngx_chain_t        out;
    ngx_open_file_info_t  of;

    ngx_memzero(&of, sizeof(ngx_open_file_info_t));
    of.read_ahead = 0;
    of.directio = NGX_OPEN_FILE_DIRECTIO_OFF;

    if (ngx_open_cached_file(r->connection->log, path, &of, r->pool)
        != NGX_OK)
    {
        return NGX_HTTP_NOT_FOUND;
    }

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    /* zero-copy: kernel sends directly from page cache via sendfile() */
    b->in_file = 1;
    b->file_pos = 0;
    b->file_last = of.size;
    b->file = ngx_pcalloc(r->pool, sizeof(ngx_file_t));
    if (b->file == NULL) {
        return NGX_ERROR;
    }

    b->file->fd = of.fd;
    b->file->name = *path;
    b->file->log = r->connection->log;
    b->last_buf = (r == r->main) ? 1 : 0;
    b->last_in_chain = 1;

    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = of.size;

    out.buf = b;
    out.next = NULL;

    ngx_http_send_header(r);

    return ngx_http_output_filter(r, &out);
}
```

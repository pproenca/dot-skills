---
title: Parse Upstream Response Incrementally in process_header
impact: MEDIUM
impactDescription: prevents incomplete header parsing on partial reads
tags: upstream, process-header, parsing, incremental
---

## Parse Upstream Response Incrementally in process_header

The `process_header` callback may be called with partial data -- the upstream's response might arrive in multiple TCP segments. Return `NGX_AGAIN` if the headers are not yet complete. nginx will call `process_header` again when more data arrives in the buffer. Assuming the entire header is present on the first call causes truncated parsing and garbage values.

**Incorrect (assumes complete headers in buffer):**

```c
static ngx_int_t
ngx_http_myproxy_process_header(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u = r->upstream;
    u_char               *p;

    /* BUG: header may be split across reads — \r\n\r\n not yet in buffer */
    p = u->buffer.pos;

    /* blindly parses status line without checking for terminator */
    u->headers_in.status_n = ngx_atoi(p + 9, 3);
    u->headers_in.status_line.data = p + 9;
    u->headers_in.status_line.len = 3;

    u->buffer.pos = ngx_strlchr(p, u->buffer.last, '\n') + 1;

    return NGX_OK;
}
```

**Correct (checks for complete header before parsing):**

```c
static ngx_int_t
ngx_http_myproxy_process_header(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u = r->upstream;
    u_char               *p, *end;

    end = ngx_strnstr(u->buffer.pos, "\r\n\r\n",
                      u->buffer.last - u->buffer.pos);

    if (end == NULL) {
        /* headers incomplete — wait for more data from upstream */
        return NGX_AGAIN;
    }

    /* safe to parse — full header block is in the buffer */
    p = u->buffer.pos;

    if (u->buffer.last - p < 12) {
        return NGX_HTTP_UPSTREAM_INVALID_HEADER;
    }

    u->headers_in.status_n = ngx_atoi(p + 9, 3);
    if (u->headers_in.status_n == NGX_ERROR) {
        return NGX_HTTP_UPSTREAM_INVALID_HEADER;
    }

    u->headers_in.status_line.data = p + 9;
    u->headers_in.status_line.len = 3;

    u->buffer.pos = end + 4;  /* skip past \r\n\r\n */

    return NGX_OK;
}
```

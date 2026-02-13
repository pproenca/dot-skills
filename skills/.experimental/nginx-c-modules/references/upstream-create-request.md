---
title: Build Complete Request Buffer in create_request
impact: MEDIUM
impactDescription: prevents malformed upstream requests
tags: upstream, create-request, buffer, protocol
---

## Build Complete Request Buffer in create_request

The `create_request` callback must produce a complete, valid protocol message in `u->request_bufs`. An incomplete buffer -- missing terminators, partial headers, or wrong content length -- causes the upstream to reject the request, reset the connection, or hang waiting for more data.

**Incorrect (partial request buffer missing HTTP terminator):**

```c
static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u = r->upstream;
    ngx_buf_t            *b;
    size_t                len;

    len = sizeof("GET ") - 1 + r->uri.len + sizeof(" HTTP/1.0\r\n") - 1;

    b = ngx_create_temp_buf(r->pool, len);
    if (b == NULL) {
        return NGX_ERROR;
    }

    /* BUG: missing final \r\n — upstream sees incomplete HTTP request */
    b->last = ngx_cpymem(b->last, "GET ", 4);
    b->last = ngx_cpymem(b->last, r->uri.data, r->uri.len);
    b->last = ngx_cpymem(b->last, " HTTP/1.0\r\n", 11);

    u->request_bufs = ngx_alloc_chain_link(r->pool);
    if (u->request_bufs == NULL) {
        return NGX_ERROR;
    }

    u->request_bufs->buf = b;
    u->request_bufs->next = NULL;

    return NGX_OK;
}
```

**Correct (complete request with Host header and double CRLF terminator):**

```c
static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u = r->upstream;
    ngx_buf_t            *b;
    size_t                len;

    len = sizeof("GET ") - 1 + r->uri.len + sizeof(" HTTP/1.0\r\n") - 1
        + sizeof("Host: ") - 1 + r->headers_in.host->value.len
        + sizeof("\r\n") - 1
        + sizeof("\r\n") - 1;  /* empty line terminates headers */

    b = ngx_create_temp_buf(r->pool, len);
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->last = ngx_cpymem(b->last, "GET ", 4);
    b->last = ngx_cpymem(b->last, r->uri.data, r->uri.len);
    b->last = ngx_cpymem(b->last, " HTTP/1.0\r\n", 11);
    b->last = ngx_cpymem(b->last, "Host: ", 6);
    b->last = ngx_cpymem(b->last, r->headers_in.host->value.data,
                          r->headers_in.host->value.len);
    b->last = ngx_cpymem(b->last, "\r\n\r\n", 4);

    u->request_bufs = ngx_alloc_chain_link(r->pool);
    if (u->request_bufs == NULL) {
        return NGX_ERROR;
    }

    u->request_bufs->buf = b;
    u->request_bufs->next = NULL;

    return NGX_OK;
}
```

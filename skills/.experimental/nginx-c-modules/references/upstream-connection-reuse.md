---
title: Enable Keepalive for Upstream Connections
impact: LOW-MEDIUM
impactDescription: eliminates TCP/TLS handshake overhead for reused connections
tags: upstream, keepalive, connection-reuse, performance
---

## Enable Keepalive for Upstream Connections

Each new upstream connection incurs TCP handshake overhead (1 RTT) plus optional TLS negotiation (1-2 additional RTTs). For a C module implementing an upstream protocol, the module must use HTTP/1.1 and avoid sending `Connection: close` to allow the built-in `ngx_http_upstream_keepalive_module` to pool connections. Sending `Connection: close` or using HTTP/1.0 forces a new TCP connection per request.

**Incorrect (HTTP/1.0 with Connection: close prevents reuse):**

```c
static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u = r->upstream;
    ngx_buf_t            *b;
    size_t                len;

    /* HTTP/1.0 + Connection: close — every request opens new TCP connection */
    len = sizeof("GET ") - 1 + r->uri.len
        + sizeof(" HTTP/1.0\r\nConnection: close\r\n\r\n") - 1;

    b = ngx_create_temp_buf(r->pool, len);
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->last = ngx_cpymem(b->last, "GET ", 4);
    b->last = ngx_cpymem(b->last, r->uri.data, r->uri.len);
    b->last = ngx_cpymem(b->last, " HTTP/1.0\r\n", 11);
    b->last = ngx_cpymem(b->last, "Connection: close\r\n", 19);
    b->last = ngx_cpymem(b->last, "\r\n", 2);

    u->request_bufs = ngx_alloc_chain_link(r->pool);
    if (u->request_bufs == NULL) {
        return NGX_ERROR;
    }

    u->request_bufs->buf = b;
    u->request_bufs->next = NULL;

    return NGX_OK;
}
```

**Correct (HTTP/1.1 enables connection pooling by the keepalive module):**

```c
static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u = r->upstream;
    ngx_buf_t            *b;
    size_t                len;

    if (r->headers_in.host == NULL) {
        return NGX_ERROR;
    }

    /* HTTP/1.1 defaults to keep-alive — no Connection: close header */
    len = sizeof("GET ") - 1 + r->uri.len
        + sizeof(" HTTP/1.1\r\nHost: ") - 1
        + r->headers_in.host->value.len
        + sizeof("\r\n\r\n") - 1;

    b = ngx_create_temp_buf(r->pool, len);
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->last = ngx_cpymem(b->last, "GET ", 4);
    b->last = ngx_cpymem(b->last, r->uri.data, r->uri.len);
    b->last = ngx_cpymem(b->last, " HTTP/1.1\r\nHost: ", 18);
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

**Note:** The `keepalive` directive in `nginx.conf` is handled by `ngx_http_upstream_keepalive_module` — you do not implement it in your C module. Your module's responsibility is to use HTTP/1.1 (which defaults to persistent connections) and avoid sending `Connection: close`. The keepalive module will then automatically pool idle connections for reuse across requests.

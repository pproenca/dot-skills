---
title: Enable Keepalive for Upstream Connections
impact: LOW-MEDIUM
impactDescription: eliminates TCP/TLS handshake overhead for reused connections
tags: upstream, keepalive, connection-reuse, performance
---

## Enable Keepalive for Upstream Connections

Each new upstream connection incurs TCP handshake overhead (1 RTT) plus optional TLS negotiation (1-2 additional RTTs). Enabling keepalive pools connections for reuse across requests, dramatically reducing latency for high-throughput upstream communication. The module must signal connection reuse readiness by clearing `r->upstream->keepalive` flags appropriately and sending correct protocol headers.

**Incorrect (new TCP connection per upstream request):**

```c
/* nginx.conf — no keepalive configured */
upstream backend {
    server 127.0.0.1:8080;
    /* missing keepalive directive — every request opens new connection */
}

/* module code — closes connection after each request */
static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    /* sends Connection: close — prevents connection reuse */
    b->last = ngx_cpymem(b->last, "Connection: close\r\n", 19);
    b->last = ngx_cpymem(b->last, "\r\n", 2);

    /* ... */
    return NGX_OK;
}
```

**Correct (keepalive enabled with proper headers):**

```c
/* nginx.conf — keepalive pool configured */
upstream backend {
    server 127.0.0.1:8080;
    keepalive 32;  /* pool of 32 idle connections per worker */
}

/* module code — signals keepalive support */
static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    /* HTTP/1.1 with Connection: keep-alive enables reuse */
    b->last = ngx_cpymem(b->last, " HTTP/1.1\r\n", 11);
    b->last = ngx_cpymem(b->last, "Connection: keep-alive\r\n", 24);
    b->last = ngx_cpymem(b->last, "\r\n", 2);

    /* ... */
    return NGX_OK;
}
```

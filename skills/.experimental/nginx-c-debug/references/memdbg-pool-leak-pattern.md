---
title: Identify Pool Memory Leak Patterns from Growing Worker RSS
impact: CRITICAL
impactDescription: worker RSS grows until OOM kill
tags: memdbg, memory-leak, pool, rss, oom
---

## Identify Pool Memory Leak Patterns from Growing Worker RSS

nginx pools do not support individual frees — memory grows until the pool is destroyed. If a handler allocates from the connection pool (`c->pool`) on every request instead of the request pool (`r->pool`), memory accumulates across requests on long-lived connections (keepalive, HTTP/2 multiplexed streams). Monitor worker RSS over time; linear growth that correlates with request rate indicates a pool-level leak.

**Incorrect (allocates per-request data from connection pool, which persists across keepalive requests):**

```c
typedef struct {
    ngx_str_t    response_body;
} my_req_data_t;

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_connection_t  *c = r->connection;
    my_req_data_t     *data;

    /* BUG: c->pool survives across keepalive requests on this connection.
     * Each request adds ~4KB here that is never freed until connection close.
     * With keepalive_requests=1000 (default), this leaks ~4MB per connection. */
    data = ngx_pcalloc(c->pool, sizeof(my_req_data_t));
    if (data == NULL) {
        return NGX_ERROR;
    }

    data->response_body.data = ngx_pnalloc(c->pool, 4096);
    if (data->response_body.data == NULL) {
        return NGX_ERROR;
    }
    data->response_body.len = 4096;

    /* ... use data to build response ... */

    return NGX_OK;
}
```

**Correct (allocates per-request data from request pool, which is destroyed when request finishes):**

```c
typedef struct {
    ngx_str_t    response_body;
} my_req_data_t;

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_req_data_t  *data;

    /* SAFE: r->pool is destroyed by ngx_http_free_request at end of request.
     * No accumulation across keepalive requests on the same connection. */
    data = ngx_pcalloc(r->pool, sizeof(my_req_data_t));
    if (data == NULL) {
        return NGX_ERROR;
    }

    data->response_body.data = ngx_pnalloc(r->pool, 4096);
    if (data->response_body.data == NULL) {
        return NGX_ERROR;
    }
    data->response_body.len = 4096;

    /* ... use data to build response ... */

    return NGX_OK;
}
```

Reference: [nginx Development Guide — Memory Pools](https://nginx.org/en/docs/dev/development_guide.html#pool)

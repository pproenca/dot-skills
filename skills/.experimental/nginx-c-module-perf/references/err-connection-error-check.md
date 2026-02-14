---
title: Check Connection Error Flag Before I/O Operations
impact: MEDIUM-HIGH
impactDescription: prevents wasted syscalls and log noise on dead connections
tags: err, connection, error-flag, io
---

## Check Connection Error Flag Before I/O Operations

Once a connection has experienced an error — client disconnect, reset, or write timeout — nginx sets `c->error = 1` on the connection. Attempting further `send()` or `recv()` on an errored connection will always fail, wasting a syscall round-trip and generating redundant log entries for every subsequent operation. Checking `c->error` early and returning immediately avoids pointless kernel transitions and keeps error logs clean for the failures that actually matter.

**Incorrect (attempts write without checking c->error, wastes syscalls on dead connections):**

```c
static ngx_int_t
ngx_http_mymodule_send_chunk(ngx_http_request_t *r, ngx_chain_t *out)
{
    ngx_connection_t  *c;
    ngx_chain_t       *cl;

    c = r->connection;

    /* BUG: if client already disconnected, every send() returns EPIPE
     * and floods the error log with identical "broken pipe" messages */
    cl = c->send_chain(c, out, 0);

    if (cl == NGX_CHAIN_ERROR) {
        ngx_log_error(NGX_LOG_ERR, c->log, 0,
                      "send_chain failed for \"%V\"", &r->uri);
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

**Correct (returns early when connection is already in error state):**

```c
static ngx_int_t
ngx_http_mymodule_send_chunk(ngx_http_request_t *r, ngx_chain_t *out)
{
    ngx_connection_t  *c;
    ngx_chain_t       *cl;

    c = r->connection;

    /* skip I/O entirely if the connection is already dead */
    if (c->error) {
        return NGX_ERROR;
    }

    cl = c->send_chain(c, out, 0);

    if (cl == NGX_CHAIN_ERROR) {
        c->error = 1;
        ngx_log_error(NGX_LOG_ERR, c->log, 0,
                      "send_chain failed for \"%V\"", &r->uri);
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

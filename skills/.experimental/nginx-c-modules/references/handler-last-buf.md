---
title: Set last_buf Flag on Final Buffer
impact: HIGH
impactDescription: prevents clients waiting indefinitely for more data
tags: handler, buffer, last-buf, response
---

## Set last_buf Flag on Final Buffer

The `last_buf = 1` flag signals the end of a response to the downstream filter chain. Without it, nginx keeps the connection open expecting more output buffers, causing the client to hang until the connection times out. For subrequests, use `last_in_chain = 1` instead, since only the main request owns the connection.

**Incorrect (missing last_buf — client hangs waiting for more data):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;
    ngx_int_t     rc;

    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = 11;
    ngx_str_set(&r->headers_out.content_type, "text/plain");

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK) {
        return rc;
    }

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->pos = (u_char *) "Hello World";
    b->last = b->pos + 11;
    b->memory = 1;
    /* BUG: last_buf not set — nginx waits for more buffers */

    out.buf = b;
    out.next = NULL;

    return ngx_http_output_filter(r, &out);
}
```

**Correct (last_buf set on final buffer, last_in_chain for subrequests):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;
    ngx_int_t     rc;

    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = 11;
    ngx_str_set(&r->headers_out.content_type, "text/plain");

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK) {
        return rc;
    }

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->pos = (u_char *) "Hello World";
    b->last = b->pos + 11;
    b->memory = 1;

    if (r == r->main) {
        b->last_buf = 1;      /* main request: signals end of response */
    } else {
        b->last_in_chain = 1; /* subrequest: signals end of this chain */
    }

    out.buf = b;
    out.next = NULL;

    return ngx_http_output_filter(r, &out);
}
```

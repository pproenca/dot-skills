---
title: Send Header Before Body Output
impact: HIGH
impactDescription: prevents corrupt HTTP responses
tags: handler, response, header, output
---

## Send Header Before Body Output

`ngx_http_send_header` must be called before `ngx_http_output_filter`. The header call writes the HTTP status line and headers to the client, and the output filter sends the body. Reversing the order or skipping the header call produces malformed HTTP that confuses clients, breaks keep-alive connections, and causes proxy chaining failures.

**Incorrect (body sent without prior header call):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->pos = (u_char *) "Hello";
    b->last = b->pos + 5;
    b->memory = 1;
    b->last_buf = 1;

    out.buf = b;
    out.next = NULL;

    /* BUG: no ngx_http_send_header — client receives body
     * without status line or headers */
    return ngx_http_output_filter(r, &out);
}
```

**Correct (headers set and sent before body output):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t     rc;
    ngx_buf_t    *b;
    ngx_chain_t   out;

    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = 5;
    ngx_str_set(&r->headers_out.content_type, "text/plain");

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK || r->header_only) {
        return rc;
    }

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->pos = (u_char *) "Hello";
    b->last = b->pos + 5;
    b->memory = 1;
    b->last_buf = 1;

    out.buf = b;
    out.next = NULL;

    return ngx_http_output_filter(r, &out);
}
```

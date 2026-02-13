---
title: Discard Request Body When Not Reading It
impact: HIGH
impactDescription: prevents connection hangs on POST/PUT requests
tags: req, discard, body, connection
---

## Discard Request Body When Not Reading It

If a handler does not need the request body, it must call `ngx_http_discard_request_body`. Without this call, the client blocks waiting to send its body and the connection hangs until timeout. This affects all methods that may carry a body (POST, PUT, PATCH).

**Incorrect (ignoring request body causes client hang):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t     rc;
    ngx_buf_t    *b;
    ngx_chain_t   out;

    /* BUG: no discard — POST clients hang waiting to send body */
    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = sizeof("OK") - 1;
    ngx_str_set(&r->headers_out.content_type, "text/plain");

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK) {
        return rc;
    }

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->pos = (u_char *) "OK";
    b->last = b->pos + sizeof("OK") - 1;
    b->memory = 1;
    b->last_buf = 1;

    out.buf = b;
    out.next = NULL;

    return ngx_http_output_filter(r, &out);
}
```

**Correct (discard body before generating response):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t     rc;
    ngx_buf_t    *b;
    ngx_chain_t   out;

    /* discard body — unblocks client, drains connection */
    rc = ngx_http_discard_request_body(r);
    if (rc != NGX_OK) {
        return rc;
    }

    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = sizeof("OK") - 1;
    ngx_str_set(&r->headers_out.content_type, "text/plain");

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK) {
        return rc;
    }

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->pos = (u_char *) "OK";
    b->last = b->pos + sizeof("OK") - 1;
    b->memory = 1;
    b->last_buf = 1;

    out.buf = b;
    out.next = NULL;

    return ngx_http_output_filter(r, &out);
}
```

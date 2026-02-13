---
title: Use header_only for Empty Body Responses
impact: MEDIUM
impactDescription: avoids unnecessary buffer allocation for status-only responses
tags: handler, header-only, empty, response
---

## Use header_only for Empty Body Responses

For responses with no body -- such as 204 No Content, 304 Not Modified, or 3xx redirects -- set `content_length_n = 0` and return the result of `ngx_http_send_header` directly. There is no need to allocate a buffer or chain. Creating empty buffers wastes pool memory and adds unnecessary complexity to the output filter chain.

**Incorrect (allocating an empty buffer for a 204 response):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;

    r->headers_out.status = NGX_HTTP_NO_CONTENT;
    r->headers_out.content_length_n = 0;
    ngx_http_send_header(r);

    /* BUG: unnecessary allocation — 204 has no body */
    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->last_buf = 1;
    out.buf = b;
    out.next = NULL;

    return ngx_http_output_filter(r, &out);
}
```

**Correct (header-only response with no buffer allocation):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    r->headers_out.status = NGX_HTTP_NO_CONTENT;
    r->headers_out.content_length_n = 0;
    r->header_only = 1;

    return ngx_http_send_header(r);
}
```

**Note:** The `r->header_only` flag tells the downstream filter chain that no body will follow. This also works for redirect responses where you set `headers_out.location` and return the header with a 301/302 status.

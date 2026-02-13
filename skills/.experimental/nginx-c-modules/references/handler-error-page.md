---
title: Return HTTP Status Codes for Error Responses
impact: MEDIUM
impactDescription: enables nginx error_page directive interception
tags: handler, error, status-code, response
---

## Return HTTP Status Codes for Error Responses

Returning `NGX_HTTP_*` status codes (e.g., `NGX_HTTP_FORBIDDEN`, `NGX_HTTP_NOT_FOUND`) from a handler lets nginx's `error_page` directive intercept the error and serve a custom response. Manually constructing an error body and sending it directly bypasses this mechanism, preventing administrators from customizing error pages in configuration.

**Incorrect (manually building error response bypasses error_page):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;

    if (!ngx_http_mymodule_check_auth(r)) {
        /* BUG: sends hardcoded body — error_page directive is bypassed */
        r->headers_out.status = NGX_HTTP_FORBIDDEN;
        r->headers_out.content_length_n = 9;
        ngx_str_set(&r->headers_out.content_type, "text/plain");
        ngx_http_send_header(r);

        b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
        b->pos = (u_char *) "Forbidden";
        b->last = b->pos + 9;
        b->memory = 1;
        b->last_buf = 1;
        out.buf = b;
        out.next = NULL;

        return ngx_http_output_filter(r, &out);
    }

    return NGX_DECLINED;
}
```

**Correct (return status code and let nginx handle error pages):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    if (!ngx_http_mymodule_check_auth(r)) {
        /* nginx will use error_page 403 if configured */
        return NGX_HTTP_FORBIDDEN;
    }

    return NGX_DECLINED;
}
```

**Note:** This applies to access phase handlers and content handlers that need to reject requests. Only build custom response bodies when you intentionally want to override the error_page mechanism with module-specific output.

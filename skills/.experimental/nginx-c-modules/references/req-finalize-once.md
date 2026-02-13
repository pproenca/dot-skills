---
title: Finalize Requests Exactly Once
impact: CRITICAL
impactDescription: prevents use-after-free and unpredictable request state
tags: req, finalize, lifecycle, safety
---

## Finalize Requests Exactly Once

`ngx_http_finalize_request` decrements `r->main->count` and may destroy the request and its pool when the count reaches zero. Calling finalize and then continuing to execute code that accesses `r` causes use-after-free. Even when the count is above zero, a second finalize double-decrements the counter, leading to premature request destruction. Always return immediately after calling finalize.

**Incorrect (double finalize on error path):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    r->headers_out.status = NGX_HTTP_OK;
    rc = ngx_http_send_header(r);

    if (rc == NGX_ERROR) {
        /* BUG: finalize then fall through to second finalize */
        ngx_http_finalize_request(r, NGX_HTTP_INTERNAL_SERVER_ERROR);
    }

    /* BUG: r may already be freed if first finalize ran */
    r->headers_out.content_length_n = 0;
    ngx_http_finalize_request(r, rc);
    return NGX_DONE;
}
```

**Correct (single finalize with immediate return):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = 0;

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK) {
        ngx_http_finalize_request(r, rc);
        return NGX_DONE;
    }

    /* all headers set BEFORE finalize — return immediately after */
    ngx_http_finalize_request(r, ngx_http_output_filter(r, NULL));
    return NGX_DONE;
}
```

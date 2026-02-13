---
title: Return After Internal Redirect
impact: MEDIUM
impactDescription: prevents double response generation
tags: req, redirect, internal, lifecycle
---

## Return After Internal Redirect

`ngx_http_internal_redirect` starts a new request phase cycle, re-running the location matching and handler chain from the beginning. The current handler must return `NGX_DONE` immediately -- any subsequent processing generates a double response or corrupts the output.

**Incorrect (continuing after internal redirect):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    if (needs_redirect(r)) {
        rc = ngx_http_internal_redirect(r, &new_uri, &r->args);
        /* BUG: falls through — generates second response */
    }

    /* this runs even after redirect, corrupting output */
    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = body.len;

    ngx_http_send_header(r);
    return ngx_http_output_filter(r, &out);
}
```

**Correct (return NGX_DONE immediately after redirect):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    if (needs_redirect(r)) {
        rc = ngx_http_internal_redirect(r, &new_uri, &r->args);
        if (rc != NGX_OK) {
            return NGX_ERROR;
        }
        /* redirect started — exit immediately, new phase cycle handles it */
        return NGX_DONE;
    }

    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = body.len;

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK) {
        return rc;
    }

    return ngx_http_output_filter(r, &out);
}
```

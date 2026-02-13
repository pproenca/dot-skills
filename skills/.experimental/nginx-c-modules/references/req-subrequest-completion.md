---
title: Use Post-Subrequest Handlers for Completion
impact: HIGH
impactDescription: prevents assuming synchronous subrequest execution
tags: req, subrequest, async, callback
---

## Use Post-Subrequest Handlers for Completion

`ngx_http_subrequest` is asynchronous -- the subrequest may complete immediately or after network I/O. Always use `ngx_http_post_subrequest_t` to handle completion. Reading the subrequest response inline produces empty or stale data because the upstream has not responded yet.

**Incorrect (reading subrequest response immediately):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_request_t  *sr;
    ngx_int_t            rc;

    rc = ngx_http_subrequest(r, &uri, NULL, &sr, NULL, 0);
    if (rc != NGX_OK) {
        return NGX_ERROR;
    }

    /* BUG: subrequest has not completed yet — sr->headers_out is empty */
    if (sr->headers_out.status == NGX_HTTP_OK) {
        r->headers_out.status = NGX_HTTP_OK;
    }

    return NGX_OK;
}
```

**Correct (process results in post-subrequest handler):**

```c
static ngx_int_t
ngx_http_mymodule_subrequest_done(ngx_http_request_t *r,
    void *data, ngx_int_t rc)
{
    ngx_http_request_t  *pr = r->parent;

    /* subrequest finished — safe to read its response */
    pr->headers_out.status = r->headers_out.status;

    return NGX_OK;
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_request_t        *sr;
    ngx_http_post_subrequest_t *ps;

    ps = ngx_palloc(r->pool, sizeof(ngx_http_post_subrequest_t));
    if (ps == NULL) {
        return NGX_ERROR;
    }

    ps->handler = ngx_http_mymodule_subrequest_done;
    ps->data = NULL;

    return ngx_http_subrequest(r, &uri, NULL, &sr, ps,
                               NGX_HTTP_SUBREQUEST_IN_MEMORY);
}
```

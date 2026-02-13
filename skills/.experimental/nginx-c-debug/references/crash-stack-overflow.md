---
title: Detect Stack Overflow from Recursive Subrequest or Filter Chains
impact: CRITICAL
impactDescription: kills worker with SIGSEGV at stack boundary
tags: crash, stack-overflow, recursion, subrequest, filter
---

## Detect Stack Overflow from Recursive Subrequest or Filter Chains

Stack overflow in nginx occurs when subrequests recurse past `NGX_HTTP_MAX_SUBREQUESTS` (default 50) or when a body filter inadvertently triggers itself in a loop. The crash presents as SIGSEGV with a fault address near the stack boundary (typically at the bottom of the mapped stack region). The backtrace in GDB shows hundreds of repeating function frames. Unlike heap-related segfaults, the fault address is far from the heap range and falls at a page boundary.

**Incorrect (body filter issues subrequest that passes through the same filter, infinite recursion):**

```c
static ngx_int_t
ngx_http_mymodule_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_http_request_t  *sr;
    ngx_int_t            rc;

    /* BUG: every invocation creates a subrequest to /internal,
     * which generates a response that passes through this same
     * body filter, creating another subrequest — infinite loop */
    rc = ngx_http_subrequest(r, &ngx_http_mymodule_uri, NULL,
                             &sr, NULL, 0);
    if (rc != NGX_OK) {
        return NGX_ERROR;
    }

    return ngx_http_next_body_filter(r, in);
}
```

**Correct (guards against re-entrant filter processing and respects subrequest limit):**

```c
static ngx_int_t
ngx_http_mymodule_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_http_request_t  *sr;
    ngx_int_t            rc;
    my_ctx_t            *ctx;

    /* skip processing for subrequests — only act on main request */
    if (r != r->main) {
        return ngx_http_next_body_filter(r, in);
    }

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        return ngx_http_next_body_filter(r, in);
    }

    /* guard: only issue the subrequest once */
    if (ctx->subrequest_issued) {
        return ngx_http_next_body_filter(r, in);
    }

    /* verify subrequest budget before issuing */
    if (r->subrequests < 1) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "mymodule: subrequest limit reached");
        return NGX_ERROR;
    }

    ctx->subrequest_issued = 1;

    rc = ngx_http_subrequest(r, &ngx_http_mymodule_uri, NULL,
                             &sr, NULL, 0);
    if (rc != NGX_OK) {
        return NGX_ERROR;
    }

    return ngx_http_next_body_filter(r, in);
}
```

**Note:** When the backtrace shows repeating frames, count the depth and identify the two or three functions forming the cycle. The fix always involves breaking the cycle with a guard flag, a subrequest counter check, or a `r != r->main` test.

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)

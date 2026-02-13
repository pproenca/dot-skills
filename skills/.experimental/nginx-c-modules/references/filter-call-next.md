---
title: Always Call Next Filter in the Chain
impact: MEDIUM-HIGH
impactDescription: prevents response truncation and client hangs
tags: filter, chain, next, propagation
---

## Always Call Next Filter in the Chain

Every filter MUST call `ngx_http_next_header_filter` or `ngx_http_next_body_filter` to pass control downstream. Returning `NGX_OK` without calling the next filter silently drops the response body, causing the client to hang waiting for data that will never arrive.

**Incorrect (returns without calling next body filter):**

```c
static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_http_myfilter_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_myfilter_module);
    if (ctx == NULL) {
        /* BUG: response is silently dropped — client hangs indefinitely */
        return NGX_OK;
    }

    /* process buffers... */
    return ngx_http_next_body_filter(r, in);
}
```

**Correct (always calls next filter, even on early return):**

```c
static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_http_myfilter_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_myfilter_module);
    if (ctx == NULL) {
        /* pass through — let downstream filters handle it */
        return ngx_http_next_body_filter(r, in);
    }

    /* process buffers... */
    return ngx_http_next_body_filter(r, in);
}
```

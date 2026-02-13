---
title: Set Buffering Flag When Accumulating Response Data
impact: MEDIUM
impactDescription: prevents premature response flushing
tags: filter, buffering, flag, accumulation
---

## Set Buffering Flag When Accumulating Response Data

When a filter needs to accumulate data before passing it downstream (e.g., for gzip, substitution, or content rewriting), it must set `r->buffered |= NGX_HTTP_MY_MODULE` to signal nginx that output is being held. Without this flag, nginx may flush the response prematurely or report errors when the expected content length does not match bytes sent.

**Incorrect (holds data without setting buffered flag):**

```c
#define NGX_HTTP_MYFILTER_BUFFERED  0x08

static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_http_myfilter_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_myfilter_module);

    /* accumulate buffers for later processing */
    if (ngx_chain_add_copy(r->pool, &ctx->pending, in) != NGX_OK) {
        return NGX_ERROR;
    }

    /* BUG: nginx thinks output is complete — may send incomplete response */
    return NGX_OK;
}
```

**Correct (sets buffered flag while holding data, clears on flush):**

```c
#define NGX_HTTP_MYFILTER_BUFFERED  0x08

static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_http_myfilter_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_myfilter_module);

    if (ngx_chain_add_copy(r->pool, &ctx->pending, in) != NGX_OK) {
        return NGX_ERROR;
    }

    if (!ctx->ready_to_flush) {
        /* signal nginx: this module is holding buffered data */
        r->buffered |= NGX_HTTP_MYFILTER_BUFFERED;
        return NGX_OK;
    }

    /* ready to send — clear flag and flush accumulated data */
    r->buffered &= ~NGX_HTTP_MYFILTER_BUFFERED;
    return ngx_http_next_body_filter(r, ctx->pending);
}
```

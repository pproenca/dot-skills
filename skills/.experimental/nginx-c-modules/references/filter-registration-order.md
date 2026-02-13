---
title: Save and Replace Top Filter in postconfiguration
impact: MEDIUM-HIGH
impactDescription: prevents filter chain breakage and skipped filters
tags: filter, registration, chain, postconfiguration
---

## Save and Replace Top Filter in postconfiguration

Filters form a singly-linked list built at startup. Each filter saves the current top filter pointer as its "next" and installs itself as the new top. Forgetting to save the current top before overwriting it breaks the chain, causing downstream filters to be silently skipped or creating infinite loops.

**Incorrect (overwrites top filter without saving next):**

```c
static ngx_int_t
ngx_http_myfilter_init(ngx_conf_t *cf)
{
    /* BUG: previous top filter is lost — all downstream filters skipped */
    ngx_http_top_body_filter = ngx_http_myfilter_body_filter;

    return NGX_OK;
}

static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    /* process buffers... */

    /* BUG: ngx_http_next_body_filter was never set — crashes or hangs */
    return ngx_http_next_body_filter(r, in);
}
```

**Correct (save current top as next, then install self):**

```c
static ngx_http_output_header_filter_pt  ngx_http_next_header_filter;
static ngx_http_output_body_filter_pt    ngx_http_next_body_filter;

static ngx_int_t
ngx_http_myfilter_init(ngx_conf_t *cf)
{
    /* save current top so we can call it as "next" */
    ngx_http_next_header_filter = ngx_http_top_header_filter;
    ngx_http_top_header_filter = ngx_http_myfilter_header_filter;

    ngx_http_next_body_filter = ngx_http_top_body_filter;
    ngx_http_top_body_filter = ngx_http_myfilter_body_filter;

    return NGX_OK;
}
```

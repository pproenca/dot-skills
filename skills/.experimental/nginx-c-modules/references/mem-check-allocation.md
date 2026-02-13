---
title: Check Every Allocation Return for NULL
impact: CRITICAL
impactDescription: prevents segfaults on allocation failure
tags: mem, null-check, allocation, safety
---

## Check Every Allocation Return for NULL

`ngx_palloc`, `ngx_pcalloc`, and `ngx_pnalloc` all return `NULL` when the pool cannot satisfy the allocation. Dereferencing a `NULL` pointer crashes the worker process, taking down all connections it serves.

**Incorrect (missing NULL check causes segfault):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t  *out;

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    /* BUG: no NULL check — segfault if pool exhausted */
    b->pos = ngx_palloc(r->pool, 256);
    b->last = b->pos + 256;

    out = ngx_palloc(r->pool, sizeof(ngx_chain_t));
    out->buf = b;
    out->next = NULL;

    return ngx_http_output_filter(r, out);
}
```

**Correct (NULL check on every allocation):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t  *out;

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    b->pos = ngx_palloc(r->pool, 256);
    if (b->pos == NULL) {
        return NGX_ERROR;
    }
    b->last = b->pos + 256;

    out = ngx_palloc(r->pool, sizeof(ngx_chain_t));
    if (out == NULL) {
        return NGX_ERROR;
    }

    out->buf = b;
    out->next = NULL;

    return ngx_http_output_filter(r, out);
}
```

**Note:** Returning `NGX_ERROR` from a handler triggers request finalization, which destroys `r->pool` and frees all prior allocations. There is no need to manually clean up earlier successful allocations.

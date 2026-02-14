---
title: Reuse Buffer Chain Links Instead of Allocating New Ones
impact: CRITICAL
impactDescription: eliminates per-request allocation overhead for chain links
tags: buf, chain, reuse, allocation
---

## Reuse Buffer Chain Links Instead of Allocating New Ones

Every `ngx_chain_t` link allocated with `ngx_alloc_chain_link` can be returned to the connection's free list via `ngx_free_chain` after use. Allocating fresh chain links in a loop — especially inside body filters called thousands of times per request — fragments the pool and wastes cycles on allocator bookkeeping. Reusing links from the pool's free list is an O(1) pointer swap with zero allocator overhead.

**Incorrect (allocates a new chain link on every filter invocation):**

```c
static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_chain_t  *cl, *out, **ll;

    out = NULL;
    ll = &out;

    for (cl = in; cl; cl = cl->next) {
        /* BUG: allocates from pool every iteration — never reused */
        *ll = ngx_palloc(r->pool, sizeof(ngx_chain_t));
        if (*ll == NULL) {
            return NGX_ERROR;
        }

        (*ll)->buf = cl->buf;
        (*ll)->next = NULL;
        ll = &(*ll)->next;
    }

    return ngx_http_next_body_filter(r, out);
}
```

**Correct (uses ngx_alloc_chain_link and returns links via ngx_free_chain):**

```c
static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_chain_t  *cl, *out, *ln, **ll;

    out = NULL;
    ll = &out;

    for (cl = in; cl; cl = cl->next) {
        /* O(1) — pops from connection free list, falls back to pool only if empty */
        ln = ngx_alloc_chain_link(r->pool);
        if (ln == NULL) {
            return NGX_ERROR;
        }

        ln->buf = cl->buf;
        ln->next = NULL;
        *ll = ln;
        ll = &ln->next;
    }

    ngx_int_t rc = ngx_http_next_body_filter(r, out);

    /* return all chain links to the free list for reuse */
    for (cl = out; cl; /* void */) {
        ln = cl->next;
        ngx_free_chain(r->pool, cl);
        cl = ln;
    }

    return rc;
}
```

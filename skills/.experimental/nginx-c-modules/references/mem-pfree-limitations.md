---
title: Avoid Relying on ngx_pfree for Pool Allocations
impact: MEDIUM
impactDescription: prevents false sense of memory reclamation
tags: mem, pfree, pool, deallocation
---

## Avoid Relying on ngx_pfree for Pool Allocations

`ngx_pfree` only frees allocations larger than `NGX_MAX_ALLOC_FROM_POOL` (typically ~4KB). For small allocations, which represent the vast majority of pool usage, `ngx_pfree` is a silent no-op that returns `NGX_DECLINED`. Calling it on small allocations gives a false sense of memory recovery while the memory remains allocated until the entire pool is destroyed.

**Incorrect (assuming ngx_pfree reclaims small allocations):**

```c
static ngx_int_t
ngx_http_mymodule_process(ngx_http_request_t *r)
{
    u_char  *scratch;
    size_t   len = 512;

    scratch = ngx_palloc(r->pool, len);
    if (scratch == NULL) {
        return NGX_ERROR;
    }

    /* ... use scratch for intermediate header processing ... */

    /* BUG: this is a no-op — 512 < NGX_MAX_ALLOC_FROM_POOL */
    /* memory is NOT reclaimed; pool still holds 512 bytes */
    ngx_pfree(r->pool, scratch);

    /* allocating again thinking previous memory was freed */
    scratch = ngx_palloc(r->pool, len);
    /* pool now holds 1024 bytes, not 512 */

    return NGX_OK;
}
```

**Correct (design allocation patterns for pool lifetime):**

```c
static ngx_int_t
ngx_http_mymodule_process(ngx_http_request_t *r)
{
    u_char  *buf;
    size_t   len = 512;

    /*
     * Accept that small allocations live until pool destruction.
     * Allocate once and reuse the buffer for multiple operations.
     */
    buf = ngx_palloc(r->pool, len);
    if (buf == NULL) {
        return NGX_ERROR;
    }

    /* phase 1: use buf for header serialization */
    ngx_memcpy(buf, header_value.data, header_value.len);

    /* phase 2: reuse same buf for body prefix */
    ngx_memzero(buf, len);
    ngx_memcpy(buf, body_prefix.data, body_prefix.len);

    return NGX_OK;
}
```

**Note:** If you genuinely need to free and reallocate repeatedly during a request, consider creating a child pool with `ngx_create_pool()` that you destroy and recreate between phases. This is how nginx handles subrequest isolation internally.

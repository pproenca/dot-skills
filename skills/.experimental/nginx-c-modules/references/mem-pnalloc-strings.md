---
title: Use ngx_pnalloc for String Data Allocation
impact: MEDIUM
impactDescription: avoids unnecessary alignment padding for string buffers
tags: mem, pnalloc, strings, alignment
---

## Use ngx_pnalloc for String Data Allocation

`ngx_palloc` aligns allocations to the platform pointer size (typically 8 bytes on 64-bit). String buffers (`u_char *`) do not require alignment, so `ngx_pnalloc` skips the alignment step. This follows the nginx core convention — `ngx_pstrdup()` uses `ngx_pnalloc` internally — and avoids unnecessary alignment padding on every string allocation.

**Incorrect (aligned allocation for string data wastes memory):**

```c
static ngx_int_t
ngx_http_mymodule_set_header(ngx_http_request_t *r, ngx_str_t *value)
{
    u_char  *p;

    /* ngx_palloc aligns to NGX_ALIGNMENT — wasteful for byte arrays */
    p = ngx_palloc(r->pool, value->len + 1);
    if (p == NULL) {
        return NGX_ERROR;
    }

    ngx_memcpy(p, value->data, value->len);
    p[value->len] = '\0';

    return NGX_OK;
}
```

**Correct (unaligned allocation for string data):**

```c
static ngx_int_t
ngx_http_mymodule_set_header(ngx_http_request_t *r, ngx_str_t *value)
{
    u_char  *p;

    /* ngx_pnalloc skips alignment — correct for u_char buffers */
    p = ngx_pnalloc(r->pool, value->len + 1);
    if (p == NULL) {
        return NGX_ERROR;
    }

    ngx_memcpy(p, value->data, value->len);
    p[value->len] = '\0';

    return NGX_OK;
}
```

**Note:** Use `ngx_palloc` when allocating structs, pointers, or any type requiring natural alignment. Use `ngx_pnalloc` exclusively for `u_char` string buffers. The nginx core follows this convention consistently — see `ngx_pstrdup()` which uses `ngx_pnalloc` internally.

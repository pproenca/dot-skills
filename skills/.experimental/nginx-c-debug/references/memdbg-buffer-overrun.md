---
title: Find Buffer Overrun from ngx_pnalloc Size Miscalculation
impact: CRITICAL
impactDescription: corrupts adjacent pool allocations silently
tags: memdbg, buffer-overrun, pnalloc, size-calculation
---

## Find Buffer Overrun from ngx_pnalloc Size Miscalculation

When calculating buffer size for string operations (concatenation, formatting), off-by-one errors or missing space for terminators cause writes past the allocated buffer. Since pool allocations are contiguous, this corrupts the next allocation silently. The crash appears later in unrelated code that reads the corrupted data, making the root cause extremely difficult to trace without AddressSanitizer.

**Incorrect (allocates exactly str1.len + str2.len bytes, missing separator and null terminator):**

```c
static ngx_int_t
ngx_http_mymodule_build_key(ngx_http_request_t *r, ngx_str_t *key,
    ngx_str_t *prefix, ngx_str_t *uri)
{
    u_char  *p;

    /* BUG: needs prefix->len + 1 (separator ':') + uri->len + 1 (null term)
     * but only allocates prefix->len + uri->len — overruns by 2 bytes */
    key->len = prefix->len + uri->len;
    key->data = ngx_pnalloc(r->pool, key->len);
    if (key->data == NULL) {
        return NGX_ERROR;
    }

    p = key->data;
    p = ngx_cpymem(p, prefix->data, prefix->len);
    *p++ = ':';                    /* writes 1 byte past allocation */
    p = ngx_cpymem(p, uri->data, uri->len);
    *p = '\0';                     /* writes 2 bytes past allocation */

    /* next ngx_pnalloc from this pool may return memory that
     * overlaps the overrun — silent corruption */

    return NGX_OK;
}
```

**Correct (calculates exact required size including separator, prefix, and null terminator):**

```c
static ngx_int_t
ngx_http_mymodule_build_key(ngx_http_request_t *r, ngx_str_t *key,
    ngx_str_t *prefix, ngx_str_t *uri)
{
    u_char  *p;

    /* separator ':' = 1 byte, null terminator = 1 byte for C library calls */
    key->len = prefix->len + 1 + uri->len;
    key->data = ngx_pnalloc(r->pool, key->len + 1);
    if (key->data == NULL) {
        return NGX_ERROR;
    }

    p = key->data;
    p = ngx_cpymem(p, prefix->data, prefix->len);
    *p++ = ':';
    p = ngx_cpymem(p, uri->data, uri->len);
    *p = '\0';

    /* SAFE: all writes are within the allocated (prefix + 1 + uri + 1) region.
     * key->len does not include the null terminator (nginx convention),
     * but the allocation does to support passing key->data to C string APIs. */

    return NGX_OK;
}
```

Reference: [nginx Development Guide — Strings](https://nginx.org/en/docs/dev/development_guide.html#strings)

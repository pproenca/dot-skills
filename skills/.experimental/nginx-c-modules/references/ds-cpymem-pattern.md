---
title: Use ngx_cpymem for Sequential Buffer Writes
impact: LOW-MEDIUM
impactDescription: eliminates manual pointer arithmetic on buffer construction
tags: ds, cpymem, buffer, string-building
---

## Use ngx_cpymem for Sequential Buffer Writes

`ngx_cpymem` returns a pointer to the byte immediately after the copied data. This enables clean sequential writes without manually computing offsets. Using `ngx_memcpy` instead requires error-prone offset arithmetic that silently produces overlapping writes or gaps when lengths are wrong.

**Incorrect (manual pointer arithmetic with ngx_memcpy):**

```c
static ngx_int_t
ngx_http_mymodule_build_response(ngx_buf_t *b, ngx_str_t *prefix,
    ngx_str_t *body, ngx_str_t *suffix)
{
    u_char  *p = b->pos;

    ngx_memcpy(p, prefix->data, prefix->len);
    /* BUG-PRONE: manual offset tracking — easy to get wrong */
    ngx_memcpy(p + prefix->len, body->data, body->len);
    ngx_memcpy(p + prefix->len + body->len, suffix->data, suffix->len);

    b->last = p + prefix->len + body->len + suffix->len;

    return NGX_OK;
}
```

**Correct (ngx_cpymem returns advanced pointer automatically):**

```c
static ngx_int_t
ngx_http_mymodule_build_response(ngx_buf_t *b, ngx_str_t *prefix,
    ngx_str_t *body, ngx_str_t *suffix)
{
    u_char  *p = b->pos;

    /* each call advances p past the copied bytes */
    p = ngx_cpymem(p, prefix->data, prefix->len);
    p = ngx_cpymem(p, body->data, body->len);
    p = ngx_cpymem(p, suffix->data, suffix->len);

    b->last = p;

    return NGX_OK;
}
```

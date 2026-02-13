---
title: Use Shadow Buffers for Derived Data Instead of Full Copies
impact: HIGH
impactDescription: saves N×buffer_size bytes of memcpy per filter stage
tags: buf, shadow, memory, filter
---

## Use Shadow Buffers for Derived Data Instead of Full Copies

When a filter needs to output a sub-range or modified view of an existing buffer, a shadow buffer (`b->shadow`) points to the same underlying memory while allowing independent `pos`/`last` cursors. This avoids duplicating the entire buffer just to change the visible range. For a filter that splits a 64 KB buffer into 4 chunks, shadow buffers save 192 KB of allocation and memcpy per invocation compared to full copies.

**Incorrect (copies entire buffer to output a sub-range):**

```c
static ngx_int_t
ngx_http_myfilter_split(ngx_http_request_t *r, ngx_buf_t *orig,
    size_t offset, size_t len)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;

    /* SLOW: allocates and copies just to output a slice */
    b = ngx_create_temp_buf(r->pool, len);
    if (b == NULL) {
        return NGX_ERROR;
    }

    ngx_memcpy(b->pos, orig->pos + offset, len);
    b->last = b->pos + len;
    b->memory = 1;

    out.buf = b;
    out.next = NULL;

    return ngx_http_next_body_filter(r, &out);
}
```

**Correct (creates a shadow buffer referencing the original memory range):**

```c
static ngx_int_t
ngx_http_myfilter_split(ngx_http_request_t *r, ngx_buf_t *orig,
    size_t offset, size_t len)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;

    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if (b == NULL) {
        return NGX_ERROR;
    }

    /* shadow buffer — points to same memory, different range */
    b->pos = orig->pos + offset;
    b->last = b->pos + len;
    b->memory = 1;
    b->shadow = orig;

    /* inherit file-backed properties if applicable */
    if (orig->in_file) {
        b->in_file = 1;
        b->file = orig->file;
        b->file_pos = orig->file_pos + offset;
        b->file_last = b->file_pos + len;
    }

    /* mark consumption progress on the original buffer */
    if (b->last == orig->last) {
        b->last_shadow = 1;
    }

    out.buf = b;
    out.next = NULL;

    return ngx_http_next_body_filter(r, &out);
}
```

**Note:** Set `last_shadow = 1` on the final shadow buffer derived from the original. This tells downstream consumers that the original buffer's memory can be reclaimed once this shadow is consumed.

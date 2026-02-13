---
title: Coalesce Small Buffers Before Output
impact: HIGH
impactDescription: reduces syscall count from N to 1 for fragmented responses
tags: buf, coalesce, syscall, output
---

## Coalesce Small Buffers Before Output

Sending many small buffers individually causes one `writev()` or `send()` syscall per buffer — each syscall costs ~1-5 microseconds of kernel overhead. For a response built from 50 small fragments, that is 50 syscalls instead of 1. Coalescing adjacent memory buffers into a single output buffer before calling the output filter collapses the syscall count and allows the kernel to send a single large TCP segment.

**Incorrect (sends each small fragment as a separate chain link):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_chain_t  *out, *cl, **ll;
    ngx_buf_t    *b;
    ngx_uint_t    i;
    ngx_int_t     rc;

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK) {
        return rc;
    }

    out = NULL;
    ll = &out;

    /* SLOW: 50 tiny buffers = 50 potential syscalls */
    for (i = 0; i < r->headers_out.count; i++) {
        b = ngx_create_temp_buf(r->pool, 64);
        if (b == NULL) {
            return NGX_ERROR;
        }

        b->last = ngx_sprintf(b->pos, "item_%ui\n", i);
        b->memory = 1;

        cl = ngx_alloc_chain_link(r->pool);
        if (cl == NULL) {
            return NGX_ERROR;
        }

        cl->buf = b;
        cl->next = NULL;
        *ll = cl;
        ll = &cl->next;
    }

    if (out) {
        out->buf->last_buf = 1;
    }

    return ngx_http_output_filter(r, out);
}
```

**Correct (pre-calculates total size and writes into a single coalesced buffer):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;
    ngx_uint_t    i, n;
    ngx_int_t     rc;
    u_char       *p;
    size_t        total;

    n = r->headers_out.count;

    /* first pass: calculate total output size */
    total = 0;
    for (i = 0; i < n; i++) {
        total += sizeof("item_\n") - 1 + NGX_INT_T_LEN;
    }

    rc = ngx_http_send_header(r);
    if (rc == NGX_ERROR || rc > NGX_OK) {
        return rc;
    }

    /* single allocation for entire response body */
    b = ngx_create_temp_buf(r->pool, total);
    if (b == NULL) {
        return NGX_ERROR;
    }

    /* second pass: write all fragments into one buffer */
    p = b->pos;
    for (i = 0; i < n; i++) {
        p = ngx_sprintf(p, "item_%ui\n", i);
    }

    b->last = p;
    b->memory = 1;
    b->last_buf = (r == r->main) ? 1 : 0;
    b->last_in_chain = 1;

    out.buf = b;
    out.next = NULL;

    /* single output filter call = single writev() syscall */
    return ngx_http_output_filter(r, &out);
}
```

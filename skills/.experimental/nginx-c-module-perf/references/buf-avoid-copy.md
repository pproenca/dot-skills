---
title: Avoid Copying Buffers When Passing Through Filter Chain
impact: CRITICAL
impactDescription: saves N x response_size bytes of memcpy across filter stages
tags: buf, filter, zero-copy, passthrough
---

## Avoid Copying Buffers When Passing Through Filter Chain

Filters that inspect but do not modify data should pass the original buffer chain through unchanged. Copying buffer contents into a newly allocated buffer at each filter stage multiplies memory usage and CPU cost by the number of filters in the chain. For a 1 MB response passing through 5 filters, unnecessary copies waste 5 MB of allocation and 5 MB of memcpy — per request.

**Incorrect (copies buffer data into a new buffer before passing downstream):**

```c
static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_chain_t  *cl, *out, **ll;
    ngx_buf_t    *b;
    size_t        len;

    out = NULL;
    ll = &out;

    for (cl = in; cl; cl = cl->next) {
        len = ngx_buf_size(cl->buf);
        if (len == 0) {
            continue;
        }

        /* SLOW: full copy of every buffer just to inspect it */
        b = ngx_create_temp_buf(r->pool, len);
        if (b == NULL) {
            return NGX_ERROR;
        }

        ngx_memcpy(b->pos, cl->buf->pos, len);
        b->last = b->pos + len;
        b->last_buf = cl->buf->last_buf;
        b->last_in_chain = cl->buf->last_in_chain;

        ngx_http_myfilter_inspect(b->pos, len);

        *ll = ngx_alloc_chain_link(r->pool);
        if (*ll == NULL) {
            return NGX_ERROR;
        }

        (*ll)->buf = b;
        (*ll)->next = NULL;
        ll = &(*ll)->next;
    }

    return ngx_http_next_body_filter(r, out);
}
```

**Correct (inspects original buffers in-place and passes chain through unmodified):**

```c
static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_chain_t  *cl;
    size_t        len;

    for (cl = in; cl; cl = cl->next) {
        if (cl->buf->in_file) {
            continue;
        }

        len = cl->buf->last - cl->buf->pos;
        if (len > 0) {
            /* read-only inspection — no copy needed */
            ngx_http_myfilter_inspect(cl->buf->pos, len);
        }
    }

    /* pass original chain through — zero allocation, zero memcpy */
    return ngx_http_next_body_filter(r, in);
}
```

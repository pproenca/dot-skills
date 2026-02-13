---
title: Iterate Buffer Chains Using cl->next Pattern
impact: MEDIUM
impactDescription: prevents processing only first buffer in multi-buffer responses
tags: filter, buffer, chain, iteration
---

## Iterate Buffer Chains Using cl->next Pattern

Response bodies arrive as linked lists of `ngx_chain_t` nodes. Each node holds a `ngx_buf_t` pointer and a `next` link. Processing only the first buffer silently discards the rest of the response, producing truncated output for any response larger than a single buffer.

**Incorrect (processes only the first buffer in the chain):**

```c
static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    u_char  *p;
    size_t   len;

    if (in == NULL) {
        return ngx_http_next_body_filter(r, in);
    }

    /* BUG: only processes in->buf — remaining buffers are ignored */
    p = in->buf->pos;
    len = in->buf->last - in->buf->pos;
    ngx_http_myfilter_transform(p, len);

    return ngx_http_next_body_filter(r, in);
}
```

**Correct (iterates entire buffer chain):**

```c
static ngx_int_t
ngx_http_myfilter_body_filter(ngx_http_request_t *r, ngx_chain_t *in)
{
    ngx_chain_t  *cl;
    u_char       *p;
    size_t        len;

    for (cl = in; cl; cl = cl->next) {
        if (cl->buf->in_file) {
            continue;  /* skip file buffers if only processing memory */
        }

        p = cl->buf->pos;
        len = cl->buf->last - cl->buf->pos;

        if (len > 0) {
            ngx_http_myfilter_transform(p, len);
        }
    }

    return ngx_http_next_body_filter(r, in);
}
```

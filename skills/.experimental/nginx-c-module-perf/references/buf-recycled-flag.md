---
title: Mark Buffers as Recycled for Upstream Response Reuse
impact: MEDIUM-HIGH
impactDescription: enables buffer pool recycling across upstream responses
tags: buf, recycled, upstream, pool
---

## Mark Buffers as Recycled for Upstream Response Reuse

When proxying upstream responses, nginx maintains a buffer pool (`p->free` and `p->busy` lists) to avoid allocating new buffers for every chunk of upstream data. Setting `b->recycled = 1` on buffers returned from `input_filter` tells the upstream machinery that this buffer can be returned to the free pool once its contents have been sent downstream. Without this flag, buffers accumulate on the busy list and are never reused — forcing a new allocation for every upstream read, which under sustained load exhausts the connection pool and triggers expensive pool growth.

**Incorrect (upstream buffers never returned to free pool):**

```c
static ngx_int_t
ngx_http_myupstream_input_filter(void *data, ssize_t bytes)
{
    ngx_http_request_t  *r = data;
    ngx_buf_t           *b;
    ngx_chain_t         *cl;

    cl = ngx_chain_get_free_buf(r->pool, &r->upstream->free_bufs);
    if (cl == NULL) {
        return NGX_ERROR;
    }

    b = cl->buf;

    b->pos = b->start;
    b->last = b->pos + bytes;
    b->memory = 1;
    b->flush = 1;
    b->tag = r->upstream->output.tag;
    /* BUG: recycled not set — buffer stays on busy list permanently */

    cl->next = NULL;
    *r->upstream->busy_end = cl;
    r->upstream->busy_end = &cl->next;

    return NGX_OK;
}
```

**Correct (marks buffers as recycled for pool reuse across upstream reads):**

```c
static ngx_int_t
ngx_http_myupstream_input_filter(void *data, ssize_t bytes)
{
    ngx_http_request_t  *r = data;
    ngx_buf_t           *b;
    ngx_chain_t         *cl;

    cl = ngx_chain_get_free_buf(r->pool, &r->upstream->free_bufs);
    if (cl == NULL) {
        return NGX_ERROR;
    }

    b = cl->buf;

    b->pos = b->start;
    b->last = b->pos + bytes;
    b->memory = 1;
    b->flush = 1;
    b->tag = r->upstream->output.tag;
    b->recycled = 1; /* enables return to free pool after downstream send */

    cl->next = NULL;
    *r->upstream->busy_end = cl;
    r->upstream->busy_end = &cl->next;

    return NGX_OK;
}
```

**Note:** The `recycled` flag works in conjunction with the buffer's `tag` field. When nginx scans the busy list after a downstream write completes, buffers with matching tags and `recycled = 1` are moved back to the free list. Ensure the tag matches `r->upstream->output.tag` for proper recycling.

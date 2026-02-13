---
title: Trace Filter Chain Execution Order and Data Flow
impact: HIGH
impactDescription: identifies which filter corrupts or drops response data
tags: trace, filter, chain, header-filter, body-filter
---

## Trace Filter Chain Execution Order and Data Flow

Header and body filters execute in reverse registration order: the last module to register its filter in the static initialization is called first. When response data is corrupted, truncated, or missing, trace the filter chain by logging buffer chain state (number of buffers, total size, `last_buf` flag) at each filter's entry and exit. Comparing the data at each filter boundary reveals exactly where corruption or data loss occurs.

**Incorrect (assuming filters run in registration order, missing data flow visibility):**

```c
/*
 * Body filter that modifies response content.
 * Developer assumes this filter runs AFTER gzip but it actually
 * runs BEFORE gzip because filters execute in reverse order.
 * No data flow tracing means the developer has no way to know
 * the execution order or where bytes are being lost.
 */
static ngx_int_t
ngx_http_mymodule_body_filter(ngx_http_request_t *r,
    ngx_chain_t *in)
{
    ngx_chain_t  *cl;

    /*
     * BUG: modifies the buffer content assuming it's the raw
     * response, but gzip hasn't run yet — this filter sees
     * uncompressed data, modifies it, and then gzip compresses
     * the modified result. The Content-Length header (set by
     * an earlier header filter) no longer matches.
     */
    for (cl = in; cl; cl = cl->next) {
        /* transform buffer content... */
        transform_buffer(cl->buf);
    }

    /* No debug output — when the response is garbled,
     * there's no trace of what data this filter received
     * or what it passed downstream */
    return ngx_http_next_body_filter(r, in);
}
```

**Correct (tracing buffer chain state at filter entry and exit):**

```c
static ngx_int_t
ngx_http_mymodule_body_filter(ngx_http_request_t *r,
    ngx_chain_t *in)
{
    off_t         total_size;
    ngx_int_t     buf_count;
    ngx_chain_t  *cl;
    ngx_int_t     has_last;
    ngx_int_t     rc;

    /* Trace: count buffers and total bytes at entry */
    total_size = 0;
    buf_count = 0;
    has_last = 0;

    for (cl = in; cl; cl = cl->next) {
        buf_count++;
        if (cl->buf->last > cl->buf->pos) {
            total_size += cl->buf->last - cl->buf->pos;
        }
        if (cl->buf->last_buf) {
            has_last = 1;
        }
    }

    ngx_log_debug4(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule body filter ENTER: "
                   "bufs=%i, total=%O, last_buf=%i, uri=\"%V\"",
                   buf_count, total_size, has_last, &r->uri);

    /* Skip subrequests — only filter the main response */
    if (r != r->main) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "mymodule body filter: passing subrequest through");
        return ngx_http_next_body_filter(r, in);
    }

    /* Apply transformation */
    for (cl = in; cl; cl = cl->next) {
        if (ngx_buf_special(cl->buf)) {
            continue;
        }
        transform_buffer(cl->buf);
    }

    /* Trace: measure output after transformation */
    total_size = 0;
    buf_count = 0;
    for (cl = in; cl; cl = cl->next) {
        buf_count++;
        if (cl->buf->last > cl->buf->pos) {
            total_size += cl->buf->last - cl->buf->pos;
        }
    }

    ngx_log_debug3(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule body filter EXIT: "
                   "bufs=%i, total=%O, last_buf=%i",
                   buf_count, total_size, has_last);

    rc = ngx_http_next_body_filter(r, in);

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule body filter: next_filter returned %i", rc);

    return rc;
}

/*
 * Debug log output — trace shows data flow through the chain:
 *
 *  [debug] mymodule body filter ENTER: bufs=3, total=4096, last_buf=0, uri="/index.html"
 *  [debug] mymodule body filter EXIT:  bufs=3, total=4102, last_buf=0
 *  [debug] mymodule body filter: next_filter returned 0
 *  [debug] gzip body filter ENTER: bufs=3, total=4102  <-- gzip sees transformed data
 *
 *  If total drops between filters, that filter is dropping data.
 *  If last_buf disappears, a filter consumed the final marker.
 */
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)

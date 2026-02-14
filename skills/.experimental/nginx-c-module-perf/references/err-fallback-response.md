---
title: Return Fallback Response When Upstream Fails
impact: HIGH
impactDescription: reduces client error rate from 100% to 0% during upstream outages
tags: err, fallback, upstream, degradation
---

## Return Fallback Response When Upstream Fails

When an upstream is unreachable or times out, returning `NGX_HTTP_BAD_GATEWAY` directly gives the client an empty error page and no useful content. A resilient module should detect the upstream failure and generate a degraded fallback response — a cached snapshot, a static default body, or a minimal JSON payload — so downstream services and end users can continue operating with stale-but-functional data instead of a hard failure.

**Incorrect (returns 502 directly, giving the client an empty error page):**

```c
static ngx_int_t
ngx_http_mymodule_upstream_finalize(ngx_http_request_t *r,
    ngx_http_upstream_t *u)
{
    if (u->peer.connection == NULL || u->headers_in.status_n == 0) {
        /* BUG: hard 502 — client gets no useful content, cascades to callers */
        return ngx_http_send_special(r, NGX_HTTP_LAST);
    }

    return NGX_OK;
}
```

**Correct (generates a fallback response body when upstream is unavailable):**

```c
static ngx_int_t
ngx_http_mymodule_upstream_finalize(ngx_http_request_t *r,
    ngx_http_upstream_t *u)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;

    if (u->peer.connection == NULL || u->headers_in.status_n == 0) {
        /* upstream failed — serve a degraded fallback instead of 502 */
        ngx_log_error(NGX_LOG_WARN, r->connection->log, 0,
                      "upstream unavailable, serving fallback for \"%V\"",
                      &r->uri);

        static u_char fallback_body[] =
            "{\"status\":\"degraded\",\"source\":\"fallback\"}";

        b = ngx_calloc_buf(r->pool);
        if (b == NULL) {
            return NGX_HTTP_INTERNAL_SERVER_ERROR;
        }

        b->pos = fallback_body;
        b->last = fallback_body + sizeof(fallback_body) - 1;
        b->memory = 1;
        b->last_buf = (r == r->main) ? 1 : 0;
        b->last_in_chain = 1;

        out.buf = b;
        out.next = NULL;

        r->headers_out.status = NGX_HTTP_OK;
        r->headers_out.content_length_n = b->last - b->pos;

        ngx_str_set(&r->headers_out.content_type, "application/json");
        r->headers_out.content_type_len = r->headers_out.content_type.len;

        ngx_http_send_header(r);

        return ngx_http_output_filter(r, &out);
    }

    return NGX_OK;
}
```

---
title: Use Lingering Close for Graceful Connection Shutdown
impact: MEDIUM-HIGH
impactDescription: prevents RST packets and client data loss on premature close
tags: conn, linger, close, graceful
---

## Use Lingering Close for Graceful Connection Shutdown

When a module finishes sending an error response (e.g., 400 or 413) but the client is still transmitting request body data, calling `ngx_close_connection()` immediately causes the kernel to send a TCP RST. The RST arrives before the client reads the response, so the client's TCP stack discards the buffered response data and reports a "connection reset" error instead of showing the server's error page. Lingering close drains the remaining client data before performing the final close, ensuring the response is fully received.

**Incorrect (immediate close sends RST while client is still sending):**

```c
static void
ngx_http_mymodule_reject_request(ngx_http_request_t *r)
{
    ngx_connection_t  *c = r->connection;
    ngx_buf_t         *b;
    ngx_chain_t        out;

    /* send 413 response */
    r->headers_out.status = NGX_HTTP_REQUEST_ENTITY_TOO_LARGE;
    r->headers_out.content_length_n = sizeof("Request too large") - 1;
    ngx_http_send_header(r);

    b = ngx_calloc_buf(r->pool);
    b->pos = (u_char *) "Request too large";
    b->last = b->pos + sizeof("Request too large") - 1;
    b->memory = 1;
    b->last_buf = 1;
    out.buf = b;
    out.next = NULL;

    ngx_http_output_filter(r, &out);

    /* BUG: client is still uploading body data — immediate close
     * sends RST, client never sees the 413 response */
    ngx_http_close_connection(c);
}
```

**Correct (lingering close drains client data so response is fully received):**

```c
static void
ngx_http_mymodule_reject_request(ngx_http_request_t *r)
{
    ngx_buf_t    *b;
    ngx_chain_t   out;

    /* send 413 response */
    r->headers_out.status = NGX_HTTP_REQUEST_ENTITY_TOO_LARGE;
    r->headers_out.content_length_n = sizeof("Request too large") - 1;
    ngx_http_send_header(r);

    b = ngx_calloc_buf(r->pool);
    b->pos = (u_char *) "Request too large";
    b->last = b->pos + sizeof("Request too large") - 1;
    b->memory = 1;
    b->last_buf = 1;
    out.buf = b;
    out.next = NULL;

    ngx_http_output_filter(r, &out);

    /* use lingering close — nginx reads and discards remaining
     * client data before final close, preventing RST;
     * r->lingering_close triggers the lingering close state machine */
    r->lingering_close = 1;
    ngx_http_finalize_request(r, NGX_HTTP_REQUEST_ENTITY_TOO_LARGE);
}
```

**Note:** `ngx_http_finalize_request` with `r->lingering_close = 1` enters nginx's built-in lingering close state machine, which reads and discards incoming data for up to `lingering_timeout` seconds. For raw connections outside the HTTP layer, use `ngx_http_set_lingering_close()` or implement a manual drain loop with a timer. The `lingering_close` and `lingering_timeout` directives in `nginx.conf` control the global behavior.

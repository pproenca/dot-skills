---
title: Trace Upstream Callback Sequence for Proxy Debugging
impact: HIGH
impactDescription: maps 8+ upstream callback transitions — proxy bugs require tracing create/init/send/read/finalize sequence
tags: trace, upstream, callback, state-machine, proxy
---

## Trace Upstream Callback Sequence for Proxy Debugging

The upstream module calls module-defined callbacks in a strict sequence: `create_request` (build request to backend), `reinit_request` (on retry after failure), `process_header` (parse backend response header), `input_filter_init` (prepare for body), `input_filter` (process body chunks), and `finalize_request` (cleanup). Understanding which callback fires, when, and with what upstream state is critical for debugging custom proxy modules. When a proxy module fails silently, the error is almost always a callback returning the wrong status code or failing to set the next state.

**Incorrect (debugging upstream issues by examining only the error response):**

```c
/*
 * Custom upstream module — returns 502 Bad Gateway but the
 * backend server is healthy. Developer only looks at the
 * final error response and the error log:
 *
 *   [error] upstream prematurely closed connection
 *
 * Without callback tracing, there's no visibility into which
 * callback failed or what the upstream state was at failure time.
 */

static ngx_int_t
ngx_http_myproxy_process_header(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u;

    u = r->upstream;

    /*
     * BUG: parse_status_line returns NGX_AGAIN because the
     * full header hasn't arrived, but this function returns
     * NGX_HTTP_UPSTREAM_INVALID_HEADER instead of NGX_AGAIN.
     * The upstream module interprets this as a protocol error
     * and sends 502 to the client.
     */
    if (parse_status_line(r, u) == NGX_AGAIN) {
        /* Developer thinks NGX_ERROR is the right "retry" code */
        return NGX_HTTP_UPSTREAM_INVALID_HEADER;
    }

    u->headers_in.status_n = 200;
    return NGX_OK;
}
```

**Correct (tracing callback entry, exit, upstream state, and return codes):**

```c
static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy: create_request ENTER, uri=\"%V\"",
                   &r->uri);

    /* ... build the request buffer to send to backend ... */

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy: create_request EXIT, "
                   "request_bufs=%p", r->upstream->request_bufs);

    return NGX_OK;
}

static ngx_int_t
ngx_http_myproxy_reinit_request(ngx_http_request_t *r)
{
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy: reinit_request (retry), "
                   "state=%ui, status=%ui",
                   r->upstream->state->status,
                   r->upstream->headers_in.status_n);

    /* reset parsing state for retry */
    return NGX_OK;
}

static ngx_int_t
ngx_http_myproxy_process_header(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u;
    ngx_int_t             rc;

    u = r->upstream;

    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy: process_header ENTER, "
                   "buf_size=%uz, buf_last-pos=%uz",
                   u->buffer.end - u->buffer.start,
                   u->buffer.last - u->buffer.pos);

    rc = parse_status_line(r, u);

    if (rc == NGX_AGAIN) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "myproxy: process_header EXIT rc=NGX_AGAIN "
                       "(need more data from backend)");
        /* Correct: return NGX_AGAIN so upstream reads more data */
        return NGX_AGAIN;
    }

    if (rc == NGX_ERROR) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "myproxy: process_header EXIT "
                       "rc=INVALID_HEADER (parse failed)");
        return NGX_HTTP_UPSTREAM_INVALID_HEADER;
    }

    u->headers_in.status_n = u->status.code;

    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy: process_header EXIT rc=NGX_OK, "
                   "backend_status=%ui, content_length=%O",
                   u->headers_in.status_n,
                   u->headers_in.content_length_n);

    return NGX_OK;
}

static void
ngx_http_myproxy_finalize_request(ngx_http_request_t *r,
    ngx_int_t rc)
{
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy: finalize_request rc=%i, status=%ui",
                   rc, r->upstream->headers_in.status_n);
}

/*
 * Debug log trace of a successful proxy request:
 *
 *  myproxy: create_request ENTER, uri="/api/data"
 *  myproxy: create_request EXIT, request_bufs=0x1e40200
 *  myproxy: process_header ENTER, buf_size=4096, buf_last-pos=0
 *  myproxy: process_header EXIT rc=NGX_AGAIN (need more data)
 *  myproxy: process_header ENTER, buf_size=4096, buf_last-pos=128
 *  myproxy: process_header EXIT rc=NGX_OK, backend_status=200, content_length=1024
 *  myproxy: finalize_request rc=0, status=200
 */
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)

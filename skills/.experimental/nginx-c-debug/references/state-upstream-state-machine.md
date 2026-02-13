---
title: Debug Upstream Module State by Logging Transition Points
impact: MEDIUM
impactDescription: maps complex proxy state machine for intermittent failures
tags: state, upstream, state-machine, proxy
---

## Debug Upstream Module State by Logging Transition Points

The upstream module implements a complex state machine with phases: connect, send request, read header, process header, read body, and finalize. Intermittent proxy failures often stem from unexpected state transitions, such as a timeout during header reading causing a jump to finalize, or a DNS resolution failure silently falling through to the next upstream. Adding debug logging only at the final error point misses the transition that triggered the failure. Log the upstream state at each callback entry to build a complete picture of the transition sequence.

**Incorrect (adding debug logging only at the final error point):**

```c
static void
ngx_http_myproxy_finalize(ngx_http_request_t *r, ngx_int_t rc)
{
    ngx_http_upstream_t  *u;

    u = r->upstream;

    /* BAD: by the time we reach finalize, we only see the final
     * state. We don't know what sequence of transitions led here.
     * Was it: connect -> timeout -> finalize?
     * Or: connect -> send -> header_read -> parse_error -> finalize?
     * Or: connect -> SSL_error -> finalize?
     * This single log line cannot distinguish the cases. */
    if (rc == NGX_ERROR) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "myproxy: upstream request failed, "
                      "status=%ui",
                      u->state.status);
    }
}
```

**Correct (logging state at each upstream callback entry to trace transitions):**

```c
/* Log helper — called at entry of each upstream callback */
static void
ngx_http_myproxy_log_state(ngx_http_request_t *r, const char *phase)
{
    ngx_http_upstream_t  *u;
    ngx_connection_t     *uc;

    u = r->upstream;
    uc = u->peer.connection;

    ngx_log_debug7(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy [%s]: peer_conn=%p status=%ui "
                   "header_sent=%d request_sent=%d "
                   "timedout=%d error=%d",
                   phase,
                   uc,
                   u->state.status,
                   u->header_sent,
                   u->request_sent,
                   uc ? uc->read->timedout : -1,
                   uc ? uc->error : -1);
}

static ngx_int_t
ngx_http_myproxy_create_request(ngx_http_request_t *r)
{
    ngx_http_myproxy_log_state(r, "create_request");
    /* ... build the upstream request buffer ... */
    return NGX_OK;
}

static ngx_int_t
ngx_http_myproxy_process_header(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u;

    u = r->upstream;

    ngx_http_myproxy_log_state(r, "process_header");

    /* Log what we actually received before parsing */
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy process_header: buffer pos=%p last=%p "
                   "(%uz bytes available)",
                   u->buffer.pos, u->buffer.last,
                   u->buffer.last - u->buffer.pos);

    /* ... parse upstream response header ... */
    return NGX_OK;
}

static void
ngx_http_myproxy_finalize(ngx_http_request_t *r, ngx_int_t rc)
{
    ngx_http_upstream_t  *u;

    u = r->upstream;

    /* Now the finalize log shows the LAST state, and the
     * preceding callback logs show the complete transition
     * history. Correlate by connection log serial. */
    ngx_log_debug4(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "myproxy [finalize]: rc=%i status=%ui "
                   "response_length=%O connect_time=%M",
                   rc,
                   u->state.status,
                   u->state.response_length,
                   u->state.connect_time);
}
```

Reference: [nginx Development Guide — Upstream](https://nginx.org/en/docs/dev/development_guide.html#http_upstream)

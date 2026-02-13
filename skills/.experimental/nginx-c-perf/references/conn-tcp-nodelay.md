---
title: Control TCP_NODELAY for Latency-Sensitive Responses
impact: HIGH
impactDescription: eliminates 40ms Nagle delay on small responses
tags: conn, tcp-nodelay, nagle, latency
---

## Control TCP_NODELAY for Latency-Sensitive Responses

Nagle's algorithm batches small TCP writes into a single segment, adding up to 40ms of delay before sending data that does not fill an MSS-sized packet. For modules that generate small interactive responses (JSON API replies, WebSocket frames, server-sent events), failing to set `TCP_NODELAY` on the connection means every sub-MSS write stalls for the Nagle timer. nginx's core sets `TCP_NODELAY` on client connections only after `tcp_nodelay on` is configured, but modules managing their own connections must set it explicitly.

**Incorrect (small writes suffer Nagle delay because TCP_NODELAY is never set):**

```c
static void
ngx_http_mymodule_send_event(ngx_connection_t *c, ngx_buf_t *event_buf)
{
    ngx_chain_t  out;

    /* SSE event is typically 50-200 bytes — well under MSS;
     * without TCP_NODELAY, Nagle holds it for ~40ms waiting
     * for more data to coalesce */
    out.buf = event_buf;
    out.next = NULL;

    event_buf->last_buf = 0;
    event_buf->flush = 1;

    c->send_chain(c, &out, 0);
}
```

**Correct (sets TCP_NODELAY after connection establishment for immediate delivery):**

```c
static ngx_int_t
ngx_http_mymodule_init_connection(ngx_connection_t *c)
{
    int  tcp_nodelay = 1;

    /* disable Nagle for this connection — small writes
     * (SSE frames, JSON responses) are sent immediately */
    if (setsockopt(c->fd, IPPROTO_TCP, TCP_NODELAY,
                   &tcp_nodelay, sizeof(int)) == -1)
    {
        ngx_log_error(NGX_LOG_ALERT, c->log, ngx_socket_errno,
                      "setsockopt(TCP_NODELAY) failed");
        return NGX_ERROR;
    }

    c->tcp_nodelay = NGX_TCP_NODELAY_SET;

    return NGX_OK;
}

static void
ngx_http_mymodule_send_event(ngx_connection_t *c, ngx_buf_t *event_buf)
{
    ngx_chain_t  out;

    /* TCP_NODELAY is set — this 50-200 byte SSE event
     * is pushed to the wire immediately */
    out.buf = event_buf;
    out.next = NULL;

    event_buf->last_buf = 0;
    event_buf->flush = 1;

    c->send_chain(c, &out, 0);
}
```

**Note:** Set `c->tcp_nodelay = NGX_TCP_NODELAY_SET` after the `setsockopt` call so nginx's core does not attempt to set it again. For bulk transfer connections (file downloads, large proxied responses), leaving Nagle enabled is correct -- it reduces small-packet overhead and improves throughput. Only disable it for latency-sensitive interactive traffic.

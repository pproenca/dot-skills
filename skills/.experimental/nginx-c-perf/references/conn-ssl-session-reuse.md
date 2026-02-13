---
title: Enable SSL Session Caching in Upstream Connections
impact: MEDIUM-HIGH
impactDescription: eliminates 1-2 RTT TLS handshake overhead on resumed connections
tags: conn, ssl, session, reuse
---

## Enable SSL Session Caching in Upstream Connections

A full TLS handshake to an upstream server costs 1-2 additional RTTs on top of the TCP handshake. When a module establishes its own TLS connections to backends (bypassing the standard upstream module), each new connection performs a full handshake unless the module stores and restores SSL sessions. Session resumption (via session IDs or session tickets) reduces the handshake to a single RTT by reusing previously negotiated cryptographic parameters.

**Incorrect (no session caching -- full TLS handshake on every connection):**

```c
static ngx_int_t
ngx_http_mymodule_ssl_connect(ngx_connection_t *c, my_upstream_conf_t *ucf)
{
    ngx_int_t  rc;

    if (ngx_ssl_create_connection(ucf->ssl, c, NGX_SSL_BUFFER) != NGX_OK) {
        return NGX_ERROR;
    }

    /* no session set — every connection performs a full TLS handshake
     * (ClientHello -> ServerHello -> Certificate -> KeyExchange -> Finished)
     * adding 1-2 RTTs of latency per upstream connection */

    rc = ngx_ssl_handshake(c);

    if (rc == NGX_AGAIN) {
        c->ssl->handler = ngx_http_mymodule_ssl_handshake_done;
        return NGX_AGAIN;
    }

    return rc;
}

static void
ngx_http_mymodule_ssl_handshake_done(ngx_connection_t *c)
{
    /* handshake complete — but session is not saved,
     * so next connection to same peer repeats full handshake */
    ngx_http_mymodule_send_request(c);
}
```

**Correct (stores and restores SSL sessions for upstream session resumption):**

```c
static ngx_int_t
ngx_http_mymodule_ssl_connect(ngx_connection_t *c, my_upstream_peer_t *peer)
{
    ngx_int_t      rc;
    ngx_ssl_session_t  *sess;

    if (ngx_ssl_create_connection(peer->ucf->ssl, c,
                                  NGX_SSL_BUFFER) != NGX_OK)
    {
        return NGX_ERROR;
    }

    /* restore cached session — enables abbreviated handshake
     * (ClientHello with session ID -> ServerHello -> Finished)
     * saving 1-2 RTTs on resumed connections */
    sess = peer->ssl_session;
    if (sess != NULL) {
        if (ngx_ssl_set_session(c, sess) != NGX_OK) {
            ngx_log_error(NGX_LOG_WARN, c->log, 0,
                          "failed to set SSL session for %V",
                          peer->name);
            /* proceed without session — will do full handshake */
        }
    }

    rc = ngx_ssl_handshake(c);

    if (rc == NGX_AGAIN) {
        c->ssl->handler = ngx_http_mymodule_ssl_handshake_done;
        return NGX_AGAIN;
    }

    if (rc == NGX_OK) {
        ngx_http_mymodule_save_ssl_session(c, peer);
    }

    return rc;
}

/* handshake callback saves session then sends request */
static void
ngx_http_mymodule_ssl_handshake_done(ngx_connection_t *c)
{
    my_upstream_peer_t  *peer = c->data;
    /* save session: ngx_ssl_get_session → swap peer->ssl_session → free old */
    ngx_http_mymodule_save_ssl_session(c, peer);
    ngx_http_mymodule_send_request(c);
}
```

**Note:** `ngx_ssl_get_session()` returns a reference-counted `SSL_SESSION` object. Store one session per upstream peer address, not per connection. When a peer is removed or the module shuts down, free the cached session with `ngx_ssl_free_session()` to avoid memory leaks. For the built-in proxy module, the `proxy_ssl_session_reuse` directive handles this automatically -- this pattern is only needed for modules managing their own TLS connections.

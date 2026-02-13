---
title: Handle Connection Drain Under Memory Pressure
impact: CRITICAL
impactDescription: prevents accept() failures when worker_connections limit approached
tags: conn, drain, pressure, worker-connections
---

## Handle Connection Drain Under Memory Pressure

Each nginx worker pre-allocates a fixed-size connection array sized by `worker_connections`. When `free_connection_n` drops near zero, the worker cannot accept new clients -- `accept()` calls fail silently and requests queue in the kernel backlog until they time out. A module that opens its own connections (upstream health checks, async backends) must monitor the free pool and proactively close its own idle connections before the pool is fully exhausted. Note: `ngx_drain_connections()` is an internal static function — modules cannot call it directly, but nginx calls it automatically inside `ngx_get_connection()` to reclaim connections marked reusable.

**Incorrect (opens connections without checking free pool capacity):**

```c
static ngx_int_t
ngx_http_mymodule_connect_backend(ngx_http_request_t *r)
{
    ngx_peer_connection_t  pc;
    ngx_int_t              rc;

    ngx_memzero(&pc, sizeof(ngx_peer_connection_t));
    pc.sockaddr = r->upstream->peer.sockaddr;
    pc.socklen = r->upstream->peer.socklen;
    pc.name = r->upstream->peer.name;
    pc.get = ngx_event_get_peer;
    pc.log = r->connection->log;
    pc.rcvbuf = -1;

    /* BUG: if free_connection_n is 0, ngx_event_connect_peer returns
     * NGX_ERROR and the request fails — no attempt to free idle
     * connections first */
    rc = ngx_event_connect_peer(&pc);

    if (rc == NGX_ERROR) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "backend connect failed");
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

**Correct (closes module's own idle connections when free pool runs low):**

```c
static ngx_int_t
ngx_http_mymodule_connect_backend(ngx_http_request_t *r)
{
    ngx_peer_connection_t  pc;
    ngx_int_t              rc;

    /* proactively close module's idle connections when pool is under pressure;
     * threshold of 32 gives headroom for accept() and other modules */
    if (ngx_cycle->free_connection_n < 32) {
        ngx_http_mymodule_close_idle_connections(r->connection->log);

        if (ngx_cycle->free_connection_n == 0) {
            ngx_log_error(NGX_LOG_CRIT, r->connection->log, 0,
                          "no free connections after idle cleanup, "
                          "worker_connections may be too low");
            return NGX_DECLINED;
        }
    }

    ngx_memzero(&pc, sizeof(ngx_peer_connection_t));
    pc.sockaddr = r->upstream->peer.sockaddr;
    pc.socklen = r->upstream->peer.socklen;
    pc.name = r->upstream->peer.name;
    pc.get = ngx_event_get_peer;
    pc.log = r->connection->log;
    pc.rcvbuf = -1;

    rc = ngx_event_connect_peer(&pc);

    if (rc == NGX_ERROR) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "backend connect failed after idle cleanup");
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

**Note:** Modules cannot call `ngx_drain_connections()` directly (it is static to `ngx_connection.c`). Instead, maintain your own list of idle connections and close them proactively when `ngx_cycle->free_connection_n` drops below a threshold. Also mark idle connections as reusable with `ngx_reusable_connection(c, 1)` (see `conn-reusable-queue`) so nginx's internal drain mechanism can reclaim them during `ngx_get_connection()`.

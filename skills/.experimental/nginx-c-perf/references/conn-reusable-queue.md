---
title: Mark Idle Connections as Reusable for Pool Recovery
impact: CRITICAL
impactDescription: prevents connection exhaustion under sustained load
tags: conn, reusable, pool, exhaustion
---

## Mark Idle Connections as Reusable for Pool Recovery

When a custom module holds long-lived connections (e.g., persistent backend channels or health-check sockets), those connections count against the worker's `worker_connections` limit. Unless the module marks idle connections as reusable via `ngx_reusable_connection()`, nginx cannot reclaim them when new connections arrive -- the worker hits `worker_connections` and starts rejecting clients with no way to free capacity.

**Incorrect (idle connections are never marked reusable, permanently consuming slots):**

```c
static void
ngx_http_mymodule_idle_handler(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;
    my_conn_ctx_t     *ctx = c->data;

    if (rev->timedout) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    /* connection sits idle waiting for next request to reuse it,
     * but it is NOT marked reusable — nginx cannot reclaim it
     * when worker_connections limit is approached */
    ctx->state = MY_CONN_IDLE;

    ngx_add_timer(rev, ctx->idle_timeout);

    if (ngx_handle_read_event(rev, 0) != NGX_OK) {
        ngx_http_mymodule_close_connection(c);
    }
}
```

**Correct (marking idle connections reusable allows nginx to reclaim them under pressure):**

```c
static void
ngx_http_mymodule_idle_handler(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;
    my_conn_ctx_t     *ctx = c->data;

    if (rev->timedout) {
        ngx_reusable_connection(c, 0);
        ngx_http_mymodule_close_connection(c);
        return;
    }

    /* mark connection as reusable — nginx can close it to free
     * a slot when worker_connections limit is under pressure */
    ctx->state = MY_CONN_IDLE;
    ngx_reusable_connection(c, 1);

    c->read->handler = ngx_http_mymodule_reuse_handler;
    ngx_add_timer(rev, ctx->idle_timeout);

    if (ngx_handle_read_event(rev, 0) != NGX_OK) {
        ngx_reusable_connection(c, 0);
        ngx_http_mymodule_close_connection(c);
    }
}

static void
ngx_http_mymodule_reuse_handler(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;

    /* remove from reusable queue before active use */
    ngx_reusable_connection(c, 0);

    if (rev->timedout) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    /* connection has incoming data — reactivate for processing */
    ngx_http_mymodule_process(c);
}
```

**Note:** Always call `ngx_reusable_connection(c, 0)` before using the connection for active I/O or before closing it. The reusable queue is a doubly-linked list on `ngx_cycle->reusable_connections_queue` -- leaving a freed connection in the queue corrupts the list.

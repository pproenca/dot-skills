---
title: Track Failures in Peer free Callback
impact: MEDIUM
impactDescription: prevents retry storms on permanently failed backends
tags: upstream, peer, free, failure-tracking
---

## Track Failures in Peer free Callback

The peer `free` callback receives a `state` bitmask indicating how the connection ended. Track failures to avoid hammering permanently down backends. Decrement `pc->tries` to control whether nginx retries the request on another peer. Ignoring the state parameter causes infinite retries against dead backends, wasting connections and delaying client responses.

**Incorrect (free callback ignores state parameter):**

```c
static void
ngx_http_mybalancer_free_peer(ngx_peer_connection_t *pc, void *data,
    ngx_uint_t state)
{
    ngx_http_mybalancer_peer_data_t  *bp = data;

    /* BUG: ignores failure state — dead backend stays in rotation */
    bp->current = (bp->current + 1) % bp->num_peers;

    /* BUG: pc->tries is never decremented — nginx retries forever */
}
```

**Correct (tracks failures and adjusts retry count):**

```c
static void
ngx_http_mybalancer_free_peer(ngx_peer_connection_t *pc, void *data,
    ngx_uint_t state)
{
    ngx_http_mybalancer_peer_data_t  *bp = data;
    ngx_http_mybalancer_peer_t       *peer;

    peer = &bp->peers[bp->current];

    if (state & NGX_PEER_FAILED) {
        peer->fails++;
        peer->last_failed = ngx_time();

        /* mark peer unavailable after threshold */
        if (peer->fails >= peer->max_fails) {
            peer->down = 1;
        }
    }

    if (pc->tries > 0) {
        pc->tries--;
    }
}
```

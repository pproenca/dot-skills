---
title: Use Exponential Backoff for Upstream Reconnection Attempts
impact: MEDIUM
impactDescription: prevents thundering herd on upstream recovery
tags: timeout, backoff, reconnect, thundering-herd
---

## Use Exponential Backoff for Upstream Reconnection Attempts

When an upstream peer goes down, a naive immediate-retry loop causes all workers to hammer the recovering backend simultaneously -- the thundering herd effect can prevent the upstream from ever stabilizing. Using timer-based exponential backoff with a cap and jitter spreads reconnection attempts over time, giving the upstream breathing room to recover while keeping the module responsive to actual restoration.

**Incorrect (immediate retry loop on upstream connection failure):**

```c
static void
ngx_http_myproxy_connect_to_backend(ngx_http_myproxy_peer_t *peer)
{
    ngx_int_t  rc;

retry:
    rc = ngx_event_connect_peer(&peer->pc);

    if (rc == NGX_ERROR || rc == NGX_DECLINED) {
        ngx_log_error(NGX_LOG_ERR, peer->log, 0,
                      "backend connect failed, retrying immediately");

        /* BUG: tight retry loop — all workers retry at once, overwhelming
         * the recovering backend and saturating the worker's event loop */
        goto retry;
    }

    if (rc == NGX_AGAIN) {
        ngx_add_timer(peer->pc.connection->write, peer->connect_timeout);
        return;
    }

    /* connected */
    ngx_http_myproxy_send_request(peer);
}
```

**Correct (timer-based exponential backoff with jitter and cap):**

```c
#define MYPROXY_BACKOFF_BASE_MS    100
#define MYPROXY_BACKOFF_MAX_MS     30000
#define MYPROXY_BACKOFF_MAX_SHIFT  8       /* 2^8 * 100ms = 25600ms */

static void
ngx_http_myproxy_reconnect_handler(ngx_event_t *ev)
{
    ngx_http_myproxy_peer_t  *peer = ev->data;
    ngx_int_t                 rc;

    rc = ngx_event_connect_peer(&peer->pc);

    if (rc == NGX_ERROR || rc == NGX_DECLINED) {
        ngx_http_myproxy_schedule_reconnect(peer);
        return;
    }

    if (rc == NGX_AGAIN) {
        ngx_add_timer(peer->pc.connection->write, peer->connect_timeout);
        return;
    }

    /* connected — reset backoff state for next failure */
    peer->reconnect_attempts = 0;
    ngx_http_myproxy_send_request(peer);
}

static void
ngx_http_myproxy_schedule_reconnect(ngx_http_myproxy_peer_t *peer)
{
    ngx_msec_t  delay, jitter;
    ngx_uint_t  shift;

    /* exponential backoff: base * 2^attempts, capped at max */
    shift = ngx_min(peer->reconnect_attempts, MYPROXY_BACKOFF_MAX_SHIFT);
    delay = MYPROXY_BACKOFF_BASE_MS << shift;

    if (delay > MYPROXY_BACKOFF_MAX_MS) {
        delay = MYPROXY_BACKOFF_MAX_MS;
    }

    /* add jitter: +/- 25% to desynchronize workers */
    jitter = (ngx_random() % (delay / 2)) - (delay / 4);
    delay += jitter;

    peer->reconnect_attempts++;

    ngx_log_error(NGX_LOG_WARN, peer->log, 0,
                  "backend down, reconnect in %Mms (attempt %ui)",
                  delay, peer->reconnect_attempts);

    peer->reconnect_ev.handler = ngx_http_myproxy_reconnect_handler;
    peer->reconnect_ev.data = peer;
    peer->reconnect_ev.log = peer->log;

    ngx_add_timer(&peer->reconnect_ev, delay);
}
```

---
title: Deduplicate Repeated Error Messages with Throttling
impact: LOW
impactDescription: prevents log file bloat and I/O saturation during error storms
tags: log, dedup, throttle, storm
---

## Deduplicate Repeated Error Messages with Throttling

When an upstream goes down or a resource becomes unavailable, the same error fires on every request and can produce thousands of identical log lines per second. This floods the disk, makes logs unreadable, and can saturate I/O bandwidth enough to degrade healthy request processing. Track the last time each recurring error was logged and suppress duplicates, emitting a periodic summary with the suppressed count instead.

**Incorrect (logs every error occurrence, flooding disk during storms):**

```c
static ngx_int_t
ngx_http_proxy_connect(ngx_http_request_t *r, ngx_addr_t *addr)
{
    ngx_int_t  rc;

    rc = ngx_event_connect_peer(&r->upstream->peer);
    if (rc == NGX_ERROR) {
        /* BAD: under a sustained upstream outage this fires thousands
         * of times per second, saturating disk I/O */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "upstream connection to %V failed", &addr->name);
        return NGX_HTTP_BAD_GATEWAY;
    }

    return NGX_OK;
}
```

**Correct (throttles repeated errors and logs a periodic summary count):**

```c
typedef struct {
    ngx_msec_t      last_logged;
    ngx_atomic_t    suppressed;
} ngx_http_mymodule_error_state_t;

static ngx_http_mymodule_error_state_t  connect_error_state;

#define NGX_HTTP_MYMODULE_LOG_INTERVAL  5000  /* 5 seconds */

static ngx_int_t
ngx_http_proxy_connect(ngx_http_request_t *r, ngx_addr_t *addr)
{
    ngx_int_t    rc;
    ngx_msec_t   now;

    rc = ngx_event_connect_peer(&r->upstream->peer);
    if (rc == NGX_ERROR) {
        now = ngx_current_msec;

        if (now - connect_error_state.last_logged
            < NGX_HTTP_MYMODULE_LOG_INTERVAL)
        {
            /* suppress duplicate — just count it */
            ngx_atomic_fetch_add(&connect_error_state.suppressed, 1);

        } else {
            /* enough time has passed — emit summary and reset */
            if (connect_error_state.suppressed) {
                ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                              "upstream connection to %V failed "
                              "(%uA occurrences suppressed in last %Ms)",
                              &addr->name,
                              connect_error_state.suppressed,
                              NGX_HTTP_MYMODULE_LOG_INTERVAL);
            } else {
                ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                              "upstream connection to %V failed",
                              &addr->name);
            }

            connect_error_state.last_logged = now;
            connect_error_state.suppressed = 0;
        }

        return NGX_HTTP_BAD_GATEWAY;
    }

    return NGX_OK;
}
```

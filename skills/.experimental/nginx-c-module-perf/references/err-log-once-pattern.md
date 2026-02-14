---
title: Limit Repeated Error Logging to Prevent Log Storms
impact: MEDIUM
impactDescription: prevents log I/O from becoming the bottleneck during error cascades
tags: err, logging, rate-limit, storm
---

## Limit Repeated Error Logging to Prevent Log Storms

During sustained failure conditions — upstream outage, shared memory exhaustion, disk full — every request triggers the same `ngx_log_error` call. At high request rates this produces thousands of identical log lines per second, and the synchronous `write()` to the error log file becomes the dominant bottleneck, stalling event loop processing for healthy requests. Tracking an error count in module context and logging only periodically (e.g., every Nth occurrence or once per interval) preserves diagnostic visibility without letting log I/O cascade into a full worker stall.

**Incorrect (logs every occurrence of a repeated error, causing log I/O storm):**

```c
static ngx_int_t
ngx_http_mymodule_shm_lookup(ngx_http_request_t *r,
    ngx_http_mymodule_loc_conf_t *lcf)
{
    ngx_http_mymodule_node_t  *node;

    node = ngx_http_mymodule_find_node(lcf->shm_zone, &r->uri);

    if (node == NULL) {
        /* BUG: under sustained cache-miss storm, this fires on every request
         * — at 10k rps that's 10k write() syscalls/sec to error.log */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "shared memory lookup failed for \"%V\"", &r->uri);
        return NGX_HTTP_SERVICE_UNAVAILABLE;
    }

    return NGX_OK;
}
```

**Correct (tracks error count in shared memory and logs periodically):**

```c
static ngx_int_t
ngx_http_mymodule_shm_lookup(ngx_http_request_t *r,
    ngx_http_mymodule_loc_conf_t *lcf)
{
    ngx_http_mymodule_node_t  *node;
    ngx_http_mymodule_shm_t   *shm;
    ngx_atomic_int_t           prev;

    node = ngx_http_mymodule_find_node(lcf->shm_zone, &r->uri);

    if (node == NULL) {
        shm = lcf->shm_zone->data;

        /* atomic increment returns the previous value — use it directly */
        prev = ngx_atomic_fetch_add(&shm->lookup_errors, 1);

        /* log only every 1000th occurrence to avoid I/O storm */
        if ((prev + 1) % 1000 == 1) {
            ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                          "shared memory lookup failed for \"%V\" "
                          "(%uA total failures)", &r->uri, prev + 1);
        }

        return NGX_HTTP_SERVICE_UNAVAILABLE;
    }

    return NGX_OK;
}
```

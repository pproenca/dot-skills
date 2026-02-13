---
title: Never Access Request After Finalization
impact: CRITICAL
impactDescription: prevents use-after-free crashes under load
tags: req, finalize, use-after-free, lifecycle
---

## Never Access Request After Finalization

After `ngx_http_finalize_request`, the request pool may be destroyed and `r`, `r->pool`, and `r->connection` become dangling pointers. Any access is undefined behavior that manifests as intermittent crashes under load when the memory is reused.

**Incorrect (accessing request after finalize):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_finalize_request(r, NGX_OK);

    /* BUG: r->pool may already be destroyed — use-after-free */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "finished processing %V", &r->uri);

    return NGX_DONE;
}
```

**Correct (capture data before finalize):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_log_t  *log;

    /* capture anything needed BEFORE finalize */
    log = r->connection->log;

    ngx_log_error(NGX_LOG_INFO, log, 0,
                  "finishing request for %V", &r->uri);

    /* finalize is the LAST operation — never touch r after this */
    ngx_http_finalize_request(r, NGX_OK);
    return NGX_DONE;
}
```

---
title: Access Configuration Through Cycle for Process-Level Operations
impact: LOW-MEDIUM
impactDescription: prevents NULL pointer crash when accessing config outside request context
tags: worker, cycle, configuration, process
---

## Access Configuration Through Cycle for Process-Level Operations

Module code that runs outside a request context -- `init_process`, timer callbacks, and posted event handlers -- has no `ngx_http_request_t` to extract configuration from. Attempting to dereference `r->` or calling `ngx_http_get_module_loc_conf(r, ...)` with a NULL or stale request pointer causes a segfault. Process-level code must walk `ngx_cycle->conf_ctx` through the module's configuration hierarchy to reach the correct `main_conf`, `srv_conf`, or `loc_conf`.

**Incorrect (accesses config through request pointer in timer callback):**

```c
static void
ngx_http_mymodule_health_check(ngx_event_t *ev)
{
    ngx_http_request_t             *r;
    ngx_http_mymodule_loc_conf_t   *mlcf;

    /* BUG: ev->data was set to the request during handler setup,
     * but the request may be long gone by the time this timer fires —
     * r is a dangling pointer, and dereferencing it crashes the worker */
    r = ev->data;

    /* SEGFAULT: r points to freed memory, accessing r->main triggers
     * a NULL deref or use-after-free */
    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    if (mlcf->health_check_interval) {
        /* ... perform health check ... */
    }

    ngx_add_timer(ev, 5000);
}
```

**Correct (accesses config through ngx_cycle->conf_ctx for process-level operations):**

```c
static void
ngx_http_mymodule_health_check(ngx_event_t *ev)
{
    ngx_http_conf_ctx_t            *ctx;
    ngx_http_mymodule_main_conf_t  *mmcf;

    /* walk the configuration tree through the cycle — safe to call
     * from any context (timers, init_process, posted events) */
    ctx = (ngx_http_conf_ctx_t *)
              ngx_get_conf(ngx_cycle->conf_ctx, ngx_http_module);
    if (ctx == NULL) {
        ngx_log_error(NGX_LOG_ERR, ev->log, 0,
                      "mymodule: http config not available");
        return;
    }

    mmcf = ctx->main_conf[ngx_http_mymodule_module.ctx_index];
    if (mmcf == NULL || !mmcf->health_check_enabled) {
        return;
    }

    /* safely use main_conf for process-level health check parameters */
    ngx_http_mymodule_run_check(ev, mmcf->upstream_addr,
                                mmcf->health_check_timeout);

    if (!ngx_exiting) {
        ngx_add_timer(ev, mmcf->health_check_interval);
    }
}
```

**Note:** For process-level code, only `main_conf` is reliably meaningful -- `srv_conf` and `loc_conf` require knowing which server block or location to target. If your module needs location-specific config in a timer, store the `loc_conf` pointer in the timer's `ev->data` during request setup, but guard against the pointer outliving the configuration reload by checking `ngx_cycle->conf_ctx` generation.

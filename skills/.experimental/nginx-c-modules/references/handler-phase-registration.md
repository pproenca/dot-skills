---
title: Register Phase Handlers in postconfiguration
impact: HIGH
impactDescription: prevents handlers from never executing
tags: handler, phase, registration, postconfiguration
---

## Register Phase Handlers in postconfiguration

Phase handlers must be registered during the `postconfiguration` callback in `ngx_http_module_t`. This is the only point in the startup sequence where the phases array is being built. Adding handlers in `init_module` or `init_process` is too late -- the phase engine has already been compiled into the phase handlers array, and new entries are ignored.

**Incorrect (registering handler in init_process -- too late):**

```c
static ngx_int_t
ngx_http_mymodule_init_process(ngx_cycle_t *cycle)
{
    ngx_http_core_main_conf_t  *cmcf;
    ngx_http_handler_pt        *h;

    cmcf = ngx_http_cycle_get_module_main_conf(cycle,
                                               ngx_http_core_module);

    /* BUG: phase engine is already built at this point —
     * handler is never called */
    h = ngx_array_push(&cmcf->phases[NGX_HTTP_ACCESS_PHASE].handlers);
    if (h == NULL) {
        return NGX_ERROR;
    }

    *h = ngx_http_mymodule_access_handler;
    return NGX_OK;
}
```

**Correct (registering handler in postconfiguration):**

```c
static ngx_int_t
ngx_http_mymodule_postconfiguration(ngx_conf_t *cf)
{
    ngx_http_core_main_conf_t  *cmcf;
    ngx_http_handler_pt        *h;

    cmcf = ngx_http_conf_get_module_main_conf(cf, ngx_http_core_module);

    h = ngx_array_push(&cmcf->phases[NGX_HTTP_ACCESS_PHASE].handlers);
    if (h == NULL) {
        return NGX_ERROR;
    }

    *h = ngx_http_mymodule_access_handler;
    return NGX_OK;
}
```

**Note:** Not all phases accept handlers. `NGX_HTTP_FIND_CONFIG_PHASE`, `NGX_HTTP_POST_REWRITE_PHASE`, and `NGX_HTTP_POST_ACCESS_PHASE` are internal and cannot have user-registered handlers.

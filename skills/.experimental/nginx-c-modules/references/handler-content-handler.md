---
title: Use content_handler for Location-Specific Response Generation
impact: MEDIUM
impactDescription: avoids phase handler overhead for simple content modules
tags: handler, content, location, response
---

## Use content_handler for Location-Specific Response Generation

For modules that generate the complete response for a specific location, set the location's `handler` field directly from the directive setter. This bypasses the phase handler iteration entirely, which avoids executing unrelated phase handlers and provides a clean ownership model -- one location, one content generator.

**Incorrect (phase handler runs for every request, not just the target location):**

```c
static ngx_int_t
ngx_http_mymodule_postconfiguration(ngx_conf_t *cf)
{
    ngx_http_core_main_conf_t  *cmcf;
    ngx_http_handler_pt        *h;

    cmcf = ngx_http_conf_get_module_main_conf(cf, ngx_http_core_module);

    /* runs for ALL requests — must check location config on each call */
    h = ngx_array_push(&cmcf->phases[NGX_HTTP_CONTENT_PHASE].handlers);
    if (h == NULL) {
        return NGX_ERROR;
    }

    *h = ngx_http_mymodule_handler;
    return NGX_OK;
}
```

**Correct (content handler set per-location in the directive setter):**

```c
static char *
ngx_http_mymodule_set(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_core_loc_conf_t  *clcf;

    clcf = ngx_http_conf_get_module_loc_conf(cf, ngx_http_core_module);

    /* handler runs ONLY for requests matching this location */
    clcf->handler = ngx_http_mymodule_handler;

    return NGX_CONF_OK;
}
```

**Note:** This pattern is used by standard modules like `ngx_http_proxy_module` and `ngx_http_static_module`. Phase handlers are better suited for cross-cutting concerns (access control, logging) that should run regardless of which location is matched.

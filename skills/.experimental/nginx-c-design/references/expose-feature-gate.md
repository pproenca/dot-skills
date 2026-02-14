---
title: Use Feature Gates for Optional Behavior
impact: CRITICAL
impactDescription: prevents wasted resources and unexpected behavior for unused features
tags: expose, feature-gate, on-off, performance
---

## Use Feature Gates for Optional Behavior

Features that add overhead (caching, buffering, logging) must be gated by an on/off directive. Following nginx pattern: `proxy_cache off` by default, `proxy_buffering on` by default. The gate directive controls whether the feature's other directives have any effect.

**Incorrect (cache logic always runs even when no cache is configured):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* BUG: always runs cache lookup even when caching is unwanted —
     * wastes cycles computing keys and checking empty shared zones */
    ngx_http_mymodule_compute_cache_key(r, mlcf);

    if (ngx_http_mymodule_cache_lookup(r, mlcf) == NGX_OK) {
        return ngx_http_mymodule_send_cached(r, mlcf);
    }

    return ngx_http_mymodule_fetch_upstream(r, mlcf);
}
```

**Correct (gate flag checked early, all feature logic skipped when disabled):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* gate directive — mymod_cache on|off (default: off) */
    { ngx_string("mymod_cache"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_enabled),
      NULL },

      ngx_null_command
};

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* skip all cache logic when the gate is off — zero overhead */
    if (mlcf->cache_enabled) {
        ngx_http_mymodule_compute_cache_key(r, mlcf);

        if (ngx_http_mymodule_cache_lookup(r, mlcf) == NGX_OK) {
            return ngx_http_mymodule_send_cached(r, mlcf);
        }
    }

    return ngx_http_mymodule_fetch_upstream(r, mlcf);
}
```

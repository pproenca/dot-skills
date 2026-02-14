---
title: Support Variables in Directive Values Only When Per-Request Variation Is Needed
impact: MEDIUM
impactDescription: prevents unnecessary complexity from script compilation overhead
tags: var, directive, interpolation, script
---

## Support Variables in Directive Values Only When Per-Request Variation Is Needed

Some directives benefit from variable interpolation (e.g., `proxy_cache_key "$scheme$host$request_uri"`). But variable support requires script compilation at config time and evaluation at request time, adding complexity. Support variables in directive values only when the value naturally varies per-request and is commonly used with `map` blocks. Do not add variable support for structural values like paths, zone names, or listen addresses.

**Incorrect (supporting variable interpolation in a zone name that never changes per request):**

```c
static char *
ngx_http_mymodule_zone(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t    *mlcf = conf;
    ngx_str_t                       *value;
    ngx_http_compile_complex_value_t ccv;

    value = cf->args->elts;

    /* BUG: compiling zone name as a complex value — it contains no
     * variables that vary per-request; zone names are structural,
     * determined once at config time, used to identify shared memory */
    ngx_memzero(&ccv, sizeof(ngx_http_compile_complex_value_t));

    ccv.cf = cf;
    ccv.value = &value[1];
    ccv.complex_value = &mlcf->zone_name_cv;

    if (ngx_http_compile_complex_value(&ccv) != NGX_OK) {
        return NGX_CONF_ERROR;
    }

    /* wasted: script eval on every request for a value that is
     * always "my_cache_zone" */
    return NGX_CONF_OK;
}
```

**Correct (supporting variables in a cache key where per-request variation is the core use case):**

```c
static char *
ngx_http_mymodule_zone(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;

    value = cf->args->elts;

    /* zone name is structural — plain string, no variable support needed */
    mlcf->zone_name = value[1];

    return NGX_CONF_OK;
}

static char *
ngx_http_mymodule_cache_key(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t    *mlcf = conf;
    ngx_str_t                       *value;
    ngx_http_compile_complex_value_t ccv;

    value = cf->args->elts;

    /* cache key naturally varies per request — variable support is essential
     * so admins can use: mymod_cache_key "$scheme$host$request_uri" */
    ngx_memzero(&ccv, sizeof(ngx_http_compile_complex_value_t));

    ccv.cf = cf;
    ccv.value = &value[1];
    ccv.complex_value = &mlcf->cache_key;

    if (ngx_http_compile_complex_value(&ccv) != NGX_OK) {
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}

/* admin uses variables where they matter:
 *
 *   mymod_zone my_cache 10m;                            # static — no variables
 *   mymod_cache_key "$scheme$host$uri$is_args$args";    # per-request — variables
 */
```

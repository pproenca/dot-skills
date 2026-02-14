---
title: Expose Variables for Per-Request Runtime Data Only
impact: MEDIUM
impactDescription: prevents confusion between config-time directives and runtime variables
tags: var, runtime, per-request, directives
---

## Expose Variables for Per-Request Runtime Data Only

Nginx variables are for per-request, runtime data that other parts of the config consume (`log_format`, `map`, `if`, `proxy_set_header`). Static configuration belongs in directives. Pattern: `$upstream_response_time` (runtime, varies per request) is a variable; `proxy_connect_timeout` (static config) is a directive. Do not expose static settings as variables.

**Incorrect (exposing a static config value as a variable — it never varies per request):**

```c
static ngx_int_t
ngx_http_mymodule_timeout_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;
    u_char                        *p;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* BUG: $mymod_timeout just mirrors the directive value —
     * it's the same for every request in this location,
     * the admin already knows it from the config file */
    p = ngx_pnalloc(r->pool, NGX_TIME_T_LEN);
    if (p == NULL) {
        return NGX_ERROR;
    }

    v->len = ngx_sprintf(p, "%M", mlcf->timeout) - p;
    v->data = p;
    v->valid = 1;
    v->no_cacheable = 0;
    v->not_found = 0;

    return NGX_OK;
}

static ngx_http_variable_t ngx_http_mymodule_vars[] = {

    /* useless variable — $mymod_timeout is always "60000" if the directive
     * says mymod_timeout 60s; no per-request information */
    { ngx_string("mymod_timeout"), NULL,
      ngx_http_mymodule_timeout_variable, 0, 0, 0 },

      ngx_http_null_variable
};
```

**Correct (exposing per-request runtime metrics that vary with each request):**

```c
static ngx_int_t
ngx_http_mymodule_response_time_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data)
{
    ngx_http_mymodule_ctx_t  *ctx;
    u_char                   *p;
    ngx_msec_int_t            ms;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL || ctx->start_time == 0) {
        v->not_found = 1;
        return NGX_OK;
    }

    /* per-request data: actual processing time varies with each request */
    ms = ngx_current_msec - ctx->start_time;

    p = ngx_pnalloc(r->pool, NGX_TIME_T_LEN + 4);
    if (p == NULL) {
        return NGX_ERROR;
    }

    v->len = ngx_sprintf(p, "%T.%03M", (time_t) ms / 1000, ms % 1000) - p;
    v->data = p;
    v->valid = 1;
    v->no_cacheable = 0;
    v->not_found = 0;

    return NGX_OK;
}

/* similar handler for $mymod_cache_status — returns HIT/MISS/BYPASS per request */

static ngx_http_variable_t ngx_http_mymodule_vars[] = {

    { ngx_string("mymod_response_time"), NULL,
      ngx_http_mymodule_response_time_variable, 0, 0, 0 },

    { ngx_string("mymod_cache_status"), NULL,
      ngx_http_mymodule_cache_status_variable, 0, 0, 0 },

      ngx_http_null_variable
};
```

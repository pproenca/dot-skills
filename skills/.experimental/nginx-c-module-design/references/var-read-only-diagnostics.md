---
title: Expose Read-Only Diagnostic Variables for Observability
impact: LOW-MEDIUM
impactDescription: "reduces debugging from hours to minutes via log_format and add_header"
tags: var, diagnostics, observability, read-only
---

## Expose Read-Only Diagnostic Variables for Observability

Expose key module metrics as read-only nginx variables for use in `log_format`, `add_header`, and `if` conditions. Pattern from nginx core: `$upstream_cache_status` (HIT/MISS/BYPASS/EXPIRED), `$upstream_response_time`, `$ssl_protocol`. These enable admins to build monitoring, alerting, and conditional logic without touching module code. Do not mark them `NGX_HTTP_VAR_CHANGEABLE` unless there is a specific reason to allow override via `set`.

**Incorrect (no diagnostic variables — admin must enable debug logging to understand module behavior):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;
    ngx_msec_t                     start;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    start = ngx_current_msec;

    /* ... process request ... */

    /* only way to see processing time is debug log level —
     * no way to include it in access_log, no way to set response
     * headers conditionally, no way to feed into monitoring */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymod: processed in %Mms", ngx_current_msec - start);

    return NGX_OK;
}

/* no variables registered — admin cannot:
 *   - log processing time in access_log
 *   - add X-MyMod-Status response header for debugging
 *   - use map/if to route based on module decisions
 *   - build Prometheus metrics from log parsing */
```

**Correct (read-only diagnostic variables enable monitoring without code changes):**

```c
static ngx_int_t
ngx_http_mymodule_status_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data)
{
    ngx_http_mymodule_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        v->not_found = 1;
        return NGX_OK;
    }

    v->data = ctx->status_str.data;
    v->len = ctx->status_str.len;
    v->valid = 1;
    v->no_cacheable = 0;
    v->not_found = 0;

    return NGX_OK;
}

/* similar handler for $mymod_processing_time — formats elapsed ms */

static ngx_http_variable_t ngx_http_mymodule_vars[] = {

    /* read-only: no NGX_HTTP_VAR_CHANGEABLE flag — cannot be
     * overwritten by "set" directive, preserving diagnostic integrity */
    { ngx_string("mymod_status"), NULL,
      ngx_http_mymodule_status_variable, 0, 0, 0 },

    { ngx_string("mymod_processing_time"), NULL,
      ngx_http_mymodule_processing_time_variable, 0, 0, 0 },

    { ngx_string("mymod_cache_hit"), NULL,
      ngx_http_mymodule_cache_hit_variable, 0, 0, 0 },

      ngx_http_null_variable
};

/* admin builds observability without touching module code:
 *
 *   log_format mymod '$remote_addr $mymod_status $mymod_processing_time';
 *   add_header X-MyMod-Status $mymod_status;
 *
 *   map $mymod_cache_hit $mymod_cache_counter {
 *       "HIT"  1;
 *       default 0;
 *   }
 */
```

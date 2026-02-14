---
title: Use Custom Handlers for Complex Directive Parsing
impact: MEDIUM
impactDescription: enables validated multi-value parsing and cross-field validation
tags: type, custom-handler, parsing, key-value
---

## Use Custom Handlers for Complex Directive Parsing

Built-in slot functions handle simple single-value directives. When a directive needs multiple arguments with different types, key=value syntax, cross-field validation, or conditional logic, use a custom `set` handler. The handler receives `cf->args` and can parse, validate, and set multiple config fields from a single directive -- keeping the admin-facing syntax clean while handling internal complexity.

**Incorrect (forcing a built-in slot for a directive with key=value pairs):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: str_slot can only store the first argument as a string —
     * "mymod_limit_req 100r/s burst=50" loses the burst parameter */
    { ngx_string("mymod_limit_req"),
      NGX_HTTP_LOC_CONF|NGX_CONF_1MORE,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, limit_req_str),
      NULL },

      ngx_null_command
};

/* the built-in slot silently stores only "100r/s",
 * burst=50 and nodelay are ignored with no error */
```

**Correct (custom handler parses positional and key=value arguments with validation):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* custom handler for: mymod_limit_req rate=100r/s burst=50 nodelay */
    { ngx_string("mymod_limit_req"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_1MORE,
      ngx_http_mymodule_limit_req,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

static char *
ngx_http_mymodule_limit_req(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_uint_t                     i;
    ngx_int_t                      rate, burst;

    value = cf->args->elts;
    rate = 0;
    burst = 0;
    mlcf->limit_nodelay = 0;

    for (i = 1; i < cf->args->nelts; i++) {

        if (ngx_strncmp(value[i].data, "rate=", 5) == 0) {
            rate = ngx_atoi(value[i].data + 5, value[i].len - 7);
            if (rate <= 0) {
                ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                                   "invalid rate \"%V\" in "
                                   "\"mymod_limit_req\" directive",
                                   &value[i]);
                return NGX_CONF_ERROR;
            }
            mlcf->limit_rate = rate;
            continue;
        }

        /* ... similar parsing for "burst=", "nodelay" ... */

        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid parameter \"%V\" in "
                           "\"mymod_limit_req\" directive", &value[i]);
        return NGX_CONF_ERROR;
    }

    /* cross-field validation — burst without rate makes no sense */
    if (mlcf->limit_rate == 0) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "\"mymod_limit_req\" requires \"rate\" parameter");
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}
```

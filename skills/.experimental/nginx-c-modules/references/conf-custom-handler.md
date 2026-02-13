---
title: Use Custom Handlers for Complex Directive Parsing
impact: MEDIUM
impactDescription: enables validation and multi-value directive parsing
tags: conf, handler, parsing, validation
---

## Use Custom Handlers for Complex Directive Parsing

Built-in slot functions like `ngx_conf_set_str_slot` and `ngx_conf_set_num_slot` handle simple single-value directives. When a directive needs multiple arguments, cross-field validation, or conditional logic, a custom `set` handler is required. Forcing a built-in slot for complex cases leads to silent data loss or parse failures.

**Incorrect (forcing built-in slot for a multi-value directive):**

```c
/* Directive: mymodule_rate_limit 100 burst=50 */
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymodule_rate_limit"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, rate),
      NULL },

    /* BUG: only reads first arg — "burst=50" is silently ignored
     * and NGX_CONF_TAKE1 rejects the second argument entirely */

    ngx_null_command
};
```

**Correct (custom handler parses and validates all arguments):**

```c
static char *
ngx_http_mymodule_rate_limit(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_int_t                      rate;

    value = cf->args->elts;

    rate = ngx_atoi(value[1].data, value[1].len);
    if (rate == NGX_ERROR || rate <= 0) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid rate \"%V\"", &value[1]);
        return NGX_CONF_ERROR;
    }

    mlcf->rate = rate;

    if (cf->args->nelts > 2
        && ngx_strncmp(value[2].data, "burst=", 6) == 0)
    {
        mlcf->burst = ngx_atoi(value[2].data + 6, value[2].len - 6);
        if (mlcf->burst == NGX_ERROR) {
            ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                               "invalid burst \"%V\"", &value[2]);
            return NGX_CONF_ERROR;
        }
    }

    return NGX_CONF_OK;
}
```

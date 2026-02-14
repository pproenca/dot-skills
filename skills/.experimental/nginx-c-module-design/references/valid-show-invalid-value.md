---
title: Include the Invalid Value in Error Messages
impact: MEDIUM
impactDescription: eliminates admin guessing about which value caused the error
tags: valid, error-message, diagnostics, ngx-conf-log-error
---

## Include the Invalid Value in Error Messages

Error messages from `ngx_conf_log_error` must include the actual invalid value using the `%V` format specifier for `ngx_str_t`. Nginx automatically adds the file path and line number, but only your handler knows which specific value was wrong. Without the value, the admin must guess which part of a multi-argument directive failed.

**Incorrect (error message hides the invalid value — admin must re-read the config and guess):**

```c
static char *
ngx_http_mymodule_set_timeout(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_msec_t                     ms;

    value = cf->args->elts;

    ms = ngx_parse_time(&value[1], 0);
    if (ms == (ngx_msec_t) NGX_ERROR) {
        /* BUG: says which directive failed but not which value —
         * if the line is "mymod_timeout abc", admin sees
         * "invalid value in mymod_timeout" and must open the file to check */
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid value in \"%V\" directive",
                           &cmd->name);
        return NGX_CONF_ERROR;
    }

    mlcf->timeout = ms;

    return NGX_CONF_OK;
}
```

**Correct (error message includes the bad value — admin knows exactly what to fix):**

```c
static char *
ngx_http_mymodule_set_timeout(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_msec_t                     ms;

    value = cf->args->elts;

    ms = ngx_parse_time(&value[1], 0);
    if (ms == (ngx_msec_t) NGX_ERROR) {
        /* includes the exact invalid value via %V — admin sees
         * 'invalid timeout value "abc" in "mymod_timeout" directive' */
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid timeout value \"%V\" in \"%V\" directive",
                           &value[1], &cmd->name);
        return NGX_CONF_ERROR;
    }

    mlcf->timeout = ms;

    return NGX_CONF_OK;
}
```

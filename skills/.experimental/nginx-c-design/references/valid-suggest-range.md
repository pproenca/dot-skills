---
title: Include Valid Range or Format in Error Messages
impact: MEDIUM
impactDescription: reduces admin debugging from minutes to seconds
tags: valid, error-message, range, format, usability
---

## Include Valid Range or Format in Error Messages

When rejecting a value, tell the admin what IS valid, not just what was wrong. Include the expected range, format, or list of valid options. The admin should be able to fix the error on the first attempt without consulting documentation.

**Incorrect (reports invalid value without indicating the valid range — admin must read docs):**

```c
static char *
ngx_http_mymodule_set_max_retries(ngx_conf_t *cf, ngx_command_t *cmd,
    void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_int_t                      n;

    value = cf->args->elts;

    n = ngx_atoi(value[1].data, value[1].len);
    if (n == NGX_ERROR || n < 0 || n > 100) {
        /* BUG: says value is invalid but not why or what is valid —
         * admin has no idea if 500 is too high, negative, or wrong type */
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid value \"%V\" in \"%V\" directive",
                           &value[1], &cmd->name);
        return NGX_CONF_ERROR;
    }

    mlcf->max_retries = (ngx_uint_t) n;

    return NGX_CONF_OK;
}
```

**Correct (error states the valid range — admin fixes it on the first attempt):**

```c
static char *
ngx_http_mymodule_set_max_retries(ngx_conf_t *cf, ngx_command_t *cmd,
    void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_int_t                      n;

    value = cf->args->elts;

    n = ngx_atoi(value[1].data, value[1].len);
    if (n == NGX_ERROR) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "\"%V\" directive requires a numeric value, "
                           "got \"%V\"",
                           &cmd->name, &value[1]);
        return NGX_CONF_ERROR;
    }

    if (n < 0 || n > 100) {
        /* includes the valid range and the actual value —
         * admin sees: 'mymod_max_retries must be between 0 and 100, got 500' */
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "\"%V\" must be between 0 and 100, got %i",
                           &cmd->name, n);
        return NGX_CONF_ERROR;
    }

    mlcf->max_retries = (ngx_uint_t) n;

    return NGX_CONF_OK;
}
```

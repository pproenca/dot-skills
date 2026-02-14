---
title: Validate All Directive Values at Config Parse Time
impact: MEDIUM
impactDescription: "prevents 100% of runtime config surprises by failing at nginx -t time"
tags: valid, parse-time, validation, set-handler
---

## Validate All Directive Values at Config Parse Time

Every directive value must be fully validated in the `set` handler or `merge` function, never deferred to request processing. The admin runs `nginx -t` to test config before reload — if validation happens at request time, bad config passes the test and breaks live traffic. Parse-time validation catches the problem before any request is served.

**Incorrect (stores raw string, validates on first request — bad config passes nginx -t):**

```c
static char *
ngx_http_mymodule_set_timeout(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;

    value = cf->args->elts;

    /* BUG: stores the raw string without validation — "nginx -t" succeeds
     * even if the value is "banana", failure happens on first request */
    mlcf->timeout_raw = value[1];

    return NGX_CONF_OK;
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;
    ngx_int_t                      ms;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* validation at request time — every request pays the cost,
     * and the first user to hit this location gets a 500 */
    ms = ngx_parse_time(&mlcf->timeout_raw, 0);
    if (ms == NGX_ERROR) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "invalid timeout value");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* ... */
    return NGX_OK;
}
```

**Correct (validates in set handler — bad config fails nginx -t before any reload):**

```c
static char *
ngx_http_mymodule_set_timeout(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_msec_t                     ms;

    value = cf->args->elts;

    /* validate immediately — admin sees the error during "nginx -t" */
    ms = ngx_parse_time(&value[1], 0);
    if (ms == (ngx_msec_t) NGX_ERROR) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid timeout value \"%V\" in \"%V\" directive",
                           &value[1], &cmd->name);
        return NGX_CONF_ERROR;
    }

    mlcf->timeout = ms;

    return NGX_CONF_OK;
}
```

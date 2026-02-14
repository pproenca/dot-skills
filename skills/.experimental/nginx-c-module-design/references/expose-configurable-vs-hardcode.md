---
title: Framework for Configurable vs Hardcoded Values
impact: CRITICAL
impactDescription: prevents admin workarounds and recompilation for deployment changes
tags: expose, configurable, hardcode, directives
---

## Framework for Configurable vs Hardcoded Values

Expose values that vary by deployment (timeouts, buffer sizes, paths, feature gates). Hardcode protocol constants, internal limits, and values with only one correct answer. The test: "Would a reasonable admin need a different value in staging vs production?"

**Incorrect (hardcoded timeout forces recompilation to change it):**

```c
/* compile-time constant — admin must rebuild the module for every change */
#define MYMOD_TIMEOUT  60000

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* timeout is baked in — staging wants 5s, production wants 60s,
     * neither can change it without recompiling */
    ngx_add_timer(r->connection->write, MYMOD_TIMEOUT);

    return NGX_OK;
}
```

**Correct (directive with UNSET init lets admins tune per-environment):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_timeout"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

      ngx_null_command
};

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* UNSET allows inheritance and merge with a sensible default */
    conf->timeout = NGX_CONF_UNSET_MSEC;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);

    return NGX_CONF_OK;
}
```

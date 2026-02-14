---
title: Expose Values That Vary by Deployment Environment
impact: MEDIUM-HIGH
impactDescription: enables single binary across all environments
tags: expose, environment, deployment, single-binary
---

## Expose Values That Vary by Deployment Environment

If a value changes between development, staging, and production (connection limits, timeouts, TLS settings, log levels, backend addresses), it must be a directive. The goal is one compiled module binary that works across all environments via config alone.

**Incorrect (compile-time ifdef creates different binaries per environment):**

```c
static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* BUG: must recompile for each environment — cannot use the
     * same binary in dev, staging, and production */
#ifdef DEBUG
    conf->connect_timeout = 30000;
    conf->verbose_errors = 1;
    conf->max_connections = 10;
#else
    conf->connect_timeout = 5000;
    conf->verbose_errors = 0;
    conf->max_connections = 1024;
#endif

    return conf;
}
```

**Correct (all environment-varying values are directives with safe defaults):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_connect_timeout"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connect_timeout),
      NULL },

    { ngx_string("mymod_verbose_errors"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, verbose_errors),
      NULL },

    { ngx_string("mymod_max_connections"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_SRV_CONF_OFFSET,
      offsetof(ngx_http_mymodule_srv_conf_t, max_connections),
      NULL },

      ngx_null_command
};

/* nginx.conf — same binary, different config per env:
 *
 *   # dev.conf
 *   mymod_connect_timeout 30s;
 *   mymod_verbose_errors on;
 *   mymod_max_connections 10;
 *
 *   # prod.conf
 *   mymod_connect_timeout 5s;
 *   mymod_verbose_errors off;
 *   mymod_max_connections 1024;
 */
```

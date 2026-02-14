---
title: Always Expose External Resource Paths
impact: HIGH
impactDescription: eliminates recompilation and enables deployment flexibility
tags: expose, paths, resources, deployment
---

## Always Expose External Resource Paths

File paths, socket paths, and external resource references MUST be directives, never hardcoded. Paths vary between environments (dev/staging/prod), containerized vs bare-metal, and different OS layouts. Following nginx pattern: `ssl_certificate`, `fastcgi_pass unix:/path`, `proxy_cache_path`.

**Incorrect (hardcoded paths force recompilation per environment):**

```c
#define MYMOD_CERT_PATH    "/etc/ssl/certs/mymodule.pem"
#define MYMOD_SOCKET_PATH  "/var/run/mymod/backend.sock"

static ngx_int_t
ngx_http_mymodule_init(ngx_conf_t *cf)
{
    /* containers mount certs at /certs, macOS uses /opt/homebrew,
     * CI uses /tmp — none of these work without recompiling */
    if (ngx_http_mymodule_load_cert(MYMOD_CERT_PATH) != NGX_OK) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "cannot load cert: %s", MYMOD_CERT_PATH);
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

**Correct (all external paths configurable via directives):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_certificate"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_SRV_CONF_OFFSET,
      offsetof(ngx_http_mymodule_srv_conf_t, certificate),
      NULL },

    { ngx_string("mymod_backend"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_set_backend,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

static char *
ngx_http_mymodule_merge_srv_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_srv_conf_t  *prev = parent;
    ngx_http_mymodule_srv_conf_t  *conf = child;

    /* no default — admin must explicitly set the cert path */
    ngx_conf_merge_str_value(conf->certificate, prev->certificate, "");

    if (conf->certificate.len == 0) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "\"mymod_certificate\" must be set");
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}
```

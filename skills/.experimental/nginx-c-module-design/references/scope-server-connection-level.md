---
title: Use http + server Scope for Connection-Level Settings
impact: HIGH
impactDescription: prevents misleading location-level SSL/connection directives that have no effect
tags: scope, connection, ssl, tls
---

## Use http + server Scope for Connection-Level Settings

Connection-level settings like SSL/TLS configuration happen before location matching. SSL is negotiated at connection time during the TLS handshake, not per-request — by the time nginx matches a location, the connection properties are already fixed. Allowing connection-level directives at location level is misleading because they silently have no effect, giving admins false confidence that different locations can use different TLS settings.

**Incorrect (SSL-related directive at location level — silently ignored):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: NGX_HTTP_LOC_CONF allows admins to write this inside
     * a location block, but the TLS handshake is already complete
     * before location matching — the directive has no effect */
    { ngx_string("mymod_tls_verify_depth"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, tls_verify_depth),
      NULL },

    { ngx_string("mymod_tls_protocols"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_1MORE,
      ngx_conf_set_bitmask_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, tls_protocols),
      &ngx_http_mymodule_tls_protocols },

      ngx_null_command
};
```

**Correct (connection-level directives restricted to http + server scope):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* http + server only — matches the connection lifecycle,
     * nginx rejects it inside location with a clear config error */
    { ngx_string("mymod_tls_verify_depth"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_SRV_CONF_OFFSET,
      offsetof(ngx_http_mymodule_srv_conf_t, tls_verify_depth),
      NULL },

    { ngx_string("mymod_tls_protocols"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_CONF_1MORE,
      ngx_conf_set_bitmask_slot,
      NGX_HTTP_SRV_CONF_OFFSET,
      offsetof(ngx_http_mymodule_srv_conf_t, tls_protocols),
      &ngx_http_mymodule_tls_protocols },

      ngx_null_command
};

static void *
ngx_http_mymodule_create_srv_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_srv_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_srv_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->tls_verify_depth = NGX_CONF_UNSET;
    conf->tls_protocols = 0;

    return conf;
}

static char *
ngx_http_mymodule_merge_srv_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_srv_conf_t  *prev = parent;
    ngx_http_mymodule_srv_conf_t  *conf = child;

    ngx_conf_merge_value(conf->tls_verify_depth, prev->tls_verify_depth, 1);
    ngx_conf_merge_bitmask_value(conf->tls_protocols, prev->tls_protocols,
                                 NGX_SSL_TLSv1_2|NGX_SSL_TLSv1_3);

    return NGX_CONF_OK;
}
```

---
title: Default to http + server + location Scope
impact: HIGH
impactDescription: enables per-vhost and per-path tuning that admins expect
tags: scope, directives, inheritance, configuration
---

## Default to http + server + location Scope

Most operational directives (timeouts, buffer sizes, feature flags) should be configurable at all three levels: `NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF`. This lets admins set a global default in `http {}`, override per virtual host in `server {}`, and fine-tune per URL path in `location {}`. Restricting scope unnecessarily forces admins to duplicate config or accept a single inflexible value across the entire server.

**Incorrect (directive only at http level — forces same value for all locations):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: NGX_HTTP_MAIN_CONF only — admin cannot override per-vhost
     * or per-path, every location gets the same timeout */
    { ngx_string("mymod_timeout"),
      NGX_HTTP_MAIN_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_MAIN_CONF_OFFSET,
      offsetof(ngx_http_mymodule_main_conf_t, timeout),
      NULL },

      ngx_null_command
};

static void *
ngx_http_mymodule_create_main_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_main_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_main_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->timeout = NGX_CONF_UNSET_MSEC;

    return conf;
}

/* no merge function — value is global, cannot vary by server or location */
```

**Correct (http + server + location with proper merge inheritance):**

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

    /* UNSET enables inheritance from parent levels */
    conf->timeout = NGX_CONF_UNSET_MSEC;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    /* inherits from http -> server -> location, falls back to 60s */
    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);

    return NGX_CONF_OK;
}
```

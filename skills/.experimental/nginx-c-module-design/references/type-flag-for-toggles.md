---
title: Use NGX_CONF_FLAG for Binary Toggles
impact: HIGH
impactDescription: "prevents config confusion — on/off is the only toggle syntax nginx admins expect"
tags: type, flag, toggle, on-off
---

## Use NGX_CONF_FLAG for Binary Toggles

When a directive is a binary toggle, use `NGX_CONF_FLAG` with `ngx_conf_set_flag_slot`. Nginx admins expect `on|off` syntax for feature switches. Name the directive as the feature noun (`mymod_buffering`, `ssl_stapling`), not `mymod_enable_buffering`. The flag pattern automatically rejects any value that is not `on` or `off`.

**Incorrect (string slot accepts arbitrary values and defers validation):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: TAKE1 with string slot — accepts "true", "yes", "1", anything */
    { ngx_string("mymod_buffering"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffering_str),
      NULL },

      ngx_null_command
};

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* must strcmp every request — "true"/"false"/"1"/"0" all need handling,
     * typos like "ture" silently treated as disabled */
    if (ngx_strcmp(mlcf->buffering_str.data, "true") == 0
        || ngx_strcmp(mlcf->buffering_str.data, "1") == 0)
    {
        return ngx_http_mymodule_buffered(r, mlcf);
    }

    return ngx_http_mymodule_unbuffered(r, mlcf);
}
```

**Correct (NGX_CONF_FLAG validates at parse time and stores an integer):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* on|off only — nginx rejects anything else at config-test time */
    { ngx_string("mymod_buffering"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffering),
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

    conf->buffering = NGX_CONF_UNSET;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    ngx_conf_merge_value(conf->buffering, prev->buffering, 1);

    return NGX_CONF_OK;
}
```

---
title: Ensure Zero-Config Produces Safe Behavior
impact: MEDIUM-HIGH
impactDescription: prevents broken deployments when admins rely on defaults
tags: default, zero-config, safety, initialization
---

## Ensure Zero-Config Produces Safe Behavior

A module loaded with no explicit directives must work safely. It may not be optimal, but it must not crash, corrupt data, or create security holes. Following the nginx pattern: `proxy_buffering on` (safe default), `sendfile off` (works everywhere, slower). The admin who just adds `load_module` should see correct behavior even if they haven't configured anything.

**Incorrect (NULL pointer dereference when no directives are configured):**

```c
typedef struct {
    ngx_str_t   upstream_host;
    ngx_uint_t  max_retries;
} ngx_http_mymodule_loc_conf_t;

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* BUG: upstream_host is {NULL, 0} from pcalloc, max_retries is 0 —
     * handler will dereference upstream_host.data and segfault */

    return conf;
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* CRASH: upstream_host.data is NULL when no directive was set */
    ngx_log_error(NGX_LOG_DEBUG, r->connection->log, 0,
                  "connecting to %V", &mlcf->upstream_host);

    return ngx_http_mymodule_connect(r, &mlcf->upstream_host);
}
```

**Correct (safe compiled-in defaults work without any explicit directives):**

```c
typedef struct {
    ngx_str_t   upstream_host;
    ngx_uint_t  max_retries;
    ngx_flag_t  enabled;
} ngx_http_mymodule_loc_conf_t;

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->max_retries = NGX_CONF_UNSET_UINT;
    conf->enabled = NGX_CONF_UNSET;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    ngx_conf_merge_str_value(conf->upstream_host, prev->upstream_host, "");
    ngx_conf_merge_uint_value(conf->max_retries, prev->max_retries, 1);
    ngx_conf_merge_value(conf->enabled, prev->enabled, 0);

    return NGX_CONF_OK;
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* module is inactive until explicitly enabled — safe no-op */
    if (!mlcf->enabled || mlcf->upstream_host.len == 0) {
        return NGX_DECLINED;
    }

    return ngx_http_mymodule_connect(r, &mlcf->upstream_host);
}
```

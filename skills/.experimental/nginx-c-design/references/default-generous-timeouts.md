---
title: Default Timeouts to Generous Values
impact: MEDIUM
impactDescription: prevents false failures in normal deployments
tags: default, timeout, generous, reliability
---

## Default Timeouts to Generous Values

Timeout defaults should be generous enough to avoid false failures in typical deployments. Pattern from nginx: most timeouts default to 60s (`proxy_connect_timeout`, `proxy_send_timeout`, `proxy_read_timeout`, `client_body_timeout`). This is slow for optimized setups but prevents timeout errors for admins who haven't tuned their config yet. Admins tighten timeouts; they should not have to relax them from overly aggressive defaults.

**Incorrect (5-second connect timeout causes failures for geographically distant upstreams):**

```c
typedef struct {
    ngx_msec_t  connect_timeout;
    ngx_msec_t  read_timeout;
    ngx_msec_t  send_timeout;
} ngx_http_mymodule_loc_conf_t;

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    /* BUG: 5s connect timeout — cross-region upstreams routinely take
     * 2-4s on cold connections, causing spurious 504s */
    ngx_conf_merge_msec_value(conf->connect_timeout,
                              prev->connect_timeout, 5000);

    /* BUG: 3s read timeout — large API responses from slow backends
     * trigger timeouts under normal load */
    ngx_conf_merge_msec_value(conf->read_timeout,
                              prev->read_timeout, 3000);

    /* BUG: 2s send timeout — clients on mobile connections
     * cannot receive data fast enough */
    ngx_conf_merge_msec_value(conf->send_timeout,
                              prev->send_timeout, 2000);

    return NGX_CONF_OK;
}
```

**Correct (60-second defaults match nginx core, letting admins tighten as needed):**

```c
typedef struct {
    ngx_msec_t  connect_timeout;
    ngx_msec_t  read_timeout;
    ngx_msec_t  send_timeout;
} ngx_http_mymodule_loc_conf_t;

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->connect_timeout = NGX_CONF_UNSET_MSEC;
    conf->read_timeout = NGX_CONF_UNSET_MSEC;
    conf->send_timeout = NGX_CONF_UNSET_MSEC;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    /* 60s — matches proxy_connect_timeout, works for all deployments */
    ngx_conf_merge_msec_value(conf->connect_timeout,
                              prev->connect_timeout, 60000);

    /* 60s — matches proxy_read_timeout, handles slow backends */
    ngx_conf_merge_msec_value(conf->read_timeout,
                              prev->read_timeout, 60000);

    /* 60s — matches proxy_send_timeout, tolerates slow clients */
    ngx_conf_merge_msec_value(conf->send_timeout,
                              prev->send_timeout, 60000);

    return NGX_CONF_OK;
}
```

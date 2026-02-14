---
title: Use Zero to Mean Unlimited or Disabled for Numeric Limits
impact: MEDIUM
impactDescription: "reduces config learning curve — 0 convention used by 20+ nginx core directives"
tags: default, zero, unlimited, convention
---

## Use Zero to Mean Unlimited or Disabled for Numeric Limits

When a directive controls a numeric limit (retries, rate, connections), use 0 to mean "unlimited" or "disabled." This is the universal nginx convention: `proxy_next_upstream_tries 0` (unlimited), `limit_rate 0` (no limit), `proxy_next_upstream_timeout 0` (no timeout). Do not use -1, MAX_INT, or other sentinel values.

**Incorrect (sentinel value -1 to mean unlimited, breaking nginx convention):**

```c
typedef struct {
    ngx_int_t   max_retries;
    ngx_int_t   rate_limit;
} ngx_http_mymodule_loc_conf_t;

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* BUG: using -1 for unlimited — no nginx directive does this,
     * admins will guess 0 and get "disabled" instead of "unlimited" */
    conf->max_retries = -1;
    conf->rate_limit = -1;

    return conf;
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* confusing: -1 means unlimited, 0 means disabled, positive means limit —
     * three-way semantics that no nginx admin expects */
    if (mlcf->max_retries == -1) {
        /* unlimited retries */
    } else if (mlcf->max_retries == 0) {
        /* no retries */
    } else {
        /* limited to max_retries */
    }

    return NGX_OK;
}
```

**Correct (0 means unlimited, matching nginx convention):**

```c
typedef struct {
    ngx_uint_t  max_retries;
    ngx_uint_t  rate_limit;
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
    conf->rate_limit = NGX_CONF_UNSET_UINT;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    /* 0 = unlimited retries, matches proxy_next_upstream_tries convention */
    ngx_conf_merge_uint_value(conf->max_retries, prev->max_retries, 0);

    /* 0 = no rate limit, matches limit_rate convention */
    ngx_conf_merge_uint_value(conf->rate_limit, prev->rate_limit, 0);

    return NGX_CONF_OK;
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* clean two-way semantics: 0 means unlimited, >0 means limited */
    if (mlcf->max_retries == 0 || attempt < mlcf->max_retries) {
        return ngx_http_mymodule_retry(r);
    }

    return NGX_HTTP_BAD_GATEWAY;
}
```

---
title: Initialize Config Fields with UNSET Constants
impact: HIGH
impactDescription: prevents broken config inheritance across server/location blocks
tags: conf, unset, initialization, merge
---

## Initialize Config Fields with UNSET Constants

nginx merges configuration from parent to child contexts (http -> server -> location). Fields initialized to `0` instead of `NGX_CONF_UNSET` cannot be distinguished from explicitly set values, so the merge step silently skips them and the parent value is never inherited.

**Incorrect (zero-init prevents inheritance from parent block):**

```c
static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* BUG: 0 looks like an explicitly set value to the merge step */
    conf->timeout = 0;
    conf->enable = 0;
    conf->max_retries = 0;

    return conf;
}
```

**Correct (UNSET constants allow merge to detect unset fields):**

```c
static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* UNSET tells merge_loc_conf these fields need parent values */
    conf->timeout = NGX_CONF_UNSET_MSEC;
    conf->enable = NGX_CONF_UNSET;
    conf->max_retries = NGX_CONF_UNSET_UINT;

    return conf;
}
```

**Note:** Use the type-appropriate constant: `NGX_CONF_UNSET` for `ngx_flag_t` and `ngx_int_t`, `NGX_CONF_UNSET_UINT` for `ngx_uint_t`, `NGX_CONF_UNSET_MSEC` for millisecond timers, `NGX_CONF_UNSET_SIZE` for `size_t`, and `NGX_CONF_UNSET_PTR` for pointers.

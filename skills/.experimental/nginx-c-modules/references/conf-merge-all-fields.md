---
title: Merge All Config Fields in merge_loc_conf
impact: HIGH
impactDescription: prevents uninitialized config values at runtime
tags: conf, merge, location, inheritance
---

## Merge All Config Fields in merge_loc_conf

Every field set to an UNSET constant in `create_loc_conf` must have a corresponding merge macro call in `merge_loc_conf`. Missing merges leave UNSET sentinel values (typically `-1`) at runtime, causing integer overflow in timeout calculations, unsigned wraparound in size comparisons, or unexpected logic branches.

**Incorrect (missing merge leaves UNSET value at runtime):**

```c
static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);
    ngx_conf_merge_value(conf->enable, prev->enable, 0);

    /* BUG: max_retries was set to NGX_CONF_UNSET_UINT in create_loc_conf
     * but has no merge here — stays as (ngx_uint_t) -1 at runtime */

    return NGX_CONF_OK;
}
```

**Correct (every UNSET field has a matching merge with a sensible default):**

```c
static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);
    ngx_conf_merge_value(conf->enable, prev->enable, 0);
    ngx_conf_merge_uint_value(conf->max_retries, prev->max_retries, 3);

    return NGX_CONF_OK;
}
```

**Note:** Match merge macros to UNSET types: `ngx_conf_merge_value` for `NGX_CONF_UNSET`, `ngx_conf_merge_uint_value` for `NGX_CONF_UNSET_UINT`, `ngx_conf_merge_msec_value` for `NGX_CONF_UNSET_MSEC`, `ngx_conf_merge_size_value` for `NGX_CONF_UNSET_SIZE`, and `ngx_conf_merge_ptr_value` for `NGX_CONF_UNSET_PTR`.

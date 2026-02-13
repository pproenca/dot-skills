---
title: Build Hash Tables During Configuration Only
impact: LOW-MEDIUM
impactDescription: prevents runtime crashes from hash table mutation
tags: ds, hash, readonly, configuration
---

## Build Hash Tables During Configuration Only

`ngx_hash_t` is an immutable open-addressing hash table. Once built with `ngx_hash_init`, its bucket array is fixed and cannot accept new keys. Attempting to add entries at runtime corrupts the hash or triggers segfaults. All keys must be collected during configuration parsing and inserted before the hash is initialized.

**Incorrect (attempts to add keys at request time):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *lcf;
    ngx_hash_key_t                 key;

    lcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* BUG: hash was already built in postconfiguration —
     * there is no API to add keys after ngx_hash_init.
     * ngx_hash_add_key operates on ngx_hash_keys_arrays_t during
     * configuration, not on the finalized ngx_hash_t at runtime */
    ngx_hash_add_key(&lcf->hosts_keys,
                     &r->headers_in.host->value,
                     (void *) 1,
                     NGX_HASH_READONLY_KEY);

    return NGX_OK;
}
```

**Correct (builds hash during config, uses ngx_hash_find at runtime):**

```c
/* during configuration: collect keys and build hash */
static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *conf = child;
    ngx_hash_init_t                hash;

    hash.hash = &conf->hosts_hash;
    hash.key = ngx_hash_key_lc;
    hash.max_size = 512;
    hash.bucket_size = 64;
    hash.name = "mymodule_hosts";
    hash.pool = cf->pool;

    /* all keys must be in conf->hosts_keys before this call */
    if (ngx_hash_init(&hash, conf->hosts_keys.elts,
                       conf->hosts_keys.nelts) != NGX_OK)
    {
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}

/* at runtime: read-only lookup */
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_loc_conf_t  *lcf;
    void                          *val;
    ngx_uint_t                     key;

    lcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    key = ngx_hash_key_lc(r->headers_in.host->value.data,
                          r->headers_in.host->value.len);

    val = ngx_hash_find(&lcf->hosts_hash, key,
                        r->headers_in.host->value.data,
                        r->headers_in.host->value.len);

    return (val != NULL) ? NGX_OK : NGX_DECLINED;
}
```

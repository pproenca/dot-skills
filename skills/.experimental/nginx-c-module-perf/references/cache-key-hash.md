---
title: Use ngx_hash for Fixed Cache Key Lookups
impact: MEDIUM
impactDescription: O(1) lookup vs O(n) linear scan for known key sets
tags: cache, hash, lookup, performance
---

## Use ngx_hash for Fixed Cache Key Lookups

When the set of cache keys is known at configuration time (e.g., a whitelist of cacheable URIs or upstream host names), a pre-built `ngx_hash_t` provides O(1) lookups. Iterating through an array or linked list to match keys at request time costs O(n) per request, which becomes a measurable bottleneck as the key set grows. Since `ngx_hash_t` is immutable after `ngx_hash_init`, build it during configuration and use `ngx_hash_find` for lock-free, read-only lookups at runtime.

**Incorrect (linear scan through array for cache key matching):**

```c
typedef struct {
    ngx_str_t    key;
    ngx_str_t    cached_value;
    time_t       expires;
} my_cache_kv_t;

typedef struct {
    my_cache_kv_t   *entries;
    ngx_uint_t       nentries;
} my_cache_loc_conf_t;

static ngx_str_t *
my_cache_find(ngx_http_request_t *r)
{
    my_cache_loc_conf_t  *lcf;
    ngx_uint_t            i;

    lcf = ngx_http_get_module_loc_conf(r, ngx_http_mycache_module);

    /* BAD: O(n) linear scan on every request — 500 entries = 500 comparisons */
    for (i = 0; i < lcf->nentries; i++) {
        if (lcf->entries[i].key.len == r->uri.len
            && ngx_strncmp(lcf->entries[i].key.data,
                           r->uri.data, r->uri.len) == 0)
        {
            if (lcf->entries[i].expires >= ngx_time()) {
                return &lcf->entries[i].cached_value;
            }
        }
    }

    return NULL;
}
```

**Correct (pre-built ngx_hash_t for O(1) lookup at request time):**

```c
typedef struct {
    ngx_str_t    cached_value;
    time_t       expires;
} my_cache_val_t;

typedef struct {
    ngx_hash_t   cache_hash;     /* built once during config merge */
} my_cache_loc_conf_t;

/* build hash table during configuration — called once */
static char *
ngx_http_mycache_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    my_cache_loc_conf_t  *conf = child;
    ngx_hash_init_t       hinit;
    ngx_array_t          *keys_array;

    /* keys_array populated by directive parsing (omitted for brevity) */
    keys_array = my_collect_cache_keys(cf, conf);
    if (keys_array == NULL) {
        return NGX_CONF_ERROR;
    }

    hinit.hash = &conf->cache_hash;
    hinit.key = ngx_hash_key_lc;
    hinit.max_size = 1024;
    hinit.bucket_size = ngx_align(64, ngx_cacheline_size);
    hinit.name = "mycache_keys";
    hinit.pool = cf->pool;
    hinit.temp_pool = cf->temp_pool;

    if (ngx_hash_init(&hinit,
                       (ngx_hash_key_t *) keys_array->elts,
                       keys_array->nelts) != NGX_OK)
    {
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}

/* O(1) lookup at request time — no locks needed, hash is immutable */
static ngx_str_t *
my_cache_find(ngx_http_request_t *r)
{
    my_cache_loc_conf_t  *lcf;
    my_cache_val_t       *val;
    ngx_uint_t            hash;

    lcf = ngx_http_get_module_loc_conf(r, ngx_http_mycache_module);

    hash = ngx_hash_key_lc(r->uri.data, r->uri.len);

    val = ngx_hash_find(&lcf->cache_hash, hash, r->uri.data, r->uri.len);

    if (val != NULL && val->expires >= ngx_time()) {
        return &val->cached_value;
    }

    return NULL;
}
```

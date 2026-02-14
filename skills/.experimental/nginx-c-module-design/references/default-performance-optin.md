---
title: Make Performance Features Opt-In
impact: MEDIUM-HIGH
impactDescription: prevents unexpected resource consumption and side effects
tags: default, performance, opt-in, resources
---

## Make Performance Features Opt-In

Features that consume additional resources (caching, shared memory, thread pools) or change behavior (buffering mode, compression) should be off by default and require explicit opt-in. Pattern from nginx: `proxy_cache off`, `gzip off`, `ssl_stapling off`. This ensures the module's resource footprint is zero until the admin explicitly enables features.

**Incorrect (cache enabled by default, allocating shared memory on module load):**

```c
typedef struct {
    ngx_shm_zone_t  *cache_zone;
    ngx_flag_t       cache_enabled;
    size_t           cache_size;
} ngx_http_mymodule_main_conf_t;

static void *
ngx_http_mymodule_create_main_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_main_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_main_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->cache_enabled = NGX_CONF_UNSET;
    conf->cache_size = NGX_CONF_UNSET_SIZE;

    return conf;
}

static char *
ngx_http_mymodule_init_main_conf(ngx_conf_t *cf, void *conf)
{
    ngx_http_mymodule_main_conf_t  *mmcf = conf;
    ngx_str_t                       name = ngx_string("mymod_cache");

    /* BUG: cache defaults to ON — allocates 32MB shared memory even when
     * nobody configured caching, wasting resources on every deployment */
    ngx_conf_init_value(mmcf->cache_enabled, 1);
    ngx_conf_init_size_value(mmcf->cache_size, 32 * 1024 * 1024);

    mmcf->cache_zone = ngx_shared_memory_add(cf, &name,
                                              mmcf->cache_size,
                                              &ngx_http_mymodule_module);
    if (mmcf->cache_zone == NULL) {
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}
```

**Correct (cache disabled by default, no resources allocated until admin sets `mymod_cache_zone`):**

```c
typedef struct {
    ngx_shm_zone_t  *cache_zone;
    size_t           cache_size;
} ngx_http_mymodule_main_conf_t;

static void *
ngx_http_mymodule_create_main_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_main_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_main_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    /* cache_zone is NULL from pcalloc — no resources until configured */

    return conf;
}

/* cache zone is only created when admin explicitly configures it:
 *     mymod_cache_zone zone=mymod:16m;
 */
static char *
ngx_http_mymodule_cache_zone(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_main_conf_t  *mmcf = conf;
    ngx_str_t                       name, s;
    ngx_uint_t                      i;

    for (i = 1; i < cf->args->nelts; i++) {
        /* parse zone=name:size arguments */
    }

    mmcf->cache_zone = ngx_shared_memory_add(cf, &name, mmcf->cache_size,
                                              &ngx_http_mymodule_module);
    if (mmcf->cache_zone == NULL) {
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_main_conf_t  *mmcf;

    mmcf = ngx_http_get_module_main_conf(r, ngx_http_mymodule_module);

    /* no cache zone configured — skip caching entirely, zero overhead */
    if (mmcf->cache_zone == NULL) {
        return ngx_http_mymodule_pass_through(r);
    }

    return ngx_http_mymodule_cached_response(r, mmcf->cache_zone);
}
```

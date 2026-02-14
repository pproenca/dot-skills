---
title: Restrict Shared Resource Directives to http Level Only
impact: HIGH
impactDescription: prevents duplicate shared memory zones and cache path conflicts
tags: scope, shared-memory, resources, cache
---

## Restrict Shared Resource Directives to http Level Only

Directives that allocate shared memory zones, cache paths, or process-wide data structures MUST be `NGX_HTTP_MAIN_CONF` only. These resources are allocated once at config parse time and shared across all workers — allowing them at server or location level would create duplicate allocations or conflicting definitions. Use a separate directive at location level to select which pre-allocated zone to use, following the pattern of `proxy_cache_path` (http only) and `proxy_cache` (location level).

**Incorrect (shared memory zone directive at location level — creates duplicate zones):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: allowing at LOC_CONF means each location block can try to
     * create its own shared memory zone with the same name, or admins
     * accidentally create many zones consuming excessive shared memory */
    { ngx_string("mymod_cache_zone"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE2,
      ngx_http_mymodule_cache_zone,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

static char *
ngx_http_mymodule_cache_zone(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_str_t   *value = cf->args->elts;

    /* each location creates its own zone — duplicates if name reused,
     * wastes shared memory if names differ */
    ngx_shared_memory_add(cf, &value[1], ngx_atosz(value[2].data, value[2].len),
                          &ngx_http_mymodule_module);

    return NGX_CONF_OK;
}
```

**Correct (zone creation at http only, zone selection at location level):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* define zone once at http level — allocated once, shared by all workers */
    { ngx_string("mymod_cache_zone"),
      NGX_HTTP_MAIN_CONF|NGX_CONF_TAKE2,
      ngx_http_mymodule_cache_zone,
      NGX_HTTP_MAIN_CONF_OFFSET,
      0,
      NULL },

    /* select which zone to use — this is safe at location level */
    { ngx_string("mymod_cache"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_cache,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

static char *
ngx_http_mymodule_cache_zone(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_main_conf_t  *mmcf = conf;
    ngx_str_t                      *value = cf->args->elts;
    ngx_shm_zone_t                 *shm_zone;

    /* single allocation at http level — no duplicates possible */
    shm_zone = ngx_shared_memory_add(cf, &value[1],
                                     ngx_atosz(value[2].data, value[2].len),
                                     &ngx_http_mymodule_module);
    if (shm_zone == NULL) {
        return NGX_CONF_ERROR;
    }

    shm_zone->init = ngx_http_mymodule_init_zone;

    return NGX_CONF_OK;
}

static char *
ngx_http_mymodule_cache(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value = cf->args->elts;

    /* location-level selection — just stores a reference to the zone */
    mlcf->cache_zone = ngx_shared_memory_add(cf, &value[1], 0,
                                              &ngx_http_mymodule_module);
    if (mlcf->cache_zone == NULL) {
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}
```

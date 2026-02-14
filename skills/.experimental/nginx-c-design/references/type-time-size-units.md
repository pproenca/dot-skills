---
title: Use Time and Size Slot Functions for Time and Size Values
impact: HIGH
impactDescription: enables admin-friendly units (60s, 8k, 1m) instead of raw numbers
tags: type, time, size, units, msec
---

## Use Time and Size Slot Functions for Time and Size Values

Always use `ngx_conf_set_msec_slot` for timeouts and `ngx_conf_set_size_slot` for buffer and limit sizes. Nginx admins expect to write `60s`, `5m`, `8k`, `1m` -- not `60000`, `300000`, `8192`, `1048576`. Using `ngx_conf_set_num_slot` for time or size values violates admin expectations and creates unit confusion that leads to outages.

**Incorrect (raw number slot forces admins to calculate milliseconds manually):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: num_slot — admin must write 60000 instead of 60s,
     * easy to confuse seconds vs milliseconds */
    { ngx_string("mymod_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    /* BUG: num_slot — admin must write 8192 instead of 8k,
     * is 1000 bytes or 1024? nobody knows */
    { ngx_string("mymod_buffer_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
      NULL },

      ngx_null_command
};

/* nginx.conf — what unit is 30000? milliseconds? microseconds? seconds? */
/* mymod_timeout 30000;    */
/* mymod_buffer_size 8192; */
```

**Correct (msec and size slots accept human-readable units):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* admin writes: mymod_timeout 30s; or mymod_timeout 2m; */
    { ngx_string("mymod_timeout"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    /* admin writes: mymod_buffer_size 8k; or mymod_buffer_size 1m; */
    { ngx_string("mymod_buffer_size"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
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

    conf->timeout = NGX_CONF_UNSET_MSEC;
    conf->buffer_size = NGX_CONF_UNSET_SIZE;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    ngx_conf_merge_msec_value(conf->timeout, prev->timeout, 60000);
    ngx_conf_merge_size_value(conf->buffer_size, prev->buffer_size, 8192);

    return NGX_CONF_OK;
}
```

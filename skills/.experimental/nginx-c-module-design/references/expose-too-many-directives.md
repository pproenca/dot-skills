---
title: Avoid Over-Configuration
impact: HIGH
impactDescription: "reduces merge paths from O(n) to O(1) per removed directive and cuts documentation surface by 5-10% per omitted knob"
tags: expose, over-configuration, simplicity, api-surface
---

## Avoid Over-Configuration

Not every internal constant needs a directive. If fewer than 1 in 100 deployments would change a value, hardcode it. The proxy module has ~60 directives for good reason, but most third-party modules should have 5-15. Each directive is a maintenance burden and documentation requirement.

**Incorrect (exposing internal tuning knobs no admin should touch):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_chain_link_count"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, chain_links),
      NULL },

    { ngx_string("mymod_hash_bucket_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, bucket_size),
      NULL },

    { ngx_string("mymod_retry_backoff_factor"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, backoff_factor),
      NULL },

    /* 20+ more internal tuning directives that no admin understands */

      ngx_null_command
};
```

**Correct (hardcode internals, expose only admin-meaningful controls):**

```c
/* internal constants — no directive needed */
#define MYMOD_CHAIN_LINKS       4
#define MYMOD_HASH_BUCKET_SIZE  64
#define MYMOD_RETRY_BACKOFF     2

static ngx_command_t ngx_http_mymodule_commands[] = {

    /* admins understand and need these */
    { ngx_string("mymod_timeout"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    { ngx_string("mymod_max_retries"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, max_retries),
      NULL },

    { ngx_string("mymod_buffer_size"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
      NULL },

      ngx_null_command
};
```

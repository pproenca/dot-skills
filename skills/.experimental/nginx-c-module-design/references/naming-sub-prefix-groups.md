---
title: Group Related Directives with Sub-Prefixes
impact: CRITICAL
impactDescription: "makes directives discoverable via tab-completion grouping"
tags: naming, sub-prefix, grouping, hierarchy
---

## Group Related Directives with Sub-Prefixes

When a module has 10+ directives, group related ones with sub-prefixes. The proxy module demonstrates this: `proxy_cache_*` (12+ directives), `proxy_ssl_*` (14+ directives), `proxy_cookie_*` (3 directives), `proxy_next_upstream*` (3 directives). This creates a scannable hierarchy in documentation and config files.

**Incorrect (flat namespace with no grouping — admin cannot scan related directives):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_cache"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_enable),
      NULL },

    /* BUG: no sub-prefix — looks unrelated to caching */
    { ngx_string("mymod_cache_ttl"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_sec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_ttl),
      NULL },

    /* BUG: "retry" instead of "next_upstream" — breaks nginx convention */
    { ngx_string("mymod_retry"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, retry),
      NULL },

    { ngx_string("mymod_retry_max"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, retry_max),
      NULL },

      ngx_null_command
};
```

**Correct (grouped sub-prefixes create scannable directive families):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* mymod_cache_* group — caching directives */
    { ngx_string("mymod_cache"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_cache,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    { ngx_string("mymod_cache_valid"),
      NGX_HTTP_LOC_CONF|NGX_CONF_1MORE,
      ngx_http_mymodule_cache_valid,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    { ngx_string("mymod_cache_key"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_cache_key,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    /* mymod_ssl_* group — upstream TLS directives */
    { ngx_string("mymod_ssl_certificate"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, ssl_certificate),
      NULL },

    { ngx_string("mymod_ssl_verify"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, ssl_verify),
      NULL },

      ngx_null_command
};
```

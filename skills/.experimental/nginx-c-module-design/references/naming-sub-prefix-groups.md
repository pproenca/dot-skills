---
title: Group Related Directives with Sub-Prefixes
impact: CRITICAL
impactDescription: "reduces directive lookup time from O(n) scanning to O(1) prefix matching in configs with 10+ directives"
tags: naming, sub-prefix, grouping, hierarchy
---

## Group Related Directives with Sub-Prefixes

When a module has 10+ directives, group related ones with sub-prefixes. The proxy module demonstrates this: `proxy_cache_*` (12+ directives), `proxy_ssl_*` (14+ directives), `proxy_cookie_*` (3 directives), `proxy_next_upstream*` (3 directives). This creates a scannable hierarchy in documentation and config files.

**Incorrect (flat namespace with no grouping — admin cannot scan related directives):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: "caching" is not a group prefix — the cache-related
     * directives below use different words for the same concept */
    { ngx_string("mymod_caching"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_enable),
      NULL },

    /* BUG: "ttl" shares no prefix with "caching" — admin must know
     * these are related despite having unrelated names */
    { ngx_string("mymod_ttl"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_sec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_ttl),
      NULL },

    /* BUG: "max_attempts" shares no prefix with other retry-related
     * directives — impossible to find by prefix scanning */
    { ngx_string("mymod_max_attempts"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, retry_max),
      NULL },

    /* BUG: "upstream_cert" uses a different pattern from "upstream_verify"
     * below — admin cannot find all TLS directives by prefix */
    { ngx_string("mymod_upstream_cert"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, ssl_certificate),
      NULL },

    { ngx_string("mymod_verify"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, ssl_verify),
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

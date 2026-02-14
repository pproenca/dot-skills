---
title: Prefer Noun Phrases for Directive Names
impact: HIGH
impactDescription: "reduces directive lookup time — 95% of nginx core directives use noun pattern"
tags: naming, noun, verb, convention
---

## Prefer Noun Phrases for Directive Names

Most nginx directives are noun phrases: `proxy_buffer_size`, `client_max_body_size`, `keepalive_timeout`. Verbs are reserved for action directives where the verb disambiguates the operation: `proxy_set_header`, `proxy_hide_header`, `proxy_pass_header`. Don't prefix nouns with verbs like `set_` or `enable_` when the noun alone is unambiguous.

**Incorrect (unnecessary verbs clutter directive names):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: "set_" is redundant — all directives set values */
    { ngx_string("mymod_set_buffer_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
      NULL },

    /* BUG: "enable_" is redundant — flags already imply on/off */
    { ngx_string("mymod_enable_cache"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache),
      NULL },

    /* BUG: "configure_" adds noise — every directive configures */
    { ngx_string("mymod_configure_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

      ngx_null_command
};
```

**Correct (clean noun phrases matching nginx core style):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_buffer_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
      NULL },

    /* on/off flag — noun is sufficient */
    { ngx_string("mymod_cache"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache),
      NULL },

    { ngx_string("mymod_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

      ngx_null_command
};
```

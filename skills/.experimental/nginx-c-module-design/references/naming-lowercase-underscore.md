---
title: Use Lowercase with Underscores Only
impact: HIGH
impactDescription: "prevents 100% of config-test failures from incorrect casing or delimiters"
tags: naming, lowercase, underscore, style
---

## Use Lowercase with Underscores Only

All nginx directives use `lowercase_with_underscores`. No camelCase, no hyphens, no UPPERCASE. This is non-negotiable. Violating this convention makes your module look like it doesn't belong in the nginx ecosystem and confuses config syntax highlighters.

**Incorrect (non-standard casing breaks config parsers and admin expectations):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: camelCase — nginx config is not JavaScript */
    { ngx_string("myMod_bufferSize"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
      NULL },

    /* BUG: hyphens — nginx uses underscores, not kebab-case */
    { ngx_string("mymod-timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    /* BUG: UPPERCASE — screaming case has no precedent in nginx */
    { ngx_string("MYMOD_CACHE"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache),
      NULL },

      ngx_null_command
};
```

**Correct (lowercase with underscores — the only accepted style):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_buffer_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
      NULL },

    { ngx_string("mymod_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    { ngx_string("mymod_cache"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache),
      NULL },

      ngx_null_command
};
```

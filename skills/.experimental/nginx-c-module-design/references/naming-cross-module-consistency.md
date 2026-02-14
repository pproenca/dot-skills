---
title: Mirror Nginx Core Suffix Patterns for Analogous Directives
impact: HIGH
impactDescription: enables instant comprehension by leveraging admin's existing nginx knowledge
tags: naming, suffix, consistency, cross-module
---

## Mirror Nginx Core Suffix Patterns for Analogous Directives

If your module does something analogous to an existing nginx module, use the same suffix pattern. The proxy/fastcgi/uwsgi/scgi modules demonstrate this: all use `_pass`, `_buffering`, `_connect_timeout`, `_cache`, `_next_upstream`. An admin who knows `proxy_*` immediately understands `mymod_*` if suffixes match.

**Incorrect (inventing new names for existing nginx concepts):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: "backend" instead of "pass" — nginx convention is _pass */
    { ngx_string("mymod_backend"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_pass,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    /* BUG: "retry_on_failure" — nginx uses _next_upstream */
    { ngx_string("mymod_retry_on_failure"),
      NGX_HTTP_LOC_CONF|NGX_CONF_1MORE,
      ngx_http_mymodule_next_upstream,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    /* BUG: "backend_timeout" — nginx uses _connect_timeout */
    { ngx_string("mymod_backend_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connect_timeout),
      NULL },

      ngx_null_command
};
```

**Correct (matching nginx suffix patterns for analogous functionality):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* matches proxy_pass, fastcgi_pass, uwsgi_pass */
    { ngx_string("mymod_pass"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_pass,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    /* matches proxy_next_upstream, fastcgi_next_upstream */
    { ngx_string("mymod_next_upstream"),
      NGX_HTTP_LOC_CONF|NGX_CONF_1MORE,
      ngx_http_mymodule_next_upstream,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    /* matches proxy_connect_timeout, fastcgi_connect_timeout */
    { ngx_string("mymod_connect_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connect_timeout),
      NULL },

    /* matches proxy_buffering, fastcgi_buffering */
    { ngx_string("mymod_buffering"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffering),
      NULL },

      ngx_null_command
};
```

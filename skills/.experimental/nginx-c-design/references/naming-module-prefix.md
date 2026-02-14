---
title: Use a Consistent Module Prefix for All Directives
impact: CRITICAL
impactDescription: prevents namespace collisions and makes directives instantly identifiable
tags: naming, prefix, namespace, directives
---

## Use a Consistent Module Prefix for All Directives

Every directive in your module MUST share the same short, clear prefix (e.g., `proxy_`, `ssl_`, `fastcgi_`). Core directives like `sendfile` have no prefix because they are foundational — your module is not foundational. The prefix acts as a namespace, preventing collisions with other modules and making your directives scannable in `nginx.conf`.

**Incorrect (mixed prefixes create ambiguity and risk collisions):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    /* BUG: different prefix — looks like a different module */
    { ngx_string("my_module_buffer_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
      NULL },

    /* BUG: reversed prefix — impossible to find by scanning */
    { ngx_string("timeout_mymod"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connect_timeout),
      NULL },

      ngx_null_command
};
```

**Correct (consistent prefix makes all directives scannable and collision-free):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    { ngx_string("mymod_buffer_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, buffer_size),
      NULL },

    { ngx_string("mymod_pass"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_pass,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};
```

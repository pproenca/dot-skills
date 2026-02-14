---
title: Do Not Support the if Context Unless Fully Tested
impact: MEDIUM-HIGH
impactDescription: prevents confusing partial-config bugs inside if blocks
tags: scope, if-context, inheritance, testing
---

## Do Not Support the if Context Unless Fully Tested

The nginx `if` directive creates a pseudo-location with its own configuration context. Directives inside `if` do NOT inherit from the parent location the way admins expect — the child context gets a fresh config that only merges from upper levels, not from the enclosing location. If your directive supports `NGX_HTTP_LIF_CONF`, an admin placing it inside `if` while putting other module directives in the parent `location` gets partial configuration, leading to subtle bugs. Either support `if` fully with extensive testing of every merge path, or omit the `if`-context flags entirely.

**Incorrect (adding NGX_HTTP_LIF_CONF without testing inheritance inside if blocks):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_header_filter"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF
      |NGX_HTTP_LIF_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, header_filter),
      NULL },

    { ngx_string("mymod_header_format"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF
      |NGX_HTTP_LIF_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, header_format),
      NULL },

      ngx_null_command
};

/*
 * BUG: admin writes this config, expecting format to inherit:
 *
 *   location /api {
 *       mymod_header_format "%t %s";     # set in parent location
 *
 *       if ($request_method = POST) {
 *           mymod_header_filter "x-post"; # set in if block
 *           # header_format is NOT inherited from parent location —
 *           # it gets the merge default, not "%t %s"
 *       }
 *   }
 */
```

**Correct (omitting if-context flags — nginx rejects directive inside if with a clear error):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* no NGX_HTTP_LIF_CONF — nginx will reject these inside if {} blocks
     * with: "mymod_header_filter directive is not allowed here" */
    { ngx_string("mymod_header_filter"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, header_filter),
      NULL },

    { ngx_string("mymod_header_format"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_str_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, header_format),
      NULL },

      ngx_null_command
};

/* admin sees a clear config-test error instead of a silent
 * partial-config bug — they can restructure with separate
 * locations instead of relying on if {} */
```

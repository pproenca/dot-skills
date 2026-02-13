---
title: Use Correct Context Flags for Directives
impact: HIGH
impactDescription: prevents directives appearing in wrong config blocks
tags: conf, directive, context, flags
---

## Use Correct Context Flags for Directives

Each directive declaration specifies which configuration contexts it is valid in via bitmask flags. Wrong flags allow a directive to appear in an unexpected block (e.g., only `http {}` when it should work per-location), or reject it from blocks where it is needed, leading to config parse errors or crashes when the handler reads from the wrong config level.

**Incorrect (main-only flag for a directive that should work per-location):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymodule_timeout"),
      NGX_HTTP_MAIN_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    /* BUG: NGX_HTTP_MAIN_CONF only — placing this directive inside
     * a server{} or location{} block causes a config parse error,
     * yet the slot reads from LOC_CONF_OFFSET */

    ngx_null_command
};
```

**Correct (flags match the intended config levels):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymodule_timeout"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    ngx_null_command
};
```

**Note:** Use `NGX_HTTP_LOC_CONF_OFFSET` with `NGX_HTTP_LOC_CONF` (and optionally parent levels for inheritance), `NGX_HTTP_SRV_CONF_OFFSET` with `NGX_HTTP_SRV_CONF`, and `NGX_HTTP_MAIN_CONF_OFFSET` with `NGX_HTTP_MAIN_CONF`. The offset level and context flags must agree.

---
title: Avoid Block Directives for Features
impact: MEDIUM-HIGH
impactDescription: prevents unnecessary config complexity and context inheritance confusion
tags: type, block, complexity, flat-directives
---

## Avoid Block Directives for Features

Block directives (`NGX_CONF_BLOCK`) create new configuration contexts. They are for structural elements like `server { }`, `location { }`, and `upstream { }` -- not for feature configuration. If you think you need a block, consider whether multi-argument directives or multiple related directives with a shared prefix would be cleaner. Block directives add context inheritance complexity, require their own create/merge functions, and confuse admins who expect feature config to be flat.

**Incorrect (block directive for feature config that could be flat):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: block directive for rate limiting config — creates a nested
     * context that needs its own create/merge, confuses inheritance */
    { ngx_string("mymod_rate_limit"),
      NGX_HTTP_LOC_CONF|NGX_CONF_BLOCK|NGX_CONF_NOARGS,
      ngx_http_mymodule_rate_limit_block,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

/* nginx.conf — unnecessary nesting for 3 simple values */
/*
 * location /api {
 *     mymod_rate_limit {
 *         rate 100;
 *         burst 50;
 *         delay nodelay;
 *     }
 * }
 */
```

**Correct (flat directives with sub-prefix grouping keep config simple):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* flat directives — no extra context, standard inheritance */
    { ngx_string("mymod_rate"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, rate),
      NULL },

    { ngx_string("mymod_rate_burst"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, rate_burst),
      NULL },

    { ngx_string("mymod_rate_nodelay"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, rate_nodelay),
      NULL },

      ngx_null_command
};

/* nginx.conf — flat, scannable, inherits naturally */
/*
 * location /api {
 *     mymod_rate 100;
 *     mymod_rate_burst 50;
 *     mymod_rate_nodelay on;
 * }
 */
```

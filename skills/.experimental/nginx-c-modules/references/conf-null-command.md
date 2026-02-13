---
title: Terminate Commands Array with ngx_null_command
impact: HIGH
impactDescription: prevents buffer overread during config parsing
tags: conf, commands, sentinel, safety
---

## Terminate Commands Array with ngx_null_command

nginx iterates the commands array sequentially until it finds a zero-filled sentinel entry. A missing `ngx_null_command` terminator causes the parser to read past the end of the array into adjacent memory, interpreting garbage as command definitions. This produces cryptic config errors or segfaults.

**Incorrect (missing sentinel — reads past array bounds):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymodule_enable"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, enable),
      NULL },

    { ngx_string("mymodule_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL }

    /* BUG: no ngx_null_command — parser reads past this array */
};
```

**Correct (sentinel terminates the array):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymodule_enable"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, enable),
      NULL },

    { ngx_string("mymodule_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, timeout),
      NULL },

    ngx_null_command
};
```

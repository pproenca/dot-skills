---
title: Use TAKE1/TAKE2/TAKE12 for Fixed Argument Counts
impact: HIGH
impactDescription: enables correct argument validation and optional parameter support
tags: type, take, arguments, fixed-count
---

## Use TAKE1/TAKE2/TAKE12 for Fixed Argument Counts

Use `NGX_CONF_TAKE1` for single-value directives, `NGX_CONF_TAKE2` for exactly two arguments (like `proxy_buffers 8 4k`), and `NGX_CONF_TAKE12` or `NGX_CONF_TAKE123` for optional second or third arguments (like `keepalive_timeout 75s` or `keepalive_timeout 75s 60s`). Never use `NGX_CONF_1MORE` when the argument count is actually fixed -- it prevents nginx from catching wrong argument counts at config-test time.

**Incorrect (1MORE accepts any argument count, including wrong ones):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: 1MORE allows "mymod_buffers 8" or "mymod_buffers 8 4k extra junk"
     * — both parse without error, handler must validate manually */
    { ngx_string("mymod_buffers"),
      NGX_HTTP_LOC_CONF|NGX_CONF_1MORE,
      ngx_http_mymodule_buffers,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

static char *
ngx_http_mymodule_buffers(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;

    value = cf->args->elts;

    /* must manually check argument count — should have been nginx's job */
    if (cf->args->nelts != 3) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid number of arguments in "
                           "\"mymod_buffers\" directive");
        return NGX_CONF_ERROR;
    }

    mlcf->bufs.num = ngx_atoi(value[1].data, value[1].len);
    mlcf->bufs.size = ngx_parse_size(&value[2]);

    return NGX_CONF_OK;
}
```

**Correct (TAKE2 enforces exactly two arguments at parse time):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* exactly 2 args: mymod_buffers <number> <size>
     * nginx rejects wrong argument count before handler runs */
    { ngx_string("mymod_buffers"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE2,
      ngx_http_mymodule_buffers,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    /* 1 or 2 args: mymod_keepalive <timeout> [header_timeout]
     * matches keepalive_timeout pattern — second arg is optional */
    { ngx_string("mymod_keepalive"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE12,
      ngx_http_mymodule_keepalive,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

static char *
ngx_http_mymodule_buffers(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;

    value = cf->args->elts;

    /* cf->args->nelts is guaranteed to be 3 (directive name + 2 args) */
    mlcf->bufs.num = ngx_atoi(value[1].data, value[1].len);
    if (mlcf->bufs.num == NGX_ERROR || mlcf->bufs.num == 0) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid number of buffers in "
                           "\"mymod_buffers\" directive");
        return NGX_CONF_ERROR;
    }

    mlcf->bufs.size = ngx_parse_size(&value[2]);
    if (mlcf->bufs.size == (size_t) NGX_ERROR || mlcf->bufs.size == 0) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid buffer size in "
                           "\"mymod_buffers\" directive");
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}
```

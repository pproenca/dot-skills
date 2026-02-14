---
title: Use 1MORE for Variable-Length Value Lists
impact: MEDIUM-HIGH
impactDescription: enables flexible multi-value directives like ssl_protocols and proxy_next_upstream
tags: type, 1more, list, bitmask
---

## Use 1MORE for Variable-Length Value Lists

When a directive accepts a variable-length list of values (like `ssl_protocols TLSv1.2 TLSv1.3` or `proxy_next_upstream error timeout http_502 http_503`), use `NGX_CONF_1MORE`. This accepts one or more arguments and delegates to a custom handler that iterates `cf->args`. Use this pattern for bitmask flags, protocol lists, and error condition lists where the admin selects a subset from a known set.

**Incorrect (separate directives for each value in the set):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: one directive per retry condition — verbose, hard to maintain,
     * admin must write 4 lines instead of 1 */
    { ngx_string("mymod_retry_on_error"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, retry_error),
      NULL },

    { ngx_string("mymod_retry_on_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, retry_timeout),
      NULL },

    { ngx_string("mymod_retry_on_500"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, retry_500),
      NULL },

    { ngx_string("mymod_retry_on_502"),
      NGX_HTTP_LOC_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, retry_502),
      NULL },

      ngx_null_command
};

/* nginx.conf — 4 lines for what should be 1 */
/* mymod_retry_on_error on;   */
/* mymod_retry_on_timeout on; */
/* mymod_retry_on_500 on;     */
/* mymod_retry_on_502 on;     */
```

**Correct (single directive with 1MORE accumulates a bitmask from all arguments):**

```c
#define NGX_HTTP_MYMOD_RETRY_ERROR    0x0002
#define NGX_HTTP_MYMOD_RETRY_TIMEOUT  0x0004
#define NGX_HTTP_MYMOD_RETRY_500      0x0008
#define NGX_HTTP_MYMOD_RETRY_502      0x0010
#define NGX_HTTP_MYMOD_RETRY_503      0x0020
#define NGX_HTTP_MYMOD_RETRY_504      0x0040
#define NGX_HTTP_MYMOD_RETRY_OFF      0x0001

static ngx_command_t ngx_http_mymodule_commands[] = {

    /* admin writes: mymod_retry error timeout http_502 http_503; */
    { ngx_string("mymod_retry"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_1MORE,
      ngx_http_mymodule_retry,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

static char *
ngx_http_mymodule_retry(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_uint_t                     i;

    value = cf->args->elts;

    for (i = 1; i < cf->args->nelts; i++) {

        if (ngx_strcmp(value[i].data, "off") == 0) {
            mlcf->retry_mask = NGX_HTTP_MYMOD_RETRY_OFF;
            return NGX_CONF_OK;
        }

        if (ngx_strcmp(value[i].data, "error") == 0) {
            mlcf->retry_mask |= NGX_HTTP_MYMOD_RETRY_ERROR;
            continue;
        }

        if (ngx_strcmp(value[i].data, "timeout") == 0) {
            mlcf->retry_mask |= NGX_HTTP_MYMOD_RETRY_TIMEOUT;
            continue;
        }

        /* ... similar for "http_500", "http_502", "http_503", "http_504" ... */

        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid retry condition \"%V\" in "
                           "\"mymod_retry\" directive", &value[i]);
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}
```

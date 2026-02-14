---
title: Keep Old Directive Name as an Alias
impact: LOW-MEDIUM
impactDescription: prevents config breakage during migration periods
tags: compat, alias, rename, backwards-compatibility
---

## Keep Old Directive Name as an Alias

When renaming a directive, register both the old and new names pointing to the same handler and config field offset. The old name triggers a deprecation warning but produces identical behavior. This allows gradual migration of automation, Ansible playbooks, and config management systems without emergency config rewrites. Pattern from nginx: `sticky_cookie_insert` was kept as an alias for `sticky cookie`.

**Incorrect (renaming a directive with no alias breaks all existing configs):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* v2.0: renamed from "mymod_max_conns" to "mymod_connection_limit"
     * with no alias — every existing config breaks on upgrade */
    { ngx_string("mymod_connection_limit"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connection_limit),
      NULL },

      ngx_null_command
};
```

**Correct (both old and new names registered, old one logs a deprecation warning):**

```c
static char *
ngx_http_mymodule_max_conns_deprecated(ngx_conf_t *cf, ngx_command_t *cmd,
    void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;

    ngx_conf_log_error(NGX_LOG_WARN, cf, 0,
                       "the \"mymod_max_conns\" directive is deprecated, "
                       "use \"mymod_connection_limit\" instead");

    value = cf->args->elts;

    mlcf->connection_limit = ngx_atoi(value[1].data, value[1].len);
    if (mlcf->connection_limit == NGX_ERROR) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid value \"%V\" in \"%V\" directive",
                           &value[1], &cmd->name);
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}

static ngx_command_t ngx_http_mymodule_commands[] = {

    /* new canonical name */
    { ngx_string("mymod_connection_limit"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connection_limit),
      NULL },

    /* old name kept as alias — same field, warns on use */
    { ngx_string("mymod_max_conns"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_max_conns_deprecated,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};
```

---
title: Maintain a Multi-Version Deprecation Window
impact: LOW-MEDIUM
impactDescription: prevents surprise breakage during routine upgrades
tags: compat, deprecation, versioning, lifecycle
---

## Maintain a Multi-Version Deprecation Window

Deprecated directives must continue working for at least 3 major versions (or 2+ years for time-based releases) before removal. Many nginx deployments run behind the latest version, and config management systems need time to update. Pattern: nginx kept `listen ... http2` working alongside the new `http2 on/off` directive for multiple versions before deprecating the old syntax.

**Incorrect (removing a directive in the very next release after deprecation):**

```c
/*
 * v2.0 changelog: "mymod_cache_size is deprecated, use mymod_cache_max"
 * v2.1 changelog: "mymod_cache_size has been removed"
 *
 * Admins upgrading from v1.x to v2.1 see:
 *   nginx: [emerg] unknown directive "mymod_cache_size"
 *   nginx: configuration file test failed
 */

static ngx_command_t ngx_http_mymodule_commands[] = {

    /* mymod_cache_size was removed in v2.1 — only one minor version
     * after deprecation, no time for admins to migrate */
    { ngx_string("mymod_cache_max"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_max),
      NULL },

      ngx_null_command
};
```

**Correct (deprecated directive maintained for 3+ versions with visible warning, then removed with a clear changelog entry):**

```c
/*
 * v2.0: mymod_cache_size deprecated — logs NGX_LOG_WARN, behavior unchanged
 * v3.0: mymod_cache_size still works — warning message updated to say
 *        "will be removed in v5.0"
 * v4.0: mymod_cache_size still works — warning says "removed in v5.0"
 * v5.0: mymod_cache_size removed — changelog entry with migration example
 */

static char *
ngx_http_mymodule_cache_size_deprecated(ngx_conf_t *cf, ngx_command_t *cmd,
    void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;

    ngx_conf_log_error(NGX_LOG_WARN, cf, 0,
                       "the \"mymod_cache_size\" directive is deprecated "
                       "and will be removed in v5.0, "
                       "use \"mymod_cache_max\" instead");

    value = cf->args->elts;

    mlcf->cache_max = ngx_parse_size(&value[1]);
    if (mlcf->cache_max == (size_t) NGX_ERROR) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid size \"%V\" in \"%V\" directive",
                           &value[1], &cmd->name);
        return NGX_CONF_ERROR;
    }

    return NGX_CONF_OK;
}

static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_cache_max"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_size_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, cache_max),
      NULL },

    /* kept for 3 major versions with removal date in warning */
    { ngx_string("mymod_cache_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_cache_size_deprecated,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};
```

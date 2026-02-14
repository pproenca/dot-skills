---
title: Log Warnings for Deprecated Directives Before Removal
impact: LOW-MEDIUM
impactDescription: "prevents config parse failures when directive names change during upgrades"
tags: compat, deprecation, warning, migration
---

## Log Warnings for Deprecated Directives Before Removal

When deprecating a directive, log a warning using `ngx_conf_log_error(NGX_LOG_WARN, ...)` but continue to honor the old directive's behavior. The admin sees the warning during `nginx -t` and reload, giving them time to update their config. Never remove a directive without a warning period — nginx deprecated `ssl on|off` in 1.15.0 (2018) and removed it in 1.25.1 (2023), a 5-year window.

**Incorrect (silently removing a directive causes config parse failures on upgrade):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* The old "mymod_backend" directive was removed entirely in v3.0 —
     * any existing config using it now fails with "unknown directive" */

    { ngx_string("mymod_upstream"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_set_upstream,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};
```

**Correct (logging a deprecation warning while still honoring the old directive):**

```c
static char *
ngx_http_mymodule_set_backend_deprecated(ngx_conf_t *cf, ngx_command_t *cmd,
    void *conf)
{
    ngx_conf_log_error(NGX_LOG_WARN, cf, 0,
                       "the \"mymod_backend\" directive is deprecated, "
                       "use \"mymod_upstream\" instead");

    /* delegate to the new handler — identical behavior */
    return ngx_http_mymodule_set_upstream(cf, cmd, conf);
}

static ngx_command_t ngx_http_mymodule_commands[] = {

    /* new canonical name */
    { ngx_string("mymod_upstream"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_set_upstream,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    /* deprecated alias — warns but still works */
    { ngx_string("mymod_backend"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_set_backend_deprecated,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};
```

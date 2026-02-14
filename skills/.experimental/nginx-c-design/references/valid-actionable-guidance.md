---
title: Provide Actionable Guidance in Error Messages
impact: MEDIUM
impactDescription: "reduces debugging time from minutes to seconds per config error"
tags: valid, error-message, guidance, usability
---

## Provide Actionable Guidance in Error Messages

Error messages should tell the admin HOW to fix the problem, not just state it. Include the expected format, required prefix, or correct syntax. Following nginx core pattern: "host not found in upstream" tells what's wrong; a good module adds what the correct format looks like so the admin can fix the config without searching documentation.

**Incorrect (states the problem without any hint about the expected format):**

```c
static char *
ngx_http_mymodule_set_backend(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_url_t                      u;

    value = cf->args->elts;

    ngx_memzero(&u, sizeof(ngx_url_t));
    u.url = value[1];
    u.no_resolve = 1;

    if (ngx_parse_url(cf->pool, &u) != NGX_OK) {
        /* BUG: admin sees "invalid URL in mymod_backend" but has no idea
         * whether the problem is a missing scheme, port, path, or something
         * else — must search docs or source code to figure out the format */
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid URL in \"%V\" directive",
                           &cmd->name);
        return NGX_CONF_ERROR;
    }

    mlcf->backend = u;

    return NGX_CONF_OK;
}
```

**Correct (error tells the admin exactly what format is required and how to fix it):**

```c
static char *
ngx_http_mymodule_set_backend(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_url_t                      u;

    value = cf->args->elts;

    /* check for required scheme prefix before parsing */
    if (ngx_strncasecmp(value[1].data, (u_char *) "http://", 7) != 0
        && ngx_strncasecmp(value[1].data, (u_char *) "https://", 8) != 0)
    {
        /* actionable message: shows what's wrong AND how to fix it —
         * admin sees: 'mymod_backend requires scheme prefix,
         * got "backend.local" — use "http://backend.local"' */
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "\"%V\" requires scheme prefix, got \"%V\" "
                           "— use \"http://%V\" or \"https://%V\"",
                           &cmd->name, &value[1], &value[1], &value[1]);
        return NGX_CONF_ERROR;
    }

    ngx_memzero(&u, sizeof(ngx_url_t));
    u.url = value[1];
    u.no_resolve = 1;

    if (ngx_parse_url(cf->pool, &u) != NGX_OK) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "\"%V\" has invalid URL \"%V\": %s",
                           &cmd->name, &value[1], u.err);
        return NGX_CONF_ERROR;
    }

    mlcf->backend = u;

    return NGX_CONF_OK;
}
```

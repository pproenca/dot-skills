---
title: Audit Security Implications of Every Exposed Directive
impact: CRITICAL
impactDescription: prevents configuration-induced vulnerabilities
tags: expose, security, validation, attack-surface
---

## Audit Security Implications of Every Exposed Directive

Every directive that accepts a path, URL, regex, or enables network access is a potential attack surface. Path directives enable traversal, regex directives enable ReDoS, URL directives enable SSRF. Validate at parse time, restrict what each directive can accept, and document security implications.

**Incorrect (arbitrary URL accepted without scheme validation):**

```c
static char *
ngx_http_mymodule_set_endpoint(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;

    value = cf->args->elts;

    /* BUG: accepts file:///etc/passwd, gopher://, or any scheme —
     * enables SSRF when module makes outbound requests */
    mlcf->endpoint = value[1];

    return NGX_CONF_OK;
}
```

**Correct (validate scheme and reject dangerous protocols at parse time):**

```c
static char *
ngx_http_mymodule_set_endpoint(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_mymodule_loc_conf_t  *mlcf = conf;
    ngx_str_t                     *value;
    ngx_url_t                      u;

    value = cf->args->elts;

    /* reject non-HTTP schemes at config parse time */
    if (ngx_strncasecmp(value[1].data, (u_char *) "http://", 7) != 0
        && ngx_strncasecmp(value[1].data, (u_char *) "https://", 8) != 0)
    {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "\"mymod_endpoint\" requires http:// or https:// "
                           "scheme, got \"%V\"", &value[1]);
        return NGX_CONF_ERROR;
    }

    /* strip scheme before ngx_parse_url — it expects host:port/path */
    ngx_memzero(&u, sizeof(ngx_url_t));

    if (ngx_strncasecmp(value[1].data, (u_char *) "https://", 8) == 0) {
        u.url.data = value[1].data + 8;
        u.url.len = value[1].len - 8;
    } else {
        u.url.data = value[1].data + 7;
        u.url.len = value[1].len - 7;
    }

    u.no_resolve = 1;

    if (ngx_parse_url(cf->pool, &u) != NGX_OK) {
        ngx_conf_log_error(NGX_LOG_EMERG, cf, 0,
                           "invalid URL in \"mymod_endpoint\": \"%V\"",
                           &value[1]);
        return NGX_CONF_ERROR;
    }

    mlcf->endpoint = value[1];

    return NGX_CONF_OK;
}
```

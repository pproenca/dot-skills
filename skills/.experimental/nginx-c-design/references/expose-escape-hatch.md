---
title: Provide Escape Hatches for Hardcoded Defaults
impact: CRITICAL
impactDescription: eliminates admin-blocking limitations without config complexity
tags: expose, escape-hatch, override, defaults
---

## Provide Escape Hatches for Hardcoded Defaults

When hardcoding defaults, provide an override directive. Pattern from proxy: default hidden headers are hardcoded, but `proxy_pass_header` overrides individual ones. `ssl_conf_command` is the ultimate escape hatch. Don't leave admins trapped by your decisions.

**Incorrect (hardcoded strip list with no way to override):**

```c
/* admin cannot pass X-Real-IP or X-Request-ID even when they need to */
static ngx_str_t  mymod_hidden_headers[] = {
    ngx_string("X-Real-IP"),
    ngx_string("X-Request-ID"),
    ngx_string("X-Internal-Trace"),
    ngx_null_string
};

static ngx_int_t
ngx_http_mymodule_filter_headers(ngx_http_request_t *r)
{
    ngx_uint_t  i;

    /* unconditionally strips headers — no config can change this */
    for (i = 0; mymod_hidden_headers[i].len; i++) {
        ngx_http_mymodule_remove_header(r, &mymod_hidden_headers[i]);
    }

    return NGX_OK;
}
```

**Correct (hardcoded defaults with per-header override directive):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* escape hatch: mymod_pass_header X-Real-IP; */
    { ngx_string("mymod_pass_header"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_pass_header,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

static ngx_int_t
ngx_http_mymodule_filter_headers(ngx_http_request_t *r)
{
    ngx_uint_t                     i;
    ngx_http_mymodule_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    for (i = 0; mymod_hidden_headers[i].len; i++) {
        /* skip headers the admin explicitly passed through */
        if (ngx_http_mymodule_is_passed(mlcf, &mymod_hidden_headers[i])) {
            continue;
        }
        ngx_http_mymodule_remove_header(r, &mymod_hidden_headers[i]);
    }

    return NGX_OK;
}
```

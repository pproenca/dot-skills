---
title: Register Custom Variables in preconfiguration
impact: MEDIUM
impactDescription: prevents 100% of $variable config references from resolving
tags: handler, variable, preconfiguration, registration
---

## Register Custom Variables in preconfiguration

Custom nginx variables (accessible as `$my_variable` in configuration) must be registered during the `preconfiguration` callback using `ngx_http_add_variable`. Registration in `postconfiguration` or later is too late — the variable hash has already been built and config parsing has already resolved variable references. A variable registered too late silently does not exist, causing config errors when referenced.

**Incorrect (registers variable in postconfiguration — too late):**

```c
static ngx_int_t
ngx_http_mymodule_postconfiguration(ngx_conf_t *cf)
{
    ngx_http_variable_t  *var;

    /* BUG: variable hash is built from preconfiguration registrations —
     * this variable will not be found during config parsing */
    var = ngx_http_add_variable(cf, &ngx_http_mymodule_var_name,
                                NGX_HTTP_VAR_NOCACHEABLE);
    if (var == NULL) {
        return NGX_ERROR;
    }

    var->get_handler = ngx_http_mymodule_var_handler;

    return NGX_OK;
}
```

**Correct (registers variable in preconfiguration with proper flags):**

```c
static ngx_str_t  ngx_http_mymodule_var_name =
    ngx_string("mymodule_request_id");

static ngx_int_t
ngx_http_mymodule_var_handler(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL || ctx->request_id.len == 0) {
        v->not_found = 1;
        return NGX_OK;
    }

    v->data = ctx->request_id.data;
    v->len = ctx->request_id.len;
    v->valid = 1;
    v->no_cacheable = 0;
    v->not_found = 0;

    return NGX_OK;
}

static ngx_int_t
ngx_http_mymodule_preconfiguration(ngx_conf_t *cf)
{
    ngx_http_variable_t  *var;

    var = ngx_http_add_variable(cf, &ngx_http_mymodule_var_name,
                                NGX_HTTP_VAR_NOCACHEABLE);
    if (var == NULL) {
        return NGX_ERROR;
    }

    var->get_handler = ngx_http_mymodule_var_handler;

    return NGX_OK;
}
```

**Note:** Use `NGX_HTTP_VAR_NOCACHEABLE` when the variable value changes per request (e.g., computed from request data). Use `NGX_HTTP_VAR_CHANGEABLE` if other modules should be allowed to redefine the variable. The `get_handler` is called lazily — only when the variable is actually referenced — so expensive computation is deferred until needed.

Reference: [nginx Development Guide — Variables](https://nginx.org/en/docs/dev/development_guide.html#http_variables)

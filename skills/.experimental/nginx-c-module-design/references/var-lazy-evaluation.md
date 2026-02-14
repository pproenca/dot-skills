---
title: Leverage Lazy Evaluation for Expensive Variables
impact: MEDIUM
impactDescription: "reduces per-request overhead to 0ns when variable is unreferenced in config"
tags: var, lazy, performance, get-handler
---

## Leverage Lazy Evaluation for Expensive Variables

Nginx variables are lazy-evaluated — the `get_handler` is called only when the variable is actually referenced in the config (`log_format`, `map`, `proxy_set_header`). This means expensive computation (regex matching, crypto operations, external lookups) has zero cost if the admin does not use the variable. Design variables with expensive computations knowing they will only execute when needed.

**Incorrect (computing all variable values eagerly in the request handler):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_ctx_t  *ctx;

    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (ctx == NULL) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    /* BUG: computing SHA-256 of request body on EVERY request,
     * even if no config references $mymod_body_hash */
    if (ngx_http_mymodule_compute_body_hash(r, &ctx->body_hash) != NGX_OK) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* BUG: running GeoIP lookup on EVERY request,
     * even if no config references $mymod_client_country */
    if (ngx_http_mymodule_geoip_lookup(r, &ctx->client_country) != NGX_OK) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* BUG: parsing and classifying user-agent on EVERY request,
     * even if no config references $mymod_device_type */
    ngx_http_mymodule_classify_device(r, &ctx->device_type);

    return NGX_DECLINED;
}
```

**Correct (get_handler computes the value on-demand only when referenced):**

```c
static ngx_int_t
ngx_http_mymodule_body_hash_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data)
{
    ngx_http_mymodule_ctx_t  *ctx;
    u_char                   *hash;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        v->not_found = 1;
        return NGX_OK;
    }

    /* computed only when $mymod_body_hash appears in config —
     * zero cost if the admin doesn't use this variable */
    if (ctx->body_hash.len == 0) {
        hash = ngx_pnalloc(r->pool, 64);
        if (hash == NULL) {
            return NGX_ERROR;
        }

        if (ngx_http_mymodule_sha256(r, hash) != NGX_OK) {
            return NGX_ERROR;
        }

        ctx->body_hash.data = hash;
        ctx->body_hash.len = 64;
    }

    v->len = ctx->body_hash.len;
    v->data = ctx->body_hash.data;
    v->valid = 1;
    v->no_cacheable = 0;
    v->not_found = 0;

    return NGX_OK;
}

static ngx_http_variable_t ngx_http_mymodule_vars[] = {

    /* get_handler fires only if config references $mymod_body_hash */
    { ngx_string("mymod_body_hash"), NULL,
      ngx_http_mymodule_body_hash_variable, 0, 0, 0 },

    /* get_handler fires only if config references $mymod_client_country */
    { ngx_string("mymod_client_country"), NULL,
      ngx_http_mymodule_country_variable, 0, 0, 0 },

    /* get_handler fires only if config references $mymod_device_type */
    { ngx_string("mymod_device_type"), NULL,
      ngx_http_mymodule_device_variable, 0, 0, 0 },

      ngx_http_null_variable
};
```

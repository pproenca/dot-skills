---
title: Use Dynamic Prefix Variables for Key-Value Data
impact: MEDIUM
impactDescription: enables access to arbitrary keys without pre-registering variables
tags: var, prefix, dynamic, key-value
---

## Use Dynamic Prefix Variables for Key-Value Data

When your module handles key-value data (headers, metadata, tags), use the dynamic prefix pattern: `$mymod_meta_<name>` where `<name>` is user-supplied at config time. Pattern from nginx core: `$http_<name>` (request headers), `$upstream_http_<name>` (upstream response headers), `$cookie_<name>`, `$arg_<name>`. Register a prefix variable handler that looks up the suffix dynamically at runtime.

**Incorrect (pre-registering individual variables for each possible key):**

```c
static ngx_http_variable_t ngx_http_mymodule_vars[] = {

    /* BUG: cannot anticipate every metadata key the backend sends —
     * adding a new key requires code change and recompilation */
    { ngx_string("mymod_meta_request_id"), NULL,
      ngx_http_mymodule_meta_request_id, 0, 0, 0 },

    { ngx_string("mymod_meta_trace_id"), NULL,
      ngx_http_mymodule_meta_trace_id, 0, 0, 0 },

    { ngx_string("mymod_meta_region"), NULL,
      ngx_http_mymodule_meta_region, 0, 0, 0 },

    /* every new key = new handler function + recompile + reload */

      ngx_http_null_variable
};
```

**Correct (single prefix handler resolves any $mymod_meta_<key> dynamically):**

```c
static ngx_int_t
ngx_http_mymodule_meta_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data)
{
    ngx_str_t                *name = (ngx_str_t *) data;
    ngx_http_mymodule_ctx_t  *ctx;
    ngx_str_t                 key, value;
    ngx_uint_t                i;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL || ctx->metadata == NULL) {
        v->not_found = 1;
        return NGX_OK;
    }

    /* extract the suffix after "mymod_meta_" to use as lookup key */
    key.len = name->len - (sizeof("mymod_meta_") - 1);
    key.data = name->data + (sizeof("mymod_meta_") - 1);

    /* convert underscores to dashes to match header convention,
     * then look up the key in module metadata */
    if (ngx_http_mymodule_lookup_meta(ctx->metadata, &key, &value) == NGX_OK) {
        v->len = value.len;
        v->data = value.data;
        v->valid = 1;
        v->no_cacheable = 0;
        v->not_found = 0;
    } else {
        v->not_found = 1;
    }

    return NGX_OK;
}

static ngx_int_t
ngx_http_mymodule_add_variables(ngx_conf_t *cf)
{
    ngx_http_variable_t  *var;

    static ngx_str_t  prefix = ngx_string("mymod_meta_");

    /* register prefix — nginx calls our handler for any $mymod_meta_<key>,
     * setting data = &v[i].name during init so the handler receives
     * the full variable name via the data parameter */
    var = ngx_http_add_variable(cf, &prefix, NGX_HTTP_VAR_PREFIX);
    if (var == NULL) {
        return NGX_ERROR;
    }

    var->get_handler = ngx_http_mymodule_meta_variable;

    return NGX_OK;
}

/* admin can now use any key without module changes:
 *
 *   proxy_set_header X-Request-ID $mymod_meta_request_id;
 *   log_format meta '$mymod_meta_trace_id $mymod_meta_region';
 */
```

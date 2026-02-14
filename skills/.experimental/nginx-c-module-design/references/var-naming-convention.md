---
title: Name Variables with Module Prefix and Descriptive Suffix
impact: MEDIUM
impactDescription: prevents namespace collisions and makes variables self-documenting
tags: var, naming, prefix, namespace
---

## Name Variables with Module Prefix and Descriptive Suffix

Variable names follow the pattern `$<module_prefix>_<descriptive_name>`. Pattern from nginx core: `$upstream_addr`, `$upstream_response_time`, `$ssl_client_s_dn`, `$proxy_host`. The module prefix prevents collisions with other modules and nginx core variables. The descriptive suffix makes the variable self-documenting in `log_format` and `map` blocks.

**Incorrect (generic names collide with other modules, cryptic abbreviations are unreadable):**

```c
static ngx_http_variable_t ngx_http_mymodule_vars[] = {

    /* BUG: "response_time" has no module prefix — collides with
     * upstream, any other module, or future nginx core variables */
    { ngx_string("response_time"), NULL,
      ngx_http_mymodule_response_time_variable, 0, 0, 0 },

    /* BUG: "mt" is a cryptic abbreviation — admin reading
     * log_format "$mt" has no idea what module this belongs to */
    { ngx_string("mt"), NULL,
      ngx_http_mymodule_type_variable, 0, 0, 0 },

    /* BUG: "cs" means nothing without context — cache_status?
     * connection_state? content_size? */
    { ngx_string("cs"), NULL,
      ngx_http_mymodule_cache_status_variable, 0, 0, 0 },

      ngx_http_null_variable
};
```

**Correct (module prefix prevents collisions, descriptive suffix is self-documenting):**

```c
static ngx_http_variable_t ngx_http_mymodule_vars[] = {

    /* $mymod_response_time — clear module ownership, describes the value */
    { ngx_string("mymod_response_time"), NULL,
      ngx_http_mymodule_response_time_variable, 0, 0, 0 },

    /* $mymod_cache_status — instantly scannable in log_format lines */
    { ngx_string("mymod_cache_status"), NULL,
      ngx_http_mymodule_cache_status_variable, 0, 0, 0 },

    /* $mymod_backend_addr — follows upstream_addr pattern, module-scoped */
    { ngx_string("mymod_backend_addr"), NULL,
      ngx_http_mymodule_backend_addr_variable, 0, 0, 0 },

      ngx_http_null_variable
};

/* usage in nginx.conf is immediately clear:
 *
 *   log_format mymod '$remote_addr - $mymod_cache_status '
 *                     '$mymod_response_time $mymod_backend_addr';
 */
```

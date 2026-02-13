---
title: Use ngx_string Macro Only with String Literals
impact: MEDIUM
impactDescription: prevents incorrect string length calculation
tags: ds, string, macro, initialization
---

## Use ngx_string Macro Only with String Literals

The `ngx_string()` macro uses `sizeof() - 1` at compile time to compute the string length. This only works with string literals where `sizeof` returns the array size. When used with a `char *` variable, `sizeof` returns the pointer size (4 or 8 bytes), producing a completely wrong length that causes truncated reads or buffer overflows.

**Incorrect (ngx_string with pointer variable computes wrong length):**

```c
static ngx_int_t
ngx_http_mymodule_set_header(ngx_http_request_t *r, char *name)
{
    ngx_str_t  header_name;

    /* BUG: sizeof(name) = sizeof(char*) = 8 on 64-bit
     * so header_name.len = 7, regardless of actual string length */
    header_name = ngx_string(name);

    /* if name is "X-Request-ID" (12 chars), len is 7 — truncated */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "header: %V", &header_name);

    return NGX_OK;
}
```

**Correct (ngx_string for literals, manual assignment for variables):**

```c
static ngx_int_t
ngx_http_mymodule_set_header(ngx_http_request_t *r, char *name)
{
    ngx_str_t  header_name;

    /* for variables: manually set data and compute length at runtime */
    header_name.data = (u_char *) name;
    header_name.len = ngx_strlen(name);

    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "header: %V", &header_name);

    return NGX_OK;
}

/* ngx_string is safe only with compile-time string literals */
static ngx_str_t  default_type = ngx_string("application/octet-stream");
static ngx_str_t  module_name = ngx_string("mymodule");
```

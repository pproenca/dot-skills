---
title: Never Assume ngx_str_t Is Null-Terminated
impact: MEDIUM
impactDescription: prevents buffer overreads and undefined behavior
tags: ds, string, null-termination, safety
---

## Never Assume ngx_str_t Is Null-Terminated

`ngx_str_t` stores a `{len, data}` pair without a null terminator. Passing `str.data` to standard C functions that expect null-terminated strings (`printf %s`, `strcmp`, `atoi`) reads past the buffer boundary, causing incorrect comparisons, garbled output, or segfaults.

**Incorrect (passes ngx_str_t data to C string functions):**

```c
static ngx_int_t
ngx_http_mymodule_check_method(ngx_http_request_t *r)
{
    /* BUG: %s reads until \0 — ngx_str_t has no terminator */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "method: %s", r->method_name.data);

    /* BUG: strcmp reads past buffer — undefined behavior */
    if (strcmp((char *) r->method_name.data, "POST") == 0) {
        return NGX_OK;
    }

    /* BUG: atoi reads unterminated string */
    int val = atoi((char *) r->args.data);

    return NGX_DECLINED;
}
```

**Correct (uses length-aware functions and format specifiers):**

```c
static ngx_int_t
ngx_http_mymodule_check_method(ngx_http_request_t *r)
{
    /* %V is nginx's format specifier for ngx_str_t pointers */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "method: %V", &r->method_name);

    /* ngx_strncmp respects the string length */
    if (r->method_name.len == 4
        && ngx_strncmp(r->method_name.data, "POST", 4) == 0)
    {
        return NGX_OK;
    }

    /* ngx_atoi takes explicit length parameter */
    ngx_int_t val = ngx_atoi(r->args.data, r->args.len);

    return NGX_DECLINED;
}
```

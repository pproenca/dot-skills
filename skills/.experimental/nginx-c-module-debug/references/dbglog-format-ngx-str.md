---
title: Format ngx_str_t Correctly in Debug Log Messages
impact: MEDIUM-HIGH
impactDescription: prevents truncated or garbage output — %V handles non-NUL-terminated ngx_str_t correctly
tags: dbglog, ngx-str, format, logging
---

## Format ngx_str_t Correctly in Debug Log Messages

`ngx_str_t` strings are NOT null-terminated. They consist of a `.data` pointer and a `.len` field. Using `%s` to log them reads past the buffer into uninitialized memory, producing garbage output, truncated strings, or crashes. Use `%V` for `ngx_str_t *` (reads `.len` bytes from `.data`). For raw `u_char *` buffers with a known length, use `%*s` with the length as the preceding argument. Incorrect format specifiers in debug logging create misleading output that sends you down the wrong debugging path.

**Incorrect (using %s with ngx_str_t data, reading past the buffer boundary):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_str_t                  token;
    ngx_http_mymodule_conf_t  *conf;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* BAD: %s expects a null-terminated C string.
     * r->uri.data is NOT null-terminated — %s reads past .len
     * into adjacent memory (next header, pool metadata, etc.)
     * producing garbage appended to the real URI. */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: request uri: %s", r->uri.data);

    /* BAD: same problem with header values */
    if (ngx_http_arg(r, (u_char *) "token", 5, &token) == NGX_OK) {
        /* token.data points into the query string buffer,
         * not null-terminated. %s reads garbage after the value. */
        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "mymodule: token param: %s", token.data);
    }

    /* BAD: %s with method name — method_name is ngx_str_t */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: method: %s", r->method_name.data);

    return NGX_DECLINED;
}
```

**Correct (using %V for ngx_str_t and %*s for u_char* with length):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_str_t                  token;
    u_char                    *raw_data;
    size_t                     raw_len;
    ngx_http_mymodule_conf_t  *conf;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* %V takes a pointer to ngx_str_t and reads exactly .len bytes.
     * Pass the ADDRESS of the ngx_str_t, not .data */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: request uri: %V", &r->uri);

    /* %V works for all ngx_str_t: headers, args, method, etc. */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: method: %V", &r->method_name);

    /* For extracted args, %V works the same way */
    if (ngx_http_arg(r, (u_char *) "token", 5, &token) == NGX_OK) {
        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "mymodule: token param: %V", &token);
    }

    /* For raw u_char* with known length, use %*s.
     * The length argument comes BEFORE the pointer. */
    raw_data = r->header_in->pos;
    raw_len = r->header_in->last - r->header_in->pos;
    if (raw_len > 64) {
        raw_len = 64;  /* truncate for readability */
    }

    ngx_log_debug3(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: raw input (%uz bytes): \"%*s\"",
                   raw_len, raw_len, raw_data);

    return NGX_DECLINED;
}
```

Reference: [nginx Development Guide — Logging](https://nginx.org/en/docs/dev/development_guide.html#logging)

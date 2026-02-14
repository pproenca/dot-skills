---
title: Set Log Action String for Operation Context
impact: LOW
impactDescription: 0ns overhead — single pointer assignment adds automatic context to all error messages
tags: log, action, context, debugging
---

## Set Log Action String for Operation Context

When nginx logs an error, it automatically appends the string pointed to by `log->action` to the message (e.g., "while connecting to upstream"). Without setting this field, error messages lack operational context, forcing developers to grep through code to determine which phase produced the log entry. Setting `log->action` before each distinct operation costs only a pointer assignment at runtime but makes every subsequent error message self-documenting.

**Incorrect (generic log messages without operation context):**

```c
static ngx_int_t
ngx_http_mymodule_process(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    rc = ngx_http_mymodule_validate_headers(r);
    if (rc != NGX_OK) {
        /* produces: "header validation failed" — but which phase? */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "header validation failed");
        return rc;
    }

    rc = ngx_http_mymodule_transform_body(r);
    if (rc != NGX_OK) {
        /* produces: "body transformation error" — no automatic context */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "body transformation error");
        return rc;
    }

    rc = ngx_http_mymodule_send_upstream(r);
    if (rc != NGX_OK) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "upstream send failed");
        return rc;
    }

    return NGX_OK;
}
```

**Correct (sets log->action before each operation for automatic context in errors):**

```c
static ngx_int_t
ngx_http_mymodule_process(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    /* pointer assignment only — negligible cost */
    r->connection->log->action = "validating request headers in mymodule";

    rc = ngx_http_mymodule_validate_headers(r);
    if (rc != NGX_OK) {
        /* produces: "header validation failed while validating
         * request headers in mymodule" */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "header validation failed");
        return rc;
    }

    r->connection->log->action = "transforming response body in mymodule";

    rc = ngx_http_mymodule_transform_body(r);
    if (rc != NGX_OK) {
        /* produces: "body transformation error while transforming
         * response body in mymodule" */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "body transformation error");
        return rc;
    }

    r->connection->log->action = "sending request to upstream in mymodule";

    rc = ngx_http_mymodule_send_upstream(r);
    if (rc != NGX_OK) {
        /* any error inside send_upstream also gets this context
         * automatically, even from nginx core functions */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "upstream send failed");
        return rc;
    }

    return NGX_OK;
}
```

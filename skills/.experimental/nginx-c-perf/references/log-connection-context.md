---
title: Attach Module Context to Connection Log for Tracing
impact: LOW-MEDIUM
impactDescription: enables request correlation across log entries without per-call overhead
tags: log, context, tracing, handler
---

## Attach Module Context to Connection Log for Tracing

When a module needs to include contextual information (request ID, upstream name, session token) in every log entry, formatting it manually in each `ngx_log_error` call duplicates work and bloats the code. Instead, set `log->handler` to a custom callback and `log->data` to your context structure once during request initialization. Nginx automatically invokes the handler to append context to every log line produced through that log object, giving you consistent tracing with zero per-call formatting overhead.

**Incorrect (manually formats request ID into every log call):**

```c
static ngx_int_t
ngx_http_trace_handler(ngx_http_request_t *r)
{
    ngx_str_t   request_id;
    ngx_int_t   rc;

    request_id = get_request_id(r);

    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "[req_id=%V] starting upstream connection", &request_id);

    rc = connect_upstream(r);
    if (rc == NGX_ERROR) {
        /* BAD: must repeat the request_id formatting in every log call */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "[req_id=%V] upstream connection failed", &request_id);
        return NGX_HTTP_BAD_GATEWAY;
    }

    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "[req_id=%V] upstream connected successfully", &request_id);

    return NGX_OK;
}
```

**Correct (sets log->handler and log->data once for automatic context injection):**

```c
typedef struct {
    ngx_str_t     request_id;
    ngx_log_t    *original_log;
} ngx_http_trace_log_ctx_t;

static u_char *
ngx_http_trace_log_handler(ngx_log_t *log, u_char *buf, size_t len)
{
    ngx_http_trace_log_ctx_t  *ctx;

    ctx = log->data;

    /* nginx calls this automatically for every log entry */
    return ngx_snprintf(buf, len, " req_id=%V", &ctx->request_id);
}

static ngx_int_t
ngx_http_trace_handler(ngx_http_request_t *r)
{
    ngx_http_trace_log_ctx_t  *ctx;
    ngx_int_t                  rc;

    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_trace_log_ctx_t));
    if (ctx == NULL) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    ctx->request_id = get_request_id(r);
    ctx->original_log = r->connection->log;

    /* attach once — all subsequent log calls include the request ID */
    r->connection->log->handler = ngx_http_trace_log_handler;
    r->connection->log->data = ctx;

    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "starting upstream connection");

    rc = connect_upstream(r);
    if (rc == NGX_ERROR) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "upstream connection failed");
        return NGX_HTTP_BAD_GATEWAY;
    }

    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "upstream connected successfully");

    return NGX_OK;
}
```

---
title: Set Log Action String for Context in Error Messages
impact: MEDIUM-HIGH
impactDescription: adds operation context to every log line — reduces log correlation time from minutes to seconds
tags: dbglog, action, log-handler, context
---

## Set Log Action String for Context in Error Messages

The log action string (`log->action`) is automatically appended to error messages by nginx's logging system, showing what operation was in progress when the error occurred. Setting this pointer before each major operation phase creates a breadcrumb trail through your module's execution. Without it, error messages like "recv() failed (104: Connection reset by peer)" lack any indication of which module phase was running, forcing you to correlate timestamps and line numbers manually.

**Incorrect (not setting log->action, producing context-free error messages):**

```c
static ngx_int_t
ngx_http_myauth_handler(ngx_http_request_t *r)
{
    ngx_int_t   rc;
    ngx_buf_t  *b;

    /* Phase 1: validate the auth token header */
    rc = ngx_http_myauth_parse_token(r);
    if (rc != NGX_OK) {
        /* Log says: "auth token parse failed"
         * but no automatic context about WHERE in the module */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "auth token parse failed");
        return NGX_HTTP_UNAUTHORIZED;
    }

    /* Phase 2: query the auth backend */
    rc = ngx_http_myauth_backend_query(r);
    if (rc != NGX_OK) {
        /* If the backend connection fails, nginx core logs:
         * "recv() failed (104: Connection reset by peer)"
         * No way to tell this came from the auth backend vs
         * the upstream, proxy, or any other module */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "auth backend query failed");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* Phase 3: inject auth headers into the request */
    rc = ngx_http_myauth_inject_headers(r);
    if (rc != NGX_OK) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "failed to inject auth headers");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    return NGX_DECLINED;
}
```

**Correct (setting log->action before each phase for automatic context in all messages):**

```c
static ngx_int_t
ngx_http_myauth_handler(ngx_http_request_t *r)
{
    ngx_int_t   rc;
    ngx_buf_t  *b;

    /* Phase 1: validate the auth token header
     * Pointer assignment only — zero runtime cost */
    r->connection->log->action = "parsing auth token in myauth module";

    rc = ngx_http_myauth_parse_token(r);
    if (rc != NGX_OK) {
        /* Now logs: "auth token parse failed while parsing
         * auth token in myauth module, client: 10.0.0.1" */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "auth token parse failed");
        return NGX_HTTP_UNAUTHORIZED;
    }

    /* Phase 2: query the auth backend */
    r->connection->log->action = "querying auth backend in myauth module";

    rc = ngx_http_myauth_backend_query(r);
    if (rc != NGX_OK) {
        /* Core errors now show context automatically:
         * "recv() failed (104: Connection reset by peer) while
         * querying auth backend in myauth module"
         * Immediately distinguishable from upstream/proxy errors */
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "auth backend query failed");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* Phase 3: inject auth headers */
    r->connection->log->action = "injecting auth headers in myauth module";

    rc = ngx_http_myauth_inject_headers(r);
    if (rc != NGX_OK) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "failed to inject auth headers");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    return NGX_DECLINED;
}
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)

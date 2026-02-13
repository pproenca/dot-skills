---
title: Handle Request Body Reading Asynchronously
impact: CRITICAL
impactDescription: prevents blocking workers on large uploads
tags: req, body, async, handler
---

## Handle Request Body Reading Asynchronously

`ngx_http_read_client_request_body` is asynchronous -- the `post_handler` callback fires when the body is fully read. The handler must return `NGX_DONE` after initiating the read, never access `r->request_body->bufs` inline, and perform all body processing inside the callback.

**Incorrect (reading body synchronously):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    rc = ngx_http_read_client_request_body(r, ngx_http_mymodule_body_handler);

    /* BUG: body may not be available yet — read is async */
    if (r->request_body && r->request_body->bufs) {
        ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                      "body length: %uz", r->request_body->bufs->buf->last
                      - r->request_body->bufs->buf->pos);
    }

    return rc;
}
```

**Correct (process body in callback, return NGX_DONE):**

```c
static void
ngx_http_mymodule_body_handler(ngx_http_request_t *r)
{
    /* body is now fully read — safe to access bufs */
    if (r->request_body == NULL || r->request_body->bufs == NULL) {
        ngx_http_finalize_request(r, NGX_HTTP_INTERNAL_SERVER_ERROR);
        return;
    }

    /* process body here, then finalize */
    ngx_http_finalize_request(r, ngx_http_mymodule_process_body(r));
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    rc = ngx_http_read_client_request_body(r, ngx_http_mymodule_body_handler);
    if (rc >= NGX_HTTP_SPECIAL_RESPONSE) {
        return rc;
    }

    /* handler exits — callback will finalize when body arrives */
    return NGX_DONE;
}
```

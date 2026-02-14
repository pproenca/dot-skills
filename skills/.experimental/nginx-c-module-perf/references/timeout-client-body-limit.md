---
title: Set Client Body Timeout to Bound Slow-Client Resource Usage
impact: MEDIUM
impactDescription: prevents slowloris-style attacks from holding connections indefinitely
tags: timeout, client, body, slowloris
---

## Set Client Body Timeout to Bound Slow-Client Resource Usage

A module that reads the client request body with `ngx_http_read_client_request_body` without enforcing a read timeout allows malicious or extremely slow clients to hold a connection open indefinitely -- sending one byte at a time to keep the socket alive. This is a variant of the slowloris attack that exhausts `worker_connections`. Setting `client_body_timeout` on the request's upstream config or adding an explicit timer in a custom body handler bounds the maximum time a client can occupy a worker connection during body transfer.

**Incorrect (reads body with no timeout -- slow client holds connection forever):**

```c
static ngx_int_t
ngx_http_myupload_handler(ngx_http_request_t *r)
{
    ngx_int_t  rc;

    /* BUG: no client_body_timeout configured, and no explicit timer —
     * a client sending 1 byte/sec on a 10MB upload holds this worker
     * connection for ~10 million seconds */
    rc = ngx_http_read_client_request_body(r,
                                           ngx_http_myupload_body_handler);

    if (rc >= NGX_HTTP_SPECIAL_RESPONSE) {
        return rc;
    }

    return NGX_DONE;
}

static void
ngx_http_myupload_body_handler(ngx_http_request_t *r)
{
    /* process body — but no timeout was ever set during the read */
    ngx_http_myupload_process(r);
}
```

**Correct (sets client body timeout and adds timer to bound slow reads):**

```c
static void *
ngx_http_myupload_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_myupload_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_myupload_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->client_body_timeout = NGX_CONF_UNSET_MSEC;

    return conf;
}

static char *
ngx_http_myupload_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_myupload_loc_conf_t  *prev = parent;
    ngx_http_myupload_loc_conf_t  *conf = child;

    /* 60s between successive read operations — drop idle clients */
    ngx_conf_merge_msec_value(conf->client_body_timeout,
                              prev->client_body_timeout, 60000);

    return NGX_CONF_OK;
}

static ngx_int_t
ngx_http_myupload_handler(ngx_http_request_t *r)
{
    ngx_int_t                      rc;
    ngx_http_myupload_loc_conf_t  *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_myupload_module);

    /* set the client body timeout so ngx_http_read_client_request_body
     * arms a timer between each recv() call — slow clients get dropped */
    r->read_event_handler = ngx_http_block_reading;

    ngx_http_core_loc_conf_t *clcf;
    clcf = ngx_http_get_module_loc_conf(r, ngx_http_core_module);
    clcf->client_body_timeout = mlcf->client_body_timeout;

    rc = ngx_http_read_client_request_body(r,
                                           ngx_http_myupload_body_handler);

    if (rc >= NGX_HTTP_SPECIAL_RESPONSE) {
        return rc;
    }

    return NGX_DONE;
}

static void
ngx_http_myupload_body_handler(ngx_http_request_t *r)
{
    /* body fully received within timeout bounds — safe to process */
    if (r->request_body == NULL || r->request_body->bufs == NULL) {
        ngx_http_finalize_request(r, NGX_HTTP_BAD_REQUEST);
        return;
    }

    ngx_http_myupload_process(r);
}
```

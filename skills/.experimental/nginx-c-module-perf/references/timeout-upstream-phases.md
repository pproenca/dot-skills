---
title: Set Separate Timeouts for Connect, Send, and Read Phases
impact: MEDIUM-HIGH
impactDescription: prevents 60s default timeout from stalling workers on slow upstreams
tags: timeout, upstream, phases, tuning
---

## Set Separate Timeouts for Connect, Send, and Read Phases

Nginx's upstream defaults all three phase timeouts (connect, send, read) to 60 seconds. A single slow upstream that takes 55 seconds to accept a TCP connection still has the full 60 seconds for headers and another 60 for the body -- holding a worker for nearly three minutes on one request. Setting explicit per-phase timeouts lets you fail-fast on connection establishment while allowing more time for legitimate data transfer, keeping worker utilization predictable.

**Incorrect (relies on 60s defaults for all upstream phases):**

```c
static ngx_int_t
ngx_http_myproxy_handler(ngx_http_request_t *r)
{
    ngx_http_upstream_t  *u;

    if (ngx_http_upstream_create(r) != NGX_OK) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    u = r->upstream;

    /* BUG: no timeout configuration — all phases default to 60000ms,
     * a single stalled upstream can hold a worker for up to 180s */
    u->conf = &mlcf->upstream;

    u->create_request = ngx_http_myproxy_create_request;
    u->process_header = ngx_http_myproxy_process_header;
    u->finalize_request = ngx_http_myproxy_finalize_request;

    ngx_http_upstream_init(r);
    return NGX_DONE;
}
```

**Correct (configures per-phase timeouts tuned to upstream SLA):**

```c
static void *
ngx_http_myproxy_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_myproxy_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_myproxy_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->upstream.connect_timeout = NGX_CONF_UNSET_MSEC;
    conf->upstream.send_timeout = NGX_CONF_UNSET_MSEC;
    conf->upstream.read_timeout = NGX_CONF_UNSET_MSEC;

    return conf;
}

static char *
ngx_http_myproxy_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_myproxy_loc_conf_t  *prev = parent;
    ngx_http_myproxy_loc_conf_t  *conf = child;

    /* fail-fast on connect: 3s is enough for local/regional backends */
    ngx_conf_merge_msec_value(conf->upstream.connect_timeout,
                              prev->upstream.connect_timeout, 3000);

    /* send timeout: request bodies are small, 10s is generous */
    ngx_conf_merge_msec_value(conf->upstream.send_timeout,
                              prev->upstream.send_timeout, 10000);

    /* read timeout: response generation may take longer, allow 30s */
    ngx_conf_merge_msec_value(conf->upstream.read_timeout,
                              prev->upstream.read_timeout, 30000);

    return NGX_CONF_OK;
}

static ngx_int_t
ngx_http_myproxy_handler(ngx_http_request_t *r)
{
    ngx_http_upstream_t           *u;
    ngx_http_myproxy_loc_conf_t   *mlcf;

    mlcf = ngx_http_get_module_loc_conf(r, ngx_http_myproxy_module);

    if (ngx_http_upstream_create(r) != NGX_OK) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    u = r->upstream;

    /* per-phase timeouts — connect fails fast, read allows backend processing */
    u->conf = &mlcf->upstream;

    u->create_request = ngx_http_myproxy_create_request;
    u->process_header = ngx_http_myproxy_process_header;
    u->finalize_request = ngx_http_myproxy_finalize_request;

    ngx_http_upstream_init(r);
    return NGX_DONE;
}
```

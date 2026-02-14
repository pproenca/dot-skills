---
title: Default Security Settings to Restrictive Values
impact: MEDIUM-HIGH
impactDescription: prevents insecure defaults from becoming production vulnerabilities
tags: default, security, restrictive, fail-closed
---

## Default Security Settings to Restrictive Values

Directives that control access, validation, or security policy must default to the most restrictive safe setting. Pattern from nginx: `ssl_protocols TLSv1.2 TLSv1.3` (rejects old TLS), `ssl_ciphers HIGH:!aNULL:!MD5` (rejects weak ciphers), `underscores_in_headers off` (silently drops suspicious headers). Fail-open for functionality, fail-closed for security.

**Incorrect (SSL verification disabled by default, accepting all cipher suites):**

```c
typedef struct {
    ngx_flag_t   verify_upstream;
    ngx_str_t    ciphers;
    ngx_uint_t   protocols;
} ngx_http_mymodule_loc_conf_t;

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    /* BUG: verification OFF by default — upstream responses are
     * trusted without any certificate validation */
    ngx_conf_merge_value(conf->verify_upstream, prev->verify_upstream, 0);

    /* BUG: accepts all ciphers including NULL and export-grade —
     * connections are trivially interceptable */
    ngx_conf_merge_str_value(conf->ciphers, prev->ciphers, "ALL");

    /* BUG: allows SSLv3 and TLSv1.0 — known vulnerable protocols */
    ngx_conf_merge_uint_value(conf->protocols, prev->protocols,
                              NGX_SSL_SSLv3|NGX_SSL_TLSv1
                              |NGX_SSL_TLSv1_1|NGX_SSL_TLSv1_2
                              |NGX_SSL_TLSv1_3);

    return NGX_CONF_OK;
}
```

**Correct (restrictive defaults that require explicit relaxation):**

```c
typedef struct {
    ngx_flag_t   verify_upstream;
    ngx_str_t    ciphers;
    ngx_uint_t   protocols;
    ngx_uint_t   verify_depth;
} ngx_http_mymodule_loc_conf_t;

static void *
ngx_http_mymodule_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_mymodule_loc_conf_t  *conf;

    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_mymodule_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->verify_upstream = NGX_CONF_UNSET;
    conf->protocols = 0;
    conf->verify_depth = NGX_CONF_UNSET_UINT;

    return conf;
}

static char *
ngx_http_mymodule_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_mymodule_loc_conf_t  *prev = parent;
    ngx_http_mymodule_loc_conf_t  *conf = child;

    /* verification ON by default — admin must explicitly disable */
    ngx_conf_merge_value(conf->verify_upstream, prev->verify_upstream, 1);

    /* only strong ciphers, reject NULL and weak suites */
    ngx_conf_merge_str_value(conf->ciphers, prev->ciphers,
                             "HIGH:!aNULL:!MD5:!EXPORT");

    /* only modern TLS — admin must explicitly add older protocols */
    ngx_conf_merge_uint_value(conf->protocols, prev->protocols,
                              NGX_SSL_TLSv1_2|NGX_SSL_TLSv1_3);

    /* reasonable depth prevents excessively long certificate chains */
    ngx_conf_merge_uint_value(conf->verify_depth, prev->verify_depth, 1);

    return NGX_CONF_OK;
}
```

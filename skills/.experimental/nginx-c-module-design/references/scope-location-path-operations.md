---
title: Restrict Path-Routing Directives to Location Context
impact: MEDIUM
impactDescription: prevents ambiguous request routing from server or http level
tags: scope, routing, location, proxy
---

## Restrict Path-Routing Directives to Location Context

Directives that route requests to a backend (like `proxy_pass`, `fastcgi_pass`) should be restricted to `NGX_HTTP_LOC_CONF|NGX_HTTP_LIF_CONF|NGX_HTTP_LMT_CONF`. These directives only make sense within a matched location because the location match provides the context of which requests should be routed. Allowing them at server or http level creates ambiguous routing — every request would be forwarded with no way to serve static files or distinguish between paths.

**Incorrect (pass directive at server level — ambiguous routing for all locations):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: NGX_HTTP_SRV_CONF allows this at server level where it
     * would apply to ALL requests — admin cannot serve static files
     * from some locations while proxying others */
    { ngx_string("mymod_pass"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_pass,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

      ngx_null_command
};

/*
 * admin writes this, expecting selective routing but getting all-or-nothing:
 *
 *   server {
 *       mymod_pass backend:8080;  # every request goes to backend
 *
 *       location /static/ {
 *           root /var/www;  # never reached — mymod_pass already matched
 *       }
 *   }
 */
```

**Correct (restricted to location + if-in-location + limit_except — requires explicit location matching):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* location context only — admin must define which paths to route */
    { ngx_string("mymod_pass"),
      NGX_HTTP_LOC_CONF|NGX_HTTP_LIF_CONF|NGX_HTTP_LMT_CONF|NGX_CONF_TAKE1,
      ngx_http_mymodule_pass,
      NGX_HTTP_LOC_CONF_OFFSET,
      0,
      NULL },

    /* tuning directives for the pass can still be at all three levels */
    { ngx_string("mymod_connect_timeout"),
      NGX_HTTP_MAIN_CONF|NGX_HTTP_SRV_CONF|NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_msec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connect_timeout),
      NULL },

      ngx_null_command
};

/*
 * admin gets clear, explicit routing:
 *
 *   server {
 *       mymod_connect_timeout 5s;  # default for all locations
 *
 *       location /api/ {
 *           mymod_pass backend:8080;  # only /api/ requests are routed
 *           mymod_connect_timeout 2s; # override for this path
 *       }
 *
 *       location /static/ {
 *           root /var/www;  # served directly, no conflict
 *       }
 *   }
 */
```

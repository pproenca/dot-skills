---
title: Avoid Custom Abbreviations in Directive Names
impact: HIGH
impactDescription: eliminates guessing and documentation lookups for unfamiliar abbreviations
tags: naming, abbreviation, readability, clarity
---

## Avoid Custom Abbreviations in Directive Names

Use only universally understood abbreviations: `ssl`, `http`, `tcp`, `uri`, `ip`. Do not invent abbreviations for domain-specific terms. `proxy_connect_timeout` not `proxy_conn_to`. `client_header_buffer_size` not `cli_hdr_buf_sz`. Every custom abbreviation forces an admin to consult documentation.

**Incorrect (custom abbreviations require documentation to decode):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    /* BUG: "conn_pool_sz" — three abbreviations in one name */
    { ngx_string("mymod_conn_pool_sz"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connection_pool_size),
      NULL },

    /* BUG: "req_buf_cnt" — unreadable without context */
    { ngx_string("mymod_req_buf_cnt"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, request_buffer_count),
      NULL },

    /* BUG: "auth_tok_ttl" — is "tok" token or ticket? */
    { ngx_string("mymod_auth_tok_ttl"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_sec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, auth_token_timeout),
      NULL },

      ngx_null_command
};
```

**Correct (full words are instantly readable without documentation):**

```c
static ngx_command_t ngx_http_mymodule_commands[] = {

    { ngx_string("mymod_connection_pool_size"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, connection_pool_size),
      NULL },

    { ngx_string("mymod_request_buffer_count"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, request_buffer_count),
      NULL },

    { ngx_string("mymod_auth_token_timeout"),
      NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_sec_slot,
      NGX_HTTP_LOC_CONF_OFFSET,
      offsetof(ngx_http_mymodule_loc_conf_t, auth_token_timeout),
      NULL },

      ngx_null_command
};
```

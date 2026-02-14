---
title: Inspect ngx_http_request_t Fields in GDB for Request State
impact: HIGH
impactDescription: reveals full request state (uri, headers, phase, count) at crash time — 20+ fields to inspect
tags: gdb, request, inspection, state
---

## Inspect ngx_http_request_t Fields in GDB for Request State

The `ngx_http_request_t` struct contains all state needed to understand what was happening at crash time. Key fields include `r->uri`, `r->phase_handler`, `r->count` (reference count), `r->main` (main vs subrequest), `r->internal` (internal redirect), and `r->connection->destroyed`. The main challenge is that `ngx_str_t` fields consist of a pointer and length, so printing them with `p r->uri` shows raw struct data instead of a readable string. Use `p *r->uri.data@r->uri.len` to display the actual string content.

**Incorrect (printing ngx_str_t fields as raw structs, unreadable output):**

```bash
# Attached to coredump or live worker
(gdb) print r->uri
# $1 = {len = 5, data = 0x7f2a3c001230 "/test\004\200..."}
#
# The raw print includes garbage after the string because
# ngx_str_t is NOT null-terminated. The output is misleading.

(gdb) print r->args
# $2 = {len = 8, data = 0x7f2a3c001236 "foo=bar\001\377..."}
#
# Again, garbage after the string data.

(gdb) print r->headers_in.host
# $3 = (ngx_table_elt_t *) 0x7f2a3c002100
#
# Just a pointer — no useful information visible.

# Developer gives up trying to read request state from GDB,
# adds printf debugging, rebuilds, and loses the crash context.
```

**Correct (using proper GDB commands to inspect nginx request fields):**

```bash
# Define a helper for ngx_str_t fields (add to ~/.gdbinit)
# define ngx_str
#   set $str = $arg0
#   set print elements $str.len
#   printf "%.*s\n", (int)$str.len, $str.data
# end

# Inspect request URI and arguments
(gdb) p *r->uri.data@r->uri.len
# $1 = "/test"

(gdb) p *r->args.data@r->args.len
# $2 = "foo=bar"

# Inspect request phase and state
(gdb) p r->phase_handler
# $3 = 7    (index into the phase handler array)

(gdb) p r->count
# $4 = 1    (reference count; >1 means active subrequests)

(gdb) p r->main == r
# $5 = 1    (this IS the main request)

(gdb) p r->internal
# $6 = 0    (no internal redirect has occurred)

# Inspect connection state
(gdb) p r->connection->fd
# $7 = 12   (socket file descriptor)

(gdb) p r->connection->destroyed
# $8 = 0    (connection is still alive)

# Inspect host header
(gdb) p *r->headers_in.host->value.data@r->headers_in.host->value.len
# $9 = "localhost"

# Inspect HTTP method
(gdb) p *r->method_name.data@r->method_name.len
# $10 = "GET"
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)

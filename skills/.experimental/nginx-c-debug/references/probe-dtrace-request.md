---
title: Trace Request Processing with DTrace pid Provider
impact: MEDIUM
impactDescription: inspects function arguments in production without debug binary
tags: probe, dtrace, pid-provider, request-tracing
---

## Trace Request Processing with DTrace pid Provider

DTrace's pid provider hooks into any function in a running process without recompilation or restart. On systems where DTrace is available (macOS, FreeBSD, Solaris, illumos), you can trace nginx request processing by probing function entries and returns, reading struct fields from function arguments, and computing per-function latency. This avoids rebuilding nginx with `--with-debug` (which changes timing and adds overhead), making it suitable for investigating production issues that only reproduce under real load.

**Incorrect (rebuilding nginx with --with-debug just to trace request flow):**

```bash
# BAD: full rebuild cycle to add tracing
$ ./configure --with-debug --add-module=../my_module
$ make && make install

# Restart nginx with debug logging
$ nginx -s stop
$ nginx

# Problems with this approach:
# 1. Requires service restart — drops active connections
# 2. --with-debug adds overhead to ALL code paths, not just
#    the functions you want to trace
# 3. Changes timing behavior — race conditions may disappear
# 4. Debug binary is ~30% larger, more instruction cache misses
# 5. Must revert and rebuild again for production
# 6. Cannot trace functions you didn't instrument with
#    ngx_log_debug calls at compile time

# Also BAD: manually adding printf/ngx_log_debug calls
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    /* Temporary debug printf — must rebuild to add/remove */
    fprintf(stderr, "handler called for %.*s\n",
            (int) r->uri.len, r->uri.data);
    /* ... */
}
```

**Correct (using DTrace pid provider to attach to running worker without rebuild):**

```bash
# Step 1: Find the worker PID
$ ps aux | grep 'nginx: worker'
www       4521  ...  nginx: worker process

# Step 2: Create a DTrace script to trace request processing
$ cat > trace_request.d << 'DTRACE_SCRIPT'
#!/usr/sbin/dtrace -s

/* Trace ngx_http_process_request — entry point for
 * every HTTP request after headers are parsed.
 * arg0 = ngx_http_request_t *r */
pid$target::ngx_http_process_request:entry
{
    self->req = arg0;
    self->start = timestamp;

    /* Read r->uri.len (offset depends on nginx version,
     * use pahole or GDB to find the exact offset) */
    this->uri_len = *(uint32_t *)copyin(arg0 + 0xb8, 4);
    this->uri_data = *(uintptr_t *)copyin(arg0 + 0xc0, 8);

    printf("REQUEST START: uri=%.*s\n",
           this->uri_len < 128 ? this->uri_len : 128,
           copyinstr(this->uri_data, this->uri_len < 128
                     ? this->uri_len : 128));
}

/* Trace your custom module handler */
pid$target::ngx_http_mymodule_handler:entry
{
    self->mod_start = timestamp;
    printf("  MYMODULE HANDLER ENTRY\n");
}

pid$target::ngx_http_mymodule_handler:return
{
    this->elapsed = (timestamp - self->mod_start) / 1000;
    printf("  MYMODULE HANDLER EXIT: %d μs, rc=%d\n",
           this->elapsed, arg1);
}

/* Trace request finalization */
pid$target::ngx_http_finalize_request:entry
{
    this->total = (timestamp - self->start) / 1000;
    printf("REQUEST FINALIZE: rc=%d total=%d μs\n",
           arg1, this->total);
    self->req = 0;
    self->start = 0;
}
DTRACE_SCRIPT

# Step 3: Run the DTrace script against the worker
$ sudo dtrace -s trace_request.d -p 4521

# Output (live, no restart required):
# REQUEST START: uri=/api/v1/users
#   MYMODULE HANDLER ENTRY
#   MYMODULE HANDLER EXIT: 42 μs, rc=0
# REQUEST FINALIZE: rc=200 total=187 μs
# REQUEST START: uri=/api/v1/health
#   MYMODULE HANDLER ENTRY
#   MYMODULE HANDLER EXIT: 3 μs, rc=-5
# REQUEST FINALIZE: rc=200 total=28 μs
```

Reference: [DTrace pid Provider Documentation](https://illumos.org/books/dtrace/chp-pid.html)

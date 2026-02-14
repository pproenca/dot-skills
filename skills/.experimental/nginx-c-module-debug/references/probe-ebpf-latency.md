---
title: Measure Per-Function Latency with eBPF Probes
impact: MEDIUM
impactDescription: identifies slow functions in production with <1% overhead vs 30%+ for --with-debug
tags: probe, ebpf, bpftrace, latency, performance
---

## Measure Per-Function Latency with eBPF Probes

eBPF (via bpftrace or bcc) attaches kernel-level probes to userspace functions with near-zero overhead when probes are not firing. Unlike strace (which intercepts every syscall via ptrace, adding microseconds per call), eBPF runs instrumentation code in-kernel and only activates on the specific functions you target. This makes it safe for production latency measurement. Use uprobes to attach to function entry/exit, compute duration in nanoseconds, and aggregate into histograms that show the full latency distribution, not just averages.

**Incorrect (using strace -T for function-level latency measurement):**

```bash
# BAD: strace measures SYSCALL latency, not function latency.
# It cannot time your module's handler function directly.
# It only shows time spent inside system calls.
$ strace -p 8402 -T -e trace=read,write 2>&1 | head -10
# read(12, "GET /api HTTP/1.1\r\n"..., 4096) = 285 <0.000013>
# write(12, "HTTP/1.1 200 OK\r\n"..., 512) = 512 <0.000009>

# Problems:
# 1. strace uses ptrace — adds ~10-50μs overhead PER syscall
# 2. Under load, this overhead accumulates: a worker doing
#    50,000 syscalls/sec gets 0.5-2.5 seconds of added latency
#    per second — fundamentally changing the behavior
# 3. Cannot measure time spent in user-space functions between
#    syscalls (your module's parsing, auth checking, etc.)
# 4. strace stops the process on every syscall (SIGSTOP/CONT),
#    disrupting epoll timing and masking race bugs
# 5. Cannot aggregate into histograms — only raw per-call times

# BAD: timing with clock_gettime in the module code
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    struct timespec start, end;
    /* Requires code change and rebuild */
    clock_gettime(CLOCK_MONOTONIC, &start);
    /* ... handler logic ... */
    clock_gettime(CLOCK_MONOTONIC, &end);
    /* Overhead of two syscalls per request */
}
```

**Correct (using bpftrace to measure function latency with near-zero overhead):**

```bash
# Step 1: Find the nginx binary and worker PID
$ NGINX_BIN=$(which nginx || echo /usr/local/nginx/sbin/nginx)
$ WORKER_PID=$(pgrep -f 'nginx: worker' | head -1)

# Step 2: Measure handler latency distribution with bpftrace
# uprobes attach at function entry/exit without modifying the binary
$ sudo bpftrace -p $WORKER_PID -e '
uprobe:'"$NGINX_BIN"':ngx_http_mymodule_handler
{
    @start[tid] = nsecs;
}

uretprobe:'"$NGINX_BIN"':ngx_http_mymodule_handler
/@start[tid]/
{
    $duration_us = (nsecs - @start[tid]) / 1000;
    @handler_latency_us = hist($duration_us);
    @total_calls = count();
    delete(@start[tid]);
}

interval:s:10
{
    printf("\n--- Handler Latency Distribution (μs) ---\n");
    print(@handler_latency_us);
    printf("Total calls: ");
    print(@total_calls);
    clear(@handler_latency_us);
    clear(@total_calls);
}
'

# Output every 10 seconds:
# --- Handler Latency Distribution (μs) ---
# @handler_latency_us:
# [1]          1523 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  |
# [2, 4)        487 |@@@@@@@@@@@@                            |
# [4, 8)         93 |@@                                      |
# [8, 16)        12 |                                        |
# [16, 32)        3 |                                        |  <-- outliers
# [32, 64)        1 |                                        |
# Total calls: 2119

# Step 3: Compare two functions to find the bottleneck
$ sudo bpftrace -p $WORKER_PID -e '
uprobe:'"$NGINX_BIN"':ngx_http_mymodule_parse_headers {
    @parse_start[tid] = nsecs;
}
uretprobe:'"$NGINX_BIN"':ngx_http_mymodule_parse_headers
/@parse_start[tid]/ {
    @parse_us = hist((nsecs - @parse_start[tid]) / 1000);
    delete(@parse_start[tid]);
}

uprobe:'"$NGINX_BIN"':ngx_http_mymodule_auth_check {
    @auth_start[tid] = nsecs;
}
uretprobe:'"$NGINX_BIN"':ngx_http_mymodule_auth_check
/@auth_start[tid]/ {
    @auth_us = hist((nsecs - @auth_start[tid]) / 1000);
    delete(@auth_start[tid]);
}

interval:s:30 { exit(); }
'
# Compare the two histograms to identify which function
# contributes most to total handler latency.
```

Reference: [bpftrace Reference Guide](https://github.com/bpftrace/bpftrace/blob/master/docs/reference_guide.md)

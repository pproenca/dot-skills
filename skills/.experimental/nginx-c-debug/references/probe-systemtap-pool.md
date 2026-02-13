---
title: Trace Memory Pool Allocations with SystemTap
impact: MEDIUM
impactDescription: tracks per-request allocation patterns in production
tags: probe, systemtap, pool, memory, allocation
---

## Trace Memory Pool Allocations with SystemTap

SystemTap probes attach to function entries and returns in a running nginx binary, enabling memory pool lifecycle tracing in production. The `ngx-leaked-pools` tapset tracks `ngx_create_pool` and `ngx_destroy_pool` calls, reporting pools that were created but never destroyed along with their creation backtraces. This finds pool leaks under real traffic without Valgrind's 20x+ overhead. SystemTap's typical overhead for pool tracing is ~11% for simple requests, making it viable for short diagnostic sessions in production.

**Incorrect (using Valgrind in production to find pool leaks):**

```bash
# BAD: running nginx under Valgrind in production
# Valgrind instruments EVERY memory access — 20-50× slowdown.
# A server handling 10,000 req/s drops to 200-500 req/s.

$ valgrind --leak-check=full \
    --show-reachable=yes \
    --track-origins=yes \
    /usr/local/nginx/sbin/nginx

# Problems:
# 1. 20-50× overhead makes real load testing impossible
# 2. Timing-dependent bugs disappear under Valgrind
# 3. nginx pools use custom allocation — Valgrind reports
#    "still reachable" for every pool allocation, generating
#    thousands of false positives
# 4. Pool-based allocation means individual free() calls
#    don't exist — Valgrind's leak detection model doesn't
#    match nginx's pool model
# 5. Valgrind requires a debug build and can't attach to
#    a running process

# Output: thousands of "still reachable" entries from pool
# allocations that are perfectly normal — the real leak is
# buried in noise.
```

**Correct (using SystemTap to trace pool lifecycle in production with ~11% overhead):**

```bash
# Step 1: Install the nginx SystemTap tapset
# (from openresty/stapxx or custom tapset)

# Step 2: Create a pool leak detection script
$ cat > ngx_pool_leak.stp << 'STP_SCRIPT'
/*
 * Track pool create/destroy to find leaked pools.
 * Attach to a running nginx worker for 60 seconds,
 * then report pools that were created but never destroyed.
 */

global pool_bt%      /* pool address -> backtrace */
global pool_size%    /* pool address -> initial size */
global pool_time%    /* pool address -> creation timestamp */

probe process("/usr/local/nginx/sbin/nginx").function("ngx_create_pool")
{
    /* ngx_create_pool(size_t size, ngx_log_t *log) */
    pool_size[tid()] = $size
}

probe process("/usr/local/nginx/sbin/nginx").function("ngx_create_pool").return
{
    if ($return != 0) {
        pool_bt[$return] = sprint_ubacktrace()
        pool_size[$return] = pool_size[tid()]
        pool_time[$return] = gettimeofday_ms()
    }
    delete pool_size[tid()]
}

probe process("/usr/local/nginx/sbin/nginx").function("ngx_destroy_pool")
{
    /* ngx_destroy_pool(ngx_pool_t *pool) */
    delete pool_bt[$pool]
    delete pool_size[$pool]
    delete pool_time[$pool]
}

probe timer.s(60)
{
    printf("\n=== LEAKED POOLS (created but not destroyed) ===\n")
    printf("Found %d leaked pools:\n\n", num_elements(pool_bt))

    foreach (pool in pool_bt- limit 20) {
        age_ms = gettimeofday_ms() - pool_time[pool]
        printf("Pool %p: size=%d, age=%d ms\n",
               pool, pool_size[pool], age_ms)
        printf("Created at:\n%s\n\n", pool_bt[pool])
    }

    exit()
}
STP_SCRIPT

# Step 3: Run against a specific worker PID
$ sudo stap ngx_pool_leak.stp -x $(pgrep -f 'nginx: worker' | head -1)

# Output after 60 seconds:
# === LEAKED POOLS (created but not destroyed) ===
# Found 3 leaked pools:
#
# Pool 0x7f3a4c012000: size=4096, age=58234 ms
# Created at:
#  ngx_create_pool+0x1a
#  ngx_http_mymodule_subrequest+0x45  <-- leak source
#  ngx_http_mymodule_handler+0x112
#  ngx_http_core_content_phase+0x1d
#
# Step 4: The backtrace shows exactly which code path
# created the pool that was never destroyed.
```

Reference: [openresty/stapxx — nginx SystemTap Toolkit](https://github.com/openresty/stapxx)

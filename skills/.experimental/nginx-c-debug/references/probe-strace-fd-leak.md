---
title: Detect File Descriptor Leaks with strace and /proc
impact: MEDIUM
impactDescription: identifies fd leak source — traces open/close syscalls to find unmatched pairs
tags: probe, strace, file-descriptor, leak, proc
---

## Detect File Descriptor Leaks with strace and /proc

File descriptor leaks in nginx modules manifest as EMFILE errors ("too many open files") after prolonged runtime. Each leaked fd (socket, file, pipe) remains open until the worker process exits, gradually consuming the per-process fd limit. Diagnosing the leak requires three steps: (1) counting open fds per worker over time via `/proc/PID/fd` to confirm the leak exists and measure its rate, (2) attaching strace with `-e trace=open,close,socket` to find fds that are opened without a matching close, (3) correlating leaked fd numbers with `/proc/PID/fdinfo` entries to identify the type and target. Simply increasing `worker_rlimit_nofile` masks the symptom while the leak continues.

**Incorrect (increasing worker_rlimit_nofile to hide the leak):**

```nginx
# nginx.conf — BAD: raising the limit to mask the leak
# The module leaks 1 fd per request to /tmp/mymodule_cache_*.
# At 100 req/s, this consumes 360,000 fds per hour.
# Raising the limit only delays the inevitable EMFILE.

worker_rlimit_nofile 1048576;  # was 65536, now 1M

events {
    worker_connections 65536;
}

# The worker will still eventually hit 1M open fds.
# Memory usage grows because each fd has kernel buffers.
# /proc/PID/fd listing becomes extremely slow.
# Performance degrades as the kernel manages 1M+ fds.
```

```c
/* The leaking module code — opens a cache file but never closes it
 * when the request pool is destroyed without a cleanup handler */
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_fd_t  fd;
    u_char    path[256];

    ngx_snprintf(path, sizeof(path), "/tmp/mymodule_cache_%V%Z",
                 &r->uri);

    fd = ngx_open_file(path, NGX_FILE_RDONLY, NGX_FILE_OPEN, 0);
    if (fd == NGX_INVALID_FILE) {
        return NGX_DECLINED;
    }

    /* BUG: fd is stored but never closed.
     * No ngx_pool_cleanup_add to close the fd when the
     * request completes. */
    /* ... read from fd ... */

    return NGX_OK;
    /* Request finishes, pool is destroyed, but fd stays open */
}
```

**Correct (diagnosing the fd leak with /proc and strace, then fixing with cleanup):**

```bash
# Step 1: Confirm the leak exists — count fds over time
$ WORKER_PID=$(pgrep -f 'nginx: worker' | head -1)
$ while true; do
    count=$(ls /proc/$WORKER_PID/fd 2>/dev/null | wc -l)
    echo "$(date +%H:%M:%S) fds=$count"
    sleep 5
  done
# 14:00:00 fds=42
# 14:00:05 fds=47
# 14:00:10 fds=53   <-- growing = leak confirmed
# 14:00:15 fds=58

# Step 2: Identify what's being leaked via /proc/PID/fd
$ ls -la /proc/$WORKER_PID/fd | tail -20
# ... normal sockets and pipes ...
# lrwx------ 1 www www 64 ... 55 -> /tmp/mymodule_cache_api_users
# lrwx------ 1 www www 64 ... 56 -> /tmp/mymodule_cache_api_health
# lrwx------ 1 www www 64 ... 57 -> /tmp/mymodule_cache_api_items
# Pattern: /tmp/mymodule_cache_* files accumulating

# Step 3: Trace open/close to find unmatched opens
$ strace -p $WORKER_PID -e trace=openat,close -T \
    2>&1 | tee /tmp/fd-trace.log &
# Let it run for 30 seconds, then:
$ kill %1

# Step 4: Find fds opened but never closed
$ awk '
  /openat.*mymodule_cache/ && /= [0-9]/ {
    match($0, /= ([0-9]+)/, m); opened[m[1]]++
  }
  /^close\(([0-9]+)\)/ {
    match($0, /close\(([0-9]+)\)/, m); closed[m[1]]++
  }
  END {
    for (fd in opened)
      if (!(fd in closed))
        printf "LEAKED fd=%s (opened %d times, never closed)\n",
               fd, opened[fd]
  }
' /tmp/fd-trace.log
# LEAKED fd=58 (opened 1 times, never closed)
# LEAKED fd=59 (opened 1 times, never closed)
```

```c
/* Fixed: register a cleanup handler to close the fd */
static void
ngx_http_mymodule_cleanup_fd(void *data)
{
    ngx_fd_t *fdp = data;

    if (*fdp != NGX_INVALID_FILE) {
        ngx_close_file(*fdp);
    }
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_fd_t            fd;
    ngx_fd_t           *fdp;
    ngx_pool_cleanup_t *cln;
    u_char              path[256];

    ngx_snprintf(path, sizeof(path), "/tmp/mymodule_cache_%V%Z",
                 &r->uri);

    fd = ngx_open_file(path, NGX_FILE_RDONLY, NGX_FILE_OPEN, 0);
    if (fd == NGX_INVALID_FILE) {
        return NGX_DECLINED;
    }

    /* Register cleanup BEFORE using the fd */
    cln = ngx_pool_cleanup_add(r->pool, sizeof(ngx_fd_t));
    if (cln == NULL) {
        ngx_close_file(fd);
        return NGX_ERROR;
    }

    fdp = cln->data;
    *fdp = fd;
    cln->handler = ngx_http_mymodule_cleanup_fd;

    /* ... read from fd ... */
    /* fd is automatically closed when request pool is destroyed */

    return NGX_OK;
}
```

Reference: [proc(5) — /proc/PID/fd](https://man7.org/linux/man-pages/man5/proc.5.html)

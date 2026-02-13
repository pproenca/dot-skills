---
title: Use strace to Trace System Call Patterns in nginx Workers
impact: MEDIUM
impactDescription: reveals I/O patterns and blocking calls without recompilation
tags: probe, strace, syscall, io-pattern
---

## Use strace to Trace System Call Patterns in nginx Workers

strace attaches to a running worker process and shows every system call with arguments, return values, and timing. It is invaluable for diagnosing: unexpected blocking calls (disk I/O in an async path, synchronous DNS resolution), socket errors that nginx logs generically, and I/O patterns that reveal performance bottlenecks. The key is attaching to a worker PID (not master) and filtering with `-e trace=` to limit output to relevant syscall categories. Running strace on the master process shows only signal handling and `waitpid` -- no request processing.

**Incorrect (running strace on the master process, which never handles requests):**

```bash
# Find nginx processes
$ ps aux | grep nginx
root      8401  ...  nginx: master process /usr/sbin/nginx
www-data  8402  ...  nginx: worker process
www-data  8403  ...  nginx: worker process

# BAD: attaching to the master PID
$ strace -p 8401

# Output shows only master process activity:
# rt_sigsuspend([], 8)              = ? ERESTARTNOHAND
# --- SIGCHLD {si_signo=SIGCHLD, ...} ---
# waitpid(-1, [{WIFEXITED(s)}], WNOHANG) = 0
# rt_sigsuspend([], 8)              = ? ERESTARTNOHAND
# ...
#
# The master process sits in sigsuspend() waiting for signals.
# You will NEVER see accept(), recv(), send(), epoll_wait(),
# or any request-handling syscalls.
# Modules' file operations, socket I/O, and upstream connections
# are all invisible from here.

# BAD: no filtering — massive output even on the right PID
$ strace -p 8402
# Produces thousands of lines per second including
# clock_gettime, gettimeofday, epoll_wait polls, etc.
# The actual bug-relevant syscalls are buried in noise.
```

**Correct (attaching to a worker PID with syscall filtering and timing):**

```bash
# Step 1: Identify the correct worker PID
$ ps aux | grep 'nginx: worker'
www-data  8402  ...  nginx: worker process
www-data  8403  ...  nginx: worker process

# Step 2: Trace network syscalls with timing (-T shows duration)
# -f follows child threads, -e filters to network category
$ strace -p 8402 -e trace=network -T 2>&1 | head -30
# accept4(7, {sa_family=AF_INET, sin_port=htons(54321),
#   sin_addr=inet_addr("10.0.0.1")}, [128->16], SOCK_NONBLOCK) = 12
#   <0.000021>
# setsockopt(12, SOL_TCP, TCP_NODELAY, [1], 4) = 0 <0.000008>
# recvfrom(12, "GET /api/v1/users HTTP/1.1\r\n"..., 4096, 0,
#   NULL, NULL) = 285 <0.000013>
# connect(13, {sa_family=AF_INET, sin_port=htons(8080),
#   sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EINPROGRESS
#   <0.000045>

# Step 3: Trace file I/O to find unexpected blocking disk access
$ strace -p 8402 -e trace=file -T 2>&1 | head -20
# openat(AT_FDCWD, "/var/cache/nginx/proxy/abc123",
#   O_RDONLY) = 14 <0.000350>
# --- A 350μs open in an event loop iteration is suspicious ---

# Step 4: Trace with full timestamps for correlation with logs
$ strace -p 8402 -e trace=network,write -tt -T \
    -o /tmp/nginx-worker-trace.log
# -tt: microsecond timestamps
# -T: syscall duration
# -o: write to file (avoids terminal I/O interfering with nginx)

# Step 5: Look for blocking patterns in the trace output
$ grep -E '<[0-9]+\.[0-9]{3,}>' /tmp/nginx-worker-trace.log
# Any syscall taking >1ms in an event-driven worker is a red flag.
# Common culprits: DNS resolution, disk reads, file locking
```

Reference: [strace(1) Manual](https://man7.org/linux/man-pages/man1/strace.1.html)

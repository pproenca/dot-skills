---
title: Use debug_connection to Isolate Single-Client Debug Output
impact: MEDIUM-HIGH
impactDescription: isolates 1 client's trace from thousands of concurrent requests
tags: dbglog, debug-connection, ip-filter, production
---

## Use debug_connection to Isolate Single-Client Debug Output

In production, enabling full debug logging generates gigabytes per minute and imposes a 5-10x latency penalty on every connection. The `debug_connection` directive in the `events` block enables debug-level logging only for connections originating from specific IP addresses or CIDR blocks. All other connections continue using the configured log level. This enables production debugging of a single client's request flow without impacting performance for other users. Requires nginx built with `--with-debug`.

**Incorrect (enabling debug globally in production, flooding disk and degrading all clients):**

```nginx
# nginx.conf — BAD: global debug logging in production
# This generates 10-50 GB/day under moderate traffic.
# Every connection gets debug-level output, including
# event loop internals, SSL handshake details, and
# upstream negotiation for ALL clients.

error_log /var/log/nginx/error.log debug;

events {
    worker_connections  4096;
    # No filtering — every client triggers full debug output
}

http {
    server {
        listen 80;
        server_name example.com;
        # ...
    }
}

# Result: disk fills up, latency spikes for all users,
# the one trace you need is buried in millions of lines.
# In high-traffic scenarios the worker may block on I/O
# waiting to flush log buffers, causing request timeouts.
```

**Correct (using debug_connection to enable debug only for the test client IP):**

```nginx
# nginx.conf — debug only for specific test client
# Non-matching connections use the 'error' log level.
# Performance impact is limited to the matched client only.

error_log /var/log/nginx/error.log error;

events {
    worker_connections  4096;

    # Enable debug logging for the test machine only.
    # Accepts IP addresses and CIDR blocks.
    debug_connection  192.168.1.100;
    debug_connection  10.0.0.0/24;

    # The debug output for matched connections goes to
    # the per-server or global error_log, but only those
    # connections produce debug-level messages.
}

http {
    server {
        listen 80;
        server_name example.com;

        # Optional: separate log file for debug output
        # so production error logs remain clean
        error_log /var/log/nginx/debug-trace.log debug;
        error_log /var/log/nginx/error.log error;
        # ...
    }
}

# Usage:
# 1. SSH to the test machine at 192.168.1.100
# 2. curl http://example.com/problematic-endpoint
# 3. Only this request produces debug output
# 4. tail -f /var/log/nginx/debug-trace.log
```

Reference: [nginx Debugging Log](https://nginx.org/en/docs/debugging_log.html)

---
title: Handle SIGTERM for Clean Shutdown
impact: MEDIUM
impactDescription: enables graceful termination by process managers
tags: signal, sigterm, shutdown, daemon
---

## Handle SIGTERM for Clean Shutdown

Handle SIGTERM to allow graceful shutdown when killed by process managers, init systems, or container orchestrators.

**Incorrect (no SIGTERM handling):**

```c
int main(void) {
    // No signal handling - abrupt termination
    while (1) {
        process_request();  // Killed mid-request
    }
}
```

```bash
# Container orchestrator sends SIGTERM, then SIGKILL after timeout
$ docker stop mycontainer
# Transactions may be left incomplete
```

**Correct (graceful SIGTERM handling):**

```c
#include <signal.h>

volatile sig_atomic_t shutdown_requested = 0;

void handle_sigterm(int sig) {
    shutdown_requested = 1;
}

int main(void) {
    struct sigaction sa = {
        .sa_handler = handle_sigterm,
        .sa_flags = 0
    };
    sigemptyset(&sa.sa_mask);
    sigaction(SIGTERM, &sa, NULL);
    sigaction(SIGINT, &sa, NULL);  // Handle both

    fprintf(stderr, "Server started, PID %d\n", getpid());

    while (!shutdown_requested) {
        // Finish current request before checking
        if (has_pending_request()) {
            process_request();
        }

        if (shutdown_requested) {
            fprintf(stderr, "Shutdown requested, finishing...\n");
            break;
        }
    }

    // Graceful cleanup
    finish_pending_transactions();
    close_connections();
    fprintf(stderr, "Shutdown complete\n");

    return 0;
}
```

```bash
$ mytool &
Server started, PID 12345
$ kill 12345  # Sends SIGTERM
Shutdown requested, finishing...
Shutdown complete
```

**For long-running services:**
- Finish current operation before exiting
- Drain connection pools
- Flush buffers and caches
- Log shutdown completion

Reference: [systemd - Daemon Shutdown](https://www.freedesktop.org/software/systemd/man/systemd.kill.html)

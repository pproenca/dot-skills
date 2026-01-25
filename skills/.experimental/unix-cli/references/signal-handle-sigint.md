---
title: Handle SIGINT Gracefully
impact: MEDIUM
impactDescription: respects user intent when pressing Ctrl-C
tags: signal, sigint, interrupt, cleanup
---

## Handle SIGINT Gracefully

When the user presses Ctrl-C (SIGINT), exit promptly after minimal cleanup. Don't ignore the signal or take too long to exit.

**Incorrect (ignores SIGINT or hangs):**

```c
void do_work(void) {
    signal(SIGINT, SIG_IGN);  // Ignores Ctrl-C!
    while (1) {
        slow_operation();  // User can't exit
    }
}

// Or: handler that does too much
void handle_sigint(int sig) {
    save_state();           // Slow
    close_connections();    // Slow
    write_logs();          // Slow
    cleanup_temp_files();  // User waiting...
    exit(1);
}
```

**Correct (exits promptly with signal acknowledgment):**

```c
#include <signal.h>

volatile sig_atomic_t interrupted = 0;

void handle_sigint(int sig) {
    interrupted = 1;  // Set flag only, exit from main loop
}

int main(void) {
    struct sigaction sa = {
        .sa_handler = handle_sigint,
        .sa_flags = 0
    };
    sigemptyset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    while (!interrupted) {
        if (do_work_chunk() < 0) break;

        // Check after each chunk
        if (interrupted) {
            fprintf(stderr, "\nInterrupted\n");
            break;
        }
    }

    // Quick cleanup only
    quick_cleanup();
    return interrupted ? 130 : 0;  // 128 + SIGINT(2)
}
```

```bash
$ mytool large_file.dat
Processing... ^C
Interrupted
$ echo $?
130  # Indicates SIGINT termination
```

**Guidelines:**
- Don't ignore SIGINT
- Set a flag in handler, check in main loop
- Exit within 1-2 seconds of Ctrl-C
- Print brief message acknowledging interrupt

Reference: [Command Line Interface Guidelines - Signals](https://clig.dev/)

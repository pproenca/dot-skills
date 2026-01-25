---
title: Skip Cleanup on Second Interrupt
impact: MEDIUM
impactDescription: respects urgent user intent to exit immediately
tags: signal, interrupt, cleanup, usability
---

## Skip Cleanup on Second Interrupt

If cleanup is taking too long, a second Ctrl-C should exit immediately. Don't trap users in a slow cleanup process.

**Incorrect (ignores second interrupt):**

```c
volatile sig_atomic_t interrupted = 0;

void handle_sigint(int sig) {
    interrupted = 1;
}

void cleanup(void) {
    fprintf(stderr, "Cleaning up...\n");
    // Long cleanup operations
    delete_temp_files();      // 5 seconds
    flush_buffers();          // 3 seconds
    close_connections();      // 2 seconds
    // User presses Ctrl-C again but nothing happens
}
```

**Correct (second interrupt exits immediately):**

```c
volatile sig_atomic_t interrupt_count = 0;

void handle_sigint(int sig) {
    interrupt_count++;
    if (interrupt_count >= 2) {
        fprintf(stderr, "\nForced exit\n");
        _exit(130);  // Exit immediately, skip all cleanup
    }
    fprintf(stderr, "\nInterrupted, cleaning up (Ctrl-C again to force quit)...\n");
}

void cleanup(void) {
    // Check between each slow operation
    if (interrupt_count < 2) {
        delete_temp_files();
    }
    if (interrupt_count < 2) {
        flush_buffers();
    }
    if (interrupt_count < 2) {
        close_connections();
    }
}

int main(void) {
    signal(SIGINT, handle_sigint);

    do_work();

    if (interrupt_count > 0) {
        cleanup();
    }

    return interrupt_count > 0 ? 130 : 0;
}
```

```bash
$ mytool very_large_operation
^C
Interrupted, cleaning up (Ctrl-C again to force quit)...
Cleaning up... ^C
Forced exit
$ echo $?
130
```

**Pattern:** Tell users about the escape hatch when cleanup starts.

Reference: [Command Line Interface Guidelines - Signals](https://clig.dev/)

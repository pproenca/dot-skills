---
title: Handle SIGPIPE for Broken Pipes
impact: MEDIUM
impactDescription: prevents unexpected crashes when piped to head/grep
tags: signal, sigpipe, pipes, robustness
---

## Handle SIGPIPE for Broken Pipes

Ignore SIGPIPE and handle write errors explicitly. Default SIGPIPE behavior terminates the program when the pipe reader closes early.

**Incorrect (crashes on broken pipe):**

```c
int main(void) {
    // Default SIGPIPE behavior
    for (int i = 0; i < 1000000; i++) {
        printf("Line %d\n", i);  // SIGPIPE kills process
    }
}
```

```bash
# Process dies silently when head closes pipe
$ mytool | head -5
Line 0
Line 1
Line 2
Line 3
Line 4
# mytool crashed with SIGPIPE, no error shown
```

**Correct (handles broken pipe gracefully):**

```c
#include <signal.h>
#include <errno.h>

int main(void) {
    // Ignore SIGPIPE, handle EPIPE error instead
    signal(SIGPIPE, SIG_IGN);

    for (int i = 0; i < 1000000; i++) {
        if (printf("Line %d\n", i) < 0) {
            if (errno == EPIPE) {
                // Reader closed pipe, exit gracefully
                break;
            }
            // Other write error
            perror("write");
            return 1;
        }
    }

    return 0;
}
```

```bash
# Exits cleanly when pipe closes
$ mytool | head -5
Line 0
Line 1
Line 2
Line 3
Line 4
$ echo $?
0  # Clean exit, no crash
```

**Alternative (check output stream):**

```c
for (int i = 0; i < 1000000; i++) {
    printf("Line %d\n", i);
    if (fflush(stdout) == EOF || ferror(stdout)) {
        break;  // Stop on any output error
    }
}
```

Reference: [signal(7) - SIGPIPE](https://man7.org/linux/man-pages/man7/signal.7.html)

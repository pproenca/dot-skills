---
title: Use 128+N for Signal Termination
impact: CRITICAL
impactDescription: enables correct signal detection by parent processes
tags: exit, signals, posix, termination
---

## Use 128+N for Signal Termination

When a program terminates due to a signal, it should exit with code 128 plus the signal number. This convention allows parent processes to determine the exact cause of termination.

**Incorrect (exits with arbitrary code on signal):**

```c
void handle_sigterm(int sig) {
    cleanup();
    exit(1);  // Bug: parent can't distinguish from normal error
}

int main(void) {
    signal(SIGTERM, handle_sigterm);
    // ...
}
```

```bash
$ mytool &
$ kill $!
$ echo $?
1  # Parent thinks it was a normal error
```

**Correct (exits with 128+signal number):**

```c
#include <signal.h>

volatile sig_atomic_t got_signal = 0;

void handle_sigterm(int sig) {
    got_signal = sig;
}

int main(void) {
    signal(SIGTERM, handle_sigterm);
    signal(SIGINT, handle_sigterm);

    while (!got_signal) {
        do_work();
    }

    cleanup();
    // Re-raise signal for correct exit code, or:
    exit(128 + got_signal);
}
```

```bash
$ mytool &
$ kill $!      # Sends SIGTERM (15)
$ echo $?
143            # 128 + 15 = 143

$ mytool &
$ kill -INT $! # Sends SIGINT (2)
$ echo $?
130            # 128 + 2 = 130
```

**Common signal exit codes:**

| Signal | Number | Exit Code |
|--------|--------|-----------|
| SIGHUP | 1 | 129 |
| SIGINT | 2 | 130 |
| SIGQUIT | 3 | 131 |
| SIGTERM | 15 | 143 |
| SIGKILL | 9 | 137 |

Reference: [Bash Reference - Exit Status](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html)

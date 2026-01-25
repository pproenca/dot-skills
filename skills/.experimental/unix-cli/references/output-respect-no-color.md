---
title: Respect NO_COLOR Environment Variable
impact: HIGH
impactDescription: enables accessibility and compatibility for all users
tags: output, color, no-color, accessibility, environment
---

## Respect NO_COLOR Environment Variable

When `NO_COLOR` environment variable is set (to any value), disable all color output. This is a cross-tool standard for accessibility and compatibility.

**Incorrect (ignores NO_COLOR):**

```c
void print_error(const char *msg) {
    printf("\033[1;31mError:\033[0m %s\n", msg);  // Always red
}

void print_success(const char *msg) {
    printf("\033[1;32mSuccess:\033[0m %s\n", msg);  // Always green
}
```

```bash
# User with color blindness or screen reader
$ export NO_COLOR=1
$ mytool process data.txt
Error: invalid data  # Still shows escape codes
```

**Correct (checks NO_COLOR and other indicators):**

```c
#include <stdlib.h>
#include <unistd.h>

int should_use_color(void) {
    // NO_COLOR takes precedence
    if (getenv("NO_COLOR") != NULL) return 0;

    // Check for dumb terminal
    const char *term = getenv("TERM");
    if (term && strcmp(term, "dumb") == 0) return 0;

    // Check if stdout is a terminal
    if (!isatty(STDOUT_FILENO)) return 0;

    // Check for forced color
    if (getenv("FORCE_COLOR") != NULL) return 1;

    return 1;
}

void print_error(const char *msg) {
    if (should_use_color()) {
        fprintf(stderr, "\033[1;31mError:\033[0m %s\n", msg);
    } else {
        fprintf(stderr, "Error: %s\n", msg);
    }
}
```

```bash
# Color disabled correctly
$ export NO_COLOR=1
$ mytool process data.txt
Error: invalid data

# Force color in pipes if needed
$ FORCE_COLOR=1 mytool status | less -R
```

**Color control precedence (highest to lowest):**
1. `--color=always` or `--color=never` flags
2. `NO_COLOR` or `FORCE_COLOR` environment variables
3. `TERM=dumb` check
4. `isatty()` check

Reference: [NO_COLOR.org](https://no-color.org/)

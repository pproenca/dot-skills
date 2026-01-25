---
title: Detect TTY for Human-Oriented Output
impact: CRITICAL
impactDescription: enables different output for interactive vs piped use
tags: output, tty, isatty, interactive, formatting
---

## Detect TTY for Human-Oriented Output

Check if stdout is a terminal before adding colors, progress bars, or interactive formatting. When output is piped or redirected, use plain machine-readable output.

**Incorrect (always uses fancy formatting):**

```c
void print_status(const char *msg) {
    printf("\033[1;32m✓\033[0m %s\n", msg);  // Always uses colors/emoji
}

int main(void) {
    print_status("File processed");
}
```

```bash
# Colors and escape codes corrupt piped output
$ mytool | head
^[[1;32m✓^[[0m File processed
# Escape codes visible as garbage
```

**Correct (adapts output to terminal type):**

```c
#include <unistd.h>

int use_color = 0;

void init_output(void) {
    use_color = isatty(STDOUT_FILENO);
}

void print_status(const char *msg) {
    if (use_color) {
        printf("\033[1;32m✓\033[0m %s\n", msg);
    } else {
        printf("OK: %s\n", msg);
    }
}

int main(void) {
    init_output();
    print_status("File processed");
}
```

```bash
# Terminal gets nice formatting
$ mytool
✓ File processed

# Pipe gets clean output
$ mytool | cat
OK: File processed
```

**Additional checks:**
- `NO_COLOR` environment variable should disable colors
- `TERM=dumb` should disable colors
- Provide `--no-color` and `--color=always` flags for overrides

Reference: [NO_COLOR Standard](https://no-color.org/)

---
title: Write Errors and Diagnostics to stderr
impact: CRITICAL
impactDescription: prevents errors from corrupting piped data
tags: output, stderr, errors, diagnostics, logging
---

## Write Errors and Diagnostics to stderr

All error messages, warnings, progress indicators, and diagnostic information must go to stderr. This allows stdout to be cleanly piped or redirected.

**Incorrect (errors go to stdout):**

```c
int main(int argc, char *argv[]) {
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        printf("Error: cannot open %s\n", argv[1]);  // stdout!
        return 1;
    }
    printf("Warning: file is large\n");  // stdout!
    // ...
}
```

```bash
# Error message ends up in the pipe
$ mytool missing.txt | grep pattern
Error: cannot open missing.txt
# grep receives the error message as input!
```

**Correct (all non-data goes to stderr):**

```c
int main(int argc, char *argv[]) {
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "Error: cannot open %s\n", argv[1]);
        return 1;
    }
    fprintf(stderr, "Warning: file is large\n");
    // ...
}
```

```bash
# Error is visible, pipe is clean
$ mytool missing.txt | grep pattern
Error: cannot open missing.txt
# grep receives nothing (no stdout output)
$ echo $?
1  # Pipeline fails correctly
```

**What goes to stderr:**
- Error messages
- Warnings
- Progress bars and spinners
- Debug/verbose output
- Usage messages (when invoked incorrectly)

Reference: [Standard Streams - Wikipedia](https://en.wikipedia.org/wiki/Standard_streams)

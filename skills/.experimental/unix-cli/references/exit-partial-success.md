---
title: Handle Partial Success Consistently
impact: HIGH
impactDescription: enables correct error aggregation in batch operations
tags: exit, partial-success, batch, error-handling
---

## Handle Partial Success Consistently

When processing multiple inputs, return non-zero if any operation failed. Use a consistent strategy: either fail fast or process all and report aggregate status.

**Incorrect (inconsistent partial success handling):**

```c
int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        if (!process_file(argv[i])) {
            fprintf(stderr, "Failed: %s\n", argv[i]);
            // Continues but forgets the failure
        }
    }
    return 0;  // Bug: returns success even if files failed
}
```

```bash
$ mytool good.txt bad.txt other.txt
Failed: bad.txt
$ echo $?
0  # Caller thinks everything succeeded
```

**Correct (tracks and reports failures):**

```c
int main(int argc, char *argv[]) {
    int failures = 0;

    for (int i = 1; i < argc; i++) {
        if (!process_file(argv[i])) {
            fprintf(stderr, "%s: processing failed\n", argv[i]);
            failures++;
        }
    }

    if (failures > 0) {
        fprintf(stderr, "%d file(s) failed\n", failures);
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
```

```bash
$ mytool good.txt bad.txt other.txt
bad.txt: processing failed
1 file(s) failed
$ echo $?
1  # Caller knows something failed
```

**Alternative (fail-fast mode with --keep-going option):**

```c
if (!process_file(argv[i])) {
    if (keep_going) {
        failures++;
        continue;
    }
    return EXIT_FAILURE;  // Stop immediately
}
```

Reference: [GNU Make - Errors in Recipes](https://www.gnu.org/software/make/manual/html_node/Errors.html)

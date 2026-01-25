---
title: Validate Input Early and Fail Fast
impact: HIGH
impactDescription: prevents partial operations and data corruption
tags: error, validation, fail-fast, input
---

## Validate Input Early and Fail Fast

Validate all inputs before starting work. Failing halfway through an operation can leave data in an inconsistent state and waste user time.

**Incorrect (validates during operation):**

```c
int main(int argc, char *argv[]) {
    // Starts processing immediately
    for (int i = 1; i < argc; i++) {
        FILE *f = fopen(argv[i], "r");
        if (!f) {
            fprintf(stderr, "%s: cannot open\n", argv[i]);
            continue;  // Already processed some files!
        }
        process(f);
        fclose(f);
    }
    write_output();  // Partial output written
}
```

```bash
# Partial output exists, hard to recover
$ mytool file1.txt file2.txt missing.txt file4.txt
Processing file1.txt... done
Processing file2.txt... done
missing.txt: cannot open
Processing file4.txt... done
# Output contains 3 of 4 files - inconsistent state
```

**Correct (validates all inputs first):**

```c
int main(int argc, char *argv[]) {
    // Phase 1: Validate all inputs
    FILE **files = malloc((argc - 1) * sizeof(FILE *));
    for (int i = 1; i < argc; i++) {
        files[i - 1] = fopen(argv[i], "r");
        if (!files[i - 1]) {
            fprintf(stderr, "%s: %s: %s\n",
                    program_name, argv[i], strerror(errno));
            // Clean up already-opened files
            for (int j = 0; j < i - 1; j++) fclose(files[j]);
            free(files);
            return EXIT_FAILURE;  // Fail before any processing
        }
    }

    // Phase 2: Process (all inputs validated)
    for (int i = 0; i < argc - 1; i++) {
        process(files[i]);
        fclose(files[i]);
    }

    free(files);
    write_output();
    return EXIT_SUCCESS;
}
```

```bash
# All-or-nothing: either all succeed or none processed
$ mytool file1.txt file2.txt missing.txt file4.txt
mytool: missing.txt: No such file or directory
# No partial output, no inconsistent state
```

**Validation checklist:**
- Required arguments present
- Files exist and are readable/writable
- Network services reachable
- Resource limits sufficient

Reference: [Crash-Only Software](https://www.usenix.org/legacy/events/hotos03/tech/full_papers/candea/candea.pdf)

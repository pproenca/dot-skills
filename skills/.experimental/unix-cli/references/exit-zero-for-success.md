---
title: Return Zero for Success Only
impact: CRITICAL
impactDescription: prevents false positives in scripts and CI/CD
tags: exit, success, posix, scripts, automation
---

## Return Zero for Success Only

Exit code 0 means success and nothing else. Any non-zero exit code indicates failure. Scripts, CI/CD pipelines, and shell operators (`&&`, `||`) depend on this convention.

**Incorrect (returns 0 on failure):**

```c
int main(int argc, char *argv[]) {
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "Could not open file\n");
        return 0;  // Bug: returns success on failure!
    }
    process(f);
    return 0;
}
```

```bash
# Script continues despite failure
$ mytool missing.txt && process_output
Could not open file
# process_output runs because exit code was 0
```

**Correct (returns non-zero on any failure):**

```c
int main(int argc, char *argv[]) {
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "Could not open file\n");
        return EXIT_FAILURE;  // Non-zero signals error
    }
    process(f);
    return EXIT_SUCCESS;  // 0 only on success
}
```

```bash
# Script stops on failure as expected
$ mytool missing.txt && process_output
Could not open file
# process_output does NOT run because exit code was 1
```

**Benefits:**
- `set -e` in scripts works correctly
- CI/CD pipelines detect failures
- `&&` and `||` operators work as expected
- `make` stops on tool failures

Reference: [POSIX Exit Status](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_08_02)

---
title: Distinguish Error Types with Different Exit Codes
impact: HIGH
impactDescription: enables scripts to handle different failures appropriately
tags: exit, error-types, scripting, automation
---

## Distinguish Error Types with Different Exit Codes

Use different exit codes for different error categories so scripts can respond appropriately. A config error should be distinguishable from a network error.

**Incorrect (same exit code for all errors):**

```c
int main(int argc, char *argv[]) {
    if (!load_config()) {
        fprintf(stderr, "Config error\n");
        return 1;  // Same code for all failures
    }
    if (!connect()) {
        fprintf(stderr, "Network error\n");
        return 1;  // Can't distinguish from config error
    }
    if (!process()) {
        fprintf(stderr, "Processing error\n");
        return 1;  // All errors look the same
    }
}
```

**Correct (distinct codes for different error categories):**

```c
#include <sysexits.h>

// Document exit codes in --help and man page
enum {
    EXIT_OK = 0,
    EXIT_USAGE = EX_USAGE,        // 64: bad arguments
    EXIT_CONFIG = EX_CONFIG,       // 78: config error
    EXIT_NETWORK = EX_UNAVAILABLE, // 69: network unavailable
    EXIT_DATA = EX_DATAERR,        // 65: input data error
    EXIT_INTERNAL = EX_SOFTWARE    // 70: internal error
};

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s config\n", argv[0]);
        return EXIT_USAGE;
    }

    if (!load_config(argv[1])) {
        fprintf(stderr, "Invalid config: %s\n", argv[1]);
        return EXIT_CONFIG;
    }

    if (!connect()) {
        fprintf(stderr, "Cannot connect to server\n");
        return EXIT_NETWORK;
    }

    return EXIT_OK;
}
```

```bash
#!/bin/bash
mytool config.yaml
case $? in
    0)  echo "Success" ;;
    64) echo "Bad arguments, check usage" ;;
    69) echo "Network down, will retry" && sleep 60 && mytool config.yaml ;;
    78) echo "Fix config file" ;;
    *)  echo "Unknown error" ;;
esac
```

**Note:** Document your exit codes in `--help` output and man pages.

Reference: [BSD sysexits](https://man.freebsd.org/cgi/man.cgi?query=sysexits)

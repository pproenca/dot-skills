---
title: Use Standard Exit Codes
impact: CRITICAL
impactDescription: enables consistent error handling across tools
tags: exit, sysexits, posix, standards, error-codes
---

## Use Standard Exit Codes

Use the BSD sysexits.h conventions for exit codes. These provide semantic meaning that scripts can act upon. Avoid inventing custom codes that conflict with reserved values.

**Incorrect (arbitrary non-standard codes):**

```c
#define ERR_FILE    100    // Conflicts with nothing but isn't standard
#define ERR_NETWORK 200    // Over 125, conflicts with shell conventions
#define ERR_PARSE   256    // Invalid: codes are 0-255

int main(int argc, char *argv[]) {
    if (!open_file()) return ERR_FILE;
    if (!connect())   return ERR_NETWORK;  // Wraps to 200-256=?
}
```

**Correct (uses sysexits.h standard codes):**

```c
#include <sysexits.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s file\n", argv[0]);
        return EX_USAGE;      // 64: command line usage error
    }

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror(argv[1]);
        return EX_NOINPUT;    // 66: cannot open input
    }

    if (!parse(f)) {
        fprintf(stderr, "Parse error\n");
        return EX_DATAERR;    // 65: data format error
    }

    return EX_OK;             // 0: successful termination
}
```

**Standard exit codes (sysexits.h):**

| Code | Name | Meaning |
|------|------|---------|
| 0 | EX_OK | Successful termination |
| 64 | EX_USAGE | Command line usage error |
| 65 | EX_DATAERR | Data format error |
| 66 | EX_NOINPUT | Cannot open input |
| 69 | EX_UNAVAILABLE | Service unavailable |
| 70 | EX_SOFTWARE | Internal software error |
| 73 | EX_CANTCREAT | Cannot create output file |
| 74 | EX_IOERR | Input/output error |
| 75 | EX_TEMPFAIL | Temporary failure; retry |
| 77 | EX_NOPERM | Permission denied |

**Codes to avoid:** 126 (command not executable), 127 (command not found), 128+ (signal termination)

Reference: [BSD sysexits](https://man.freebsd.org/cgi/man.cgi?query=sysexits)

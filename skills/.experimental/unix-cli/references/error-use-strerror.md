---
title: Use strerror for System Errors
impact: HIGH
impactDescription: provides consistent, localized error descriptions
tags: error, strerror, errno, system-calls, posix
---

## Use strerror for System Errors

When system calls fail, use `strerror(errno)` or `perror()` to provide the standard system error message. These messages are consistent, localized, and familiar to users.

**Incorrect (custom messages for system errors):**

```c
int fd = open(filename, O_RDONLY);
if (fd < 0) {
    fprintf(stderr, "File could not be opened\n");  // Vague
    return 1;
}

if (mkdir(path, 0755) < 0) {
    fprintf(stderr, "mkdir failed\n");  // Missing why
    return 1;
}
```

```bash
$ mytool /etc/shadow
File could not be opened
# Was it permissions? Not found? Disk error?
```

**Correct (uses system error messages):**

```c
#include <errno.h>
#include <string.h>

int fd = open(filename, O_RDONLY);
if (fd < 0) {
    fprintf(stderr, "%s: %s: %s\n",
            program_name, filename, strerror(errno));
    return 1;
}

// Or use perror for simpler cases:
if (mkdir(path, 0755) < 0) {
    perror(path);  // Prints: path: Permission denied
    return 1;
}
```

```bash
$ mytool /etc/shadow
mytool: /etc/shadow: Permission denied

$ mytool /nonexistent
mytool: /nonexistent: No such file or directory

$ mytool /dev/full
mytool: /dev/full: No space left on device
```

**Note:** Save `errno` immediately after the failing call if you need to do other work before printing the error.

```c
int fd = open(filename, O_RDONLY);
int saved_errno = errno;  // Save before other calls
log_attempt(filename);     // This might change errno
if (fd < 0) {
    fprintf(stderr, "%s: %s\n", filename, strerror(saved_errno));
}
```

Reference: [strerror(3) - Linux manual page](https://man7.org/linux/man-pages/man3/strerror.3.html)

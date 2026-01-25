---
title: Use Atomic File Writes
impact: MEDIUM
impactDescription: prevents data loss on crash or interrupt
tags: io, atomic, reliability, crash-safety
---

## Use Atomic File Writes

Write to a temporary file and rename it to the final destination. This prevents partial writes from corrupting data if the program crashes or is interrupted.

**Incorrect (direct write can corrupt):**

```c
int main(int argc, char *argv[]) {
    FILE *f = fopen(argv[1], "w");
    // If crash/interrupt happens here, file is empty/partial
    write_data(f);
    fclose(f);
}
```

```bash
# Ctrl-C during write corrupts the file
$ mytool important.conf
^C
$ cat important.conf
# Partial content, file corrupted
```

**Correct (write to temp, then rename):**

```c
#include <stdio.h>
#include <unistd.h>

int write_file_atomic(const char *path, const char *content) {
    char temp_path[PATH_MAX];
    snprintf(temp_path, sizeof(temp_path), "%s.XXXXXX", path);

    // Create temp file in same directory (for same filesystem)
    int fd = mkstemp(temp_path);
    if (fd < 0) return -1;

    FILE *f = fdopen(fd, "w");
    if (!f) {
        close(fd);
        unlink(temp_path);
        return -1;
    }

    // Write to temp file
    if (fputs(content, f) == EOF) {
        fclose(f);
        unlink(temp_path);
        return -1;
    }

    // Ensure data is flushed to disk
    fflush(f);
    fsync(fileno(f));
    fclose(f);

    // Atomic rename
    if (rename(temp_path, path) < 0) {
        unlink(temp_path);
        return -1;
    }

    return 0;
}
```

```bash
# Interrupt can't corrupt the file
$ mytool important.conf
^C
$ cat important.conf
# Original content preserved (or new content complete)
```

**Requirements for atomicity:**
- Temp file must be on same filesystem as target
- Use `fsync()` before rename for crash safety
- Clean up temp file on failure

Reference: [Ensuring data reaches disk](https://lwn.net/Articles/457667/)

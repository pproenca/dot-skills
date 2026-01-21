---
title: Never Use SUID/SGID on Shell Scripts
impact: CRITICAL
impactDescription: prevents privilege escalation vulnerabilities
tags: safety, suid, sgid, privileges, security
---

## Never Use SUID/SGID on Shell Scripts

Shell scripts cannot be made secure with SUID/SGID due to race conditions between the kernel reading the shebang and the interpreter opening the file. Many systems ignore SUID on scripts entirely.

**Incorrect (SUID shell script):**

```bash
#!/bin/bash
# File: /usr/local/bin/admin-task
# Permissions: -rwsr-xr-x (SUID set)
# DANGEROUS: Multiple attack vectors exist

# Race condition: attacker can replace script between
# kernel reading shebang and bash opening file
rm -rf /var/cache/app/*
```

**Correct (use sudo with specific permissions):**

```bash
#!/bin/bash
# File: /usr/local/bin/admin-task
# Permissions: -rwxr-xr-x (no SUID)

# Check if running with required privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with sudo" >&2
  exit 1
fi

rm -rf /var/cache/app/*
```

**sudoers configuration:**

```bash
# /etc/sudoers.d/admin-task
# Allow specific users to run specific script
appuser ALL=(root) NOPASSWD: /usr/local/bin/admin-task
```

**Alternative (compiled wrapper):**

```c
/* For complex cases, use a compiled SUID wrapper */
/* that validates arguments before exec'ing script */
#include <unistd.h>
int main(int argc, char *argv[]) {
    /* Validate environment, clear dangerous vars */
    clearenv();
    setenv("PATH", "/usr/bin:/bin", 1);
    execl("/usr/local/lib/admin-task.sh", "admin-task", NULL);
    return 1;
}
```

Reference: [Google Shell Style Guide - SUID/SGID](https://google.github.io/styleguide/shellguide.html)

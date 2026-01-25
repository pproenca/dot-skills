---
title: Never Read Secrets from Command-Line Flags
impact: CRITICAL
impactDescription: prevents credential exposure in process lists and logs
tags: args, security, secrets, passwords, credentials
---

## Never Read Secrets from Command-Line Flags

Command-line arguments appear in process listings (`ps aux`), shell history, and logs. Never accept passwords, API keys, or tokens as flag values.

**Incorrect (secret visible in process list):**

```bash
# Anyone on the system can see this password
$ ps aux | grep mytool
user  1234  mytool --password=SuperSecret123 --user=admin

# Password saved in shell history
$ history
  500  mytool --password=SuperSecret123 --user=admin
```

```c
static struct option opts[] = {
    {"password", required_argument, NULL, 'p'},  // Visible in ps
    {"api-key",  required_argument, NULL, 'k'},  // Visible in ps
    {NULL, 0, NULL, 0}
};
```

**Correct (read secrets from file or stdin):**

```bash
# Read from file (with restricted permissions)
$ mytool --password-file=/etc/mytool/credentials

# Read from environment (slightly better, still visible in /proc)
$ MYTOOL_PASSWORD=secret mytool

# Read from stdin (safest, not logged anywhere)
$ echo "secret" | mytool --password-stdin
$ mytool --password-stdin < /dev/tty
```

```c
static struct option opts[] = {
    {"password-file",  required_argument, NULL, 'P'},
    {"password-stdin", no_argument,       NULL, 's'},
    {NULL, 0, NULL, 0}
};

char *read_password(int from_stdin, const char *file) {
    if (from_stdin) {
        return read_line(stdin);  // Read from stdin
    }
    if (file) {
        FILE *f = fopen(file, "r");
        // Check file permissions (should be 0600)
        return read_line(f);
    }
    return NULL;
}
```

**Additional security measures:**
- Check that password files have mode 0600
- Use a secrets manager or keyring when available
- Clear password from memory after use

Reference: [Command Line Interface Guidelines - Security](https://clig.dev/)

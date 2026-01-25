---
title: Use Consistent Environment Variable Naming
impact: MEDIUM
impactDescription: enables predictable configuration discovery
tags: config, environment, naming, conventions
---

## Use Consistent Environment Variable Naming

Prefix environment variables with your program name and use SCREAMING_SNAKE_CASE. This prevents conflicts and makes variables discoverable.

**Incorrect (inconsistent or generic names):**

```c
// Generic names conflict with other programs
const char *debug = getenv("DEBUG");
const char *port = getenv("PORT");
const char *timeout = getenv("TIMEOUT");

// Inconsistent casing
const char *level = getenv("MyTool_LogLevel");
const char *file = getenv("mytool-config");
```

**Correct (prefixed, consistent naming):**

```c
// All variables prefixed with MYTOOL_
const char *debug = getenv("MYTOOL_DEBUG");
const char *port = getenv("MYTOOL_PORT");
const char *timeout = getenv("MYTOOL_TIMEOUT");
const char *log_level = getenv("MYTOOL_LOG_LEVEL");
const char *config = getenv("MYTOOL_CONFIG");

// Document supported variables
void print_env_help(void) {
    printf("Environment variables:\n");
    printf("  MYTOOL_DEBUG       Enable debug output (1 or 0)\n");
    printf("  MYTOOL_PORT        Server port (default: 8080)\n");
    printf("  MYTOOL_TIMEOUT     Timeout in seconds (default: 30)\n");
    printf("  MYTOOL_LOG_LEVEL   Log level: debug, info, warn, error\n");
    printf("  MYTOOL_CONFIG      Config file path\n");
}
```

```bash
# Clear which program these configure
$ export MYTOOL_PORT=9000
$ export MYTOOL_DEBUG=1
$ export MYTOOL_LOG_LEVEL=debug
$ mytool serve
```

**Naming conventions:**
- Prefix: `APPNAME_`
- Format: `SCREAMING_SNAKE_CASE`
- Only uppercase letters, digits, underscores
- No hyphens (not valid in all shells)

Reference: [POSIX Environment Variables](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html)

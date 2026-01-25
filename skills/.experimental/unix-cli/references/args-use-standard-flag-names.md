---
title: Use Standard Flag Names
impact: CRITICAL
impactDescription: leverages user's existing knowledge, reduces learning curve
tags: args, conventions, flags, standards, consistency
---

## Use Standard Flag Names

Use conventional flag names that users already know. Consistency across tools reduces cognitive load and prevents errors.

**Incorrect (non-standard flag names):**

```c
static struct option opts[] = {
    {"silent",    no_argument, NULL, 's'},       // Should be --quiet
    {"outfile",   required_argument, NULL, 'O'}, // Should be --output
    {"test-mode", no_argument, NULL, 't'},       // Should be --dry-run
    {"info",      no_argument, NULL, 'I'},       // Conflicts with --interactive
    {NULL, 0, NULL, 0}
};
```

**Correct (uses established conventions):**

```c
static struct option opts[] = {
    // Standard names users expect
    {"verbose",   no_argument,       NULL, 'v'},
    {"quiet",     no_argument,       NULL, 'q'},
    {"debug",     no_argument,       NULL, 'd'},
    {"force",     no_argument,       NULL, 'f'},
    {"recursive", no_argument,       NULL, 'r'},
    {"output",    required_argument, NULL, 'o'},
    {"dry-run",   no_argument,       NULL, 'n'},
    {"help",      no_argument,       NULL, 'h'},
    {"version",   no_argument,       NULL, 'V'},
    {NULL, 0, NULL, 0}
};
```

**Standard flag conventions:**

| Flag | Long Form | Meaning |
|------|-----------|---------|
| `-v` | `--verbose` | Increase output verbosity |
| `-q` | `--quiet` | Suppress non-error output |
| `-d` | `--debug` | Enable debug mode |
| `-f` | `--force` | Force operation without confirmation |
| `-r` | `--recursive` | Operate recursively |
| `-o` | `--output` | Specify output file |
| `-n` | `--dry-run` | Show what would happen without doing it |
| `-i` | `--interactive` | Prompt before actions |
| `-h` | `--help` | Show help text |
| `-V` | `--version` | Show version |

Reference: [Command Line Interface Guidelines](https://clig.dev/)

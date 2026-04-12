---
title: Include Copy-Pasteable Examples in Every --help
impact: CRITICAL
impactDescription: reduces invocation guessing to O(1) lookup
tags: help, examples, documentation, discoverability
---

## Include Copy-Pasteable Examples in Every --help

Agents pattern-match on examples far more reliably than on prose flag descriptions. A help text with "Options: --env <env>" forces the agent to guess the valid values, flag-argument shape, and quoting rules; an Examples section with `mycli deploy --env staging --tag v1.2.3` teaches the full invocation in one line. Every `--help` — especially subcommand help — should end with 2-4 real, copy-pasteable examples that cover the common cases.

**Incorrect (flag list only, no examples):**

```text
$ mycli deploy --help
Usage: mycli deploy [options]

Options:
  --env <env>      target environment
  --tag <tag>      image tag
  --replicas <n>   number of replicas
  --force          skip confirmation
  -h, --help       show help
```

**Correct (flag list plus a concrete Examples section):**

```text
$ mycli deploy --help
Usage: mycli deploy [options]

Deploy a service to a target environment.

Options:
  --env <env>      target environment (staging|production)
  --tag <tag>      image tag, e.g. v1.2.3 or "latest"
  --replicas <n>   number of replicas (default: 3)
  --force          skip confirmation prompt
  -h, --help       show this help and exit

Examples:
  mycli deploy --env staging --tag v1.2.3
  mycli deploy --env production --tag v1.2.3 --replicas 5
  mycli deploy --env staging --tag "$(mycli build --output tag-only)" --force

See also:
  mycli deploy list      list recent deploys
  mycli deploy rollback  roll back the last deploy
```

**Benefits:**
- Agents learn flag shapes from examples instead of guessing
- Real values (`v1.2.3`, `staging`) are far more useful than angle-bracket placeholders
- Chained examples (`$(mycli build ...)`) teach the agent how to compose subcommands

Reference: [clig.dev — Lead with examples](https://clig.dev/#help)

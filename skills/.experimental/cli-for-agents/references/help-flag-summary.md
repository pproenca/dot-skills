---
title: List Both Short and Long Forms for Every Flag
impact: HIGH
impactDescription: prevents brittle single-letter scripts and collision bugs
tags: help, flags, long-options, posix, gnu
---

## List Both Short and Long Forms for Every Flag

When help shows only `-e <env>`, agents learn that shape and generate scripts using the single-letter form — then break when a new release adds `--env` and repurposes `-e` for something else. GNU coding standards and POSIX utility conventions both require that every short option has a corresponding long option for exactly this reason. Show both in `--help` so agents can prefer the long form, which is stable, self-documenting, and collision-resistant.

**Incorrect (only short flag shown):**

```text
$ mycli deploy --help
Usage: mycli deploy [options]

Options:
  -e <env>       environment
  -t <tag>       image tag
  -r <n>         replicas
  -f             force
  -h             help
```

**Correct (short + long flag with default values):**

```text
$ mycli deploy --help
Usage: mycli deploy [options]

Options:
  -e, --env <env>         target environment (staging|production)
  -t, --tag <tag>         image tag (default: latest)
  -r, --replicas <n>      replica count (default: 3)
  -f, --force             skip confirmation
  -h, --help              show this help and exit
```

**Benefits:**
- Agents prefer `--env staging` over `-e staging` — clearer in scripts, diff-friendly
- Long flags are stable across versions; short flags can collide and get remapped
- Matches GNU/POSIX conventions that other tools rely on

**When NOT to use this pattern:**
- Commands with only a single flag (e.g., `--help`) don't need a short form
- Experimental or debug-only flags can be long-only to discourage scripting against them

Reference: [GNU Coding Standards — Command-Line Interfaces](https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html)

---
title: Every Subcommand Owns Its Own --help
impact: HIGH
impactDescription: reduces loaded help context by 80-95%
tags: help, subcommands, progressive-disclosure, context
---

## Every Subcommand Owns Its Own --help

Dumping the entire manual on `mycli --help` pollutes the agent's context with details about commands it isn't using. Agents pay for every token they read, so a monolithic help text forces them to carry 500+ lines of flag descriptions just to find the one flag they need. Layered help — top-level lists subcommands, each subcommand describes itself on demand — lets the agent load only the branch of the tree it is actually walking.

**Incorrect (top-level --help dumps every subcommand's flags):**

```text
$ mycli --help
Usage: mycli <command> [options]

Commands:
  deploy
    --env <env>            target environment
    --tag <tag>            image tag
    --replicas <n>         replica count
    --force                skip confirmation
    ... (20 more flags)
  config
    --file <path>          config file
    --format <fmt>         output format
    ... (15 more flags)
  logs
    --tail <n>             tail last N lines
    --follow               follow output
    ... (12 more flags)
  # Every subcommand's flags, in one 400-line blob
```

**Correct (top-level lists subcommands; details live in subcommand help):**

```text
$ mycli --help
Usage: mycli <command> [options]

Commands:
  deploy     Deploy a service to an environment
  config     Manage mycli configuration
  logs       Tail service logs
  service    List and manage services

Use "mycli <command> --help" for details on a command.
  mycli deploy --help
  mycli logs --help

$ mycli deploy --help
Usage: mycli deploy [options]
... (only the deploy-relevant flags)
```

**Benefits:**
- Agent loads ~15 lines to pick a subcommand, then ~40 for that subcommand's detail — not 400
- Every subcommand's help is self-contained and copy-pasteable
- New subcommands don't inflate the top-level help page

Reference: [clig.dev — Display helpful output on help](https://clig.dev/#help)

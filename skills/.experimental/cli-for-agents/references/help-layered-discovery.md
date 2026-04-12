---
title: Structure Top-Level Help as a Navigational Index
impact: HIGH
impactDescription: reduces top-level discovery context from ~200 lines to ~15
tags: help, navigation, toc, top-level
---

## Structure Top-Level Help as a Navigational Index

Top-level help is not the manual — it's the table of contents. Agents use it to pick the right subcommand, then load that subcommand's own help for details. Putting flag details, environment variables, or configuration syntax at the top level doubles context cost for zero discovery benefit. The top level should list every subcommand with a one-line description, nothing more.

**Incorrect (top-level help tries to cover everything):**

```text
$ mycli --help
mycli - production infrastructure CLI

SYNOPSIS
  mycli [global-opts] <command> [command-opts] [args]

DESCRIPTION
  mycli is a comprehensive production infrastructure management tool
  supporting deployments, logs, secrets, and service configuration.
  It uses the following environment variables:
    MYCLI_TOKEN, MYCLI_REGION, MYCLI_PROFILE, ...
  Configuration files are searched in the following order:
    ./mycli.yml, ~/.config/mycli/config.yml, /etc/mycli/config.yml
  ... (another 200 lines before getting to the subcommand list)
```

**Correct (top-level help is the TOC):**

```text
$ mycli --help
Usage: mycli <command> [options]

Production infrastructure CLI.

Commands:
  deploy      Deploy a service to an environment
  logs        Tail service logs
  secret      Manage encrypted secrets
  service     List and manage services
  config      Show or edit the mycli configuration

Run "mycli <command> --help" for details on a specific command.
Run "mycli config --help" for configuration and environment variables.
```

**Benefits:**
- Agent consumes ~15 lines to navigate, not 200
- Each subcommand is one line — easy to scan and pattern-match
- Environment variables and config live in `mycli config --help`, loaded only when relevant

Reference: [clig.dev — Lead with common examples](https://clig.dev/#help)

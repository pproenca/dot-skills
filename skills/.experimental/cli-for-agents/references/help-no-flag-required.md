---
title: Show Help When Invoked With Zero Arguments
impact: HIGH
impactDescription: prevents silent side effects from discovery attempts
tags: help, discovery, zero-args, safe-default
---

## Show Help When Invoked With Zero Arguments

Agents exploring a CLI will often try `mycli` with no args to see what happens. Three outcomes are possible: (1) silent exit — the agent has no idea what the CLI does; (2) run a default action — the agent doesn't learn the CLI's shape, and any side effect from the default is a surprise; (3) print a usage summary — the agent learns what's available. Option 3 is the only safe one. Top-level help with no args should also support `-h`, `--help`, and the bare `help` subcommand so the agent can find it however it guesses.

**Incorrect (no args runs the default command):**

```python
import click

@click.command()
@click.argument('service', required=False)
def mycli(service):
    # Running `mycli` with no args shows the last-used service's build status.
    # Looks harmless, but agents can't tell what the tool does — they just see
    # output and assume the CLI is working without ever reading --help.
    if not service:
        service = get_last_used_service()
    show_build_status(service)

if __name__ == '__main__':
    mycli()
```

**Correct (no args prints usage, exits 0):**

```python
import sys
import click

@click.group(invoke_without_command=True)
@click.pass_context
def mycli(ctx):
    if ctx.invoked_subcommand is None:
        # Safe default: show help and exit successfully
        click.echo(ctx.get_help())
        ctx.exit(0)

@mycli.command()
@click.argument('service')
def status(service):
    show_build_status(service)

if __name__ == '__main__':
    mycli()
```

**Benefits:**
- `mycli`, `mycli -h`, `mycli --help`, and `mycli help` all work
- Zero-arg invocation is safe: never runs side-effectful commands
- Exit code 0 signals "this is a successful discovery, not an error"

Reference: [clig.dev — Display helpful output on zero-arg invocation](https://clig.dev/#help)

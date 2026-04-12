---
title: Provide --yes or --force to Skip Confirmation Prompts
impact: HIGH
impactDescription: prevents confirmation prompts from blocking scripted runs
tags: safe, force, yes, confirmation
---

## Provide --yes or --force to Skip Confirmation Prompts

A CLI that always prompts before destructive actions is safe for humans but unusable for agents — the agent has no keyboard. `--yes` (often aliased `-y` or `--force`) skips the confirmation and proceeds directly. Keep the interactive default safe; keep the non-interactive path fast. npm, terraform, apt, rm, and gh all implement this exact pattern. For extra strictness against harnesses that falsely report TTY, see [`input-no-prompt-fallback`](input-no-prompt-fallback.md), which requires `--interactive` to even reach a prompt.

**Incorrect (confirmation is the only safety mechanism):**

```python
import click

@click.command()
@click.argument('service')
def delete(service):
    if not click.confirm(f"Really delete service '{service}'?"):
        click.echo("Aborted.")
        return
    api.delete_service(service)
    click.echo(f"Deleted {service}.")
```

**Correct (--yes skips the prompt; default stays safe for humans):**

```python
import sys
import click

@click.command()
@click.argument('service')
@click.option('-y', '--yes', is_flag=True, help='skip confirmation prompt')
def delete(service, yes):
    if not yes:
        if not sys.stdin.isatty():
            raise click.UsageError(
                f"Refusing to delete '{service}' without --yes in non-interactive mode.\n"
                f"  mycli delete {service} --yes"
            )
        if not click.confirm(f"Really delete service '{service}'?"):
            click.echo("Aborted.")
            return
    api.delete_service(service)
    click.echo(f"Deleted {service}.")
```

**Benefits:**
- Human workflow unchanged: `mycli delete myapp` still prompts
- Agent workflow works: `mycli delete myapp --yes` proceeds directly
- Non-TTY + no `--yes` = explicit refusal (safer than silent delete)

Reference: [clig.dev — Always allow -f or --force to skip confirmation](https://clig.dev/#robustness)

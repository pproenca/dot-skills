---
title: Accept Common Flags Through Environment Variables
impact: MEDIUM-HIGH
impactDescription: prevents repetition of the same flag on every invocation
tags: input, env-vars, precedence, configuration
---

## Accept Common Flags Through Environment Variables

Agents and scripts set environment variables once per session and then reuse them. For values that don't change between commands — region, profile, log format, API endpoint — accept an env-var fallback so the agent can set it once and omit the flag everywhere. The precedence must be: flag > environment variable > config file > built-in default, so an explicit flag always wins.

**Incorrect (region must be repeated on every command):**

```python
import click

@click.command()
@click.option('--region', required=True)
@click.argument('service')
def status(region, service):
    show_status(region, service)

# Agent must pass --region on every call:
#   mycli status --region us-east-1 svc-a
#   mycli status --region us-east-1 svc-b
#   mycli status --region us-east-1 svc-c
```

**Correct (MYCLI_REGION env var provides the fallback):**

```python
import click

@click.command()
@click.option('--region', envvar='MYCLI_REGION', required=True,
              help='target region (env: MYCLI_REGION)')
@click.argument('service')
def status(region, service):
    show_status(region, service)

# Agent sets MYCLI_REGION=us-east-1 once, then:
#   mycli status svc-a
#   mycli status svc-b
#   mycli status svc-c --region eu-west-1   # flag overrides env var
```

**Benefits:**
- `envvar='MYCLI_REGION'` wires precedence automatically in click
- Scripts set the env var at the top and forget about it
- Explicit `--region` still wins when the agent needs a one-off override

**When NOT to use this pattern:**
- Secrets should NOT use env-var fallback (see `input-stdin-for-secrets`) — they leak too easily
- Values that change per command (like `--service`) would mask bugs if env-var-sourced

Reference: [clig.dev — Use environment variables for context-dependent config](https://clig.dev/#configuration)

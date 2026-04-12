---
title: Include a Concrete Fix in Every Error Message
impact: HIGH
impactDescription: reduces retry loops by collapsing guess-and-check to one round
tags: err, messages, actionable, suggestions
---

## Include a Concrete Fix in Every Error Message

"Invalid input" is useless — the agent retries the same wrong thing with a different guess. "Invalid --env 'staing'. Valid values: staging, production, canary." tells the agent exactly how to fix it in one round. Every error should include the specific flag, the specific value, the specific fix, or the specific command to run next.

**Incorrect (error names a problem but not a fix):**

```python
import click

@click.command()
@click.option('--env', required=True)
def deploy(env):
    if env not in {'staging', 'production'}:
        raise click.ClickException('Invalid environment.')
    do_deploy(env)
```

**Correct (error names the problem AND the fix):**

```python
import click

VALID_ENVS = ('staging', 'production', 'canary')

@click.command()
@click.option('--env', required=True)
def deploy(env):
    if env not in VALID_ENVS:
        raise click.ClickException(
            f"Invalid --env '{env}'. Valid values: {', '.join(VALID_ENVS)}.\n"
            f"  deploy --env staging"
        )
    do_deploy(env)
```

**Benefits:**
- Agent fixes the input on the first retry, not the fifth
- `ClickException` exits with code 1 and prints to stderr automatically
- Listing valid values turns the error into a mini-help message

Reference: [clig.dev — Rewrite error messages for humans](https://clig.dev/#errors)

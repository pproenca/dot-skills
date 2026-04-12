---
title: Support a --no-input Flag to Force Non-Interactive Mode
impact: HIGH
impactDescription: prevents prompts inside harnesses that falsely report TTY
tags: interact, no-input, ci, scripting
---

## Support a --no-input Flag to Force Non-Interactive Mode

TTY detection is not always enough. Agents often run inside a terminal session (tmux, VS Code terminal, pty harness), so `isatty()` returns true even though no human is there to answer. `--no-input` is the explicit opt-out: "I am a script, never prompt, fail fast on missing values." clig.dev recommends this pattern specifically for this reason, and several large CLIs (npm, terraform) implement it verbatim.

**Incorrect (no way to disable prompts from a harness):**

```python
import click

@click.command()
@click.option('--env')
def deploy(env):
    if not env:
        # Always prompts in a TTY, even for automated runs
        env = click.prompt('Environment')
    do_deploy(env)
```

**Correct (--no-input forces the error path):**

```python
import click

@click.command()
@click.option('--env')
@click.option('--no-input', is_flag=True, envvar='MYAPP_NO_INPUT',
              help='Disable all prompts; fail on missing values.')
def deploy(env, no_input):
    if not env:
        if no_input:
            raise click.UsageError(
                'Missing --env. Valid values: staging, production.\n'
                '  myapp deploy --env staging'
            )
        env = click.prompt('Environment', type=click.Choice(['staging', 'production']))
    do_deploy(env)
```

**Benefits:**
- Agents set `MYAPP_NO_INPUT=1` once and never hit a prompt again
- `--no-input` is a well-known flag in the ecosystem (npm, terraform, gcloud)
- Keeps the interactive UX intact for humans without a separate code path

Reference: [clig.dev — Provide --no-input to disable prompts](https://clig.dev/#interactivity)

---
title: Accept `-` as Filename for stdin and stdout
impact: HIGH
impactDescription: prevents pipeline composition workarounds and temp files
tags: input, stdin, pipes, composability
---

## Accept `-` as Filename for stdin and stdout

The UNIX convention is that `-` as a file argument means "stdin" for inputs and "stdout" for outputs. This is what makes `curl https://... | tar -xf -` work, and what makes `jq . file.json` and `cat file.json | jq . -` equivalent. A CLI that accepts only real paths forces pipeline composition through temporary files, which agents must then remember to clean up.

**Incorrect (only accepts real file paths):**

```python
import click
import json

@click.command()
@click.argument('input_file', type=click.Path(exists=True, dir_okay=False))
def import_cmd(input_file):
    with open(input_file) as f:
        records = json.load(f)
    for r in records:
        save(r)
    click.echo(f"imported {len(records)} records")

# Agent must stage a scratch file to pipe:
#   mycli fetch --json > ./scratch-records.json && mycli import ./scratch-records.json
```

**Correct (`-` reads from stdin):**

```python
import click
import json
import sys

@click.command()
@click.argument('input_file', type=click.File('r'), default='-')
def import_cmd(input_file):
    records = json.load(input_file)
    for r in records:
        save(r)
    click.echo(f"imported {len(records)} records")

# Now the agent can pipe directly:
#   mycli fetch --json | mycli import -
#   mycli import ./data.json
```

**Benefits:**
- `click.File('r')` handles both paths and `-` automatically
- Pipeline composition without temp files or cleanup
- Consistent with `cat`, `jq`, `tar`, `curl`, and every other UNIX tool

Reference: [clig.dev — Support - for stdin/stdout](https://clig.dev/#the-basics)

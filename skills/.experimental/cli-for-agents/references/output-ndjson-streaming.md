---
title: Stream Large Result Sets as NDJSON
impact: MEDIUM-HIGH
impactDescription: prevents agent context blowup on large list commands
tags: output, ndjson, streaming, jsonl
---

## Stream Large Result Sets as NDJSON

A command that returns 10,000 records as a single top-level JSON array forces the agent to buffer the entire response before parsing — and then load the whole thing into context just to look at the first 50. NDJSON (newline-delimited JSON, one object per line, also known as JSON Lines) lets agents pipe through `head -n 50`, `jq -c 'select(.status=="failing")'`, or `awk`-style tools without buffering the full set, and keeps structural validity at every line. Offer `--ndjson` (or make it the default for `list` commands with a `--json` that emits a top-level array for small results).

**Incorrect (single-array JSON forces buffering the full result):**

```python
import click
import json

@click.command()
@click.option('--json', 'as_json', is_flag=True)
def list_deploys(as_json):
    deploys = api.list_all_deploys()  # might be 50,000 rows
    if as_json:
        click.echo(json.dumps([d.to_dict() for d in deploys]))
    else:
        for d in deploys:
            click.echo(f'{d.id}\t{d.status}\t{d.env}')

# Agent: `mycli list --json | jq '.[0:10]'` → buffers 50,000 rows before `.[0:10]` runs
```

**Correct (NDJSON streams one object per line; agent can `head` or filter live):**

```python
import click
import json
import sys

@click.command()
@click.option('--json', 'as_json', is_flag=True, help='output as NDJSON (one object per line)')
def list_deploys(as_json):
    deploys = api.iter_deploys()  # streaming iterator, no buffering
    for d in deploys:
        if as_json:
            # Each line is a self-contained JSON object. BrokenPipe is normal
            # when downstream `head` closes the pipe — catch and exit cleanly.
            try:
                sys.stdout.write(json.dumps(d.to_dict()) + '\n')
                sys.stdout.flush()
            except BrokenPipeError:
                sys.exit(0)
        else:
            click.echo(f'{d.id}\t{d.status}\t{d.env}')

# Agent: `mycli list --json | head -n 10 | jq -c '.status'` → reads 10 rows and stops
# Agent: `mycli list --json | jq -c 'select(.status=="failing")'` → streams live
```

**Benefits:**
- Agent can `| head -n 50` to bound context cost without server-side pagination
- `jq -c` / `jq --slurp` both work; NDJSON is a superset of the array form
- No memory pressure on the client — works even for unbounded result sets
- Each line is independently valid JSON, so a mid-stream failure doesn't corrupt earlier records

**When NOT to use this pattern:**
- For a single-object response (e.g., `mycli deploy show <id>`), emit the object directly — NDJSON is only for collections
- Commands that return <100 records can also emit a top-level array; document which form is used per command

Reference: [JSON Lines — Official format spec](https://jsonlines.org/)

---
title: Provide --json for Stable Machine-Readable Output
impact: MEDIUM-HIGH
impactDescription: prevents brittle regex parsing of human-readable tables
tags: output, json, machine-readable, stability
---

## Provide --json for Stable Machine-Readable Output

Human-readable output is a moving target — you'll want to add columns, change widths, and reformat as the tool evolves. Agents that scrape human output with regex will break on every cosmetic change. `--json` is the stable contract: a schema that only changes through explicit versioned deprecations. Every list, show, and status command should offer `--json`, emitting one object per record or a single top-level object.

**Incorrect (only decorated human output; agents must regex-parse):**

```python
import click
from rich.table import Table
from rich.console import Console

@click.command()
def list_services():
    services = api.list_services()
    table = Table(title='Services')
    table.add_column('Name')
    table.add_column('Status')
    table.add_column('Version')
    for s in services:
        table.add_row(s.name, s.status, s.version)
    Console().print(table)

# Agent gets ANSI-decorated box drawing it has to strip and parse
```

**Correct (human output stays pretty; --json is the stable contract):**

```python
import json
import click
from rich.table import Table
from rich.console import Console

@click.command()
@click.option('--json', 'as_json', is_flag=True, help='output as JSON')
def list_services(as_json):
    services = api.list_services()
    if as_json:
        click.echo(json.dumps(
            [{'name': s.name, 'status': s.status, 'version': s.version} for s in services],
            indent=2,
        ))
        return
    table = Table(title='Services')
    table.add_column('Name')
    table.add_column('Status')
    table.add_column('Version')
    for s in services:
        table.add_row(s.name, s.status, s.version)
    Console().print(table)

# Agent pipes: mycli list --json | jq '.[] | select(.status=="failing") | .name'
```

**Benefits:**
- Agents use `jq` instead of regex — faster, more reliable, more expressive
- Human output can evolve freely without breaking scripts
- JSON schema can be versioned and documented separately

**When NOT to use this pattern:**
- Commands whose output is a single scalar (`mycli service count` → emit the number; JSON adds `{"count": 42}` ceremony without clarity)
- Commands that emit binary data or raw file contents — use `--output <file>` instead
- Commands that already emit a stable structured format (YAML config dump) — re-serializing to JSON would lose fidelity

Reference: [clig.dev — Implement a --json output mode](https://clig.dev/#output)

---
title: Emit One Record Per Line for Grep-Able Human Output
impact: MEDIUM
impactDescription: prevents grep/awk/cut breakage on borders and wrapped cells
tags: output, lines, grep, awk, parseable
---

## Emit One Record Per Line for Grep-Able Human Output

Table borders (`+---+---+`), multi-line cells, and word-wrapped columns break `grep`, `awk`, and `cut`. Agents that don't have `--json` fall back to line-based parsing, and line-based parsing only works when every line is a self-contained record. Emit human-readable output as one record per line with stable column positions or a consistent separator, even when the record is long. Pretty tables belong in a `--pretty` mode, not the default.

**Incorrect (multi-line table with borders and wrapping):**

```text
$ mycli service list
+----------+--------+-------------------------------------+
| Name     | Status | Description                         |
+----------+--------+-------------------------------------+
| api      | up     | REST API for the public product,    |
|          |        | handles /v1 and /v2 endpoints       |
| worker   | up     | Background job processor            |
| billing  | down   | Payment and subscription service    |
+----------+--------+-------------------------------------+

# `mycli service list | grep down` matches only one line of a multi-line cell
```

**Correct (one record per line, stable field order):**

```text
$ mycli service list
NAME     STATUS  DESCRIPTION
api      up      REST API for the public product; handles /v1 and /v2 endpoints
worker   up      Background job processor
billing  down    Payment and subscription service

# `mycli service list | grep down` matches the full billing record
# `mycli service list | awk '$2=="down"' | cut -f1` extracts failing service names
```

**Implementation:**

```python
import click

@click.command()
def list_services():
    services = api.list_services()
    # Headers (single line)
    click.echo('NAME\tSTATUS\tDESCRIPTION')
    for s in services:
        # Each record on exactly one line; newlines in description replaced
        desc = s.description.replace('\n', '; ')
        click.echo(f'{s.name}\t{s.status}\t{desc}')
```

**Benefits:**
- Every UNIX line-based tool (grep, awk, cut, sort, uniq, wc) works out of the box
- Stable tab-separated output can be imported into spreadsheets and data tools
- Agent parsing is `.split('\t')` — no state machine needed

Reference: [Heroku CLI Style Guide — Output handling](https://devcenter.heroku.com/articles/cli-style-guide#output)

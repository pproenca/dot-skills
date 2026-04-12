---
title: Use Standard Flag Names — --help, --version, --verbose, --quiet
impact: MEDIUM
impactDescription: prevents agents from guessing wrong flags
tags: struct, flags, standards, gnu
---

## Use Standard Flag Names — --help, --version, --verbose, --quiet

Every major CLI uses the same names for the same concepts. Agents learn these from their pre-training on thousands of existing tools and will try them first, regardless of what your `--help` says. Rebinding `-v` to mean `--version` (when the rest of the world uses `-v` for `--verbose`) causes agents to pass `-v` expecting verbosity and get version output instead — a silent and confusing failure. Reserve the standard short flags for their standard meanings, and invent new ones only for concepts not already in the ecosystem.

**Incorrect (non-standard short-flag bindings):**

```python
import click

@click.command()
@click.option('-v', is_flag=True, help='print version')       # conflicts with convention
@click.option('-q', help='queue name')                         # conflicts with --quiet
@click.option('-f', help='config file')                        # conflicts with --force
@click.option('-d', is_flag=True, help='delete')               # conflicts with --debug
def mycli(v, q, f, d):
    ...
```

**Correct (standard short flags retain their standard meanings):**

```python
import click

@click.command()
@click.version_option(version='1.2.3')                         # -V / --version
@click.option('-v', '--verbose', is_flag=True)                 # -v → verbose
@click.option('-q', '--quiet', is_flag=True)                   # -q → quiet
@click.option('-f', '--force', is_flag=True)                   # -f → force
@click.option('-n', '--dry-run', is_flag=True)                 # -n → dry-run
@click.option('--queue', help='queue name')                    # custom concept, long-only
@click.option('--config-file', type=click.Path())              # custom concept, long-only
def mycli(verbose, quiet, force, dry_run, queue, config_file):
    ...
```

**Standard short flags to respect:**

| Short | Long | Meaning |
|-------|------|---------|
| `-h` | `--help` | Show help |
| `-V` | `--version` | Show version (capital V; some tools use `-v`) |
| `-v` | `--verbose` | Verbose output |
| `-q` | `--quiet` | Suppress non-essential output |
| `-f` | `--force` | Skip confirmations |
| `-n` | `--dry-run` | Preview without applying |
| `-o` | `--output` | Output file or format |
| `-y` | `--yes` | Assume yes to prompts |

**Benefits:**
- Agents guess right on the first try
- Scripts that composed well with other tools continue to compose with yours
- New domain-specific flags stay as long-form to avoid collisions

Reference: [GNU Coding Standards — Standard Command-Line Options](https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html)

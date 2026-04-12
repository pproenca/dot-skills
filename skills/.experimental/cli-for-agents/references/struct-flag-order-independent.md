---
title: Parse Flags in Any Position Relative to Subcommands
impact: MEDIUM
impactDescription: prevents confusing errors when agents append flags
tags: struct, flags, ordering, parsing
---

## Parse Flags in Any Position Relative to Subcommands

Agents often construct a command and then append flags to it: `mycli deploy --env staging` becomes `mycli deploy --env staging --debug`. If the parser only accepts flags in a specific position (e.g., global flags before the subcommand, local flags after), then `mycli --debug deploy --env staging` and `mycli deploy --env staging --debug` behave differently — and the one that fails produces a cryptic error. Parse flags in any position; GNU getopt does this by default, and it's what agents expect.

**Incorrect (POSIXLY_CORRECT parser rejects flags after the subcommand):**

```c
// POSIX-strict: option processing stops at first non-option argument
int main(int argc, char **argv) {
    int opt;
    while ((opt = getopt(argc, argv, "+v")) != -1) {
        if (opt == 'v') verbose = 1;
    }
    // `mycli deploy -v` — the -v is never seen because "deploy" stopped parsing
    handle_subcommand(argc - optind, argv + optind);
}
```

**Correct (GNU getopt permutes argv so flags work in any position):**

```c
// GNU getopt: by default, permutes argv so all options move to the front
int main(int argc, char **argv) {
    int opt;
    while ((opt = getopt(argc, argv, "v")) != -1) {
        if (opt == 'v') verbose = 1;
    }
    // `mycli deploy -v`, `mycli -v deploy`, and `mycli deploy --env staging -v`
    // all set verbose=1 correctly
    handle_subcommand(argc - optind, argv + optind);
}
```

**Or in Python click (subcommand groups propagate global flags automatically):**

```python
import click

@click.group()
@click.option('-v', '--verbose', is_flag=True)
@click.pass_context
def cli(ctx, verbose):
    ctx.ensure_object(dict)
    ctx.obj['verbose'] = verbose

@cli.command()
@click.option('--env', required=True)
@click.pass_context
def deploy(ctx, env):
    if ctx.obj['verbose']:
        click.echo(f"deploying to {env}...")
    do_deploy(env)

# All three work:
#   mycli -v deploy --env staging
#   mycli deploy -v --env staging
#   mycli deploy --env staging -v
```

**Benefits:**
- Agents append flags without worrying about position
- `-v` for verbose works on any subcommand without being redeclared
- Matches the behavior of nearly every modern CLI

Reference: [GNU Coding Standards — Command-Line Interfaces](https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html)

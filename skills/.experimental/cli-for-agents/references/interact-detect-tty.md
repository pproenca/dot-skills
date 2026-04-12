---
title: Check for a TTY Before Prompting
impact: CRITICAL
impactDescription: prevents indefinite hangs under agents and CI
tags: interact, tty, isatty, stdin
---

## Check for a TTY Before Prompting

Even when you legitimately need a prompt — a wizard mode, a credentials walkthrough, a password entry — the prompt must ALWAYS be guarded by `isatty(stdin)`. Without the guard, the prompt blocks forever when piped, run in CI, or invoked by an agent — there is no one on the other end to answer it. `process.stdin.isTTY` (Node), `sys.stdin.isatty()` (Python), and `term.IsTerminal(int(os.Stdin.Fd()))` (Go) are one-line guards that turn "hang forever" into "fail fast with a usable error." Note: this rule is about guarding the prompt you chose to write; separately, prompts should never be the implicit fallback for a missing flag — see [`input-no-prompt-fallback`](input-no-prompt-fallback.md).

**Incorrect (prompt runs unconditionally, hangs when piped):**

```python
import click

@click.command()
def login():
    # When piped or run by an agent, input() blocks forever
    username = input('Username: ')
    password = input('Password: ')
    authenticate(username, password)

if __name__ == '__main__':
    login()
```

**Correct (wizard mode is explicit + isatty-guarded; missing flags error fast):**

```python
import sys
import click

@click.command()
@click.option('--username', envvar='MYAPP_USERNAME')
@click.option('--password-file', type=click.Path(exists=True))
@click.option('--interactive', is_flag=True,
              help='enter credentials interactively (requires a TTY)')
def login(username, password_file, interactive):
    if interactive:
        if not sys.stdin.isatty():
            raise click.UsageError(
                '--interactive requires a TTY on stdin.\n'
                '  myapp login --username alice --password-file ~/.myapp/pw'
            )
        username = username or click.prompt('Username')
        password = click.prompt('Password', hide_input=True)
        authenticate(username, password)
        return

    if not username or not password_file:
        raise click.UsageError(
            'Missing --username or --password-file.\n'
            '  myapp login --username alice --password-file ~/.myapp/pw\n'
            '  myapp login --interactive    # enter credentials at a TTY prompt'
        )
    authenticate(username, read_password(password_file))
```

Reference: [clig.dev — Only use interactive elements if stdin is a TTY](https://clig.dev/#interactivity)

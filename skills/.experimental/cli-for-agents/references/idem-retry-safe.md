---
title: Make Running the Same Command Twice Safe
impact: MEDIUM-HIGH
impactDescription: prevents duplicate side effects on retry
tags: idem, retry, duplicate, side-effects
---

## Make Running the Same Command Twice Safe

Agents retry commands after transient failures — network blips, rate limits, timeouts. If the first run actually succeeded but the response was lost, the retry produces a second side effect: two rows inserted, two emails sent, two PRs opened. The fix is to define operations as "ensure this state" rather than "apply this delta." A re-run of an already-successful command becomes a no-op, and no manual reconciliation is needed.

**Incorrect (each invocation creates a new resource):**

```python
import click
import requests

@click.command()
@click.argument('email')
def invite(email):
    # Every invocation POSTs a new invite row
    resp = requests.post('https://api.example.com/invites', json={'email': email})
    resp.raise_for_status()
    click.echo(f"invite sent to {email}: id={resp.json()['id']}")

# Agent retries after a timeout → email gets two invites
```

**Correct (second run detects the existing invite and no-ops):**

```python
import click
import requests

@click.command()
@click.argument('email')
def invite(email):
    existing = requests.get(
        'https://api.example.com/invites',
        params={'email': email},
    ).json()
    if existing:
        click.echo(f"invite for {email} already exists: id={existing[0]['id']}")
        return

    resp = requests.post(
        'https://api.example.com/invites',
        json={'email': email},
        headers={'Idempotency-Key': f'invite:{email}'},
    )
    resp.raise_for_status()
    click.echo(f"invite sent to {email}: id={resp.json()['id']}")
```

**Benefits:**
- Retrying after a timeout is safe — no duplicate invite
- The `Idempotency-Key` header protects against races even during a single retry
- Output is identical on both runs, so downstream parsing doesn't care which branch ran

Reference: [clig.dev — Make idempotency a design goal](https://clig.dev/#robustness)

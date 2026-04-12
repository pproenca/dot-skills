---
title: Prefer "Ensure State" Semantics Over Delta Application
impact: MEDIUM
impactDescription: prevents errors when partial state is already applied
tags: idem, state, reconciliation, delta
---

## Prefer "Ensure State" Semantics Over Delta Application

"Apply these 5 migrations" is a delta — if some of them are already applied, the command errors out or double-applies. "Ensure the schema matches revision 42" is a state reconciliation — the command calculates the diff itself and applies only what's needed. State-based semantics are naturally idempotent, handle partial application gracefully, and let agents retry blindly. Terraform, Kubernetes, Ansible, Alembic's `upgrade head`, and every modern infrastructure tool use this pattern.

**Incorrect (delta-based migration errors on partial state):**

```python
import click
from alembic import command
from alembic.config import Config

@click.command()
@click.argument('revisions', nargs=-1)
def migrate(revisions):
    cfg = Config('alembic.ini')
    # Caller must supply exactly the revisions not yet applied
    for rev in revisions:
        command.upgrade(cfg, rev)
    # Retry after a network blip → errors: "revision already applied"
```

**Correct ("upgrade head" reconciles to the target, whatever's already applied):**

```python
import click
from alembic import command
from alembic.config import Config

@click.command()
@click.option('--target', default='head',
              help='revision to reconcile to (default: head)')
def migrate(target):
    cfg = Config('alembic.ini')
    # Alembic computes the delta from current to target and applies only the gap
    command.upgrade(cfg, target)
    click.echo(f'schema reconciled to {target}')
```

**Benefits:**
- Agent retries are always safe — reconciliation is the happy path
- Partial failures don't require manual rollback before retry
- The target state is the contract, not the steps to get there

**When NOT to use this pattern:**
- Destructive reconciliation (drop columns, delete rows) should still be explicit — use `--allow-destructive` or a separate command
- Ordered, non-commutative operations (e.g., "run this exact set of scripts in order") are delta-shaped by design

Reference: [Kubernetes — Declarative object configuration](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/)

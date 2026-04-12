---
title: Exit Successfully When Delete Targets Are Already Gone
impact: MEDIUM-HIGH
impactDescription: prevents retry-loop errors on already-clean state
tags: safe, idempotent, delete, retry-safety
---

## Exit Successfully When Delete Targets Are Already Gone

Agents retry commands on transient failures. If a delete command errors out because the resource is already gone, the retry will fail forever — the resource can never become "not yet deleted" again. The correct behavior for a delete is: "if the target doesn't exist, exit successfully with a message saying so." This turns "delete" into "ensure not present," which is naturally idempotent.

**Incorrect (delete errors when resource is already gone):**

```python
import click
import requests

@click.command()
@click.argument('service_id')
def delete(service_id):
    resp = requests.delete(f'https://api.example.com/services/{service_id}')
    if resp.status_code == 404:
        raise click.ClickException(f"service '{service_id}' not found")
    if resp.status_code != 200:
        raise click.ClickException(f"delete failed: {resp.text}")
    click.echo(f"deleted {service_id}")

# Agent retries after a network blip — second run errors with "not found"
```

**Correct (delete exits 0 when target is already gone):**

```python
import sys
import click
import requests

@click.command()
@click.argument('service_id')
def delete(service_id):
    resp = requests.delete(f'https://api.example.com/services/{service_id}')
    if resp.status_code == 200:
        click.echo(f"deleted {service_id}")
        sys.exit(0)
    if resp.status_code == 404:
        click.echo(f"{service_id} already absent", err=True)
        sys.exit(0)  # idempotent success, not an error
    raise click.ClickException(f"delete failed: {resp.status_code} {resp.text}")
```

**Benefits:**
- Safe to retry blindly — second run is a no-op
- Distinguishes "already gone" (stderr note) from "deleted just now" (stdout)
- Matches the semantics of `rm -f`, `kubectl delete --ignore-not-found`, `terraform destroy`

Reference: [clig.dev — Make operations idempotent where possible](https://clig.dev/#robustness)

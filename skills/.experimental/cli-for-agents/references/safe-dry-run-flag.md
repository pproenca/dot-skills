---
title: Provide --dry-run for Every Destructive Command
impact: HIGH
impactDescription: prevents irreversible mistakes during agent exploration
tags: safe, dry-run, preview, destructive
---

## Provide --dry-run for Every Destructive Command

Agents explore CLIs by trying commands, and destructive commands without a `--dry-run` flag force a binary choice: never use the command (losing a capability), or run it with full effect and hope (losing data). `--dry-run` (or `-n`) shows exactly what WOULD change — which files, which resources, which API calls — without actually making the change. It is the difference between a command an agent can safely experiment with and one it must avoid.

**Incorrect (no preview mode at all):**

```bash
#!/usr/bin/env bash
set -euo pipefail

# cleanup-orphans.sh — removes untagged container images
for image in $(docker images --filter "dangling=true" -q); do
  docker rmi "$image"
done
echo "Cleanup complete."
```

**Correct (--dry-run shows the plan without executing):**

```bash
#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      cat <<EOF
Usage: cleanup-orphans [--dry-run]
  --dry-run, -n    show what would be removed without removing it
Examples:
  cleanup-orphans --dry-run
  cleanup-orphans
EOF
      exit 0 ;;
    *) echo "Error: unknown flag '$1'" >&2; exit 2 ;;
  esac
done

mapfile -t orphans < <(docker images --filter "dangling=true" -q)
if [[ ${#orphans[@]} -eq 0 ]]; then
  echo "No orphaned images."
  exit 0
fi

if (( DRY_RUN )); then
  echo "Would remove ${#orphans[@]} orphaned images:"
  printf '  %s\n' "${orphans[@]}"
  exit 0
fi

for image in "${orphans[@]}"; do
  docker rmi "$image"
done
echo "Removed ${#orphans[@]} orphaned images."
```

**Benefits:**
- Agents preview cleanup before committing — no irreversible surprises
- Same code path for dry-run and real run, reducing divergence bugs
- `--dry-run` output is the audit trail of what the real run will do

**When NOT to use this pattern:**
- Commands whose action IS the preview — linters, validators, `terraform plan` (the whole command is already a dry-run)
- Read-only commands (list, show, get) — there is nothing destructive to preview
- Commands where "what would change" cannot be computed without actually doing the work (e.g., stream transformers that read stdin byte-by-byte)

Reference: [clig.dev — Provide a --dry-run flag](https://clig.dev/#robustness-guidelines)

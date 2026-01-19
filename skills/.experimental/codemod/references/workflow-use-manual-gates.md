---
title: Use Manual Gates for Critical Steps
impact: MEDIUM-HIGH
impactDescription: prevents runaway migrations with human checkpoints
tags: workflow, gates, manual, approval
---

## Use Manual Gates for Critical Steps

Add manual approval gates before destructive or irreversible operations. Gates pause execution until human approval.

**Incorrect (fully automatic):**

```yaml
# workflow.yaml - no human checkpoints
version: "1"
nodes:
  - id: migrate-database
    steps:
      - type: run
        command: npm run db:migrate
        # Runs immediately, no review

  - id: deploy-production
    depends_on: [migrate-database]
    steps:
      - type: run
        command: npm run deploy:prod
        # Deploys without approval!
```

**Correct (manual gates):**

```yaml
# workflow.yaml - human checkpoints
version: "1"
nodes:
  - id: migrate-database
    steps:
      - type: run
        command: npm run db:migrate:dry-run
        # Dry run first

  - id: review-migration
    type: manual  # Pauses for approval
    depends_on: [migrate-database]

  - id: apply-migration
    depends_on: [review-migration]
    steps:
      - type: run
        command: npm run db:migrate

  - id: review-deployment
    type: manual  # Another checkpoint
    depends_on: [apply-migration]

  - id: deploy-production
    depends_on: [review-deployment]
    steps:
      - type: run
        command: npm run deploy:prod
```

**Resume after approval:**

```bash
# Check workflow status
npx codemod workflow status

# Resume after manual review
npx codemod workflow resume -w ./workflow.yaml
```

**When to use manual gates:**
- Before database migrations
- Before production deployments
- After large-scale transforms (review diffs)
- Before irreversible operations

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)

---
title: Assert on Preview Results Before Deployment
impact: MEDIUM
impactDescription: prevents unintended destructive changes
tags: test, preview, assertions, safety
---

## Assert on Preview Results Before Deployment

Use Automation API to run previews and assert on planned changes before applying. This catches unexpected modifications in CI/CD pipelines.

**Incorrect (blind deployment):**

```bash
# CI/CD pipeline
pulumi up --yes
# Deploys whatever changes exist
# No validation of change scope
# Accidental destructive changes possible
```

**Correct (preview with assertions):**

```typescript
// scripts/safe-deploy.ts
import { LocalWorkspace } from "@pulumi/pulumi/automation";

async function safeDeploy() {
  const stack = await LocalWorkspace.selectStack({
    stackName: "prod",
    workDir: ".",
  });

  // Run preview first
  const preview = await stack.preview();

  // Assert on changes
  const changes = preview.changeSummary;

  // Fail if any resources will be deleted
  if (changes.delete && changes.delete > 0) {
    throw new Error(
      `Deployment would delete ${changes.delete} resources. ` +
      `Review changes and use --target for intentional deletions.`
    );
  }

  // Fail if too many resources changing
  const totalChanges = (changes.create ?? 0) + (changes.update ?? 0);
  if (totalChanges > 10) {
    throw new Error(
      `Deployment would modify ${totalChanges} resources. ` +
      `Large changes require manual approval.`
    );
  }

  // Safe to proceed
  console.log("Preview passed safety checks, deploying...");
  await stack.up();
}
```

**Correct (limit allowed change types):**

```typescript
const preview = await stack.preview();
const changes = preview.changeSummary;

// For a migration, only allow creates (no updates or deletes)
if (changes.update && changes.update > 0) {
  throw new Error(
    `Migration should only create resources, but ${changes.update} would be updated.`
  );
}

if (changes.delete && changes.delete > 0) {
  throw new Error(
    `Migration should only create resources, but ${changes.delete} would be deleted.`
  );
}

console.log(`Migration preview: ${changes.create ?? 0} resources to create`);
```

---
title: Enable Drift Detection for Production
impact: LOW-MEDIUM
impactDescription: reduces drift-related incidents by 80%
tags: auto, drift, detection, reconciliation
---

## Enable Drift Detection for Production

Drift occurs when cloud resources are modified outside of Pulumi. Enable scheduled drift detection to identify and remediate unauthorized changes.

**Incorrect (manual drift checks):**

```bash
# Occasional manual refresh
pulumi refresh
# Only catches drift when someone remembers to run it
# Manual changes accumulate unnoticed
# Deployment failures from unexpected state
```

**Correct (scheduled drift detection):**

```yaml
# .github/workflows/drift-detection.yml
name: Drift Detection
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:  # Manual trigger

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for Drift
        uses: pulumi/actions@v5
        with:
          command: refresh
          stack-name: org/project/prod
          expect-no-changes: true  # Fail if drift detected
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}

      - name: Alert on Drift
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "⚠️ Infrastructure drift detected in production!"
            }
```

**Correct (Pulumi Deployments drift detection):**

```typescript
// Enable via Pulumi Cloud API
const deployment = await pulumiService.createDeployment({
  organization: "my-org",
  project: "my-project",
  stack: "prod",
  operation: "refresh",
  // Schedule for automatic drift detection
  schedule: {
    cron: "0 */6 * * *",
  },
});
```

**Benefits:**
- Early detection of manual changes
- Audit trail of drift events
- Automated remediation option
- Compliance evidence

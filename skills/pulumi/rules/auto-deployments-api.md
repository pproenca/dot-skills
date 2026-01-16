---
title: Use Pulumi Deployments for GitOps
impact: LOW-MEDIUM
impactDescription: enables managed CI/CD without self-hosted runners
tags: auto, deployments, gitops, managed
---

## Use Pulumi Deployments for GitOps

Pulumi Deployments provides managed infrastructure for running Pulumi operations. Use it to eliminate self-hosted CI/CD runners and enable click-to-deploy workflows.

**Incorrect (self-managed CI/CD complexity):**

```yaml
# .github/workflows/deploy.yml
# Requires: secrets management, runner maintenance, scaling
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
      - name: Install Pulumi
        run: curl -fsSL https://get.pulumi.com | sh
      - name: Configure AWS
        run: # Complex credential setup
      - name: Deploy
        run: pulumi up --yes
        env:
          # Multiple secrets to manage
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

**Correct (Pulumi Deployments):**

```yaml
# Pulumi.yaml
name: my-infrastructure
runtime: nodejs
backend:
  url: https://api.pulumi.com

# Configure deployment settings in Pulumi Cloud UI or via API
# No CI/CD configuration needed
```

```typescript
// Trigger deployment via API
import { PulumiService } from "@pulumi/pulumi-service";

const service = new PulumiService();
await service.createDeployment({
  organization: "my-org",
  project: "my-project",
  stack: "prod",
  operation: "update",
  // OIDC authentication - no static credentials
  operationContext: {
    oidc: {
      aws: { roleArn: "arn:aws:iam::123456:role/pulumi-deploy" },
    },
  },
});
```

**Benefits:**
- No CI/CD runners to maintain
- OIDC authentication eliminates static credentials
- Click-to-deploy from Pulumi Cloud console
- Automatic drift detection and remediation

Reference: [Pulumi Deployments](https://www.pulumi.com/docs/deployments/)

---
title: Run Preview in PR Checks
impact: LOW-MEDIUM
impactDescription: prevents 90% of deployment failures
tags: auto, ci-cd, preview, pull-request
---

## Run Preview in PR Checks

Run `pulumi preview` in pull request checks to validate infrastructure changes before merge. This catches syntax errors, type mismatches, and policy violations early.

**Incorrect (preview only at deploy time):**

```yaml
# .github/workflows/deploy.yml
# Preview only runs when deploying to production
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pulumi up --yes
# Broken infrastructure code merged to main
# Production deployment fails
```

**Correct (preview in PR checks):**

```yaml
# .github/workflows/preview.yml
name: Preview Infrastructure
on:
  pull_request:
    branches: [main]
    paths:
      - 'infrastructure/**'
      - 'Pulumi*.yaml'
jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci
        working-directory: infrastructure

      - name: Pulumi Preview
        uses: pulumi/actions@v5
        with:
          command: preview
          stack-name: org/project/staging
          work-dir: infrastructure
          comment-on-pr: true  # Posts preview diff to PR
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

**Benefits:**
- Syntax errors caught before merge
- Team can review infrastructure changes in PR
- Policy violations block merge
- Preview diff visible in PR comments

Reference: [Pulumi GitHub Actions](https://www.pulumi.com/docs/using-pulumi/continuous-delivery/github-actions/)

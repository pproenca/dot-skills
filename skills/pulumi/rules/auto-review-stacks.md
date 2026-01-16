---
title: Use Review Stacks for PR Environments
impact: LOW-MEDIUM
impactDescription: enables testing in isolated environments per PR
tags: auto, review-stacks, pull-request, ephemeral
---

## Use Review Stacks for PR Environments

Create ephemeral stacks for each pull request to test infrastructure changes in isolation. Destroy them when the PR is merged or closed.

**Incorrect (shared staging environment):**

```yaml
# All PRs deploy to same staging environment
name: Deploy PR
on:
  pull_request:
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - run: pulumi stack select staging && pulumi up --yes
# Multiple PRs overwrite each other
# Testing one PR breaks another
# Difficult to isolate issues
```

**Correct (per-PR review stacks):**

```yaml
# .github/workflows/review-stack.yml
name: Review Stack
on:
  pull_request:
    types: [opened, synchronize, reopened, closed]

jobs:
  manage-stack:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Create/Update Review Stack
        if: github.event.action != 'closed'
        uses: pulumi/actions@v5
        with:
          command: up
          stack-name: org/project/pr-${{ github.event.number }}
          work-dir: infrastructure
        env:
          PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}

      - name: Comment Stack URL
        if: github.event.action != 'closed'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: '🚀 Review stack deployed: https://app-pr-${{ github.event.number }}.example.com'
            })

      - name: Destroy Review Stack
        if: github.event.action == 'closed'
        uses: pulumi/actions@v5
        with:
          command: destroy
          stack-name: org/project/pr-${{ github.event.number }}
          remove: true  # Also removes the stack
```

**Benefits:**
- Isolated testing environment per PR
- No interference between concurrent PRs
- Automatic cleanup on merge/close
- Reviewers can test actual infrastructure

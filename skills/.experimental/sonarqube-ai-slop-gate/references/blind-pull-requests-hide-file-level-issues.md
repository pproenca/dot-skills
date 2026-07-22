---
title: Expect main to go red after a green pull request
tags: blind, pull-requests, new-code, reporting
---

## Expect main to go red after a green pull request

A pull-request gate is easy to read as authoritative: green PR means the merge is safe, and main will stay green. Two documented behaviours break that inference, and when main turns red the morning after a clean merge, the usual conclusion is that SonarQube is flaky rather than that it is working as specified.

First, the condition sets differ. On a pull request, *"Only conditions defined on new code are applied."* On a branch, *"Both the conditions defined on overall code and conditions defined on new code are applied."* Since the AI-qualified gate carries three overall-code conditions (`aica-the-builtin-ai-gate-is-lenient`), those conditions are **never evaluated during PR analysis** and are evaluated the moment the merge lands on main. A change that pushes the project's overall Security rating from A to B passes every PR check and fails main.

Second, PR analysis has a reporting gap of its own: *"pull request analysis doesn't report issues raised at the file level"*, and *"the first analysis on the target branch after the merge may report new issues on old code that were not reported by the pull request analysis."*

Both are consequences of PR analysis scoping to the diff. Neither is a defect, but together they mean the pull-request gate is a *necessary* condition for a merge and not a sufficient one.

```yaml
# Analyze main after every merge, not only pull requests. Without this the
# overall-code conditions in an AI-qualified gate are never evaluated anywhere.
on:
  pull_request:
  push:
    branches: [main]

jobs:
  sonar:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - uses: SonarSource/sonarqube-scan-action@v8
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

The design consequence is where to put the blocking. Blocking on the pull-request gate catches new-code regressions at review time, which is what you want for a slop gate. Blocking main's build on the overall-code conditions produces a broken trunk for debt that no single commit introduced. The workable split is to block merges on the PR gate and alert — not block — on main's overall-code conditions, treating those as a backlog signal rather than a build failure.

Reference: [Introduction to quality gates](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates) · [Pull request analysis](https://docs.sonarsource.com/sonarqube-server/discovering/code-analysis/pull-request-analysis)

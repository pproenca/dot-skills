---
title: Budget for Developer Edition before designing a pull-request gate
tags: plat, editions, community-build, pull-requests
---

## Budget for Developer Edition before designing a pull-request gate

Asked to stand up SonarQube, the default move is `sonarqube:community` — it is free, the image tag is familiar, and every tutorial uses it. Then comes a CI workflow triggered on `pull_request`. That combination does not work, and it does not announce that it does not work.

SonarQube Community Build supports **main branch analysis only**. In the feature comparison table, "Branch analysis" reads *"Only main branch analysis"* and the "Pull Request Analysis" cell is **blank** — as are "Quality gate status report on pull requests", "Preventing merge when quality gate fails", and "AI Code Assurance". The Community Build documentation has no branch-analysis or pull-request-analysis pages at all.

The failure mode is silent rather than loud. `sonar.pullrequest.key` on a Community Build scanner does not raise a licensing error that stops the pipeline; the analysis publishes onto the project's single main-branch history. Every PR's code lands in one ever-growing timeline, the new code period stops corresponding to anything a reviewer would call new, and the dashboard looks healthy because it is measuring a codebase nobody is gating.

A continuous gate on AI-generated changes is by definition a pull-request-time gate — it has to block the merge, not report after it. So **Developer Edition is the floor**, and that is a licensing decision to settle before any YAML is written.

```yaml
# docker-compose.yml — the edition decides whether a PR gate is possible at all
services:
  sonarqube:
    # Community Build: main branch only. No PR analysis, no AI Code Assurance.
    #   image: sonarqube:community
    # Developer Edition and up: branch + PR analysis, AI Code Assurance.
    image: sonarqube:developer
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonarqube
```

Branch and pull-request analysis are not marked "From Enterprise" in the comparison table, which places them at the lowest paid Server tier. The AI Code Assurance row is blank for Community Build in that same table, so the one tier unlocks both halves of this skill. AI CodeFix is the exception and sits higher — see `plat-ai-features-are-edition-gated`.

Community Build remains a reasonable choice for a single-trunk repository where you want main-branch trend data and no merge blocking. It is not a reduced-capability version of the gate described here; it is a different product with no gate.

Reference: [Feature comparison table](https://docs.sonarsource.com/sonarqube-community-build/feature-comparison-table) · [Set up AI Code Assurance](https://docs.sonarsource.com/sonarqube-server/project-administration/ai-features/set-up-ai-code-assurance)

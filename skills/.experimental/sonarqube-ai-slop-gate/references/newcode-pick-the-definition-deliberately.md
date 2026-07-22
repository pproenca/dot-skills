---
title: Match the new code definition to the branching model
tags: newcode, reference-branch, quality-gates, configuration
---

## Match the new code definition to the branching model

The new code definition decides what "new" means, and therefore what every new-code gate condition is measured against. Left alone it inherits the instance default — *"The default baseline for new code is the Previous version option"* — which keys off the project version from `pom.xml`, `build.gradle`, or `sonar.projectVersion`. On a repository that never increments a version, the baseline never moves, and "new code" grows without bound until the whole codebase is new and the gate fails on everything.

Four options exist:

| Option | Baseline | Fits |
|---|---|---|
| **Reference branch** | Diff against a named branch | Trunk-based work; the right default for a PR gate |
| Previous version | Last version increment | Released libraries with real version bumps |
| Number of days | Rolling window, **max 90** | Continuous deployment with no versions |
| Specific analysis | A pinned past analysis | Freezing a baseline during remediation |

For a continuous AI-slop gate, **reference branch** is the one that matches the question being asked. It defines new code as *"Any differences between your branch and a selected reference branch"*, so a pull request is measured against exactly what it would merge into. The other three are time- or version-based and drift out of alignment with the diff under review.

Two constraints on where each can be set. Globally only Previous version and Number of days are available; project and branch level offer Previous version, Number of days, and Reference branch. **Specific analysis is API-only by design** — *"the Specific analysis option can only be set using the Web API, as it would require frequent user action to be kept up to date."* And the rolling window is capped: *"The maximum possible value is 90 days."*

The bootstrap case is worth knowing because it bites on the very first pipeline run, before the reference branch exists on the server:

```properties
# Overrides the server-side new code definition for this analysis. Needed on a
# project's first run, when the reference branch has not been analyzed yet.
sonar.newCode.referenceBranch=main
```

The documentation describes this as *"particularly useful during the first analysis when the branch to be analyzed does not exist yet in SonarQube."* Leave it in the properties file permanently only if you want the definition pinned in version control rather than administered on the server; otherwise use it to bootstrap and then manage the definition centrally, so it can be changed without a commit to every repository.

Reference: [About new code](https://docs.sonarsource.com/sonarqube-server/user-guide/about-new-code) · [Configuring new code calculation](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/configuring-new-code-calculation)

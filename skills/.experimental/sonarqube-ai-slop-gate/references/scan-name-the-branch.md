---
title: Pass branch or pull request parameters, or everything lands on main
tags: scan, branches, pull-requests, ci
---

## Pass branch or pull request parameters, or everything lands on main

When `sonar.branch.name` is absent, the scanner does not refuse to publish and does not guess from the checkout. *"The analysis will be performed on the main branch."* Every feature branch's analysis overwrites the main branch's results, the main branch's history becomes an interleaving of unrelated work, and the new code period computed from it describes nothing.

There are two distinct modes, and mixing them up produces the same silent misfiling:

```properties
# Branch analysis — a long-lived or feature branch, analyzed on its own.
sonar.branch.name=feature/checkout-retry

# Pull request analysis — a proposed merge. Do NOT also set sonar.branch.name;
# the two modes are mutually exclusive.
sonar.pullrequest.key=1432          # the PR number in the DevOps platform
sonar.pullrequest.branch=feature/checkout-retry
sonar.pullrequest.base=main         # defaults to the main branch
```

`sonar.pullrequest.key` must match the platform's own identifier — *"Must correspond to the key of the pull request in your DevOps Platform"* — because that key is what PR decoration uses to find the pull request to comment on. A synthetic or incremented value produces an analysis that succeeds and a decoration that never appears.

In practice these rarely need setting by hand: *"The SonarScanner can automatically detect the branch name parameters when running on the following CI services (you don't need to perform any additional setup)."* On a supported CI the correct move is to set nothing and let detection work, since a hardcoded `sonar.branch.name` in a committed properties file overrides detection and pins every analysis to one branch name — the same failure as omitting it, reached from the opposite direction.

That makes this a rule about *verification* more than configuration. After the first pipeline run on a branch, open the project and confirm a branch or pull-request entry appeared. If the only thing listed is the main branch, detection did not happen and the analysis was misfiled.

Both modes require Developer Edition or higher. On Community Build these properties do not enable anything (`plat-community-build-cannot-see-pull-requests`), and their presence in a configuration file is a reliable sign that a pipeline was written against documentation for a different edition.

Reference: [Setting up branch analysis](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/setting-up-the-branch-analysis) · [Setting up pull request analysis](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/setting-up-the-pull-request-analysis)

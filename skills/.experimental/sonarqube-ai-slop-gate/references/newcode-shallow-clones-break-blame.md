---
title: Check out full history or new code degrades to analysis timestamps
tags: newcode, scm, blame, ci
---

## Check out full history or new code degrades to analysis timestamps

CI checkout steps default to shallow clones because they are faster, and `fetch-depth: 1` is what most pipeline templates ship with. For SonarQube that setting removes the input the entire new-code mechanism runs on.

The documentation states the requirement twice, on two separate pages: *"A full Git clone is required. If a shallow clone is found, the blame information retrieval will be skipped and the analysis may fail."* The recommended setting is explicit: *"With Git, this means using `fetch-depth: 0`. This disables shallow clones and fetches all branches."*

"May fail" undersells the more dangerous outcome, which is that it succeeds. When blame is unavailable, SonarQube does not stop — it falls back: *"Without SCM data, SonarQube Server determines new code using analysis dates (to timestamp modification of lines)."* Attribution shifts from *who changed which line when* to *which lines were present at which analysis*. Whole files start reading as new because a build ran, issues get attributed to whoever triggered the pipeline, and the new-code period stops describing the change under review. The gate keeps producing verdicts; they are about something else.

Pull requests need more history than a single commit for a second reason: *"On pull requests, not just the last commit but all the commits that are not on the target branch are considered. This requires a history long enough to find the common commit."*

```yaml
- uses: actions/checkout@v7
  with:
    # Required. fetch-depth defaults to 1, which skips blame retrieval and
    # silently degrades new-code attribution to analysis timestamps.
    fetch-depth: 0
```

The tells that this has gone wrong are specific: *"'Missing blame information…' and 'Could not find ref…' can be caused by checking out with a partial / shallow clone, or using Git submodules."* Treat either warning in an analysis log as a broken gate rather than noise.

One smaller point that follows from the same mechanism: blame runs through JGit, so *"there's no need to have Git command line tool installed on the machine where analysis is performed"* — a slim CI image is fine, and a missing `git` binary is not the explanation when blame fails.

Related, for anyone not using a reference-branch definition: Sonar recommends fast-forward merges without a merge commit, so blame for merged commits always carries a more recent date. That advice is scoped to the other new code options, so it does not apply to the reference-branch setup `newcode-pick-the-definition-deliberately` recommends.

Reference: [Verifying the code checkout step](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scanners/scanner-environment/verifying-code-checkout-step) · [SCM integration](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scm-integration) · [Configuring new code calculation](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/configuring-new-code-calculation)

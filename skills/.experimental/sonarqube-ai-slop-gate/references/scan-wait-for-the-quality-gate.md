---
title: Set sonar.qualitygate.wait or the pipeline passes on a red gate
tags: scan, quality-gates, ci, blocking
---

## Set sonar.qualitygate.wait or the pipeline passes on a red gate

Analysis is asynchronous. The scanner uploads a report and exits successfully once the upload is accepted; the server then processes it and computes the gate. Those are separate events, and by default the pipeline does not wait for the second one.

`sonar.qualitygate.wait` defaults to **`false`**. With it unset, a scanner step exits 0 on every run where the upload succeeded — including runs whose gate goes on to fail. The build is green, the merge proceeds, and the failure is visible only to whoever opens the SonarQube UI afterwards. A gate that does not block is a dashboard.

Setting it changes the step into a blocking check: *"Forces the analysis step to poll the server instance and wait for the Quality Gate status. This setting will fail the pipeline if the quality gate fails."*

```properties
# Without this the scanner exits 0 as soon as the report is uploaded, long
# before the gate is computed.
sonar.qualitygate.wait=true

# Seconds to wait for report processing. Default 300; raise it for large
# repositories, where a timeout fails the build on a gate that would have passed.
sonar.qualitygate.timeout=600
```

Both properties are in the "parameters not settable in the UI" set, meaning they must be supplied on the CI host — as properties, `-D` flags, or the scan action's `args`. There is no server-side switch that makes every pipeline blocking, so this is per-pipeline configuration that has to be present in each repository, and its absence is the most common reason a correctly configured gate never blocks anything.

The timeout is worth tuning rather than leaving at 300 seconds. On a large monorepo, or an instance processing several reports concurrently, report processing can exceed five minutes; the scanner then fails the build having never learned the gate result. That failure is indistinguishable at a glance from a genuine gate failure, and the usual reaction — removing `wait` to stop the flakiness — silently reverts the pipeline to non-blocking.

**A failing job is not a blocked merge.** This property makes the CI job exit non-zero, and that is where most setups stop. Unless the SonarQube check is also marked as a *required status check* in the platform's branch protection rules, the merge button stays enabled and the red job is advisory. Configure both — the property makes the verdict visible to CI, branch protection makes it binding — and verify by opening a pull request that deliberately fails the gate and confirming the merge is actually refused.

Pair this with `plat-community-build-cannot-see-pull-requests`: waiting on the gate only blocks a merge if pull requests are analyzed at all, which the free tier does not do.

Reference: [Analysis parameters](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/analysis-parameters/parameters-not-settable-in-ui)

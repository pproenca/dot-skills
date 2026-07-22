---
title: Tune duplication thresholds per language, and skip the attempt on Java
tags: blind, duplication, cpd, java
---

## Tune duplication thresholds per language, and skip the attempt on Java

Sonar's duplication detector is deliberately conservative, and the defaults are coarse enough that assistant-generated near-copies slip under them. For non-Java languages a block counts as duplicated only when *"There should be at least 100 successive and duplicated tokens"* spread over *"10 lines of code for other languages"*. A thirty-line duplicated React component with renamed props may not reach one hundred identical tokens.

Those two numbers are tunable through `sonar.cpd.<language>.minimumTokens` (default 100) and `sonar.cpd.<language>.minimumLines` (default 10). Lowering them is the correct lever when duplication is the defect you are hunting.

**Java is the exception, and it fails silently.** Java uses a different algorithm — *"a piece of code is considered duplicated when there is a series of at least 10 statements in a row, regardless of the number of tokens and lines"* — and the documentation is explicit: *"This threshold cannot be overridden."* A `sonar.cpd.java.minimumTokens=60` line in a properties file is accepted by the scanner, appears in the analysis log's property dump, and does nothing. It reads as configuration and behaves as a comment.

```properties
# Tighten duplication detection for the languages where it is tunable.
# The placeholder is the language KEY, not its name: `py`, not `python`.
sonar.cpd.js.minimumTokens=60
sonar.cpd.ts.minimumTokens=60
sonar.cpd.py.minimumTokens=60

# sonar.cpd.java.minimumTokens has no effect — Java is fixed at 10 successive
# statements. Do not add it; it looks like a working control and is not.
```

Two further properties of the detector shape what it can see. *"Differences in indentation and in string literals are ignored while detecting duplications"* — helpful here, since it means a copy with changed literals still registers. And duplication detection is **entirely unsupported** for some languages: *"Duplication detection is not supported for Terraform and similar IaC languages, or for CSS."* A gate whose duplication condition is the primary control over a Terraform repository is measuring nothing at all.

Lower these thresholds gradually. Going straight to 30 tokens on a mature codebase surfaces every boilerplate constructor and DTO in the repository at once, and the usual response to that flood is to disable the condition — which is a worse outcome than the coarse default.

Reference: [Metrics definition](https://docs.sonarsource.com/sonarqube-server/user-guide/code-metrics/metrics-definition) · [Analysis parameters](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/analysis-parameters/parameters-not-settable-in-ui)

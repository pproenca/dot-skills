---
title: Do not expect the duplication gate to see generated test code
tags: blind, duplication, test-code, coverage
---

## Do not expect the duplication gate to see generated test code

Duplication is the defect most associated with assistant-generated code, and test files are where assistants duplicate most heavily — near-identical arrange/act/assert blocks, one per case, differing by a literal. Configuring `new_duplicated_lines_density` at 3% and expecting it to catch that is a reasonable inference and a wrong one.

SonarQube does not measure duplication on test code at all:

> "While test code quality impacts your quality gate, it's only measured based on the Maintainability and Reliability metrics in MQR Mode and Code Smells and Bugs metrics in Standard Experience. **Duplication and security issues are not measured on test code.**"

So a pull request adding six hundred lines of copy-pasted test cases scores 0% duplication on new code. The gate passes, and the metric that passed was never computed over the files in question. This compounds with the fudge factor (`blind-fudge-factor-skips-small-changes`): the two exemptions together account for most of what an AI-slop duplication gate is expected to catch.

The mitigation is not a configuration flag — there is no setting that turns duplication measurement on for test code. What works instead is making sure test code is *classified* as test code deliberately, so you know which files are exempt, and then covering the gap with rules rather than metrics, since Maintainability rules **do** apply to test files:

```properties
# Classify test code explicitly. Files not matched by sonar.tests are analyzed
# as production code — where duplication IS measured. Misclassification cuts
# both ways: too broad and real duplication becomes invisible.
sonar.sources=src
sonar.tests=src/test,tests,e2e

# S1192 (duplicated string literals, default threshold 3) fires on test files
# and feeds new_violations, which the gate does evaluate.
```

The practical consequence for gate design: **do not rely on `new_duplicated_lines_density` as the primary AI-slop signal.** It is blind to test code and skipped on small changes. `new_violations` fed by rules is the condition that actually evaluates on every change and every file class, which is why `blind-no-new-code-complexity-metric` routes complexity through rules as well.

A second-order effect worth checking: an over-broad `sonar.tests` pattern silently moves production files into the exempt class. If duplication density drops sharply after a scope change, compare the analyzed-file counts rather than assuming the codebase improved.

Reference: [Introduction to quality gates](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates) · [Analysis parameters](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/analysis-parameters/parameters-not-settable-in-ui)

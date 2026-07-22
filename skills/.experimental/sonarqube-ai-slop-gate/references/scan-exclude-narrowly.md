---
title: Exclude with the narrowest property, not sonar.exclusions
tags: scan, exclusions, duplication, metrics
---

## Exclude with the narrowest property, not sonar.exclusions

Generated code — protobuf stubs, OpenAPI clients, migrations — creates duplication noise, and the reflex is to add it to `sonar.exclusions`. That property is far broader than the problem. It *"Defines the source files (non-test files) to be excluded from **the analysis**"*, and files excluded that way are removed from analysis entirely: they stop counting toward `ncloc`, coverage, and duplication alike.

Removing files from `ncloc` is the part that does damage quietly, because `ncloc` is the **denominator** of the metrics the gate reads. `duplicated_lines_density` is `duplicated_lines / lines * 100`. Excluding a large generated tree shrinks the denominator, so the same amount of hand-written duplication now reports as a higher percentage — or, if the generated code itself contained the duplication, the metric drops and the codebase appears to have improved. Neither number is comparable with the one from before the change, and nothing marks the discontinuity.

Three narrower properties do the job without touching anything else:

| Property | Excludes from |
|---|---|
| `sonar.cpd.exclusions` | the duplication check only |
| `sonar.coverage.exclusions` | code coverage only |
| `sonar.test.exclusions` | test-code analysis (note: singular `test`) |

```properties
# Generated clients duplicate heavily and nobody maintains them by hand, but
# they are still real code — keep them in ncloc and in issue detection.
sonar.cpd.exclusions=**/generated/**,**/*_pb2.py,**/openapi/**

# Reserve sonar.exclusions for files that should not be analyzed at all —
# vendored dependencies, build output, minified bundles.
sonar.exclusions=**/node_modules/**,**/dist/**,**/*.min.js
```

The rule of thumb is to name the measurement you want to suppress rather than removing the file. If the complaint is "this generated code trips the duplication gate", the answer is `sonar.cpd.exclusions`; if it is "these files are not our code", `sonar.exclusions` is correct.

Two precedence facts matter when a setting appears not to apply: *"a parameter set on the CI/CD host has precedence over any UI setting of the same parameter"*, and *"The parameter defined at the project level will override the same parameter defined at the global level."* A properties file in the repository therefore beats the exclusions an administrator configured in the UI, which is a common source of "I excluded it and it is still being analyzed".

For suppressing specific *rules* on specific paths rather than whole measurements, the mechanism is the Issue Exclusions configuration under the project's analysis-scope administration — a different tool from these file-pattern properties, and the right one when the goal is "stop this one rule firing here".

Reference: [Excluding files based on patterns](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/setting-analysis-scope/excluding-files-based-on-patterns) · [Exclude from coverage and duplication](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/setting-analysis-scope/exclude-from-coverage-duplication)

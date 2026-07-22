---
title: Declare sonar.tests explicitly, which has no default
tags: scan, test-scope, configuration, coverage
---

## Declare sonar.tests explicitly, which has no default

`sonar.sources` has a sensible fallback — it defaults to `sonar.projectBaseDir`, so omitting it still analyzes the project. That symmetry does not extend to test code. The documentation is blunt: *"If this property is not defined, no code will be analyzed as test code as there is no default value."*

The consequence is not that tests go unanalyzed. It is that **test files are analyzed as production code**, because they still fall under `sonar.sources`. Every test file then counts toward `ncloc`, toward duplication density, and toward the lines the coverage ratio is computed over — so a repository with a large suite reports coverage diluted by the test files themselves, and duplication inflated by the repetitive assertions that a correctly configured project would exempt.

For an AI-slop gate this matters in both directions, and neither is obviously safer. Classified as production code, generated tests inflate duplication — which produces noisy failures but does at least surface the copy-paste. Classified as test code, they are exempt from duplication measurement entirely (`blind-test-code-escapes-duplication`). What you cannot afford is not knowing which of the two is happening.

```properties
sonar.sources=src
# No default. Unset means every test file is measured as production code.
sonar.tests=src/test,tests,e2e
```

One naming trap sits next to this, and the documentation flags it explicitly because it catches people repeatedly: the exclusion counterpart is **singular**. *"In this property key, the `test` string is in singular, unlike the `sonar.tests` property defining the initial scope"* — so it is `sonar.tests` to define scope but `sonar.test.exclusions` to narrow it. A `sonar.tests.exclusions` line is not a valid property and is ignored silently.

There is also an ordering effect worth knowing when both scopes are configured through inclusion patterns: *"If test file inclusion patterns are used, the scanner will automatically set these patterns as source file exclusion patterns during project analysis."* The two scopes are kept disjoint automatically, so a file matched as a test is removed from sources rather than counted twice.

Confirm the split after any change by comparing the analyzed file counts on the project's Code page rather than trusting the patterns to have matched what you intended.

Reference: [Analysis parameters](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/analysis-parameters/parameters-not-settable-in-ui) · [Excluding files based on patterns](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/setting-analysis-scope/excluding-files-based-on-patterns)

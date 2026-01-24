---
title: Assign Appropriate Severity Levels
impact: MEDIUM
impactDescription: enables prioritized issue triage
tags: org, severity, lint, diagnostics
---

## Assign Appropriate Severity Levels

Set severity levels that reflect the actual impact of rule violations. This enables developers to prioritize fixes and configure CI appropriately.

**Incorrect (everything is error):**

```yaml
id: prefer-const
severity: error  # Style preference shouldn't block CI

id: sql-injection
severity: warning  # Security issue should be error
```

**Correct (severity matches impact):**

```yaml
id: prefer-const
language: javascript
severity: hint  # Style suggestion
rule:
  pattern: let $VAR = $VAL
message: Consider using const for variables that are never reassigned
---
id: sql-injection
language: javascript
severity: error  # Security vulnerability
rule:
  pattern: db.query($QUERY)
message: Potential SQL injection vulnerability
```

**Severity level guidelines:**

| Severity | Use Case | CI Behavior |
|----------|----------|-------------|
| error | Security, correctness bugs | Fail build |
| warning | Likely bugs, deprecated usage | Warn, may fail |
| hint | Style preferences | Informational |
| off | Temporarily disabled | Skipped |

**Note field for context:**

```yaml
severity: error
message: Avoid eval() for security
note: |
  eval() executes arbitrary code, enabling code injection attacks.
  Use JSON.parse() for data or Function constructor for dynamic code.
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

---
title: Write Clear Actionable Messages
impact: MEDIUM
impactDescription: 2-5× faster issue resolution
tags: org, message, note, documentation
---

## Write Clear Actionable Messages

Write messages that explain what's wrong and how to fix it. Use `note` for detailed guidance and `labels` for precise highlighting.

**Incorrect (vague, unhelpful message):**

```yaml
id: bad-code
message: Bad code detected
```

**Correct (specific, actionable):**

```yaml
id: no-console-in-production
language: javascript
rule:
  pattern: console.$METHOD($$$ARGS)
message: Remove console.$METHOD() before deploying to production
note: |
  Console statements slow down execution and expose debugging
  information in production. Use a logging library instead:

  - logger.info() for informational messages
  - logger.error() for error tracking

  Or wrap in environment check: if (process.env.NODE_ENV === 'development')
```

**Using labels for precision:**

```yaml
id: missing-await
rule:
  pattern: $PROMISE
  inside:
    kind: expression_statement
    has:
      kind: call_expression
labels:
  - source: $PROMISE
    style: primary
    message: This promise is not awaited
```

**Message writing guidelines:**
- State the problem clearly
- Reference captured variables: `$METHOD`
- Provide the fix in `note`
- Include code examples in `note` when helpful
- Use labels to highlight specific code regions

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

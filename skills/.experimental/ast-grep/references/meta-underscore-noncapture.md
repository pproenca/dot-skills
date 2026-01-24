---
title: Use Underscore Prefix for Non-Capturing Matches
impact: CRITICAL
impactDescription: reduces memory allocation in hot paths
tags: meta, underscore, performance, non-capturing
---

## Use Underscore Prefix for Non-Capturing Matches

Prefix meta variables with underscore (`$_`) when you don't need their captured value. This avoids HashMap creation during matching, improving performance.

**Incorrect (captures values never used):**

```yaml
id: find-console-usage
language: javascript
rule:
  pattern: console.$METHOD($ARGS)
# $METHOD and $ARGS captured but never referenced
```

**Correct (underscore signals no capture needed):**

```yaml
id: find-console-usage
language: javascript
rule:
  pattern: console.$_METHOD($_ARGS)
message: Avoid console statements in production
```

**When to capture vs non-capture:**

```yaml
# Need the value for rewrite - capture it
id: migrate-console-to-logger
rule:
  pattern: console.log($MSG)
fix: logger.info($MSG)  # $MSG referenced in fix

# Just detecting presence - don't capture
id: find-console
rule:
  pattern: console.$_METHOD($_ARGS)
```

**Performance note:** Non-capturing variables can match different content at each occurrence in the same pattern, unlike capturing variables which enforce equality.

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

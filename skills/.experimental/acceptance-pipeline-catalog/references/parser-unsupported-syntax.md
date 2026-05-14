---
title: Reject Unsupported Gherkin Syntax
impact: CRITICAL
impactDescription: attempting to support 9 excluded syntax forms (tags, rules, localized keywords, etc.) creates non-portable behavior across conforming parsers
tags: parser, unsupported, tags, rules, localization, doc-strings
---

## Reject Unsupported Gherkin Syntax

The spec deliberately excludes several Gherkin features. This is not an oversight — it is a portability and simplicity decision. Each excluded feature adds parser complexity, IR fields, and downstream handling without contributing to the core pipeline goal of acceptance testing with mutation coverage.

### Excluded Syntax

| Syntax | Why Excluded |
|--------|--------------|
| **Tags** (`@tag`) | Filtering logic varies by project; not needed for mutation testing |
| **Rules** (`Rule:`) | Grouping construct that adds IR nesting without changing test execution |
| **Localized keywords** | Requires locale tables; English-only keeps parser simple and portable |
| **Escaped pipes** (`\|`) | Adds escape-handling complexity to table parsing |
| **Quoted table cells** | Ambiguous quoting rules across Gherkin implementations |
| **Multiline cells** | Breaks the one-row-per-line parsing model |
| **Doc strings** (`"""` / `` ``` ``) | Multi-line step data requires IR schema changes and handler protocol changes |
| **Data tables attached to steps** | Step-level tables need IR schema changes distinct from example tables |
| **Semantic comments** | Comments with meaning (`# @setup`) blur the line between comments and metadata |

### What Happens When Unsupported Syntax Appears

Lines that do not match supported syntax are treated as **free-form lines and ignored** (per the general parsing rules). This means a `@tag` line is silently dropped, not treated as an error.

The exception is structural violations — for example, an `Examples:` section outside a scenario is still an error. But decorative syntax like tags simply has no effect.

### Why This Matters

A small, deterministic syntax subset means every conforming parser produces identical IR for the same input. This is essential for the mutation testing model, which depends on stable, predictable IR structure. Adding optional syntax would create parser variants that produce different IR, breaking cross-tool compatibility.

Projects that need tags or rules can preprocess their Gherkin files before feeding them to this pipeline.

### Examples

**Incorrect (parser attempts to support tags, creating non-portable IR):**

```gherkin
@smoke @login
Feature: User Authentication
  Scenario: Login succeeds
    Given a valid user
```

```json
{
  "name": "User Authentication",
  "tags": ["smoke", "login"],
  "scenarios": [...]
}
```

**Correct (unsupported syntax silently ignored, clean portable IR):**

```json
{
  "name": "User Authentication",
  "scenarios": [
    {
      "name": "Login succeeds",
      "steps": [
        { "keyword": "Given", "text": "a valid user", "parameters": [] }
      ],
      "examples": []
    }
  ]
}
```

---
title: Account for Language-Specific Syntax Differences
impact: CRITICAL
impactDescription: prevents cross-language pattern failures
tags: pattern, language, syntax, parsing
---

## Account for Language-Specific Syntax Differences

Identical pattern strings parse differently across languages. Single quotes denote strings in JavaScript but character literals in C/Java.

**Incorrect (assumes JavaScript semantics in C):**

```yaml
id: find-char-literal
language: c
rule:
  pattern: 'a'  # Matches char literal, not string
message: Found character literal
```

**Correct (uses language-appropriate syntax):**

```yaml
id: find-string-literal
language: c
rule:
  pattern: '"hello"'  # C strings use double quotes
message: Found string literal
```

**When working with multiple languages:**
- Test each pattern in language-specific playground
- Create separate rules for similar languages (TypeScript vs JavaScript)
- Use `languageGlobs` only for true supersets

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

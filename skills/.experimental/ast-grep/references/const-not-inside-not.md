---
title: Avoid Constraints Inside Not Rules
impact: HIGH
impactDescription: prevents unexpected constraint behavior
tags: const, not, limitations, constraints
---

## Avoid Constraints Inside Not Rules

Constraints cannot be used inside `not` rules because `not` succeeds when nothing matches, leaving no node to constrain.

**Incorrect (constraint inside not):**

```yaml
id: find-non-private
language: javascript
rule:
  all:
    - kind: identifier
    - not:
        pattern: $NAME
        constraints:
          NAME:
            regex: ^_  # This won't work as expected!
```

**Correct (constrain outside not):**

```yaml
id: find-non-private
language: javascript
rule:
  all:
    - kind: identifier
    - pattern: $NAME
    - not:
        regex: ^_
constraints:
  NAME:
    kind: identifier
```

**Alternative (use regex directly in not):**

```yaml
id: find-non-private
language: javascript
rule:
  all:
    - kind: identifier
    - not:
        regex: ^_
```

**Why this happens:** Constraints filter captured meta variables. When `not` succeeds, nothing was captured, so there's nothing to constrain.

**Workaround strategies:**
1. Move constraint to outer rule
2. Use `regex` directly in `not` (atomic rule)
3. Restructure as positive match with constraint

Reference: [FAQ](https://ast-grep.github.io/advanced/faq.html)

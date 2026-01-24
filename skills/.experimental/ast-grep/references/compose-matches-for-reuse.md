---
title: Use Matches for Rule Reusability
impact: HIGH
impactDescription: enables DRY rule composition
tags: compose, matches, utility-rules, reuse
---

## Use Matches for Rule Reusability

The `matches` rule references utility rules by ID. Define common patterns once and reuse them across multiple rules.

**Incorrect (duplicates pattern logic):**

```yaml
id: rule-1
rule:
  all:
    - pattern: console.log($MSG)
    - inside:
        any:
          - kind: function_declaration
          - kind: arrow_function
---
id: rule-2
rule:
  all:
    - pattern: console.warn($MSG)
    - inside:
        any:
          - kind: function_declaration
          - kind: arrow_function
```

**Correct (utility rule for reuse):**

```yaml
# utils/inside-function.yml
id: inside-function
language: javascript
rule:
  inside:
    any:
      - kind: function_declaration
      - kind: arrow_function
---
# rules/no-console-log.yml
id: no-console-log
rule:
  all:
    - pattern: console.log($MSG)
    - matches: inside-function
---
# rules/no-console-warn.yml
id: no-console-warn
rule:
  all:
    - pattern: console.warn($MSG)
    - matches: inside-function
```

**Utility rule best practices:**
- Place in `utils/` directory
- Use descriptive IDs: `inside-function`, `is-exported`, `has-type-annotation`
- Reference with `matches: rule-id`
- Configure `utilsDirs` in `sgconfig.yml`

Reference: [Utility Rules](https://ast-grep.github.io/guide/project/utility-rule.html)

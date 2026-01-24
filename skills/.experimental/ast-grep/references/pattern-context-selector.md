---
title: Use Context and Selector for Code Fragments
impact: CRITICAL
impactDescription: enables matching incomplete code patterns
tags: pattern, context, selector, fragments
---

## Use Context and Selector for Code Fragments

Code fragments like object keys or function parameters cannot be parsed standalone. Use `context` to provide surrounding structure and `selector` to target the specific node.

**Incorrect (fragment cannot be parsed):**

```yaml
id: find-json-key
language: json
rule:
  pattern: '"name"'  # Invalid standalone JSON
```

**Correct (context provides structure, selector targets node):**

```yaml
id: find-json-key
language: json
rule:
  pattern:
    context: '{"name": $VAL}'
    selector: pair
```

**Common use cases:**
- Object keys: `context: '{key: $VAL}'` with `selector: pair`
- Function parameters: `context: 'function($PARAM) {}'` with `selector: formal_parameters`
- Array elements: `context: '[$ELEM]'` with `selector: array`

Reference: [Rule Configuration](https://ast-grep.github.io/guide/rule-config.html)

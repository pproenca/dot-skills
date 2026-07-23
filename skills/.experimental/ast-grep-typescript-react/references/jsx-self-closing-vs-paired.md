---
title: Match both self-closing and paired JSX elements
tags: jsx, self-closing, any, elements
---

## Match both self-closing and paired JSX elements

`<Icon />` and `<Icon></Icon>` are **different node kinds** in the grammar: the first is a `jsx_self_closing_element`, the second is a `jsx_element` (an `jsx_opening_element` + children + `jsx_closing_element`). A pattern written for one form never matches the other, so a rule like `<Icon $$$PROPS />` silently skips every `<Icon>…</Icon>` in the codebase. When a component can appear either way, match both with `any`.

```yaml
# Find <Icon> usage regardless of whether it self-closes.
language: tsx
rule:
  any:
    - pattern: <Icon $$$PROPS />
    - pattern: <Icon $$$PROPS>$$$CHILDREN</Icon>
```

If you only care that the element exists (not its children), matching on `kind: jsx_self_closing_element` plus `kind: jsx_element` under `any`, constrained by the tag name, is an alternative. But for most component-usage searches the two-pattern `any` above is the clearest.

Reference: [ast-grep pattern syntax](https://ast-grep.github.io/guide/pattern-syntax.html)

---
title: Rule Title in Imperative Form
tags: category-prefix, concept, concept
---

## Rule Title in Imperative Form

WHY (1-3 sentences): name the wrong default a capable model hits here when using
ast-grep against TypeScript/React code, and its concrete consequence — usually a
rule that silently matches nothing or a codemod that drops code. The model
generalizes from the reason, not the instruction.

```yaml
# The canonical way — a real ast-grep rule or CLI invocation with production
# realistic component/type names, never foo/bar. Verify node kinds with
# `ast-grep run --pattern '...' --lang tsx --debug-query=ast` before writing them.
language: tsx
rule:
  pattern: <RealComponent $$$PROPS />
```

Reference: [Source Title](https://ast-grep.github.io/relevant-page.html)

<!--
Use an Incorrect/Correct foil ONLY when the wrong way is a real, common trap
(e.g. a bare metavar in a JSX attribute value). Keep the diff minimal. Optional
sections: **When NOT to use this pattern:** for genuine exceptions.
-->

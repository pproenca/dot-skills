---
title: Preserve every JSX metavariable in the fix
tags: fix, rewrite, jsx, multi-meta
---

## Preserve every JSX metavariable in the fix

A `fix` template replaces the matched node wholesale — anything the pattern captured but the fix omits is **deleted**. When renaming a JSX element it is easy to write `fix: <NewName />` and silently drop every prop and child the old element carried. Capture props and children with multi-metavariables (`$$$PROPS`, `$$$CHILDREN`) and re-emit them verbatim.

```yaml
# Rename <Tooltip> to <HoverCard>, preserving all props and children.
language: tsx
rule:
  pattern: <Tooltip $$$PROPS>$$$CHILDREN</Tooltip>
fix: <HoverCard $$$PROPS>$$$CHILDREN</HoverCard>
```

Two things to expect: the rewrite is text-based, so it may **collapse the original indentation/newlines** onto one line — run your formatter (Prettier/Biome) over changed files afterward. And a paired element and a self-closing element are different nodes (see `jsx-self-closing-vs-paired`), so a rename usually needs an `any` with a second rule and a `fix: <HoverCard $$$PROPS />` for the `<Tooltip … />` form.

Reference: [ast-grep rewrite guide](https://ast-grep.github.io/guide/rewrite-code.html)

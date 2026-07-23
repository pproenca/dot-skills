---
title: Use the tsx language for any file containing JSX
tags: lang, jsx, tsx, typescript
---

## Use the tsx language for any file containing JSX

ast-grep treats `typescript` and `tsx` as two different grammars: `typescript` (aliases `ts`, `typescript`; extensions `.ts`/`.cts`/`.mts`) does **not** understand JSX, because in a `.ts` file `<Type>value` is a type assertion, not an element. Passing `--lang typescript` on a component parses the JSX into an `ERROR` node, so the rule matches nothing — with no failure, just empty output. Any pattern that touches JSX must run under `tsx`.

```bash
# A component file — JSX is present, so parse as tsx.
ast-grep run --pattern '<Button $$$PROPS />' --lang tsx src/components/Button.tsx

# --lang typescript here parses <div> as an ERROR node and silently matches nothing:
#   printf 'const x = <div>hi</div>' | ast-grep run -p '<div>$$$</div>' --lang typescript
#   → Warning: Pattern contains an ERROR node
```

The `--debug-query=ast` flag reveals the misparse: under `typescript`, a JSX pattern shows an `ERROR` node instead of `jsx_element`. When in doubt, debug the pattern before blaming the rule.

Reference: [ast-grep language list](https://ast-grep.github.io/reference/languages.html)

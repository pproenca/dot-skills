---
title: Cover both .ts and .tsx when scanning a React repo
tags: lang, sgconfig, languageglobs, monorepo
---

## Cover both .ts and .tsx when scanning a React repo

A React codebase mixes `.ts` (hooks, utilities, types) and `.tsx` (components), and ast-grep parses them with **different** grammars. A single rule with `language: tsx` silently skips every `.ts` file; `language: typescript` skips every `.tsx` file. The default of writing one rule and assuming it covers the repo therefore misses half the code.

Two correct approaches, depending on whether the rule touches JSX:

```yaml
# Rule targets JSX → it only applies to .tsx anyway; language: tsx is complete.
language: tsx
rule:
  pattern: <Suspense $$$PROPS>$$$CHILDREN</Suspense>
```

```yaml
# Rule targets plain TS (e.g. an import) and must hit BOTH .ts and .tsx.
# Force .ts files through the tsx grammar in sgconfig.yml so one rule covers both:
#   languageGlobs:
#     tsx: ['*.ts']
language: tsx
rule:
  pattern: import { $$$NAMES } from 'lodash'
```

**When NOT to use `languageGlobs: { tsx: ['*.ts'] }`:** the tsx grammar reads `<Type>value` type assertions as JSX, so a `.ts` file that uses angle-bracket casts will misparse. If your `.ts` code uses `<T>x` assertions, keep it on the `typescript` grammar and write a second rule (or use `as` casts, which parse identically under both).

Reference: [sgconfig.yml reference](https://ast-grep.github.io/reference/sgconfig.html)

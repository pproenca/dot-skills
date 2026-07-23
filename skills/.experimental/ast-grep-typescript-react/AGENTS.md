# ast-grep (TypeScript/React)

**Version 0.1.0**  
dot-skills  
July 2026

---

## Abstract

The TypeScript/React-specific wrong defaults when using ast-grep: the tsx-vs-typescript language split that makes JSX rules silently match nothing, JSX and TypeScript node kinds, fragment matching with context/selector, JSX/TS codemods, and the @ast-grep/napi API. Complements the general-purpose ast-grep skill, which covers language-agnostic rule mechanics. Every node kind and behavior was verified against ast-grep 0.44.1.

---

## Table of Contents

1. [Language Selection](references/_sections.md#1-language-selection)
   - 1.1 [Cover both .ts and .tsx when scanning a React repo](references/lang-scan-ts-and-tsx.md)
   - 1.2 [Use the tsx language for any file containing JSX](references/lang-tsx-for-jsx.md)
2. [Fragment Matching](references/_sections.md#2-fragment-matching)
   - 2.1 [Match TS/React fragments with context and selector](references/ctx-fragment-context-selector.md)
3. [JSX Node Kinds](references/_sections.md#3-jsx-node-kinds)
   - 3.1 [Match both self-closing and paired JSX elements](references/jsx-self-closing-vs-paired.md)
   - 3.2 [Place JSX attribute metavariables in a valid value position](references/jsx-attribute-metavars.md)
4. [TypeScript Constructs](references/_sections.md#4-typescript-constructs)
   - 4.1 [Distinguish type-only imports from value imports](references/ts-type-only-imports.md)
   - 4.2 [Match type casts as as_expression, not angle brackets](references/ts-as-expression-casts.md)
   - 4.3 [Target the type annotation to strip React.FC](references/ts-generic-react-fc.md)
5. [Rewrites & Codemods](references/_sections.md#5-rewrites-&-codemods)
   - 5.1 [Preserve every JSX metavariable in the fix](references/fix-jsx-rewrite-completeness.md)
6. [Programmatic Use](references/_sections.md#6-programmatic-use)
   - 6.1 [Parse with Lang.Tsx when scripting ast-grep over components](references/napi-lang-tsx-findall.md)

---

## References

1. [https://ast-grep.github.io/reference/languages.html](https://ast-grep.github.io/reference/languages.html)
2. [https://ast-grep.github.io/reference/sgconfig.html](https://ast-grep.github.io/reference/sgconfig.html)
3. [https://ast-grep.github.io/guide/api-usage/js-api.html](https://ast-grep.github.io/guide/api-usage/js-api.html)
4. [https://ast-grep.github.io/reference/yaml/transformation.html](https://ast-grep.github.io/reference/yaml/transformation.html)
5. [https://ast-grep.github.io/guide/pattern-syntax.html](https://ast-grep.github.io/guide/pattern-syntax.html)
6. [https://ast-grep.github.io/reference/rule.html](https://ast-grep.github.io/reference/rule.html)
7. [https://ast-grep.github.io/guide/rewrite-code.html](https://ast-grep.github.io/guide/rewrite-code.html)
8. [https://github.com/tree-sitter/tree-sitter-typescript](https://github.com/tree-sitter/tree-sitter-typescript)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
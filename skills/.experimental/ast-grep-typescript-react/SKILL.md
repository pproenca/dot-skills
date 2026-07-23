---
name: ast-grep-typescript-react
description: Use this skill when writing, debugging, or reviewing ast-grep patterns, YAML rules, or codemods against TypeScript or React (.ts/.tsx) code — searching for JSX elements, props, hooks, imports, or type constructs, and rewriting them. Covers the TS/React-specific traps — the tsx-vs-typescript language split, JSX and TypeScript node kinds, fragment matching, rewrites, and the @ast-grep/napi API. Complements the general-purpose ast-grep skill (rule mechanics) — reach for this one whenever the target code is TypeScript or React.
---

# ast-grep for TypeScript & React

The wrong defaults a capable model hits when pointing ast-grep at `.ts`/`.tsx` code — mostly cases where a rule **silently matches nothing** because the language or a node kind was guessed wrong. This skill assumes you already know ast-grep's rule mechanics (patterns, meta-variables, `all`/`any`/`has`/`inside`, constraints); it corrects only what TypeScript and React add on top.

For general ast-grep rule-writing mechanics, use the companion `ast-grep` skill.

## When to Apply

- Writing an ast-grep pattern or YAML rule whose target is `.ts` or `.tsx` code
- Searching for JSX elements, props, React hooks, imports, or TS type constructs
- Building a codemod that rewrites JSX or TypeScript (rename a component, strip `React.FC`, migrate imports)
- A rule "matches nothing" on TSX and you don't know why (usually the language or a node kind)
- Driving ast-grep programmatically from a JS/TS script via `@ast-grep/napi`

## First moves when a TS/React rule misbehaves

1. **Check the language.** JSX-bearing files must run under `tsx`, never `typescript`. This is the single most common cause of silent no-match. See [`lang-tsx-for-jsx`](references/lang-tsx-for-jsx.md).
2. **Debug the pattern's AST.** `ast-grep run --pattern '<your pattern>' --lang tsx --debug-query=ast` on a real snippet shows the node kinds and reveals `ERROR` nodes. Trust this over guessed kind names.
3. **Wrap fragments.** If the pattern is an attribute, prop, or type annotation, it needs `context` + `selector`. See [`ctx-fragment-context-selector`](references/ctx-fragment-context-selector.md).

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Language Selection | `lang` | tsx-vs-typescript split, scanning `.ts` + `.tsx`, `languageGlobs` |
| 2 | Fragment Matching | `ctx` | `context`/`selector` for JSX attrs, props, type annotations |
| 3 | JSX Node Kinds | `jsx` | self-closing vs paired elements, attribute-value metavariables |
| 4 | TypeScript Constructs | `ts` | type-only imports, `as` casts, `React.FC` generics |
| 5 | Rewrites & Codemods | `fix` | re-emitting JSX metavars so children/props aren't dropped |
| 6 | Programmatic Use | `napi` | `@ast-grep/napi` `Lang.Tsx`, `NapiConfig` shape |

## Quick Reference

### 1. Language Selection (lang)
- [`lang-tsx-for-jsx`](references/lang-tsx-for-jsx.md) — Use tsx for any JSX; typescript parses JSX as ERROR and matches nothing
- [`lang-scan-ts-and-tsx`](references/lang-scan-ts-and-tsx.md) — Cover both `.ts` and `.tsx`; `languageGlobs` for reuse (+ the `<T>`-cast caveat)

### 2. Fragment Matching (ctx)
- [`ctx-fragment-context-selector`](references/ctx-fragment-context-selector.md) — Wrap fragments (attrs, props, type annotations) in context/selector

### 3. JSX Node Kinds (jsx)
- [`jsx-self-closing-vs-paired`](references/jsx-self-closing-vs-paired.md) — `<X/>` and `<X></X>` are different kinds; match both with `any`
- [`jsx-attribute-metavars`](references/jsx-attribute-metavars.md) — Metavariables must sit in a valid attribute-value position

### 4. TypeScript Constructs (ts)
- [`ts-type-only-imports`](references/ts-type-only-imports.md) — Distinguish `import type` and inline `type` from value imports
- [`ts-as-expression-casts`](references/ts-as-expression-casts.md) — Match casts as `as_expression`, not angle brackets
- [`ts-generic-react-fc`](references/ts-generic-react-fc.md) — Strip `React.FC` by targeting the type annotation

### 5. Rewrites & Codemods (fix)
- [`fix-jsx-rewrite-completeness`](references/fix-jsx-rewrite-completeness.md) — Re-emit `$$$PROPS`/`$$$CHILDREN` or they're deleted

### 6. Programmatic Use (napi)
- [`napi-lang-tsx-findall`](references/napi-lang-tsx-findall.md) — Parse with `Lang.Tsx`; `findAll` takes a `NapiConfig`

## How to Use

Read the individual reference file for the decision you're making — each is self-contained with a canonical example. [references/_sections.md](references/_sections.md) defines the categories; [AGENTS.md](AGENTS.md) is the full compiled index.

## Related Skills

- `ast-grep` — general ast-grep rule-writing mechanics (patterns, composition, constraints, testing). This skill layers TS/React specifics on top of it.

# Sections

This file defines all sections, their ordering, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.
Categories are ordered by importance × frequency — the decisions that come up
most often and fail most silently in TypeScript/React work come first.

---

## 1. Language Selection (lang)

**Description:** Choosing the wrong `language` makes ast-grep parse JSX as an ERROR node and match nothing — no error, no output. `.ts` and `.tsx` are distinct languages; picking the right one (and reconciling both in one repo) is the first thing to get right.

## 2. Fragment Matching (ctx)

**Description:** Incomplete TS/React fragments (a JSX attribute, a prop, a type annotation) reparse as a different node when written as a bare pattern, so they silently mismatch. `context` + `selector` is how you match a fragment as the node you mean.

## 3. JSX Node Kinds (jsx)

**Description:** JSX splits into node kinds a model guesses wrong — self-closing vs paired elements are different kinds, and attribute values only accept metavariables in specific positions. Getting the kind right is the difference between matching and matching nothing.

## 4. TypeScript Constructs (ts)

**Description:** Type-only imports, `as` casts, and generic type annotations (`React.FC<Props>`) have their own node kinds distinct from their value-level look-alikes. Targeting the type node — not the value — is what makes type-focused rules and codemods correct.

## 5. Rewrites & Codemods (fix)

**Description:** JSX and TSX rewrites drop children, attributes, or captures unless every meta-variable is re-emitted in the fix. These rules cover the TS/React-specific rewrite traps.

## 6. Programmatic Use (napi)

**Description:** Driving ast-grep from a TypeScript toolchain via `@ast-grep/napi` carries the same `Tsx`-vs-`TypeScript` trap as the CLI, plus the `NapiConfig` shape the model gets wrong. These rules cover embedding ast-grep in JS/TS scripts.

---
name: react-19-component-scaffolder
description: Use this skill whenever scaffolding new React 19 / React 19.2 code in TypeScript — components, Server Component pages, client islands, form actions with useActionState, context providers, custom hooks, reducers, or document metadata + resource hints. Generates production-grade code that follows React 19 idioms (ref-as-prop, <Context value={...}>, useActionState, inline metadata, useSyncExternalStore) and refuses deprecated React 18 patterns (forwardRef, <Context.Provider>, useFormState, react-dom/test-utils). Trigger even when the user says "create a component", "new page", "add a form", "new hook", or "scaffold X" without explicitly mentioning React 19.
---

# React 19 Component Scaffolder

Generate React 19/19.2 components, pages, hooks, and supporting files from parameterized templates. Every template enforces the patterns codified in the sibling `react` skill — refs as regular props (never `forwardRef`), Context rendered directly as provider (never `.Provider`), form actions with `useActionState` + `useFormStatus`, inline document metadata, `useSyncExternalStore` for external subscriptions, and YMNNAE-compliant hook bodies.

## When to Apply

- Creating a new React component (Server, Client, or unspecified — defaults to Server)
- Adding a new route/page in a React 19 app
- Building a form that needs progressive enhancement, optimistic UI, or pending state
- Setting up a new Context provider with state + dispatch split
- Writing a custom hook that subscribes to external state or wraps async work
- Modeling complex state with a typed reducer
- Adding document metadata (`<title>`, `<meta>`, `<link>`) or resource hints (`preload`, `preconnect`, `prefetchDNS`)
- The user says "scaffold", "boilerplate", "generate", "new component", "new page", "new hook", or names any of the template types

## Available Templates

All filenames are kebab-case; the exported React identifier (`{Name}`, `use{Name}`) is PascalCase / camelCase.

| # | Template | When to use | Files generated |
|---|----------|-------------|-----------------|
| 1 | [function-component](assets/templates/function-component.tsx.template) | Generic reusable component (works in Server or Client) | `{name-kebab}.tsx`, `{name-kebab}.test.tsx` |
| 2 | [server-component-page](assets/templates/server-component-page.tsx.template) | Route page with server data fetch + Suspense + metadata | `page.tsx` |
| 3 | [client-island](assets/templates/client-island.tsx.template) | `'use client'` interactivity nested inside a server page | `{name-kebab}-island.tsx`, `{name-kebab}-island.test.tsx` |
| 4 | [form-action](assets/templates/form-action.tsx.template) | Mutation form with `useActionState` + Zod schema + server action | `{name-kebab}-form.tsx`, `actions.ts`, `schema.ts` |
| 5 | [context-provider](assets/templates/context-provider.tsx.template) | Shared state with state/dispatch split and accessor hook | `{name-kebab}-context.tsx` |
| 6 | [custom-hook](assets/templates/custom-hook.ts.template) | YMNNAE-compliant hook (external subscription or composed effect) | `use-{name-kebab}.ts`, `use-{name-kebab}.test.ts` |
| 7 | [reducer](assets/templates/reducer.ts.template) | Typed reducer with discriminated-union actions + exhaustive switch | `{name-kebab}-reducer.ts`, `{name-kebab}-reducer.test.ts` |
| 8 | [head-and-hints](assets/templates/head-and-hints.tsx.template) | Document metadata + resource hints for above-the-fold assets | `{name-kebab}-head.tsx` |

## How to Use

1. **Identify the template** that matches the user's request. If ambiguous, ask. Default to `function-component` for unqualified "make me a component" requests.
2. **Read the template** at `assets/templates/{name}.template`.
3. **Read the related conventions** at `references/conventions.md` — every template emits code that obeys these conventions.
4. **Collect parameters** (see "Parameters" below). Ask the user only for parameters you cannot infer from context.
5. **Substitute placeholders** in the template. Every placeholder is wrapped in `{curly_braces}`. Empty placeholders (e.g., `{additional_hooks}` when there are none) collapse to empty string.
6. **Write each output file** using the Write tool. Use the path conventions in `config.json` (`module_path`, `route_path`).
7. **Mention the conventions enforced** so the user understands why the generated code looks the way it does (e.g., "I used `ref` as a prop rather than `forwardRef` because…").

## Parameters

Common parameters (most templates accept these):

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `name` | yes | — | Component / hook / reducer identifier in PascalCase (or camelCase for hooks/reducers). The scaffolder derives `file_name` (kebab-case) and `name_kebab` automatically. |
| `module_path` | no | `src/components` (or from `config.json`) | Directory under the project root for the generated files |
| `props` | no | `[]` | List of `{name, type, required}` — emitted as the props interface |
| `with_test` | no | `true` | Generate the matching `*.test.tsx` / `*.test.ts` file |
| `with_ref` | no | `false` | Add `ref?: Ref<T>` to props (templates 1 and 3) |

Template-specific parameters are documented in each template's leading comments.

## Setup

On first use, populate `config.json` with project-specific paths so generated files land in the right place. The defaults assume a standard `src/`-rooted project. To override interactively:

- `module_path` — Where components live (e.g., `src/components`, `app/_components`)
- `route_path` — Where Server Component pages live (e.g., `app/`, `src/routes/`)
- `hooks_path` — Where custom hooks live (e.g., `src/hooks`)
- `test_runner` — `vitest` (default) or `jest` (changes the imports in test templates)

## Conforming Existing Code (Multi-File Refactor)

When the user asks to **conform, modernize, or align existing components with this skill's conventions** across one or more files — not to generate new code — follow [`references/_conform-algorithm.md`](references/_conform-algorithm.md) instead of going file-by-file.

Two non-negotiables from that doc:

1. **Judgment over grep.** Every convention is keyed off a syntactic marker (`forwardRef`, `<Context.Provider>`, `react-helmet`, `onSubmit=`, `react-dom/test-utils`). Grep finds the easy cases and *misses* the disguised ones — a manually drilled callback ref because the author dodged `forwardRef`, a bespoke `useState({ pending, error })` that's `useActionState` without the name, a `document.title` hand-roll. Use grep for inventory and post-hoc completeness only, never as the primary detector.
2. **Convention-major, not file-major.** Load all target files first, then sweep one convention at a time across all files in priority order (refs/context/forms first, naming/imports last). Reports group by convention, surfacing cross-file clusters.

For brand-new scaffolds, skip this — go straight to a template.

## React 19 Patterns This Skill Refuses to Generate

- `forwardRef(...)` wrappers — emits `function Name({ ref, ...props })` instead
- `<Context.Provider value={...}>` — emits `<Context value={...}>` instead
- `useFormState` — emits `useActionState` instead
- `onSubmit` handlers for mutations — emits `<form action={serverAction}>` instead
- `useRef<T>()` without an argument — emits `useRef<T>(null)`
- `useEffect` for derived state, parent notification, or POST-on-state-change — refuses entirely (see [conventions: State derivation](references/conventions.md))
- `react-dom/test-utils` — emits `import { act } from '@testing-library/react'` instead
- Manual `<link rel="preload">` JSX — emits `preload()` from `react-dom` instead
- `react-helmet` / `react-helmet-async` — emits inline `<title>`/`<meta>`/`<link>` instead

## Gotchas

See [gotchas.md](gotchas.md). Empty on first release — gotchas accumulate as the skill is used.

## Related Skills

- [`react`](../react/SKILL.md) — Authoritative React 19 best-practices distillation (44 rules). The templates in this skill emit code that conforms to those rules.

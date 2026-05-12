# React 19 Scaffolding Conventions

These are the conventions every template enforces. Each one is here because not following it has caused real problems — the rationale matters more than the rule.

## Placeholder substitution rules

Templates use `{placeholder_name}` syntax. The full placeholder reference for each template lives in its header comment block — read it before substituting. General rules:

- **Single token** (`{Name}`, `{name_kebab}`): expands to a single identifier with no surrounding whitespace.
- **Block content** (`{prop_definitions}`, `{action_test_cases}`, `{content_body}`): expands to one or more complete lines, each with its own trailing `\n`. Indent inside the block matches the position of the placeholder.
- **Comma-prefixed lists** (`{additional_react_hooks}`, `{optimistic_import}`): expand to `, item1, item2` when present, empty string when absent. Templates expect the leading comma.
- **Optional lines** (`{with_ref_prop}`, `{with_children_prop}`): expand to a complete line including its `\n`, or empty string. Two consecutive optional lines safely collapse to nothing.
- **Optional imports** (`{additional_type_imports}`, `{reducer_import}`): expand to zero or more full `import ...` lines, each ending in `\n`, or empty string.

When a placeholder is absent, substitute the empty string — never leave the literal `{...}` in the output.

---


## File naming: kebab-case files, PascalCase components

Files use kebab-case (`user-card.tsx`); the exported React component uses PascalCase (`UserCard`).

**Why:** macOS is case-insensitive by default; Linux CI is case-sensitive. Mixed-case filenames cause "works on my machine, fails in CI" bugs. The kebab-case file / PascalCase component split keeps the component identity readable in JSX while staying portable on disk.

**Exception:** Next.js route files (`page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`) keep their framework-mandated names.

## Refs: regular prop, never `forwardRef`

Templates emit:

```tsx
interface InputProps {
  ref?: Ref<HTMLInputElement>
  placeholder?: string
}
function Input({ ref, placeholder }: InputProps) { /* ... */ }
```

Not:

```tsx
const Input = forwardRef<HTMLInputElement, InputProps>(/* ... */)
```

**Why:** React 19 made `ref` a regular prop on function components. `forwardRef` will be deprecated in a future major. New code using `forwardRef` is born deprecated. The codemod path (`npx codemod@latest react/19/replace-forwardRef`) goes one direction — we generate code that doesn't need it.

## Context: `<Context value={...}>`, never `.Provider`

Templates emit:

```tsx
<UserContext value={user}>{children}</UserContext>
```

Not:

```tsx
<UserContext.Provider value={user}>{children}</UserContext.Provider>
```

**Why:** Same as refs — `.Provider` is the legacy syntax. React 19 rewrote the React developer surface to make `Context` directly renderable.

## `useRef<T>(null)` — always pass an initial value

Templates emit:

```ts
const inputRef = useRef<HTMLInputElement>(null)
```

Not:

```ts
const inputRef = useRef<HTMLInputElement>()
```

**Why:** React 19 made the argument required (TypeScript breaking change). The single-argument form is also clearer — readers see immediately what the ref starts as.

## Forms: server action, never `onSubmit` for mutations

Templates emit:

```tsx
<form action={createUser}>
```

Not:

```tsx
<form onSubmit={(e) => { e.preventDefault(); createUser(/* ... */) }}>
```

**Why:** Form actions work without JavaScript (progressive enhancement). They eliminate `preventDefault` boilerplate. They integrate with `useActionState`, `useFormStatus`, and `useOptimistic` for pending and optimistic UI. Reaching for `onSubmit` regresses to React 18.

**Exception:** Client-only forms with no server (e.g., a search box driving a router push). Even there, `<form action={fn}>` with a client-side function is the cleaner pattern.

## Server Components by default, Client Components by exception

Templates default to no `'use client'`. The client island template (`client-island.tsx.template`) is the only one that emits the directive, and only because that's its purpose.

**Why:** `'use client'` boundaries become bundle inclusions. The lower in the tree the boundary lives, the less JavaScript ships. The default of "Server Component unless we explicitly need state, event handlers, or browser APIs" produces smaller bundles.

## Test imports: `act` from `react`, never `react-dom/test-utils`

Test templates emit:

```ts
import { act } from '@testing-library/react'
// or, when needed standalone:
import { act } from 'react'
```

**Why:** `react-dom/test-utils` was removed in React 19. The codemod (`npx codemod@latest react/19/replace-act-import`) moves to `react`. New test files should never grow that import.

## Custom hook naming: `use{Verb}{Noun}` or `use{Noun}`

Templates emit `useToggleTheme`, `useDebouncedValue`, `useUserPreferences` — verbs when the hook drives a behavior, plain noun when it exposes state.

**Why:** Disambiguates side-effecting hooks from pure-read hooks. `useTheme()` reads; `useToggleTheme()` toggles. Mixing the two in the same code becomes confusing.

## State derivation: render-time, not effects

The custom-hook and reducer templates have NO `useEffect` calls for derived state. If the value can be computed from props/state, it is — `const fullName = `${first} ${last}``.

**Why:** Effects for derived state cause extra render passes and create sync holes (state can be stale between updates). [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect) catalogues a dozen variants of this anti-pattern. We refuse to generate any of them.

## External subscriptions: `useSyncExternalStore`, not manual `useEffect` + listeners

The custom-hook template offers a `subscribe_target` parameter; when set, it generates a `useSyncExternalStore` skeleton, not an effect-based subscription.

**Why:** `useSyncExternalStore` is tearing-free in concurrent rendering, SSR-safe via the third argument, and has the cleanup wired in for you. Manual `useEffect` + `addEventListener` is a pre-React-18 pattern.

## Exhaustive switches in reducers

The reducer template ends every switch with:

```ts
default:
  return assertNever(action)
```

**Why:** Adding a new action variant without handling it becomes a TypeScript error rather than a silent runtime fall-through. The cost is one helper function; the value is catching unhandled actions at compile time.

## Server-side validation, always

The form-action template's `actions.ts` always calls `schema.safeParse(raw)` on the server. Client-side validation is optional cosmetic; server-side validation is non-negotiable.

**Why:** Client-side validation can be bypassed (disable JS, edit the DOM, hit the action directly). The server is the only place where validation is enforceable. Skipping server validation is a security bug, not a style choice.

## Imports: framework → external → internal → relative, blank line between groups

Templates lay out imports in four blocks separated by blank lines:

```ts
import { useState } from 'react'              // framework
import { useFormStatus } from 'react-dom'

import { z } from 'zod'                       // external

import { db } from '@/lib/db'                 // internal alias

import { schema } from './schema'             // relative
```

**Why:** Auto-formatters (Biome, Prettier with plugins, ESLint `import/order`) all agree on this grouping. Keeping the convention prevents merge churn from formatter disagreements. The visual grouping also makes "is this a third-party import?" obvious at a glance.

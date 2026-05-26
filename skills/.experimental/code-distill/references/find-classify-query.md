---
title: Classify the query before grepping — component, composition, state, effect, error, build, routing
tags: find, classification, query-routing
---

## Classify the query before grepping — component, composition, state, effect, error, build, routing

By default the agent takes the user's keywords ("design system", "composition", "effect handling") and runs `grep` against them directly. This produces hundreds of false positives — `grep "effect"` in any React repo hits every `useEffect` call site. The move is to **classify the query into a recognizable kind first** — each kind has its own grep targets, folder hints, and file-extension filters. The classification takes seconds and cuts the search space by 10× or more.

```text
Query kind          Grep targets                Folder hints
─────────────────────────────────────────────────────────────────────
Component           class names; export const   src/components/, ui/,
  "design system"   <Capitalized>; cva, tv;     registry/, packages/<ui>/
  "tokens"          tailwind.config, tokens.ts

Composition         Slot, asChild, Comp =,      components with both
  "slot props"      Children, cloneElement;     <X.Root> and <X.Trigger>
  "compound"        forwardRef + children

State management    Provider, Context, store,   src/state/, store/,
  "global state"    create, atom, signal,       contexts/, providers/
  "store"           subscribe, dispatch

Effects / async     Effect., Layer., gen, pipe; tests using effect/test;
  "effect-ts"       useEffect with deps;        examples/ for runtime use
  "side effects"    Promise.all, AbortController

Error handling      throw new <Lib>Error,       errors.ts, exceptions.ts,
  "error model"     Result, Either, Option,     boundaries/
                    ErrorBoundary, catch +
                    instanceof

Build / bundling    rollup, vite, esbuild,      build/, scripts/, package.json
  "exports"         "exports" in package.json   "files", "main", "module"
  "tsconfig"        tsconfig.json paths

Routing             Route, useNavigate, href,   app/, pages/, routes/,
  "navigation"      <Link>, redirect,           middleware files
                    middleware
```

The mechanical trigger: before any `Grep` or `Bash grep` call, state the query kind out loud (even silently). If you cannot classify it, ask the user to clarify what kind of thing they want to see — "component" and "composition" can blur together, "state" and "effect" can overlap in some libraries, and grepping under the wrong category wastes the entire session.

If the query crosses two kinds (e.g. "how does shadcn compose its components into a design system" — both *component* AND *composition*) run the classifications sequentially, not in one mixed grep.

Anti-pattern: searching for vague nouns from the user's prompt ("system", "handling", "approach") as if they were code identifiers. Those words live in prose, not source. Translate them to the closest kind, then grep for the kind's targets.

Reference: [Diátaxis — the same kind of question-classification discipline applied to documentation; transfers to code search](https://diataxis.fr/)

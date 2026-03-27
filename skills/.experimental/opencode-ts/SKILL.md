---
name: opencode-ts
description: Write and refactor TypeScript code that fits the opencode codebase. Use this skill when implementing features, fixing bugs, writing tests, or refactoring in opencode or opencode-style repos that use Effect services, Zod schemas, event-sourced persistence, and namespace-driven architecture. Triggers on tasks involving TypeScript code in packages/opencode, session/tool/provider changes, new service modules, test writing, route handlers, or schema definitions.
---

# Opencode TypeScript

Code like the opencode core team. This skill contains real code extracted from the repo — complete implementations, not abstract rules. Follow the workflow below based on your task.

---

## Implement (new code)

Follow these phases in order:

### 1. Orient — where does this go?

Load [architecture.md](references/architecture.md). Find:
- Which module owns this behavior
- What the dependency direction allows
- What file naming convention to follow
- Whether this is a new module or an addition to an existing one

### 2. Gather — what already exists?

Load [helpers-deep-dive.md](references/helpers-deep-dive.md). Before writing ANY utility:
- Check if it already exists in `util/`, `effect/`, `bus/`, `sync/`
- Check the usage matrix to see how other modules use it
- If it exists, use it. If it doesn't, inline first — extract only when awkwardness repeats.

For quick lookups: [primitives.md](references/primitives.md) (shorter, import paths + signatures only)

### 3. Build — write the code

Load the reference that matches what you're building:

| Building... | Load this |
|---|---|
| Service module (namespace + Effect service + schemas + events) | [service-module.md](references/service-module.md) |
| Tool or modifying tool behavior | [tool-module.md](references/tool-module.md) |
| Database tables, schemas, events, error types | [schemas-and-state.md](references/schemas-and-state.md) |
| Server routes, config, plugins, project lifecycle | [server-and-routes.md](references/server-and-routes.md) |
| Tests | [test-writing.md](references/test-writing.md) |

### 4. Check — does it smell right?

Load [style-dna.md](references/style-dna.md). Verify:
- Single-word variable names where clear
- No `try`/`catch`, no `else`, no `any`, no unnecessary destructuring
- `const` + ternary over `let` + mutation
- snake_case Drizzle fields, `.meta({ref})` on boundary schemas
- Effect is used for services, not plain async classes

### 5. Review — would the core team accept this?

Load [review-voice.md](references/review-voice.md). Self-check against real reviewer feedback:
- Would Dax or Aiden push back on any of this?
- Am I adding abstraction they'd ask to remove?
- Am I renaming things that don't need renaming?
- Is the diff minimal for what I'm changing?

---

## Refactor (changing existing code)

### 1. Orient — what touches what?

Load [architecture.md](references/architecture.md). Map the blast radius before changing anything.

### 2. Study — what do good transitions look like?

Load [refactoring-patterns.md](references/refactoring-patterns.md). See real before/after diffs from the core team:
- Simplification patterns (removing unnecessary abstraction)
- Consolidation patterns (merging scattered files)
- Migration patterns (moving to Effect services)
- Deletion patterns (removing dead code)

### 3. Gather — can an existing utility replace this code?

Load [helpers-deep-dive.md](references/helpers-deep-dive.md). The best refactor often replaces 20 lines with one utility call.

### 4. Check + Review

Same as implement phases 4-5: [style-dna.md](references/style-dna.md) then [review-voice.md](references/review-voice.md).

---

## Key decisions (always apply)

- **Effect is mandatory** — all services use `Context.Tag` / `Layer` / `makeRuntime`. No plain async classes.
- **Namespace ownership** — one `export namespace X {}` per feature, one file until real split pressure.
- **Zod for boundaries, Effect Schema for internals** — Zod + `z.infer` for DTOs/tool params. `Schema.TaggedErrorClass` for Effect errors. `Newtype` for branded IDs.
- **Event-sourced writes** — mutations go through `SyncEvent.run` → projectors → SQLite. Direct DB writes only for non-event-sourced features.
- **No mocks in tests** — use `tmpdir` + `Instance.provide` + real services. Mocks only for external SDKs.
- **Single-word variables** — `state`, `pending`, `info`, `row`, `cfg`, `tx`. Multi-word only when genuinely ambiguous.

---

## Reference index

| File | Size | What it contains |
|------|------|-----------------|
| [style-dna.md](references/style-dna.md) | 18K | Mandatory style rules, naming, control flow, 14 review traps |
| [primitives.md](references/primitives.md) | 22K | Quick-lookup: every utility with import path + signature |
| [helpers-deep-dive.md](references/helpers-deep-dive.md) | ~40K | Full deep-dive: every utility, every usage site, when NOT to use |
| [architecture.md](references/architecture.md) | ~30K | Module map, dependency graph, data flow, file conventions |
| [service-module.md](references/service-module.md) | 27K | Complete Question + Permission implementations |
| [tool-module.md](references/tool-module.md) | 28K | Full tool implementations, registry, prompt loop |
| [test-writing.md](references/test-writing.md) | 42K | 5 complete test files with all fixture patterns |
| [schemas-and-state.md](references/schemas-and-state.md) | 36K | SQL tables, Zod/Effect schemas, SyncEvent flow, errors |
| [server-and-routes.md](references/server-and-routes.md) | 32K | Routes, config, plugins, project lifecycle |
| [review-voice.md](references/review-voice.md) | ~25K | Real PR review comments from Dax + Aiden |
| [refactoring-patterns.md](references/refactoring-patterns.md) | ~25K | Real before/after diffs from cleanup commits |

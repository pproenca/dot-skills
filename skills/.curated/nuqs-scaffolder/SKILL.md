---
name: nuqs-scaffolder
description: Use this skill whenever you need to add URL-state filters to a Next.js page, build a typed `searchParams.ts` parser map, or wire up a `<Filters />` client component backed by `useQueryStates`. From a single JSON spec, generates four files in lockstep — client parser map, server loader/cache/serializer, client component, and Vitest test — all sharing the same parser definitions per the nuqs Standard Schema pattern. Trigger even when the user only says "add filters to /search" or "I need a typed query string for this page" — both are exactly this skill's job.
---

# nuqs Scaffolder

Generate a coherent set of nuqs files from one spec. The skill is **template-driven** — you read the spec, copy the templates, and substitute placeholders. No build step, no codegen runtime; the templates ARE the artifact.

## When to Apply

Use this skill when:
- A new Next.js page needs URL-backed filters, pagination, search, or sort state
- You're standardising an existing page's ad-hoc `useState` filters onto nuqs
- A code review keeps catching client/server drift in parser definitions — this skill makes drift mechanically impossible because both sides import the same map
- A user asks to "add Standard Schema validation to these query params for tRPC" — the generated `searchParams.server.ts` already exports the schema

If the codebase has legacy nuqs patterns instead, run the [`nuqs-codemod-runner`](../nuqs-codemod-runner/) skill first.

## How to Use

1. **Read or create a spec.** Start from `assets/templates/spec.template.json` and fill in `name`, `module`, and `params`. See "Spec Format" below.
2. **Render each template** by replacing placeholders with values derived from the spec.
3. **Write each rendered file** to the path computed from `config.json` (overridable per-call).
4. **Show the user the diff before committing** — this skill never modifies existing files; if a target path exists, ask before overwriting.

The agent does the rendering — Claude is the templating engine. Each template is annotated with markers (`/*= ... =*/`) that name the placeholder slot and document the substitution rule.

## Spec Format

```jsonc
{
  "name":   "Search",                    // PascalCase — drives the exported symbol names
  "module": "search",                    // kebab-case — drives file paths and the "module" folder

  "params": {
    "q":          { "type": "string",                                    "default": "" },
    "page":       { "type": "integer",                                   "default": 1 },
    "limit":      { "type": "integer",                                   "default": 10 },
    "categories": { "type": "array-of-string-native",                    "default": [] },
    "sort":       { "type": "string-literal", "values": ["asc","desc"],  "default": "asc" },
    "minPrice":   { "type": "float",                                     "default": null },
    "lastSeen":   { "type": "iso-date",                                  "default": null }
  }
}
```

### Supported `type` values

| `type` | Parser used | Notes |
|--------|-------------|-------|
| `string` | `parseAsString` | |
| `integer` | `parseAsInteger` | |
| `float` | `parseAsFloat` | |
| `boolean` | `parseAsBoolean` | |
| `iso-date` | `parseAsIsoDate` | Date-only |
| `iso-date-time` | `parseAsIsoDateTime` | Date + time |
| `timestamp` | `parseAsTimestamp` | ms since epoch |
| `hex` | `parseAsHex` | Numeric value, hex URL form |
| `index` | `parseAsIndex` | 0-based in code, 1-based in URL |
| `array-of-string` | `parseAsArrayOf(parseAsString)` | `?tags=a,b,c` |
| `array-of-string-native` | `parseAsNativeArrayOf(parseAsString)` | `?tag=a&tag=b` — requires nuqs ≥ 2.7 |
| `string-literal` | `parseAsStringLiteral(values)` | Requires `values: string[]` |
| `number-literal` | `parseAsNumberLiteral(values)` | Requires `values: number[]` |
| `json` | `parseAsJson(SchemaName.parse)` | Generates a Zod schema stub; mark `default` separately |

If `default` is `null`, the param is nullable; otherwise the template uses `.withDefault(...)`.

## Available Templates

| Template | Renders to (default) | Loaded when |
|----------|----------------------|-------------|
| [`searchParams.ts.template`](assets/templates/searchParams.ts.template) | `lib/{module}-search-params.ts` | Always |
| [`searchParams.server.ts.template`](assets/templates/searchParams.server.ts.template) | `lib/{module}-search-params.server.ts` | Always |
| [`filters.tsx.template`](assets/templates/filters.tsx.template) | `components/{module}/{name}-filters.tsx` | Always |
| [`filters.test.tsx.template`](assets/templates/filters.test.tsx.template) | `components/{module}/{name}-filters.test.tsx` | If `config.generate_tests` is true |
| [`spec.json.template`](assets/templates/spec.json.template) | Anywhere — starter for the user | First-run prompt |

Template files end in `.template` so editors don't apply syntax highlighting to placeholder markers — the original extension is preserved as the suffix-before-`.template` so you can still tell at a glance what the rendered file will be.

Paths are configurable in `config.json` — override globs, file naming style (kebab vs PascalCase), and whether tests are emitted.

## Placeholder Reference

All templates use the same placeholder syntax. The agent substitutes them in one pass:

| Placeholder | Source | Example |
|-------------|--------|---------|
| `__NAME__` | `spec.name` | `Search` |
| `__name__` | camelCase form of `spec.name` | `search` |
| `__module__` | `spec.module` | `search` |
| `/*= PARSERS =*/` | Iterate `spec.params` → `key: parseAsXxx.withDefault(...)` lines | see template |
| `/*= COMPONENT_FIELDS =*/` | Iterate `spec.params` → one input/select per type | see template |
| `/*= TEST_CASES =*/` | Iterate `spec.params` → one assertion per default | see template |
| `/*= NULLABLE_IMPORTS =*/` | Add `Nullable` helper import if any param is nullable | conditional |
| `/*= ZOD_SCHEMAS =*/` | For `json` type params, emit a Zod schema stub | conditional |

`/*= ... =*/` markers are **instructions to the agent**, not literal substitutions. Replace the entire marker (including the `/*= =*/` delimiters) with the expanded content.

## Conventions

Read [`references/conventions.md`](references/conventions.md) for:
- File naming (kebab-case) and why
- Import ordering (external → nuqs → internal → relative) and why
- Why the server file exists as a sibling, not inside `app/`
- When to fork the templates (you usually shouldn't)

## Setup

`config.json` is pre-populated with sensible Next.js App Router defaults. Override only if your repo uses different conventions:

```jsonc
{
  "lib_dir": "lib",
  "components_dir": "components",
  "generate_tests": true,
  "test_runner": "vitest"
}
```

On first use, the agent should ask the user for the spec via `AskUserQuestion` if no spec file is provided.

## Related Skills

- [`nuqs`](../nuqs/) — Best-practice reference these templates encode. Read it to understand WHY the templates are shaped this way.
- [`nuqs-codemod-runner`](../nuqs-codemod-runner/) — Run BEFORE this skill if migrating an existing page from pre-v2.5 nuqs.

## Gotchas

See [`gotchas.md`](gotchas.md) for edge cases discovered during use.

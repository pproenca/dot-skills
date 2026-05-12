---
name: base-ui-migrator
description: Use this skill whenever the user wants to migrate React UI code to Base UI (`@base-ui/react`) — replacing bespoke modals, custom dropdowns, raw `<dialog>`/`<select>` elements, ad-hoc popovers/menus/tooltips, or other component libraries (Radix UI, Headless UI, Reach UI). Triggers on phrases like "migrate to base-ui", "use base-ui instead of X", "replace this dialog/popover/menu with base-ui", or when scanning a React codebase for components Base UI can replace. The skill ships a 37-component catalog (snapshotted from base-ui.com/llms.txt) and scripts to refresh it, scan for migration candidates, and verify the migration compiles. Trigger even if the user only mentions one component (e.g., "swap this modal for base-ui dialog") — the workflow scales from one file to a whole repo.
---

# Base UI Migrator

Automated workflow that converts bespoke React UI primitives and other component libraries to [Base UI](https://base-ui.com) (`@base-ui/react`).

Base UI is the unstyled successor to Radix UI, maintained by the Material UI team and Radix authors. It exposes the same composition model (`Root` + parts) but with a single canonical API, modern data attributes for state styling, and built-in transitions. This skill knows the full catalog (37 components, snapshotted) and how to map common bespoke patterns to it.

## When to Apply

Use this skill when:

- The user explicitly asks to migrate to Base UI, or to a specific Base UI component.
- You spot a React file with bespoke overlays — manual modals, dropdown menus built from `useState` + click-outside hooks, floating UI compositions — that have a Base UI equivalent.
- The codebase uses Radix UI, Headless UI, Reach UI, or react-aria components — these are 1:1 mappable to Base UI.
- The user wants to consolidate a fragmented set of UI primitives behind one library.
- The user wants to scan a directory for migration opportunities.

Do NOT trigger when:

- The user is starting a fresh project and asks for a UI library recommendation (suggest they install Base UI directly, no migration needed).
- The user is migrating *away from* Base UI (out of scope).

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│ 0. Stale check — is assets/data/llms.txt > 7 days old?      │
│    └─ if yes → scripts/refresh-catalog.sh                   │
├─────────────────────────────────────────────────────────────┤
│ 1. Scan target — scripts/scan-candidates.sh <path>          │
│    Output: JSON {file, line, pattern, suggested_component}  │
├─────────────────────────────────────────────────────────────┤
│ 2. Triage — present candidates to the user, confirm scope   │
│    (write-risk gate: never migrate silently)                │
├─────────────────────────────────────────────────────────────┤
│ 3. Install @base-ui/react if missing                        │
│    └─ Use the project's package manager (autodetected)      │
├─────────────────────────────────────────────────────────────┤
│ 4. Per candidate:                                           │
│    a. Look up references/catalog.md → get component name    │
│    b. Read references/migration-patterns.md (top tier) OR   │
│       fetch-component-doc.sh <component> (cached on disk)   │
│    c. Edit source — replace bespoke with Base UI parts      │
│    d. Preserve existing styling (Tailwind / CSS Modules)    │
├─────────────────────────────────────────────────────────────┤
│ 5. Verify — scripts/verify-migration.sh                     │
│    Runs typecheck + build + flags leftover bespoke patterns │
├─────────────────────────────────────────────────────────────┤
│ 6. Cleanup — uninstall replaced libraries (optional)        │
└─────────────────────────────────────────────────────────────┘
```

**Risk level:** Write. The skill edits source files. It never force-pushes, deletes branches, or runs irreversible commands. Always commit (or stash) before starting so `git diff` shows the migration cleanly.

## Tool Requirements

| Tool | Purpose | Install |
|------|---------|---------|
| `curl` | Fetch llms.txt + component docs | preinstalled |
| `jq` | Parse JSON output | `brew install jq` |
| `rg` (ripgrep) | Fast candidate scanning | `brew install ripgrep` |
| Node.js + project's typecheck | Verification step | per project |

`scripts/scan-candidates.sh` falls back to `grep` if `rg` is missing, but is much slower.

## Quick Reference

### Scripts

| Script | When to run |
|--------|-------------|
| [`scripts/refresh-catalog.sh`](scripts/refresh-catalog.sh) | Catalog stale (>7 days) or before a large migration |
| [`scripts/scan-candidates.sh`](scripts/scan-candidates.sh) `<path>` | Find migration candidates in a file/dir |
| [`scripts/fetch-component-doc.sh`](scripts/fetch-component-doc.sh) `<name>` | Cache a single component's doc on demand |
| [`scripts/verify-migration.sh`](scripts/verify-migration.sh) | After editing — typecheck + build + leftover scan. Pass `--skip-build` for fast iteration during the migration. |

### References

| File | Read when |
|------|-----------|
| [`references/catalog.md`](references/catalog.md) | Mapping a bespoke pattern to a Base UI component |
| [`references/migration-patterns.md`](references/migration-patterns.md) | Migrating overlays/interactive components (full before/after) |
| [`references/migration-patterns-primitives.md`](references/migration-patterns-primitives.md) | Migrating primitives (Button, Input, etc.) — condensed recipes |
| [`references/workflow.md`](references/workflow.md) | Detailed step-by-step with error handling and rollback |
| [`references/styling-notes.md`](references/styling-notes.md) | Adapting unstyled Base UI to your project's styling |

### Cached Catalog Data

| Path | Description |
|------|-------------|
| `assets/data/llms.txt` | Snapshot of base-ui.com/llms.txt (refresh via script) |
| `assets/data/components/<name>.md` | Per-component docs, fetched on demand and cached |

## Setup

On first use, the skill reads `config.json` for project-specific settings. If empty, ask the user:

- `project_root` — where to scan and apply edits (default: current working directory)
- `package_manager` — `pnpm` / `npm` / `yarn` / `bun` (autodetect from lockfile, confirm)
- `styling` — `tailwind` / `css-modules` / `styled-components` / `emotion` / `vanilla-extract` / `other` (so migrations preserve the project's idiom)
- `target_paths` — directories to scan (default: `src/`)

Save responses back to `config.json` before proceeding.

## Triggers Worth Acting On (Even When Phrased Casually)

- "Swap this modal for Base UI" → run scan on one file
- "We're moving off Radix" → run scan on whole repo, expect 1:1 mappings
- "Replace `<dialog>` with something accessible" → migrate to `Dialog`
- "Build a popover" (in an existing codebase) → check catalog before scaffolding bespoke

## Gotchas

See [`gotchas.md`](gotchas.md). Highlights:

- **Package was renamed**: `@base-ui-components/react` → `@base-ui/react`. Old imports still resolve in some snapshots; always migrate to the new name.
- **Portals are required for overlays**: `Dialog`, `Popover`, `Menu`, `Select`, `Tooltip`, `AlertDialog` all need `<Component.Portal>` between `Root` and `Backdrop`/`Positioner`/`Popup`. Forgetting this is the #1 cause of "it renders but doesn't appear."
- **State is styled via data attributes**: `data-[state=open]`, `data-[starting-style]`, `data-[ending-style]`. Don't reach for JS-driven enter/exit animations — the data attributes drive CSS transitions.
- **Controlled vs uncontrolled**: every interactive component has both modes. Match the source code — if the bespoke version used `useState` for `open`, port to `<Dialog.Root open={...} onOpenChange={...}>`.

## Related Skills

- `react-19-component-scaffolder` — generate new Base UI components from templates after migration
- `tailwind-refactor` — clean up the styling once the structure is on Base UI
- `react-optimise` — re-check rendering performance after the migration

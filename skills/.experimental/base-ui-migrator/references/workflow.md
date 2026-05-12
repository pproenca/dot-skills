# Detailed Workflow

The end-to-end procedure the agent should follow to migrate code to Base UI, with error handling, rollback, and per-step exit criteria.

## Prerequisites

Before starting:

- [ ] Project is a git repo with a clean working tree (`git status` clean). Otherwise the migration mixes with unrelated changes and is hard to review.
- [ ] `config.json` is filled in (or the agent prompts the user for missing fields on first use).
- [ ] `curl`, `jq`, and ideally `rg` are installed.

If the working tree isn't clean: ask the user to commit or stash, don't proceed silently.

## Step 0 — Stale Catalog Check

**Purpose:** The shipped snapshot may be days/weeks old. Refresh once at the start of a migration session so the agent reasons over the current API.

```bash
scripts/refresh-catalog.sh --check
# Exit 0: fresh
# Exit 2: stale → run refresh-catalog.sh
```

**On failure:** Network unavailable. Proceed with the on-disk snapshot but warn the user that Base UI may have added components or renamed parts since the snapshot date.

## Step 1 — Scan Target

**Purpose:** Build a list of migration candidates so the user can triage.

```bash
scripts/scan-candidates.sh <path>     # Both library imports + bespoke patterns
scripts/scan-candidates.sh <path> --library
scripts/scan-candidates.sh <path> --bespoke
```

The output is newline-delimited JSON, one match per line. Parse it with `jq` if you need to group by file or by suggested component:

```bash
scripts/scan-candidates.sh src/ | jq -s 'group_by(.suggested) | map({component: .[0].suggested, count: length, files: [.[].file] | unique})'
```

**Exit criteria:** Agent has a candidate list. If empty, the codebase has no obvious migration candidates — confirm scope with the user (maybe they want to migrate something not in the pattern list).

## Step 2 — Triage with the User

**Purpose:** Migration is a write operation. Never proceed silently.

Present the candidate list to the user grouped by component:

```
Found 14 candidates:
  Dialog: 4 files (src/EditProfile.tsx:23, src/Delete.tsx:18, ...)
  Menu: 3 files
  Tooltip: 7 files

Migrate all? (default: all)
Skip any?
```

Use `AskUserQuestion` to gather:

- Which components to migrate (default: all)
- Which to skip with reason (records go in PR description)
- Whether to migrate all candidates of a component or just a subset

**Exit criteria:** Explicit user-confirmed list of {file, component} pairs to migrate.

## Step 3 — Install `@base-ui/react` if Missing

**Purpose:** Migrations fail to compile if the package isn't installed. Check first, install once.

```bash
# Detect package manager:
[[ -f pnpm-lock.yaml ]] && PM=pnpm
[[ -f yarn.lock ]] && PM=yarn
[[ -f bun.lockb ]] && PM=bun
[[ -z "${PM:-}" ]] && PM=npm

# Check + install:
if ! grep -q '"@base-ui/react"' package.json; then
  $PM add @base-ui/react      # or: $PM install @base-ui/react
fi
```

Confirm with the user before installing. If they prefer to install manually, output the command and let them run it.

**On failure:** Install errored (network, registry auth). Surface the error and exit — don't try to migrate without the dependency.

## Step 4 — Per-Candidate Migration

For each {file, component} pair:

### 4a. Look up the component

Open `references/catalog.md` and find the row for the suggested component. Note the import path.

### 4b. Read the migration pattern

- **Tier A component?** Open `references/migration-patterns.md`, find the section, study the before/after.
- **Tier B component?** Open `references/migration-patterns-primitives.md`.
- **Need exact prop names?** Open the cached doc: `assets/data/components/<name>.md`. If missing, run `scripts/fetch-component-doc.sh <name>`.

### 4c. Read the source file

Use the `Read` tool. Identify:
- The trigger element (button, hover target, right-click target)
- The content (children of the dialog/menu/popover)
- The state owner (`useState`, controlled by parent, etc.)
- The existing styling approach (Tailwind, CSS Module class names, etc.)

### 4d. Edit the source file

Use the `Edit` tool. Minimal diff principle:

- Replace the import: bespoke imports / `@radix-ui/...` / `@headlessui/react` → `@base-ui/react/<component>`
- Replace the JSX tree following the migration pattern
- Map existing class names: state-conditional Tailwind (`isOpen ? 'opacity-100' : 'opacity-0'`) → data attribute (`data-[state=open]:opacity-100 data-[state=closed]:opacity-0`). See [`styling-notes.md`](styling-notes.md).
- Keep event handlers (`onClick`, `onSubmit`, etc.) on the same conceptual element — Base UI's `render` prop polymorphism makes this easy.
- Preserve refs if any (Base UI parts accept `ref` and forward).

**Do NOT:**
- Bulk-edit multiple files in one Edit call. One file per edit so the diff is reviewable.
- Refactor surrounding logic. Migrate the UI, not the feature.
- Add new comments to the migrated code unless the WHY is non-obvious.

### 4e. Verify the single-file change compiles

After each file's edit, you can optionally run `tsc --noEmit` on just that path:

```bash
npx tsc --noEmit -p tsconfig.json --incremental
```

Fast-fail if the migration introduced a type error before moving to the next file.

## Step 5 — Full Verification

After all migrations are done:

```bash
scripts/verify-migration.sh
```

This runs:
1. Package check — `@base-ui/react` is installed, old name absent
2. TypeScript — `tsc --noEmit`
3. Build — `next build` or `vite build` (auto-detected)
4. Leftover scan — confirms no remaining bespoke patterns from the targeted set

**On failure:**

- **Typecheck errors:** Read the errors, fix per-file. Common causes:
  - Wrong import path: `@base-ui/react` not `@base-ui/react/dialog`
  - Renamed parts: HeadlessUI's `Menu.Button` → Base UI's `Menu.Trigger`
  - Prop name changes: `onOpenChange` not `onChange` for `Root` components
- **Build errors:** Often a missing peer dependency or a Tailwind config issue (data-attribute selectors require `tailwindcss >= 3.1`).
- **Leftover bespoke patterns:** Either intentional (document the skip) or missed (migrate them now).

## Step 6 — Cleanup (Optional)

If the migration replaced an entire library:

```bash
# Uninstall the replaced library (after confirming no other usage):
$PM remove @radix-ui/react-dialog @radix-ui/react-popover @radix-ui/react-tooltip
$PM remove @headlessui/react
$PM remove focus-trap-react   # if Dialog migrations were the only consumer

# Run scan again to ensure no other usage:
scripts/scan-candidates.sh src/ --library
```

**Don't auto-uninstall.** Show the user which packages can be removed and let them confirm — there may be transitive usage you didn't scan.

## Rollback

If something goes wrong mid-migration:

```bash
# Discard all uncommitted changes in the project (you committed before starting, right?):
git checkout -- .

# Or, more surgically — revert specific files:
git checkout HEAD -- src/EditProfile.tsx src/Delete.tsx
```

If the migration is committed and verified but you discover a regression in production:

```bash
# Find the migration commit(s):
git log --oneline --grep="base-ui" -n 20

# Revert (creates a new commit that undoes the migration):
git revert <commit-sha>
```

**Don't use `git reset --hard` unless the user explicitly requests it.** Always favor reversible operations.

## Troubleshooting

### "It renders but doesn't appear"

Forgot `<Component.Portal>`. Overlays (Dialog, Popover, Menu, Select, Tooltip, AlertDialog, ContextMenu, Drawer, PreviewCard) require the Portal between Root and the visible parts.

### "Transitions don't work"

You're driving open/closed state with JS. Use `data-[starting-style]` and `data-[ending-style]` selectors instead — see [`styling-notes.md`](styling-notes.md).

### "Click outside doesn't close it"

Check the source had a manual `mousedown` handler. Base UI does this for free — remove the handler. If you genuinely want click-outside disabled (e.g., a confirm dialog), prefer `AlertDialog` — it's designed for this case and disables backdrop-click-to-close by default. Alternatively, use a controlled `<Dialog.Root open={open} onOpenChange={handler}>` where `handler` intercepts close requests (e.g., shows a confirmation). Do NOT use `modal={false}` for this purpose — it does the opposite (allows outside interaction, unlocks page scroll).

### "The form doesn't submit values"

Switch/Checkbox/Radio inside a `<form>` need a `name` prop to participate in form data. Add `name="..."` on `Switch.Root` / `Checkbox.Root` / `Radio.Root`.

### "TypeScript error: `render` prop expects ReactElement"

The `render` prop receives ONE React element, not children. Wrong: `<Tooltip.Trigger render={() => <button>...} />`. Right: `<Tooltip.Trigger render={<button>...</button>} />`.

## Adding to gotchas.md

Whenever you hit a snag the troubleshooting list doesn't cover, append it to `gotchas.md` with the date. Over time this becomes the most valuable part of the skill.

# nuqs-codemod-runner Workflow

Detailed step-by-step reference for the four-stage pipeline (`scan → report → apply → verify`).

---

## Stage 1: `scan.sh <repo-root>`

Reads `config.json` for include/exclude globs, runs ripgrep with the five pattern regexes, and emits `scan.json`.

**Inputs:**
- `<repo-root>` (absolute path; the repo must contain `package.json` with `nuqs` declared)

**Outputs:**
- `$CLAUDE_PLUGIN_DATA/scan.json` (falls back to skill root if `CLAUDE_PLUGIN_DATA` is unset)
- Shape:
  ```json
  {
    "meta": {
      "repoRoot": "/abs/path",
      "gitHead": "sha",
      "scannedAt": "2026-05-11T12:34:56Z",
      "nuqsVersion": "^2.4.0"
    },
    "matches": [
      { "codemod": "throttle-ms", "path": "src/Foo.tsx", "line": 42, "snippet": "..." }
    ]
  }
  ```

**Failure modes:**
- `ripgrep` or `jq` not installed → exits 1 with install hint
- `nuqs` not in `package.json` → exits 2 (the agent should treat this as "nothing to do")

**The `manual-debounce` heuristic:** the ripgrep pattern matches `setTimeout(() => setX(...))` across many shapes, including legitimate non-nuqs uses. After the initial scan, we re-filter the candidate file list to only files that ALSO contain `useQueryState(`, dropping any false-positive file. The transform itself does a second, stricter AST check.

---

## Stage 2: `report.sh [scan-file]`

Renders `scan.json` as markdown. The agent should show the output to the user verbatim and explicitly ask "Apply these changes?" before continuing.

**Shape of the report:**
- Header with repo, git HEAD, scan time, declared nuqs version, total match count
- One section per codemod, each with:
  - A one-line description of what the codemod does (and which nuqs version made the old pattern obsolete)
  - A table of `(file, line, snippet)` rows, snippet truncated to 120 chars

**Zero-match case:** report prints "Nothing to migrate" and exits 0.

---

## Stage 3: `apply.sh [--filter <codemod-id>] [--allow-dirty]`

Refuses to run unless:
1. `scan.json` exists at the expected path
2. `meta.gitHead` matches the current `git rev-parse HEAD`
3. `meta.scannedAt` is younger than `scan_max_age_minutes` (default 60)
4. Working tree is clean (`git diff --quiet HEAD`) — overridden by `--allow-dirty`

Then, for each codemod with matches, runs:

```
npx --yes jscodeshift@latest \
  --transform scripts/transforms/<codemod>.js \
  --parser tsx --extensions=ts,tsx,js,jsx --no-babel --print=false --run-in-band \
  <every absolute file path with a match for this codemod>
```

**Order of transforms:** `apply.sh` runs them in `jq` sort order (alphabetical by codemod ID). This is intentional — the transforms are independent: each one touches a different AST shape, so order doesn't matter. If a future transform overlaps, sequence them explicitly here.

**Output:** `$CLAUDE_PLUGIN_DATA/last-run.json`
```json
{
  "repoRoot": "/abs/path",
  "gitHeadAtApply": "sha",
  "appliedAt": "2026-05-11T12:40:00Z",
  "touchedFiles": ["src/Foo.tsx", "src/Bar.ts"]
}
```

**`CODEMOD_HAS_ZOD` environment variable:** the `unchecked-json-cast` transform produces a friendlier output if Zod is already a dep. `apply.sh` doesn't set this automatically yet — to opt in, run:

```bash
CODEMOD_HAS_ZOD=$(jq -e '(.dependencies.zod // .devDependencies.zod)' "$REPO_ROOT/package.json" >/dev/null && echo 1 || echo 0) \
  scripts/apply.sh
```

---

## Stage 4: `verify.sh`

Runs the two commands from `config.json`:
1. `typecheck_command` (default: `npx tsc --noEmit`)
2. `lint_command` (default: `npm run lint`)

**On success:** prints "All checks passed" and exits 0. The user reviews the diff and commits manually.

**On failure:**
1. Logs are preserved at `$CLAUDE_PLUGIN_DATA/verify-logs/<label>-<timestamp>.log`
2. `git restore` is run against every file in `last-run.json:touchedFiles`
3. Exits 1 with a pointer to the logs

The auto-revert assumes the working tree was clean at apply time. If `--allow-dirty` was used, the user's prior uncommitted changes to a touched file will also be reverted — that's why the dirty-tree guard exists.

---

## Per-Codemod Transform Notes

### `throttle-ms`
- Replaces every `throttleMs: <number>` key in an object literal passed to `.withOptions({...})` or a `setX(value, {...})` setter call.
- `throttleMs: 0` becomes `limitUrlUpdates: defaultRateLimit` (the documented opt-out value).
- Adds `throttle` and/or `defaultRateLimit` to the existing `nuqs` import. If there is no `nuqs` import in the file (e.g. it re-exports from a barrel), the transform logs a warning to stderr and leaves the import alone — `tsc` will flag the missing symbol during `verify.sh`.

### `manual-debounce`
- Pattern-matches the exact three-statement trio (mirror `useState` + sync `useEffect` + timer `useEffect`). If your codebase uses a different shape — e.g. lodash `debounce` in a `useMemo`, or a custom hook — the transform skips the file and leaves the match in `scan.json` for manual review.
- Extracts the debounce delay from the `setTimeout(_, N)` literal. Defaults to 300 if the delay is non-literal.

### `unchecked-json-cast`
- Does NOT generate a working validator (we can't know your shape). Instead it inserts a TODO marker and a placeholder that fails type-checking, so `verify.sh` immediately flags every spot that needs your attention.
- This is intentional — silent rewrites of validation code are dangerous. The transform's job is to land you in a failing `tsc` state with clear TODOs, not to ship working code.

### `react-router-unversioned`
- Always rewrites to `/v6` (the alias the unversioned import historically pointed at). If your project is actually on React Router v7, `verify.sh` will fail on the adapter type mismatch — re-run with the v7 path by hand.

### `parser-builder-type`
- Only renames identifiers that came from the `nuqs` import. If the import is aliased (`import { ParserBuilder as PB } from 'nuqs'`), the transform renames the imported name but leaves the local alias untouched.

---

## Recovery & Rollback

- If `apply.sh` runs but you change your mind before `verify.sh`: `git restore -- <files from last-run.json>`
- If `verify.sh` succeeds but you spot a bad rewrite: `git restore` the specific file, then re-run `apply.sh --filter <codemod-id>` to retry without that file's pattern.
- If something goes badly wrong: `git reset --hard HEAD` will restore to the apply-time HEAD recorded in `last-run.json`.

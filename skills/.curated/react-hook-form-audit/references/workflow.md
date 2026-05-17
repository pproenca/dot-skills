# Workflow

Detailed end-to-end workflow for the React Hook Form audit. Read this when you need to understand what each step does, how errors are handled, or how to integrate the audit into CI.

## Entry Point

`scripts/audit.sh` orchestrates everything. It accepts:

- `--project <path>` — override `project_root` from `config.json`
- `--dry-run` — skip writing the report file; print the summary only
- `-h` / `--help` — show usage

## Step 1: Detect Project

`scripts/detect-project.sh <project-root>`

**Purpose:** Fail fast when the target isn't a Next.js + RHF project.

**Checks:**
- `package.json` exists at `<project-root>`
- `next` is listed in `dependencies` or `devDependencies`
- `react-hook-form` is listed in `dependencies` or `devDependencies`
- Reports detected Next.js version, RHF version, and router (App vs Pages)

**Failure mode:** exits 2 with a message telling the user exactly what's missing.

**Why we check this:** detectors 05 (use-client) and 10 (useActionState mixing) are Next.js-specific. Running them on a Vite or CRA app would produce misleading results.

## Step 2: Collect Files

`scripts/collect-files.sh <project-root> <config-file>`

**Purpose:** Narrow the AST pass to only files that import `react-hook-form`. This keeps the audit fast on large monorepos.

**How it works:**
- Reads `include_globs` / `exclude_globs` from `config.json`
- Runs ripgrep for `from ['"]react-hook-form(/|['"])` (matches subpath imports too)
- Emits a JSON array of relative paths to stdout

**Empty result:** if no files match, `audit.sh` exits 0 with "nothing to audit" — not an error.

**Failure mode:** ripgrep returning exit code 1 (no matches) is converted to an empty array, not a failure.

## Step 3: Fast Pass (ripgrep)

`scripts/detect-fast.sh <project-root> <files-json>`

**Purpose:** Run the detectors whose patterns are reliably detectable with a line-level regex.

**Implements:**
- Rule 05: file missing `"use client"` directive while importing RHF
- Rule 11: `mode: 'onChange'`
- Rule 14: `reValidateMode: 'onBlur'`

**Output:** JSON array of finding objects, each with `rule`, `severity`, `message`, `file`, `line`, `column`, `snippet`.

**Why these are fast-pass:** they're string-shaped, not structure-shaped. The cost of spinning up ts-morph just to find `mode: 'onChange'` is wasted; ripgrep does it in milliseconds.

## Step 4: AST Pass (ts-morph)

`node scripts/detect-ast.mjs --project <root> --files <files-json>`

**Purpose:** Run detectors that need to understand code structure — "is this `watch()` call inside the same function as `useForm()`?", "does this async submit handler have a `try/catch`?"

**First-run setup:** `audit.sh` runs `npm install` in `scripts/` to pull `ts-morph` into a local `node_modules`. This is one-time and self-contained — the audited project's `node_modules` is never touched.

**Implements:**
- Rule 01: `watch()` in same enclosing function as `useForm()`
- Rule 02: `watch()` with no arguments
- Rule 03: `useForm()` without `defaultValues` in its options object
- Rule 04: `useEffect` deps array contains the `useForm` return variable
- Rule 06: `<Controller>` JSX inside the function that calls `useForm()`
- Rule 07: async submit handler (passed to `handleSubmit`) without `try/catch`
- Rule 08: schema literal (`z.object`, `yup.object`, `Joi.object`, `valibot.object`) defined inside the component
- Rule 09: submit handler calls `fetch`/`axios` but never `setError('root.*')`
- Rule 10: `useActionState` in same component as `useForm`
- Rule 12: `register('name', { disabled: <state> })` where the state is an Identifier/PropertyAccess/Binary
- Rule 13: `fields.map(...)` from `useFieldArray` without `key={field.id}`
- Rule 15: any `useFormContext()` usage (informational)

**Output:** JSON array of findings, same shape as the fast pass.

**Failure mode:** any uncaught exception is fatal — `audit.sh` propagates the exit code 2.

## Step 5: Render Report

`node scripts/render-report.mjs --findings <all.json> --project <root> [--rule-link-base <base>]`

**Purpose:** Merge fast-pass and AST-pass findings, sort by severity then file:line, render as markdown.

**Output structure:**
- Header: project path, generation timestamp, total finding count
- Summary table: count per severity
- By-rule table: count per rule, with link to companion distillation rule
- One section per severity, each finding rendered with file:line:column, rule ID, link, message, and a snippet

**Companion-rule links:** the report links each finding back to the corresponding rule file in the `react-hook-form` distillation skill. Configure `rule_link_base` in `config.json`:
- For PR review (default): GitHub URL to the dot-skills repo
- For local agents: a relative path like `skills/.curated/react-hook-form/references`

## Exit Codes

- `0` — no CRITICAL or HIGH findings
- `1` — at least one CRITICAL or HIGH finding (CI-friendly for blocking merges)
- `2` — environment or configuration error (missing `rg`, `node`, `jq`; invalid project; `ts-morph` install failure)

MEDIUM and LOW findings do NOT block — they appear in the report for review but don't fail CI.

## CI Integration

GitHub Actions example:

```yaml
- name: Install ripgrep + jq
  run: sudo apt-get update && sudo apt-get install -y ripgrep jq

- name: Run RHF audit
  run: bash skills/.curated/react-hook-form-audit/scripts/audit.sh --project .

- name: Upload report
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: rhf-audit-report
    path: |
      .rhf-audit-report.md
      .rhf-audit-report.json
```

The skill's exit code drives the job result: red on CRITICAL/HIGH, green otherwise.

## Error Handling

| Failure | Where | Exit | Recovery |
|---------|-------|------|----------|
| `rg` missing | audit.sh dependency check | 2 | Install ripgrep |
| `node` missing | audit.sh dependency check | 2 | Install Node 18+ |
| `jq` missing | audit.sh dependency check | 2 | Install jq |
| `ts-morph` install fails | audit.sh first-run | 2 | Run `cd scripts && npm install` manually with verbose output |
| `package.json` not found | detect-project.sh | 2 | Verify `--project` path is correct |
| `next` / `react-hook-form` missing from deps | detect-project.sh | 2 | Verify the project actually uses RHF; otherwise skip the audit |
| File parse error in AST pass | detect-ast.mjs | 2 | Likely a TypeScript syntax error in the target file — fix the file or exclude it via `exclude_globs` |
| No candidate files found | collect-files.sh | 0 | Not an error; the project doesn't use RHF in scanned paths |

## Idempotency

The audit is fully idempotent. Running it twice produces identical results (modulo the timestamp in the report header). Re-running overwrites the previous report — there's no "merge with previous" mode.

## Limitations

- **Cross-file analysis:** the AST pass runs file-by-file. It does not trace identifiers across module boundaries. A `Controller` defined in file A and imported into file B that calls `useForm` will not be flagged for rule 06.
- **Type information:** ts-morph runs without `tsconfig.json` and skips library file resolution. Detectors that would benefit from type-checking (e.g., "is this `Identifier` actually the `useForm` return?") fall back to name-matching heuristics.
- **JSX in non-`.tsx` files:** detectors only run on files matched by `include_globs`. Adjust if you put JSX in `.js` files.
- **Server vs Client components:** rule 05 checks for the `"use client"` directive at the top of the file. Files inside a folder marked `"use client"` at a layout level are still flagged — Next.js does not currently propagate the directive transitively, and the safe assumption is per-file.

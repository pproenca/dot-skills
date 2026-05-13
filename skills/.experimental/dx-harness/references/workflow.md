# Workflow

Complete step-by-step orchestration of a DX audit + scaffold pass. The agent should follow this exactly, branching only where the workflow explicitly says so.

## Preconditions

Before starting, verify:

1. `pwd` is a git repo (`git rev-parse --is-inside-work-tree` returns true) — if not, ask the user which repo to audit
2. Working tree is clean — if not, ask the user to stash or proceed at their own risk (audit is read-only, but scaffolding may be confusing on top of uncommitted changes)
3. `jq` is on PATH — required for JSON pipeline between steps

## Step 1 — Discover

Run `scripts/discover.sh` to produce `repo-fingerprint.json`. The fingerprint is the single source of truth for what the repo IS — every downstream step reads it. Do not re-detect things in later scripts.

The fingerprint includes:

| Field | Example | Used by |
|-------|---------|---------|
| `languages` | `["typescript", "python"]` | audit, scaffold-bootstrap |
| `package_manager` | `"pnpm"` | scaffold-bootstrap |
| `task_runner` | `"justfile"` \| `"makefile"` \| `"npm-scripts"` \| `"none"` | scaffold-justfile |
| `test_runner` | `"vitest"` \| `"jest"` \| `"pytest"` \| `null` | audit, verify |
| `ci_provider` | `"github-actions"` \| `"none"` | audit |
| `has_database` | `true`/`false` | scaffold-seed, scaffold-reset |
| `db_kind` | `"postgres"` \| `null` | scaffold-reset |
| `agents_md_present` | `true`/`false` | audit, scaffold-agents-md |
| `existing_scripts` | `["bootstrap.sh"]` | audit, scaffold-bootstrap |

**Failure mode**: If the repo is genuinely unrecognizable (no manifests, no scripts), the fingerprint will be sparse and downstream steps will skip most checks. Tell the user the repo looks empty and ask if they're sure this is the right path.

## Step 2 — Audit

Run `scripts/audit.sh <fingerprint>` to produce `dx-audit.json`. The audit runs each check in [audit-checklist.md](audit-checklist.md) against the fingerprint and emits findings.

Each finding has shape:

```json
{
  "id": "ttfc",
  "category": "time-to-first-commit",
  "severity": "P1",
  "title": "Time-to-first-commit exceeds 60s target",
  "evidence": "bootstrap.sh took 87s in scratch worktree",
  "fix_recipe": "scaffold-bootstrap",
  "frequency_score": 10,
  "pain_score": 8,
  "fix_cost_score": 4
}
```

**Failure mode**: If a check can't run (e.g., `verify.sh` can't clone), the audit emits a finding with `severity: "unknown"` and `evidence: "check failed: <reason>"` — do not silently skip.

## Step 3 — Prioritize

Run `scripts/prioritize.sh <audit>` to rank findings. The score is `frequency × pain ÷ fix_cost`, normalized 0-100. The output sorts findings highest-impact first.

The agent should present the top 5-10 findings to the user in a table:

```
Rank  Score  Severity  Finding                                          Fix
1     95     P1        No one-command bootstrap                         scaffold-bootstrap
2     87     P1        Missing AGENTS.md (agents can't discover loop)   scaffold-agents-md
3     72     P2        Manual db re-seeding after reset                 scaffold-seed
...
```

Then ask the user which findings to address. Default suggestion: top 5 P1 items.

## Step 4 — Scaffold

For each chosen finding, run the matching `scaffold-*.sh` script. The script:

1. Reads the fingerprint
2. Renders the relevant template (`assets/templates/*.tmpl`) with substitutions
3. Writes the rendered output to a **scratch directory** (`${TMPDIR}/dx-harness-<timestamp>/`)
4. Prints the scratch path

Multiple scaffolds for one finding are allowed (e.g., `scaffold-justfile` adds entries for whatever `scaffold-bootstrap` produced).

**Never write directly to the working tree at this stage.** The user reviews the scratch dir before anything moves.

## Step 5 — Confirm

After scaffolding, show the user a unified diff:

```bash
diff -ruN <repo>/ <scratch>/dx-harness/
```

Ask via `AskUserQuestion` which files to copy across. Per-file confirmation, not blanket. After confirmation, copy files in.

If the repo already has the file (e.g., an old `bootstrap.sh`), show the diff against the existing file and ask whether to merge, replace, or skip. **Never silently overwrite.**

## Step 6 — Verify

Run `scripts/verify.sh`. This:

1. Creates a fresh git worktree at `${TMPDIR}/dx-harness-verify-<timestamp>/`
2. Runs `./bootstrap.sh` (or `just bootstrap` / `make bootstrap`) in the worktree
3. Times the run
4. Runs `./reset.sh` if present, asserts clean state
5. Runs the test command (`just test` / `make test` / `npm test` / `pytest`), asserts pass
6. Cleans up the worktree

Output is a PASS/FAIL report with timings. If TTFC exceeds `ttfc_target_seconds` from config, that's a FAIL — the audit's headline metric.

**Failure mode**: If bootstrap fails in the scratch worktree but works in the user's working dir, it's almost always because the user has uncommitted state (`.env` file, local DB) that the scratch worktree lacks. The script emits a specific hint when it detects this.

## Step 7 — Track

Run `scripts/track-attrition.sh <audit>`. This:

1. Appends the audit to `${CLAUDE_PLUGIN_DATA}/dx-harness/audits.log` (newline-delimited JSON)
2. Reads the previous audit for this repo
3. Diffs current findings vs previous — new findings = regressions, missing findings = wins
4. Prints a short trend summary

Trend data is what makes this skill more than a one-shot. Over time, repeated audits show whether DX is rotting or improving.

## Error Recovery

| Step fails | Action |
|------------|--------|
| Discover crashes | Likely permission issue or non-git dir. Ask user, don't auto-retry. |
| Audit crashes on one check | Continue with other checks; emit `severity: unknown` for the broken one. |
| Scaffold can't render template | Stop. Print the missing fingerprint field. Ask user to fill in via `config.json` or rerun discover. |
| User declines all findings | Acknowledge, save the audit anyway so trend tracking still benefits next run. |
| Verify fails | Show the failure output. Do NOT auto-rollback — the user may still want to keep the partial scaffold. |

## Idempotency

The whole workflow is safe to re-run. Discover always produces the same fingerprint for the same repo state. Audit always produces the same findings for the same fingerprint. Scaffold always produces the same scratch output for the same fingerprint.

`track-attrition.sh` appends every audit to the log (one NDJSON row per run). It does **not** deduplicate — repeat audits are intentional history, used for trend analysis. The trend summary it prints compares the current audit to the most recent prior audit *for the same repo hash*, so identical back-to-back audits produce a "no change" trend line, not an error.

## When to Stop Early

Stop and ask the user if:

- Fingerprint shows multiple conflicting toolchains (e.g., both Cargo and package.json) — the scaffold needs guidance
- Audit produces zero findings — confirm the user actually wants to proceed (the answer is usually yes, just for the verify step)
- A finding's fix recipe is `manual` (e.g., "your test suite is missing entirely") — the skill can't auto-fix; produce guidance instead

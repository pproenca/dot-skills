# Audit Checklist

The canonical list of DX checks `scripts/audit.sh` runs. Each check has an ID, a question it answers, a detection method, a severity, and a fix recipe.

The audit's headline metric is **time-to-first-commit (TTFC)**: clone → setup → make a change → run tests. Target: 60 seconds. Anything over is P1.

## Severity Levels

| Severity | Meaning | Example |
|----------|---------|---------|
| P1 | Blocks the dev loop or causes daily friction | Missing bootstrap, TTFC > target, no test command |
| P2 | Slows the dev loop but workarounds exist | Manual seeding after reset, slow watch mode |
| P3 | Polish — costs minutes per week, not hours | Missing badges, no editor config |
| info | Observation, not a finding | "Uses pnpm" |

## Checks

### `ttfc` — Time-to-first-commit

**Question:** Can a new dev clone this repo and run the tests within `ttfc_target_seconds`?

**Detection:**
- Clean git worktree in scratch dir
- Run the detected bootstrap command (`./bootstrap.sh` → `just bootstrap` → `make bootstrap` → `npm install` → manual fallback)
- Time wall-clock from clone-end to test-command-success

**Severity:** P1 if TTFC > target, P2 if > 2×target, info if under target.

**Fix recipe:** `scaffold-bootstrap` (and possibly `scaffold-justfile` to wire it up).

**False negatives to avoid:** TTFC measured on a warm machine is lower than cold. The verify script uses a fresh worktree but cannot reset the user's package cache — note this in the report.

---

### `bootstrap-exists` — One-command bootstrap

**Question:** Is there a single command that brings a fresh checkout to a runnable state?

**Detection (in priority order):**
1. Executable `bootstrap.sh` / `scripts/bootstrap.sh` / `bin/bootstrap`
2. `just bootstrap` or `just setup` in `Justfile`
3. `make bootstrap` or `make setup` in `Makefile`
4. README contains a single fenced shell block titled "Setup" or "Bootstrap" with one command
5. `package.json` script named `bootstrap`, `setup`, or `prepare`

**Severity:** P1 if none found.

**Fix recipe:** `scaffold-bootstrap` + `scaffold-justfile` (if a task runner exists).

---

### `reset-exists` — One-command reset

**Question:** Is there a single command that returns the dev environment to a known-clean state (drop DB, clear caches, kill background processes)?

**Detection:**
- `reset.sh` / `scripts/reset.sh`
- `just reset` / `make reset`
- `npm run reset`

**Severity:** P1 if repo has a database and no reset; P2 otherwise.

**Fix recipe:** `scaffold-reset`.

**Gotcha:** "reset" is a strong word. A correct reset should reset BOTH data and state — dropping the DB but leaving a stale Redis cache is a half-reset and counts as missing.

---

### `seed-exists` — Idempotent seed

**Question:** Can the dev environment be filled with realistic-enough data with a single command, and is it safe to run twice?

**Detection:**
- `seed.sh` / `scripts/seed.sh`
- `just seed` / `make seed`
- `npm run seed` / `npm run db:seed`
- Framework-specific (`prisma db seed`, `rails db:seed`)

**Severity:** P1 if repo has a database and the reset-then-seed flow requires manual login/registration; P2 if seed exists but isn't idempotent (running twice errors or duplicates).

**Fix recipe:** `scaffold-seed`. The recipe explicitly bakes in a test user with known credentials so "I have to register every time" goes away.

---

### `test-command` — One-command tests

**Question:** Is there a single command that runs the test suite?

**Detection:**
- `just test` / `make test` / `npm test` / `pytest` / `cargo test` / `go test ./...`
- `package.json` has a `test` script
- README explicitly documents it

**Severity:** P1 if missing.

**Fix recipe:** `manual` — the skill cannot invent tests. Produces guidance: "Add at least one test and wire `test` script in package.json".

---

### `test-watch` — Hot test feedback

**Question:** Can the dev run a test watcher that re-runs on file change?

**Detection:**
- `just test-watch`, `npm run test:watch`, `vitest`, `jest --watch`, `pytest-watch`, `cargo watch -x test`

**Severity:** P2 if missing.

**Fix recipe:** `scaffold-justfile` adds a `test-watch` entry calling the appropriate watcher for the detected runner.

---

### `dev-server` — Hot dev loop

**Question:** Is there a single command to start the dev server with HMR / autoreload?

**Detection:**
- `just dev`, `npm run dev`, `cargo run`, `go run`, `python manage.py runserver`, `uvicorn ... --reload`

**Severity:** P2 if the repo is an app (has any server entrypoint) and no dev command exists.

**Fix recipe:** `scaffold-justfile` adds the canonical `dev` entry for the detected stack.

---

### `agents-md` — Agent-discoverable conventions

**Question:** Is there an `AGENTS.md` (or `CLAUDE.md`) that lists the harness commands and key conventions?

**Detection:**
- `AGENTS.md` or `CLAUDE.md` or `.cursorrules` at repo root

**Severity:** P1 if missing (agents must guess the bootstrap, which wastes time every session).

**Fix recipe:** `scaffold-agents-md`. The generated AGENTS.md lists detected commands by name and points to canonical files (no hallucinated paths).

**Quality bar:** A passing AGENTS.md must include at least: bootstrap command, test command, reset command (if exists), and "where the conventions live". A stub one-liner is not passing.

---

### `ci-status` — CI is wired

**Question:** Does the repo have a CI workflow that runs tests on every push?

**Detection:**
- `.github/workflows/*.yml` containing `test` step
- `.circleci/config.yml`
- `.gitlab-ci.yml`
- `azure-pipelines.yml`

**Severity:** P2 if missing; P3 if exists but doesn't run tests.

**Fix recipe:** `manual` — CI generation is out of scope (different providers, secrets, etc.). The audit surfaces this so the human knows.

---

### `repeated-manual-steps` — Attrition signals in git history

**Question:** Does git history reveal repeated manual chores that should be scripted?

**Detection:** see [attrition-patterns.md](attrition-patterns.md). Greps git log for phrases like "again", "every time", "manual", "wip: setup", "fix: re-seed", "reset db", "register again".

**Severity:** P2 per pattern, capped at P1 if more than 5 distinct patterns found.

**Fix recipe:** depends on the pattern. The audit emits one finding per detected pattern with the right recipe attached.

---

### `secrets-bootstrap` — Bootstrap is offline-friendly

**Question:** Does bootstrap require secrets the new dev doesn't have?

**Detection:**
- Bootstrap script greps for env vars (`$AWS_*`, `$STRIPE_*`, etc.) without a fallback
- `.env.example` exists but bootstrap doesn't copy it to `.env`

**Severity:** P2.

**Fix recipe:** `scaffold-bootstrap` is regenerated to copy `.env.example` → `.env` if missing, and to skip steps that require real secrets when running in `--offline` mode.

---

### `dependency-pin-drift` — Lockfile present and committed

**Question:** Is the lockfile committed?

**Detection:**
- Has package.json but no pnpm-lock.yaml / package-lock.json / yarn.lock / bun.lockb in git
- Has Cargo.toml but no Cargo.lock committed (for binaries) — note: libraries shouldn't commit Cargo.lock

**Severity:** P2.

**Fix recipe:** `manual` — emit guidance to commit the lockfile.

---

## Scoring

The prioritize step combines:

| Factor | Source | Range |
|--------|--------|-------|
| `frequency_score` | How often this friction hits a dev per week | 1-10 |
| `pain_score` | How much friction each occurrence costs | 1-10 |
| `fix_cost_score` | How expensive the fix is | 1-10 (higher = more expensive) |

Final score: `(frequency × pain) / fix_cost`, normalized 0-100.

Each check declares its own default scores in `audit.sh`. The user can override via `config.json`.

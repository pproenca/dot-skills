# Fix Recipes

For each friction type the audit can find, this document specifies the canonical fix the skill produces.

A recipe is more than "run this script". It's: what's the principle behind the fix, what does the output look like, and what NOT to do.

## Recipe: `scaffold-bootstrap`

**Friction it fixes:** missing or slow one-command setup.

**Principle:** one script, idempotent, offline-friendly, prints what it's doing.

**Output:** an executable `bootstrap.sh` at repo root that:

1. Checks toolchain prerequisites (`node`, `cargo`, `python` — whichever the fingerprint detected) and prints actionable install hints if missing
2. Copies `.env.example` to `.env` if `.env` doesn't exist
3. Installs dependencies via the detected package manager
4. Starts any required services (`docker compose up -d` for db, if present)
5. Runs migrations (if framework detected)
6. Runs seed (if `seed.sh` exists)
7. Prints a one-line success summary with next-step commands

**Idempotency rule:** running bootstrap twice in a row should be a no-op on the second run (apart from "starting" already-running services).

**What NOT to do:**
- Don't generate a bootstrap that runs tests at the end. Tests belong in `verify` / CI / dev loop, not bootstrap. Bootstrap should be < 60s; tests inflate this and obscure failures.
- Don't generate bootstrap that requires interactive prompts. Bootstrap must be unattended.
- Don't generate bootstrap that creates a global state (modifying ~/.bashrc, installing global tools). Use project-local installs.

---

## Recipe: `scaffold-reset`

**Friction it fixes:** "I have to do X manually every time I want to start clean."

**Principle:** reset returns the project to "fresh clone + bootstrap" state without re-cloning.

**Output:** an executable `reset.sh` at repo root that:

1. Stops any running services (`docker compose down`)
2. Wipes ephemeral data (DB volumes, caches, build artifacts)
3. Re-runs bootstrap

**Critical property:** after `reset.sh`, the dev should NOT need to re-register or re-login — `seed.sh` (run as part of bootstrap) provides credentialed test users.

**What NOT to do:**
- Don't reset the user's `.env` if it has been modified — back it up to `.env.bak` instead.
- Don't `rm -rf node_modules` unless the audit specifically found stale-dep issues; it's slow and rarely needed.
- Don't drop production databases. The script must fail loudly if `NODE_ENV=production` or equivalent.

---

## Recipe: `scaffold-seed`

**Friction it fixes:** "every time I reset I have to register/login/click around to get to a usable state."

**Principle:** seed creates the data a dev needs to start working immediately — a logged-in test user, sample records, anything that would otherwise require manual clicking.

**Output:** an executable `seed.sh` that:

1. Detects the database (`DATABASE_URL` env, framework conventions)
2. Inserts a canonical test user (e.g., `dev@local.test` / `password`) — credentials match what's in `AGENTS.md`
3. Inserts minimal but realistic fixture data (workspace, org, sample records)
4. Is idempotent: running twice doesn't error, doesn't duplicate

**Critical property:** the credentials seeded by `seed.sh` must be documented in `AGENTS.md` and `.env.example` so the dev (and any agent) finds them without asking.

**What NOT to do:**
- Don't use `INSERT` without `ON CONFLICT DO NOTHING` (or framework equivalent). Idempotency matters more than perfect data.
- Don't seed production-like volumes (thousands of records). Seed should be fast.
- Don't seed real-looking data that could be confused with prod. Use obvious test names ("Acme Test Co", "user-1@local.test").

---

## Recipe: `scaffold-agents-md`

**Friction it fixes:** agents (and humans) waste a session figuring out the harness because nothing tells them.

**Principle:** AGENTS.md is the table of contents to the dev loop. Short, factual, links to canonical files. Not a tutorial.

**Output:** an `AGENTS.md` at repo root with sections:

```markdown
# Project Conventions

## Dev Loop
- Bootstrap: `./bootstrap.sh`
- Dev server: `just dev`
- Tests: `just test`
- Watch tests: `just test-watch`
- Reset: `./reset.sh`

## Test User
- Email: dev@local.test
- Password: password
- Seeded by: `./seed.sh` (run as part of bootstrap)

## Where things live
- Source: `src/`
- Tests: `tests/` (or wherever fingerprint detected)
- Database migrations: `migrations/` (if applicable)

## Conventions
- Lint: `just lint`
- Format: `just fmt`
- {detected framework-specific conventions}
```

**Critical property:** every command mentioned in AGENTS.md must actually exist. The audit re-runs after AGENTS.md is generated to verify.

**What NOT to do:**
- Don't write prose explaining what each file does. Link, don't narrate.
- Don't repeat content from README. AGENTS.md is for agents/devs onboarding; README is for users.
- Don't hallucinate paths. The skill only writes paths it verified exist in the fingerprint.

---

## Recipe: `scaffold-justfile`

**Friction it fixes:** commands exist as scripts but aren't discoverable. `just --list` should answer "what can I run here?".

**Principle:** extend the existing task runner (Justfile, Makefile, package.json scripts). Never migrate to a different runner without explicit user request.

**Output:**

If `Justfile` exists: append missing entries.
If `Makefile` exists: append missing entries.
If `package.json` is the only manifest: add npm scripts.
If none exist: create a `Justfile` (or `Makefile` if `preferred_task_runner: make` in config) with bootstrap/dev/test/reset/seed entries.

**Canonical entries:**

```
bootstrap:  ./bootstrap.sh
dev:        {detected dev command}
test:       {detected test command}
test-watch: {detected watch command}
reset:      ./reset.sh
seed:       ./seed.sh
lint:       {detected lint}
fmt:        {detected formatter}
```

**Critical property:** the runner becomes the canonical discovery surface — `just --list` (or `make help`) prints all available commands.

**What NOT to do:**
- Don't overwrite existing entries. Append-only; show the diff if entries differ.
- Don't migrate from one runner to another. Adapt to what exists.
- Don't add entries that call non-existent files. Verify each target's script exists before adding.

---

## Recipe: `manual`

For findings the skill cannot auto-fix (missing test suite, broken CI, secret rotation), the audit emits guidance but does not scaffold. The output is a markdown bullet under "Manual follow-ups" in the report.

These are tracked in the audit log too — repeated manual findings without action surface as a trend ("you've had 'no test suite' as a P1 finding for 6 audits").

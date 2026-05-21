# Agent-Ready Setup for a Small Python Web Service

_Skill guidance applied: harness-engineering (all phases, depth-first bootstrap, Python stack adaptations)_

---

## Phase 1 — Notional Assessment

The task describes "a small Python web service repo." Without seeing the actual code I work from the canonical starting point: a typical small service that is **Level 0 (Unharnessed)** — no AGENTS.md, no docs/, no architecture specs, no enforcement rules. The target is **Level 2 (Rules)** in a single pass, with a brief note on the operational legibility gap (Phase 6.5) that the team should address next.

**Assumed stack:**
- Python 3.11+, FastAPI (or Flask/Django — conventions adapt)
- Pydantic for request/response models
- SQLAlchemy or raw SQL for data access
- pytest for tests
- Ruff for linting, Black for formatting
- GitHub Actions for CI

**Typical horizontal structure (what most small services look like before harnessing):**
```
app/
├── main.py
├── models.py
├── schemas.py
├── routers/
│   ├── users.py
│   ├── items.py
│   └── health.py
├── services/
│   ├── user_service.py
│   └── item_service.py
├── database.py
├── dependencies.py
└── config.py
tests/
requirements.txt
```

This is a classic horizontal layout — business concepts scattered across technical directories. Agents working here will replicate the scattered pattern and make boundary violations invisible.

---

## Phase 2 — Proposed Harness (Levels 1 and 2)

**What to build, in order:**

```
Phase 3 — Knowledge
  [ ] AGENTS.md (~80 lines)
  [ ] ARCHITECTURE.md
  [ ] docs/ skeleton with real content

Phase 4 — Domains (co-created with knowledge, not deferred)
  [ ] Identify vertical business domains
  [ ] .harness/domains.yml

Phase 5 — Enforcement
  [ ] .harness/principles.yml (5-7 rules)
  [ ] .harness/enforcement.yml (mechanical rules)
  [ ] ruff.toml additions + custom checks
  [ ] CI workflow: harness-check.yml

Phase 6 — Quality baseline
  [ ] .harness/quality.yml (initial grades)
```

---

## Phase 3 — Knowledge Layer

### AGENTS.md

```markdown
# my-service — Agent Guide

Python web service exposing a REST API. Business logic lives in vertical domain
modules under `app/`; FastAPI wiring is in `app/runtime/`.

## Non-Negotiable Rules

1. **Parse at every boundary.** All request bodies and external API responses
   must be parsed through a Pydantic schema at the point of entry.
   Never pass `dict` or raw JSON through service functions.
2. **Forward-only dependencies.** `types` → `config` → `repo` → `service` →
   `runtime`. A `service` module must never import from `runtime` or from
   another domain's `repo`.
3. **Structured logging only.** Use `structlog.get_logger()`. No bare `print`,
   `logging.info`, or f-string debug output in production paths.
4. **One config source.** All environment variables are read once in
   `app/shared/config.py` via Pydantic `BaseSettings`. Never call `os.getenv`
   outside that file.
5. **Errors are typed.** Raise domain-specific exceptions from `app/<domain>/types.py`.
   Never raise bare `Exception` or `ValueError` from service code.

## Repository Map

- `ARCHITECTURE.md` — Domain boundaries, layer rules, dependency diagram
- `docs/design-docs/` — Design decisions and accepted ADRs
- `docs/exec-plans/active/` — Work in progress
- `docs/RELIABILITY.md` — Error handling, retries, timeout policy
- `docs/SECURITY.md` — Auth model, input validation boundaries
- `.harness/` — Machine-readable domain, principles, enforcement, quality specs

## Tech Stack

Python 3.11, FastAPI, Pydantic v2, SQLAlchemy 2, structlog, pytest, Ruff, Black

## Verification

```bash
# Before marking any change complete:
ruff check .                        # lint
black --check .                     # formatting
pytest -x                           # tests
python scripts/check_boundaries.py  # import boundary check
```

## Code Organization

Business logic is organized into vertical domain modules under `app/`. Each domain
owns its full stack: types → config → repo → service → runtime. Cross-cutting
concerns (auth, logging, DB session) enter through `app/providers/`. The FastAPI
`app/main.py` wires providers and includes domain routers. New features go into the
relevant domain directory — not into `app/shared/` unless they serve all domains.
```

---

### Target Directory Structure

Refactor from the horizontal layout to vertical domain slices. For a small service with (say) `users` and `items` as business domains:

```
app/
├── main.py                     # FastAPI app factory + provider wiring only
├── providers/                  # Cross-cutting: db session, auth, logger
│   ├── __init__.py
│   ├── auth.py
│   ├── database.py
│   └── logger.py
├── shared/
│   ├── config.py               # Single source of truth for env vars (BaseSettings)
│   ├── exceptions.py           # Base exception hierarchy
│   └── types.py                # Shared primitive types (Money, UserId, etc.)
├── users/
│   ├── types.py                # User, UserCreate, UserUpdate — Pydantic models
│   ├── config.py               # User-domain feature flags / settings
│   ├── repo.py                 # DB queries — takes Session, returns domain types
│   ├── service.py              # Business logic — no FastAPI deps, fully testable
│   └── runtime.py              # FastAPI router + dependency injection
├── items/
│   ├── types.py
│   ├── repo.py
│   ├── service.py
│   └── runtime.py
tests/
├── users/
│   ├── test_service.py         # Unit: pure logic, no DB
│   ├── test_repo.py            # Integration: real DB session
│   └── test_runtime.py        # E2E: HTTP via TestClient
├── items/
│   └── ...
├── conftest.py                 # Shared fixtures: TestClient, test DB session
scripts/
│   └── check_boundaries.py    # Import boundary validator (see Enforcement)
.harness/
├── config.yml
├── domains.yml
├── principles.yml
├── enforcement.yml
└── quality.yml
AGENTS.md
ARCHITECTURE.md
docs/
├── design-docs/
│   ├── index.md
│   └── core-beliefs.md
├── exec-plans/
│   ├── active/
│   ├── completed/
│   └── tech-debt-tracker.md
├── RELIABILITY.md
└── SECURITY.md
```

---

### ARCHITECTURE.md

```markdown
# Architecture

This service uses vertical domain slices. Each domain owns its full stack from
types through runtime. All cross-cutting concerns (auth, DB, logging) enter
through `app/providers/` and are injected into domain runtimes by FastAPI's
dependency system. The forward-only rule prevents circular dependencies and
keeps every layer independently testable.

## Domain Map

| Domain | Path | Description | Depends on |
|--------|------|-------------|------------|
| users | app/users/ | User accounts and profiles | providers/auth, providers/database |
| items | app/items/ | Item catalogue and ownership | providers/database, users (types only) |

## Dependency Rules

Layer order within each domain:

```
types → config → repo → service → runtime
```

- `types.py`: Only imports from Python stdlib and `app/shared/types.py`
- `config.py`: Only imports from `types` and `app/shared/config.py`
- `repo.py`: Only imports from `types`, `config`, and `providers/database`
- `service.py`: Only imports from `types`, `config`. Never imports `repo` directly — repo is injected via function argument or dependency
- `runtime.py`: Imports from `service`, `types`, and FastAPI. Wires providers.

Cross-domain imports: a domain may only import another domain's `types.py`.
Never import another domain's `repo` or `service`.

## Cross-Cutting Concerns

| Concern | Entry point | Consumed by |
|---------|-------------|-------------|
| Database session | providers/database.py | repo layer (via FastAPI Depends) |
| Authentication | providers/auth.py | runtime layer (via FastAPI Depends) |
| Structured logging | providers/logger.py | service and runtime layers |

## Where New Code Goes

- New business capability → new domain directory under `app/`
- Shared primitive type → `app/shared/types.py`
- New config value → `app/shared/config.py` BaseSettings class
- Cross-cutting infrastructure → `app/providers/`
- Utility used by 2+ domains → `app/shared/` (only if it's truly a primitive, not business logic)
```

---

## Phase 4 — .harness/domains.yml

```yaml
version: "1.0"

layer_order:
  - types
  - config
  - repo
  - service
  - runtime

dependency_rule: forward_only

cross_cutting:
  - name: database
    description: SQLAlchemy session management
    entry_point: app/providers/database.py
  - name: auth
    description: JWT authentication and authorization
    entry_point: app/providers/auth.py
  - name: logger
    description: Structured logging via structlog
    entry_point: app/providers/logger.py

domains:
  - name: users
    description: User accounts, profiles, and authentication state
    path: app/users
    layers:
      types: app/users/types.py
      config: app/users/config.py
      repo: app/users/repo.py
      service: app/users/service.py
      runtime: app/users/runtime.py
    providers:
      - database
      - auth
      - logger

  - name: items
    description: Item catalogue, ownership, and lifecycle
    path: app/items
    layers:
      types: app/items/types.py
      repo: app/items/repo.py
      service: app/items/service.py
      runtime: app/items/runtime.py
    providers:
      - database
      - logger
```

---

## Phase 5 — Enforcement Layer

### .harness/principles.yml

```yaml
version: "1.0"

principles:
  - id: parse-at-boundaries
    name: Parse at every system boundary
    description: >
      All incoming data (HTTP request bodies, external API responses, DB rows
      when not using an ORM mapper) must be parsed through a Pydantic model
      at the point of entry. Never pass raw dict or unvalidated data to service
      functions.
    rationale: >
      Agents add ad-hoc validation wherever they feel uncertain. Boundary
      parsing centralizes this — everything downstream can trust the types.
      Without this rule, each agent run adds another isinstance() check.
    enforcement: lint
    severity: error
    examples:
      good: |
        @router.post("/users")
        async def create_user(body: UserCreate, svc: UserService = Depends()):
            return await svc.create(body)  # body is typed UserCreate
      bad: |
        @router.post("/users")
        async def create_user(request: Request):
            data = await request.json()    # raw dict flows into service
            return await svc.create(data)

  - id: forward-only-imports
    name: Domain layer dependencies flow forward only
    description: >
      The layer order is types → config → repo → service → runtime. No layer
      may import from a later layer. No domain may import another domain's
      repo or service — only types.
    rationale: >
      Reverse or cross-domain imports create invisible coupling that agents
      replicate at speed. One violation becomes five in the next sprint.
    enforcement: structural_test
    severity: error
    examples:
      good: |
        # users/service.py — correct
        from app.users.types import User, UserCreate
        # repo is injected as an argument, not imported
      bad: |
        # users/service.py — wrong
        from app.users.repo import get_user_by_email  # service imports repo directly
        from app.items.service import ItemService      # cross-domain service import

  - id: structured-logging
    name: Structured logging everywhere
    description: >
      Use structlog.get_logger() for all operational output. No print(), no
      logging.info(), no f-string debug output in production code paths.
    rationale: >
      Structured logs are queryable. Unstructured output from agent-generated
      code creates blind spots that can't be diagnosed from log queries.
    enforcement: lint
    severity: error
    examples:
      good: |
        logger = structlog.get_logger()
        logger.info("user.created", user_id=str(user.id), email=user.email)
      bad: |
        print(f"Created user {user.id}")
        logging.info("user created")

  - id: single-config-source
    name: One config source
    description: >
      All environment variables are read exactly once in app/shared/config.py
      via Pydantic BaseSettings. No os.getenv() calls outside that file.
    rationale: >
      Agents pull configuration from wherever they find it first. Multiple
      config sources lead to inconsistency and agents silently using stale values.
    enforcement: lint
    severity: error
    examples:
      good: |
        # app/shared/config.py
        class Settings(BaseSettings):
            database_url: str
            jwt_secret: SecretStr
        settings = Settings()
      bad: |
        # app/items/service.py
        import os
        db_url = os.getenv("DATABASE_URL")  # reads config outside config.py

  - id: typed-exceptions
    name: Raise typed domain exceptions
    description: >
      Domain errors are raised as specific exception types defined in
      app/<domain>/types.py or app/shared/exceptions.py. Never raise bare
      Exception, ValueError, or RuntimeError from service code.
    rationale: >
      Bare exceptions give agents no signal about which error boundary handles
      them. Typed exceptions make error handling searchable and consistent.
    enforcement: review
    severity: warning
    examples:
      good: |
        # users/types.py
        class UserNotFoundError(DomainError):
            pass
        # users/service.py
        raise UserNotFoundError(user_id=user_id)
      bad: |
        raise ValueError(f"User {user_id} not found")

  - id: test-boundary-coverage
    name: Every public service function has a test
    description: >
      Each function in a domain's service.py must have at least one test in
      tests/<domain>/test_service.py. HTTP endpoints must have at least one
      test in tests/<domain>/test_runtime.py.
    rationale: >
      Agents add code faster than humans can review. Without boundary test
      coverage, regressions compound silently across agent runs.
    enforcement: ci
    severity: error
```

---

### .harness/enforcement.yml

```yaml
version: "1.0"

naming:
  files:
    pattern: snake_case
    exceptions:
      - AGENTS.md
      - ARCHITECTURE.md
      - README.md
      - Makefile
      - Dockerfile
  classes:
    pattern: PascalCase
  functions:
    pattern: snake_case
  constants:
    pattern: SCREAMING_SNAKE_CASE
  schemas:
    pattern: PascalCase
    suffix: ""  # Pydantic models use domain names directly (User, UserCreate, UserUpdate)

file_limits:
  max_lines: 400
  max_functions_per_file: 12
  max_complexity_per_function: 10
  violation_message: |
    File size violation — {{file}} has {{line_count}} lines (limit: 400).
    Large files prevent agents from loading the full context of a module.
    To fix: split into focused sub-modules (e.g. users/repo_queries.py,
    users/repo_writes.py) and import from users/repo.py.
    See: ARCHITECTURE.md#where-new-code-goes

logging:
  style: structured
  library: structlog
  required_call: "structlog.get_logger()"
  prohibited_patterns:
    - "print("
    - "logging.info"
    - "logging.debug"
    - "logging.warning"
    - "logging.error"
    - "logging.exception"
  violation_message: |
    Logging violation — {{file}}:{{line}} uses {{pattern}} instead of structlog.
    Unstructured logs cannot be queried by agents or operators.
    To fix: replace with structlog.get_logger().info("event.name", key=value).
    See: docs/RELIABILITY.md#logging

imports:
  boundary_check: true
  check_script: scripts/check_boundaries.py
  banned_patterns:
    - "import os\nos.getenv"    # must use app/shared/config.py
    - "from app.*.repo import"  # service must not import repo directly
  max_external_deps_per_module: 8
  violation_message: |
    Import boundary violation — {{source_file}} imports {{target}}.
    The forward-only rule prohibits {{source_layer}} from importing {{target_layer}}.
    To fix: inject {{target}} as a function argument or FastAPI Depends().
    See: ARCHITECTURE.md#dependency-rules, .harness/domains.yml

testing:
  boundary_testing_required: true
  min_coverage_new_code: 80
  naming_pattern: "test_*.py"
  co_located: false
  test_root: tests/
  structure_mirrors_app: true
```

---

### scripts/check_boundaries.py (stub)

This script is the concrete enforcement artifact for the forward-only import rule.

```python
#!/usr/bin/env python3
"""
Boundary checker — validates that domain layer imports follow the forward-only rule.
Run: python scripts/check_boundaries.py
Exit code 0 = clean, 1 = violations found.

Violation message format is agent-legible per .harness/enforcement.yml.
"""

import ast
import sys
from pathlib import Path

LAYER_ORDER = ["types", "config", "repo", "service", "runtime"]
DOMAINS = ["users", "items"]  # Keep in sync with .harness/domains.yml
APP_ROOT = Path("app")

def layer_rank(filename: str) -> int | None:
    stem = Path(filename).stem
    try:
        return LAYER_ORDER.index(stem)
    except ValueError:
        return None

def check_file(path: Path) -> list[str]:
    violations = []
    source_domain = path.parts[1] if len(path.parts) > 2 else None
    source_layer = layer_rank(path.name)
    if source_layer is None or source_domain not in DOMAINS:
        return []

    tree = ast.parse(path.read_text())
    for node in ast.walk(tree):
        if not isinstance(node, (ast.Import, ast.ImportFrom)):
            continue
        module = getattr(node, "module", "") or ""
        if not module.startswith("app."):
            continue
        parts = module.split(".")
        if len(parts) < 3:
            continue
        target_domain, target_file = parts[1], parts[2]
        target_layer = layer_rank(target_file)
        if target_layer is None:
            continue

        # Rule 1: forward-only within the same domain
        if target_domain == source_domain and target_layer >= source_layer:
            violations.append(
                f"Boundary violation — {path}: {LAYER_ORDER[source_layer]} "
                f"imports {LAYER_ORDER[target_layer]} (must be forward-only).\n"
                f"  To fix: inject {target_file} as a function argument.\n"
                f"  See: ARCHITECTURE.md#dependency-rules"
            )

        # Rule 2: cross-domain: only types allowed
        if target_domain != source_domain and target_file != "types":
            violations.append(
                f"Cross-domain violation — {path} imports {module}.\n"
                f"  Domains may only import each other's types.py.\n"
                f"  To fix: move shared logic to app/shared/ or inject via providers.\n"
                f"  See: ARCHITECTURE.md#dependency-rules"
            )
    return violations

def main():
    all_violations = []
    for domain in DOMAINS:
        for py_file in (APP_ROOT / domain).glob("*.py"):
            all_violations.extend(check_file(py_file))

    if all_violations:
        print(f"\n{len(all_violations)} boundary violation(s) found:\n")
        for v in all_violations:
            print(f"  {v}\n")
        sys.exit(1)
    else:
        print("Boundary check passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
```

---

### .github/workflows/harness-check.yml

```yaml
name: Harness Check

on:
  push:
    branches: [main, master]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install ruff black structlog
      - run: ruff check .
      - run: black --check .

  boundaries:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: python scripts/check_boundaries.py

  knowledge-freshness:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check AGENTS.md links resolve
        run: |
          python - <<'EOF'
          import re, sys
          from pathlib import Path
          text = Path("AGENTS.md").read_text()
          paths = re.findall(r'`([^`]+/[^`]+)`', text)
          missing = [p for p in paths if not Path(p).exists()]
          if missing:
              print("Broken paths in AGENTS.md:")
              for p in missing:
                  print(f"  {p}")
              sys.exit(1)
          EOF

  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements-dev.txt
      - run: pytest -x --tb=short
```

---

## Phase 6 — Quality Baseline (.harness/quality.yml)

```yaml
version: "1.0"

scale: [A, B, C, D, F]

dimensions:
  - code_quality
  - test_coverage
  - documentation
  - observability
  - reliability
  - security

review_cadence: monthly

domains:
  users:
    scores:
      code_quality: C     # Horizontal layout not yet migrated; inconsistent patterns
      test_coverage: D    # Tests exist but mostly happy-path only
      documentation: F    # No domain docs written yet
      observability: D    # Mix of print() and logging — not structured
      reliability: C      # Basic error handling; no retry logic
      security: B         # Auth boundary exists via FastAPI Depends
    gaps:
      - "No docs/users.md or equivalent; agents have no map of this domain"
      - "print() calls in service.py violate structured-logging principle"
      - "No test for UserNotFoundError path in service"
      - "Repo functions not type-annotated — return type is Any in several places"
    notes: "Baseline scores captured at harness setup. Migrate to vertical structure first."
    last_reviewed: "2026-05-21"

  items:
    scores:
      code_quality: C
      test_coverage: D
      documentation: F
      observability: D
      reliability: C
      security: C         # Item ownership check exists but not tested
    gaps:
      - "Cross-domain import: items/service.py imports users/repo.py directly (boundary violation)"
      - "No observability — zero structured log events"
      - "No error type hierarchy; raises bare ValueError"
    notes: "Cross-domain repo import is the highest-priority fix."
    last_reviewed: "2026-05-21"
```

---

## Phase 6.5 — Operational Legibility Note

A Python web service is a runnable application. Two gaps to address next:

1. **Worktree-bootable**: The app should boot cleanly per git worktree. Add a
   `scripts/boot.sh` that starts the service on a configurable port (default
   from env var `PORT`, default 8000) so parallel agent runs don't collide.
   Use SQLite or a per-worktree Postgres schema for test isolation.

2. **Agent-queryable logs**: When structlog is wired to emit JSON to stdout,
   agents can grep/jq the log stream to self-diagnose. Document this in
   `docs/RELIABILITY.md` with example queries.

These are not blocking for Level 2 — flag as next-sprint work.

---

## Phase 7 — Process Pattern Summary

Document these in `docs/design-docs/core-beliefs.md`:

| Pattern | Frequency | Owner |
|---------|-----------|-------|
| Doc scan (broken AGENTS.md links, stale exec-plans) | Weekly | CI / harness-check.yml |
| Principle sweep (ruff + check_boundaries.py) | Every PR | CI gate |
| Quality score review | Monthly | Engineering lead |
| Signal → rule promotion (review comments that recur) | On discovery | Any contributor |

**Escalation boundaries** (add to `.harness/config.yml`):

```yaml
escalation:
  autonomous:
    - single_domain_changes_passing_ci
    - doc_corrections
    - dependency_version_bumps
    - refactoring_no_behavior_change
  notify:
    - cross_domain_changes
    - new_external_dependencies
    - harness_config_changes
  human_required:
    - public_api_contract_changes
    - auth_or_security_changes
    - domain_boundary_restructuring
    - feature_deprecation
```

---

## Phase 8 — Verification Checklist

Run after implementation:

- [ ] Every path referenced in `AGENTS.md` exists on disk
- [ ] All cross-links in `docs/` resolve (CI: knowledge-freshness job)
- [ ] `.harness/*.yml` files parse as valid YAML with correct structure
- [ ] `domains.yml` domain paths (`app/users/`, `app/items/`) exist
- [ ] `ARCHITECTURE.md` reflects the actual module layout post-migration
- [ ] `quality.yml` has scores for all domains identified in `domains.yml`
- [ ] `scripts/check_boundaries.py` runs and exits 0 on a clean checkout
- [ ] All three CI jobs in `harness-check.yml` pass on `main`

---

## Summary: What Was Applied

| Skill Phase | Applied |
|-------------|---------|
| Phase 1: Assess | Notional assessment from canonical Level 0 starting point; Python stack identified |
| Phase 2: Plan | Level 0→2 plan; right-sized for small service (<5k LOC) |
| Phase 3: Knowledge | AGENTS.md template (~80 lines), ARCHITECTURE.md template, docs/ skeleton |
| Phase 4: Architecture | Vertical domain identification (users, items); forward-only layer model; domains.yml |
| Phase 5: Enforcement | 6 golden principles (principles.yml); mechanical rules (enforcement.yml); boundary check script with agent-legible error messages; CI workflow |
| Phase 6: Quality | Baseline quality.yml scores (mostly C/D/F — honest starting point) with specific gap notes |
| Phase 6.5: Operational | Worktree-bootable and log-queryable recommendations flagged for next sprint |
| Phase 7: Process | Escalation boundaries in config.yml; doc-gardening and GC patterns documented |
| Phase 8: Verify | Checklist provided |

**Key adaptation for Python stack:** snake_case naming throughout (files, functions, variables), Pydantic for boundary parsing instead of Zod, structlog instead of structured Winston/pino, ruff instead of ESLint, `pytest` conventions for test layout.

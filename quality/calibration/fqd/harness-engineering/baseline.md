# Agent-Ready Python Web Service: Baseline Setup

## What "agent-ready" means

An AI coding agent needs to orient itself in under 60 seconds, understand where things live, understand what it must not touch, and run a fast feedback loop without manual intervention. Every structural decision below serves one of those four goals.

---

## 1. File and directory structure

```
my-service/
├── .claude/
│   ├── CLAUDE.md              # agent entrypoint — orientation + workflow
│   └── settings.json          # allowed/denied tool permissions
├── src/
│   └── my_service/
│       ├── __init__.py
│       ├── main.py            # app factory, startup only
│       ├── config.py          # settings via pydantic-settings; no logic
│       ├── api/               # HTTP layer — routers, request/response schemas
│       │   ├── __init__.py
│       │   ├── routes.py
│       │   └── schemas.py
│       ├── domain/            # pure business logic, no I/O
│       │   ├── __init__.py
│       │   └── <bounded_context>.py
│       ├── infra/             # I/O adapters (DB, queues, external APIs)
│       │   ├── __init__.py
│       │   ├── db.py
│       │   └── clients.py
│       └── services/          # orchestration — calls domain + infra
│           ├── __init__.py
│           └── <use_case>.py
├── tests/
│   ├── unit/                  # domain/ tests — no I/O, no fixtures
│   ├── integration/           # services/ + infra/ tests — real DB/mock HTTP
│   └── conftest.py
├── scripts/
│   └── check_rules.sh         # linting + type-check + test in one command
├── pyproject.toml             # single source of tool config (ruff, mypy, pytest)
├── Makefile                   # thin aliases: make test, make lint, make run
└── ARCHITECTURE.md            # human-readable domain map (agent reads this)
```

---

## 2. CLAUDE.md — the agent entrypoint

Place at `.claude/CLAUDE.md`. This is the first file an agent reads.

```markdown
## What this service does
One paragraph. No jargon.

## Domain boundaries (read before touching code)
- `domain/` — pure logic. No imports from `infra/` or `api/`. No I/O.
- `infra/` — all external I/O. Never imported by `domain/`.
- `api/` — HTTP concerns only. Calls `services/`, never `domain/` directly.
- `services/` — the only layer that wires domain + infra together.

## Feedback loop
```bash
make test        # unit + integration
make lint        # ruff + mypy
make check       # both
```
All three must pass before opening a PR. CI runs the same commands.

## Off-limits
- Do not edit `pyproject.toml` tool config sections without approval.
- Do not add dependencies to `pyproject.toml` without approval.
- Do not commit secrets or `.env` files.

## Gotchas
- Config is loaded once at startup via `config.py`. Do not read env vars elsewhere.
- Tests that hit the DB require `DATABASE_URL` set in `.env.test`.
```

---

## 3. Domain boundaries and enforcement

### Layer rules (import discipline)

| Layer | May import | Must not import |
|-------|-----------|-----------------|
| `domain/` | stdlib, pure libs (no I/O) | `infra/`, `api/`, `services/` |
| `infra/` | `domain/`, stdlib, DB/HTTP libs | `api/`, `services/` |
| `services/` | `domain/`, `infra/` | `api/` |
| `api/` | `services/`, schemas | `infra/`, `domain/` directly |

Enforce with `import-linter` (add to `pyproject.toml`):

```toml
[tool.importlinter]
root_packages = ["my_service"]

[[tool.importlinter.contracts]]
name = "Domain is pure"
type = "forbidden"
source_modules = ["my_service.domain"]
forbidden_modules = ["my_service.infra", "my_service.api", "my_service.services"]

[[tool.importlinter.contracts]]
name = "API does not call infra directly"
type = "forbidden"
source_modules = ["my_service.api"]
forbidden_modules = ["my_service.infra"]
```

Run with `lint-imports` (part of `import-linter` package). Add to `make lint`.

### Type safety

Full mypy strict mode in `pyproject.toml`:

```toml
[tool.mypy]
strict = true
plugins = ["pydantic.mypy"]
```

Agents must not disable mypy on a line without a comment explaining why.

### Linting

```toml
[tool.ruff]
line-length = 100
select = ["E", "F", "I", "UP", "B", "SIM", "TCH"]

[tool.ruff.lint.isort]
known-first-party = ["my_service"]
```

---

## 4. Fast feedback loop

`Makefile`:

```makefile
.PHONY: test lint check run

test:
	pytest tests/unit -x -q
	pytest tests/integration -x -q

lint:
	ruff check src tests
	mypy src
	lint-imports

check: lint test

run:
	uvicorn my_service.main:app --reload
```

`scripts/check_rules.sh` (identical logic, for CI and agents that prefer shell):

```bash
#!/usr/bin/env bash
set -euo pipefail
ruff check src tests
mypy src
lint-imports
pytest tests/ -x -q
echo "All checks passed."
```

An agent should always run `make check` (or `bash scripts/check_rules.sh`) after any non-trivial change.

---

## 5. ARCHITECTURE.md — domain map

Keep it short. One section per bounded context. Example:

```markdown
# Architecture

## Bounded contexts
- **Orders** (`domain/orders.py`) — create, validate, price an order
- **Inventory** (`domain/inventory.py`) — check and reserve stock

## Key flows
1. POST /orders → api/routes → services/order_service → domain/orders + infra/db
2. GET /inventory/:id → api/routes → services/inventory_service → infra/db

## External dependencies
- PostgreSQL (orders + inventory tables)
- Stripe (payments, via infra/clients.py)
```

This file is the first thing to update when adding a new domain concept. Agents use it to know where a new feature belongs before writing a single line.

---

## 6. .claude/settings.json — agent permissions

```json
{
  "permissions": {
    "allow": [
      "Bash(make:*)",
      "Bash(pytest:*)",
      "Bash(ruff:*)",
      "Bash(mypy:*)",
      "Bash(lint-imports:*)",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ],
    "deny": [
      "Bash(git push --force:*)",
      "Bash(pip install:*)",
      "Bash(rm -rf:*)"
    ]
  }
}
```

Agents can run tests and linters freely. Installing packages and force-pushing require human approval.

---

## 7. Minimal pyproject.toml skeleton

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "my-service"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.110",
    "uvicorn[standard]>=0.29",
    "pydantic-settings>=2.0",
    "sqlalchemy>=2.0",
]

[project.optional-dependencies]
dev = [
    "pytest",
    "pytest-asyncio",
    "httpx",
    "ruff",
    "mypy",
    "import-linter",
]

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]

[tool.ruff]
line-length = 100
select = ["E", "F", "I", "UP", "B", "SIM", "TCH"]

[tool.mypy]
strict = true

[tool.importlinter]
root_packages = ["my_service"]
# ... contracts as above
```

---

## Summary: what makes this agent-ready

| Concern | Mechanism |
|---------|-----------|
| Orientation | `.claude/CLAUDE.md` + `ARCHITECTURE.md` |
| Layer discipline | `import-linter` contracts, enforced in CI |
| Type safety | mypy strict, no inline suppressions without reason |
| Feedback loop | `make check` = lint + types + tests, runs in <30s for most services |
| Permissions | `.claude/settings.json` allows read/test/lint, blocks install/force-push |
| Off-limits | Explicit list in CLAUDE.md; agents won't guess |
| Config hygiene | Single `config.py`, no stray `os.getenv` calls |

# Architecture Layer: Domains, Layers, and Boundaries

This reference covers domain identification, layer mapping, and dependency rules.

## The Tracer-Bullet Principle

A domain is a **vertical slice** that cuts through ALL integration layers
end-to-end. Think of it as a tracer bullet: it starts at the data shapes (Types)
and travels through configuration, data access, business logic, orchestration,
all the way to the user-facing output (UI or CLI). That complete vertical path,
serving one coherent business purpose, is a domain.

This is the most important concept in the architecture layer, and the most
commonly confused. Agents default to slicing by technical function — grouping
all controllers together, all models together, all utilities together. That
produces horizontal layers, not domains. The harness architecture requires
vertical slices.

### The Litmus Test

Ask: **"Can I trace a user-visible action from the UI, through business logic,
through data access, down to the data types — and does that entire path belong
to one coherent business concept?"**

If yes → that's a domain.
If the path crosses multiple business concepts → those are separate domains.
If the grouping is by technical function (all controllers, all models) → that's
a layer, not a domain.

### Visual: Vertical vs Horizontal

```
CORRECT — Vertical domains:             WRONG — Horizontal layers:

  Billing     Auth     Onboarding        ┌─ controllers/ ─────────────┐
  ┌──────┐  ┌──────┐  ┌──────────┐      │  billing_ctrl, auth_ctrl   │
  │Types │  │Types │  │Types     │      ├─ services/ ────────────────┤
  │Config│  │Config│  │Config    │      │  billing_svc, auth_svc     │
  │Repo  │  │Repo  │  │Service   │      ├─ models/ ─────────────────┤
  │Svc   │  │Svc   │  │UI        │      │  billing_model, auth_model │
  │Rntme │  │Rntme │  └──────────┘      ├─ utils/ ──────────────────┤
  │UI    │  │UI    │                     │  helpers, formatters       │
  └──────┘  └──────┘                     └────────────────────────────┘

Each domain owns its full     Technical grouping scatters
stack. Layers are INSIDE      each business concept across
each domain.                  multiple directories.
```

## Domain Identification Heuristics

### Step 1: Start From Business Concepts, Not Code

Before looking at the code, ask: what does this product DO for users? Each
distinct capability is a domain candidate:
- "Users can subscribe and pay" → Billing domain
- "Users can sign up and configure their account" → Onboarding domain
- "Users can search for content" → Search domain
- "The system sends notifications" → Notifications domain

### Step 2: Validate Against the Codebase

Now look at the code to see how these concepts are implemented:

1. **Directory structure** — Top-level directories under `src/`, `lib/`, `app/`,
   or `packages/` often map to domains if the repo is well-organized.
2. **Package manifests** — In monorepos, each package/workspace may be a domain.
3. **Import graphs** — Code that imports each other heavily but has few external
   imports is likely one domain.
4. **Data models** — Clusters of related types/schemas that serve one business
   concept indicate a domain.
5. **Team ownership** — If different teams own different parts, those boundaries
   are often domain boundaries.

### Step 3: Apply the Vertical Test

For each candidate domain, check: does it own (or could it own) its own
vertical stack? A domain should contain or be able to contain its own:
- Data types and contracts
- Business logic
- Data access (if applicable)
- User-facing interface (if applicable)

If a candidate "domain" is actually a technical concern shared across multiple
business concepts (logging, auth middleware, test utilities), it's a
**cross-cutting concern**, not a domain. It enters through Providers.

### What Makes a Good Domain Boundary

- **Vertical ownership**: The domain owns its stack from types to UI
- **Business alignment**: The name maps to a business concept users would recognize
- **Cohesion**: Code inside the domain is tightly related to one purpose
- **Loose coupling**: Domains interact through defined interfaces, not deep imports

### Common Anti-Patterns

- **Horizontal slicing as domains**: "controllers", "models", "services", "utils",
  "tooling", "testing" are layers or concerns, NEVER domains. This is the single
  most common mistake. If your domain name describes a technical function rather
  than a business capability, it's wrong.
- **Too granular**: Every directory becomes a "domain" — usually means the code
  should just be a module within a larger domain.
- **Too coarse**: Everything is one domain — look for natural seams where distinct
  user-facing capabilities emerge.
- **Infrastructure as domains**: "database", "api-gateway", "message-queue" are
  infrastructure, not domains. They serve domains through the Repo or Runtime layers.

### Worked Example: A Skills Repository

Consider a repo that contains AI agent skills:

**Wrong** (horizontal slicing):
- "skills-content" (the skill files) ← technical grouping
- "skills-tooling" (validation scripts) ← technical grouping
- "skills-testing" (test fixtures) ← technical grouping

**Right** (vertical slicing by business concept):
- "skill-authoring" domain: types for skill format → validation service →
  CLI tooling for creating/editing skills → template generation
- "skill-distribution" domain: packaging types → registry service →
  install/publish commands
- "skill-evaluation" domain: eval types → scoring service → test runner →
  report output

Each domain owns a complete user-facing capability with its own vertical stack.
The "tooling" and "testing" that were incorrectly labeled as domains are actually
layers within the real domains.

## Layer Structure

Within each domain, code is organized into layers with strict dependency direction.

### Canonical Layers

```
Types → Config → Repo → Service → Runtime → UI
```

| Layer | Purpose | Typical contents |
|-------|---------|-----------------|
| Types | Data shapes and contracts | Interfaces, schemas, enums, constants |
| Config | Configuration and environment | Env vars, feature flags, settings |
| Repo | Data access | Database queries, API clients, cache access |
| Service | Business logic | Core operations, validation, transformations |
| Runtime | Orchestration and lifecycle | Server setup, workers, job queues, middleware |
| UI | User-facing interface | Components, pages, routes, CLI output |

### The Forward-Only Rule

Dependencies must flow forward in the layer order. A `types` module never imports
from `service`. A `repo` module never imports from `ui`. This is the single most
important architectural rule — it prevents circular dependencies and keeps each
layer independently testable.

### Not Every Domain Has Every Layer

A CLI tool might have: Types → Config → Service → Runtime (no Repo, no UI).
A shared library might have: Types → Service (nothing else).
A frontend-only module might have: Types → Service → UI.

Map what actually exists. Don't force empty layers into existence.

### Cross-Cutting Concerns

Auth, telemetry, feature flags, connectors — these cut across all domains.
They enter through a single explicit interface: **Providers**.

```
Cross-cutting concern → App Wiring → Providers → Service layer
```

Providers are injected at the application wiring level and consumed by the
service layer. This keeps cross-cutting logic out of domain internals while
making it available everywhere.

### Mapping for Different Tech Stacks

**TypeScript/Node.js:**
```
domain/
├── types.ts        (or types/)
├── config.ts
├── repo.ts         (or repo/)
├── service.ts      (or service/)
├── runtime.ts      (middleware, routes)
└── ui/             (React components)
```

**Python:**
```
domain/
├── types.py        (or models.py, schemas.py)
├── config.py
├── repo.py         (or repository.py)
├── service.py
├── runtime.py      (FastAPI routes, CLI commands)
└── ui/             (templates, if applicable)
```

**Swift:**
```
Domain/
├── Types/
├── Config/
├── Repository/
├── Service/
├── Runtime/
└── Views/
```

**Go:**
```
domain/
├── types.go
├── config.go
├── repo.go
├── service.go
├── handler.go      (runtime/HTTP handlers)
└── (no UI layer typically)
```

Adapt layer names to the ecosystem's conventions. The structure matters more
than the exact names.

## Generating domains.yml

When writing `.harness/domains.yml`, map only what actually exists in the codebase.

**Pre-check before writing any domain entry**: Does this domain pass the
tracer-bullet test? Ask:
1. Does the name describe a **business capability** (not a technical function)?
2. Can I trace a user-visible action through this domain's layers end-to-end?
3. Does it own its own types, logic, and at least one integration layer?

If the answer to #1 is no — it's probably a cross-cutting concern (put it in
`cross_cutting:`) or a layer within a real domain.

Each domain entry should:

1. Have a clear `name` and `description` tied to a business concept
2. Specify the `path` where the domain lives
3. List only the layers that actually exist in the code
4. Declare which cross-cutting providers the domain consumes

If a domain's internal structure doesn't follow clean layers yet, note this in
the domain description and flag it in quality.yml. The spec captures the target
state and the current reality.

### When the Codebase Is Horizontally Organized

Many repos are organized by technical layer (`controllers/`, `models/`,
`services/`). This doesn't mean there are no domains — it means the domain
boundaries are implicit in the code rather than explicit in the directory
structure.

In this case:
1. Identify the business concepts that the code serves
2. Map which files across the horizontal directories belong to each concept
3. Document these as the domains in domains.yml, noting that the current
   directory structure is horizontal
4. Flag this as a quality gap — the harness spec describes the target vertical
   organization even if the code hasn't been restructured yet

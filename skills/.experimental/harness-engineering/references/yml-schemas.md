# .harness/ YAML Schemas

All machine-readable harness configuration lives in `.harness/` at the repo root.
This reference defines the schema for each file with examples.

## config.yml

Top-level harness metadata.

```yaml
version: "1.0"
name: "my-project"
created: "2026-03-17"
updated: "2026-03-17"
tech_stack:
  languages:
    - typescript
    - python
  frameworks:
    - next.js
    - fastapi
  build:
    - turborepo
    - poetry
  test:
    - vitest
    - pytest
harness_components:
  - knowledge
  - architecture
  - enforcement
  - quality
  - process
```

**Fields:**
- `version`: Schema version (currently "1.0")
- `name`: Repository/project name
- `created`/`updated`: ISO dates
- `tech_stack`: Detected or declared technology stack
- `harness_components`: Which harness layers are active

## domains.yml

Business domain definitions with layer rules. Each domain is a **vertical slice**
— a tracer bullet that owns a complete path from data types to user-facing output.
Domains are NEVER horizontal technical layers (controllers, utils, tooling).
See `references/architecture-layer.md` for the full identification guide.

```yaml
version: "1.0"

layer_order:
  - types
  - config
  - repo
  - service
  - runtime
  - ui

dependency_rule: forward_only

cross_cutting:
  - name: auth
    description: Authentication and authorization
    entry_point: providers
  - name: telemetry
    description: Logging, metrics, and tracing
    entry_point: providers
  - name: feature-flags
    description: Feature flag evaluation
    entry_point: providers

domains:
  - name: billing
    description: Subscription management and payment processing
    path: src/billing
    layers:
      types: src/billing/types
      config: src/billing/config
      repo: src/billing/repo
      service: src/billing/service
      runtime: src/billing/runtime
      ui: src/billing/ui
    providers:
      - auth
      - telemetry

  - name: onboarding
    description: New user registration and setup flow
    path: src/onboarding
    layers:
      types: src/onboarding/types
      service: src/onboarding/service
      ui: src/onboarding/ui
    providers:
      - auth
      - telemetry
      - feature-flags
```

**Fields:**
- `layer_order`: The canonical layer sequence for this repo
- `dependency_rule`: `forward_only` means imports go left-to-right only
- `cross_cutting`: Shared concerns with their domain entry point
- `domains[]`: Each domain with its path, active layers, and consumed providers
- `domains[].layers`: Only list layers that actually exist in the codebase

## principles.yml

Golden principles with rationale and enforcement guidance.

```yaml
version: "1.0"

principles:
  - id: parse-at-boundaries
    name: Parse data shapes at system boundaries
    description: >
      Transform raw data into typed structures at the point of entry.
      Don't pass untyped data through and validate later.
    rationale: >
      Without boundary parsing, agents add ad-hoc validation everywhere.
      Typed structures from the boundary forward let agents trust the types.
    enforcement: lint
    severity: error
    examples:
      good: |
        // API route handler
        const order = OrderSchema.parse(req.body);
        await processOrder(order);  // order is typed
      bad: |
        // API route handler
        const data = req.body;
        if (data.items && Array.isArray(data.items)) {
          await processOrder(data);  // data is untyped
        }

  - id: shared-utils
    name: Shared utilities over hand-rolled helpers
    description: >
      Common operations belong in shared utility packages, not scattered
      across domains as one-off helpers.
    rationale: >
      Agents replicate patterns they find. Scattered helpers breed more
      scattered helpers. Centralized utilities are used by default.
    enforcement: review
    severity: warning
    examples:
      good: |
        import { mapWithConcurrency } from '@/shared/async';
        const results = await mapWithConcurrency(items, processItem, { limit: 5 });
      bad: |
        // billing/utils.ts
        async function processBatch(items, fn, concurrency) {
          // hand-rolled concurrency logic duplicating shared/async
        }
```

**Fields:**
- `id`: Kebab-case identifier
- `name`: Human-readable name
- `description`: What the rule is
- `rationale`: Why it matters in an agent-driven codebase
- `enforcement`: How it's checked — `lint`, `test`, `review`, `ci`, or `manual`
- `severity`: `error` (must fix), `warning` (should fix), `info` (advisory)
- `examples`: Concrete good/bad code from the actual codebase when possible

## enforcement.yml

Mechanical rules that tooling can check automatically.

```yaml
version: "1.0"

naming:
  files:
    pattern: kebab-case
    exceptions:
      - AGENTS.md
      - ARCHITECTURE.md
      - README.md
      - PLANS.md
      - Makefile
      - Dockerfile
  types:
    pattern: PascalCase
  functions:
    pattern: camelCase
  constants:
    pattern: SCREAMING_SNAKE_CASE
  schemas:
    pattern: PascalCase
    suffix: Schema

file_limits:
  max_lines: 500
  max_functions_per_file: 15
  max_complexity_per_function: 10

logging:
  style: structured
  required_fields:
    - level
    - message
    - timestamp
  prohibited_patterns:
    - console.log
    - console.warn
    - console.error

imports:
  boundary_check: true
  max_external_deps_per_module: 10
  banned_patterns:
    - "../../**/internal"
    - "../../../"

testing:
  boundary_testing_required: true
  min_coverage_new_code: 80
  naming_pattern: "*.test.ts"
  co_located: true
```

**Fields:**
- `naming`: Conventions per entity type with exceptions
- `file_limits`: Size and complexity limits
- `logging`: Structured logging requirements
- `imports`: Dependency rules and banned patterns
- `testing`: Coverage and test organization rules

## quality.yml

Per-domain quality grades.

```yaml
version: "1.0"

scale:
  - A
  - B
  - C
  - D
  - F

dimensions:
  - code_quality
  - test_coverage
  - documentation
  - observability
  - reliability
  - security

review_cadence: monthly

domains:
  billing:
    scores:
      code_quality: B
      test_coverage: C
      documentation: D
      observability: F
      reliability: B
      security: B
    gaps:
      - "No structured logging in payment webhook handlers"
      - "Missing retry logic for payment provider timeouts"
      - "Domain docs not yet written"
    notes: "Payment v2 migration in progress — scores will shift after completion"
    last_reviewed: "2026-03-17"

  onboarding:
    scores:
      code_quality: A
      test_coverage: B
      documentation: B
      observability: C
      reliability: C
      security: A
    gaps:
      - "Metrics not wired for funnel drop-off tracking"
      - "No circuit breaker on email service calls"
    notes: "Recently refactored — quality is high"
    last_reviewed: "2026-03-17"
```

**Fields:**
- `scale`: The grading scale (A–F)
- `dimensions`: What to grade
- `review_cadence`: How often to re-evaluate (daily, weekly, monthly, quarterly)
- `domains[]`: Each domain with scores, gaps, notes, and review date

## knowledge.yml

Configuration for the knowledge base structure.

```yaml
version: "1.0"

agents_md:
  style: toc
  max_lines: 100

docs_structure:
  design_docs:
    enabled: true
    index: true
    core_beliefs: true
  exec_plans:
    enabled: true
    sections:
      - active
      - completed
      - tech_debt
    template_path: PLANS.md
  product_specs:
    enabled: true
    index: true
  references:
    enabled: true
  generated:
    enabled: false

guides:
  - name: FRONTEND
    path: docs/FRONTEND.md
    description: Frontend architecture and component patterns
  - name: RELIABILITY
    path: docs/RELIABILITY.md
    description: Reliability engineering and SLOs
  - name: SECURITY
    path: docs/SECURITY.md
    description: Security model and threat boundaries
```

**Fields:**
- `agents_md`: AGENTS.md configuration (style and size constraint)
- `docs_structure`: Which docs/ sections are enabled
- `guides[]`: Domain-specific guide files to create/maintain

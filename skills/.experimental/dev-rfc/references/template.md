# RFC Reference Templates

Three templates for three scales. Most real RFCs blend proposal and architecture elements — use the RFC template as the backbone when proposing changes, and pull in Architecture Doc sections for the technical deep dive.

---

# Template A: RFC (Technical Proposal)

For pre-build alignment. Answers: "Should we build this, and how?"

```markdown
# [Project Name] RFC

| Field | Value |
|-------|-------|
| **Author(s)** | [names] |
| **Approver(s)** | [names — who needs to sign off] |
| **Status** | Draft · In Review · Approved · Superseded · Deprecated |
| **Created** | [date] |
| **Last Updated** | [date] |
| **Team** | [owning team] |

---

## Abstract

[3-5 sentence executive summary. State what the RFC proposes, why it matters,
and the key trade-off or insight that makes this proposal non-obvious.
A reader should be able to decide whether to read the full RFC from this alone.]

---

## Motivation

[Why are we doing this? Ground in concrete data or incidents —
"Users experience 3s load times on the dashboard" not "The page is slow."
Include links to metrics, incident reports, or user feedback.]

---

## Goals and Non-Goals

**Goals:**
- [Specific, measurable. "P99 latency under 200ms" not "fast."]
- [Each goal should be verifiable after the project ships.]

**Non-Goals:**
- [What this project will NOT do. Prevents scope creep.]
- [If a non-goal is planned for later, say so.]

---

## Approaches

Present all evaluated options together. Each approach should be given a fair treatment with genuine pros and cons.

### Approach 1: [Name]

**Description:** [How this approach works at a high level.]

**Architecture:**

```
    +------------------+     +------------------+     +------------------+
    |   Component A    |---->|   Component B    |---->|   Component C    |
    |   (description)  |     |   (description)  |     |   (description)  |
    +------------------+     +------------------+     +------------------+
```

**Pros:**
- [Genuine advantage]
- [Genuine advantage]

**Cons:**
- [Honest trade-off]
- [Honest trade-off]

**Estimated Effort:** [T-shirt size or person-weeks]

### Approach 2: [Name]

[Same structure as Approach 1.]

### Approach 3: [Name] (if applicable)

[Same structure.]

### Recommendation

**Chosen approach:** [Name]

**Justification:** [Why this approach wins given the specific goals, constraints,
and trade-offs. Acknowledge what you're giving up relative to the alternatives.]

---

## Detailed Design

Deep dive on the recommended approach only.

### Architecture Changes

[Diagram showing the proposed architecture. Mark new components with `[NEW]`
and changed ones with `[CHANGED]`.]

```
    +---------+    +-------------+    +-----------+
    | Client  |--->| Gateway     |--->| Service A |
    +---------+    | [NEW]       |    | [CHANGED] |
                   +------+------+    +-----------+
                          |
                   +------+------+
                   | Service B   |
                   | [NEW]       |
                   +-------------+
```

### API / Interface Design

[Endpoints, request/response schemas, or function signatures.
Include examples of key request/response payloads.]

### Data Model

[Schema, entity relationships, key fields. Call out denormalization,
indexing strategy, and any migration required.]

---

## Service SLAs

| Metric | Target |
|--------|--------|
| **Availability** | [e.g., 99.95%] |
| **Latency P50** | [e.g., 50ms] |
| **Latency P95** | [e.g., 150ms] |
| **Latency P99** | [e.g., 300ms] |
| **Throughput** | [e.g., 10k RPS] |
| **Error Budget** | [e.g., 0.05% / month] |

[Justify targets based on user expectations and upstream/downstream constraints.]

---

## Service Dependencies

| Dependency | Type | Failure Mode | Mitigation |
|------------|------|-------------|------------|
| [Service/DB] | [sync/async] | [What happens if it's down] | [Circuit breaker, cache, fallback] |

[Call out any new dependencies introduced and their SLA impact.]

---

## Security Considerations

- **Authentication:** [How users/services authenticate]
- **Authorization:** [Access control model, permission boundaries]
- **Data Protection:** [Encryption at rest/transit, sensitive data handling]
- **Threat Model:** [Key attack vectors considered and mitigations]

---

## Testing & Rollout

### Test Plan
- **Unit tests**: [Key behaviors to cover]
- **Integration tests**: [Cross-component interactions]
- **Load tests**: [Performance targets and methodology]

### Rollout Plan
- **Phase 1**: [Feature flags, shadow mode, or canary deployment]
- **Phase 2**: [Gradual rollout — percentage, metrics to watch]
- **Phase 3**: [Full rollout, cleanup of old code paths]

### Rollback Plan
[How to revert if something goes wrong. Include specific steps and decision criteria.]

### Data Migration
[If applicable — how existing data is transformed, backfill strategy, rollback for data changes.]

---

## Observability

- **Key Metrics**: [What to measure — latency, error rates, throughput, business metrics]
- **Dashboards**: [What dashboards to create or update]
- **Alerts**: [What triggers pages vs. warnings, thresholds]
- **Tracing**: [Distributed tracing spans, correlation IDs]

---

## Open Questions

1. [Question — include context and your leaning]
2. [Question]

---

## References

- [Related RFCs, prior art, dashboards, incident reports]
```

---

## Domain Addenda

Include the relevant addendum sections based on the system type. These go after the core RFC sections.

### Backend / Infrastructure Addendum

```markdown
## Load & Performance Testing

[Load test methodology, target throughput, stress test scenarios.
Include baseline comparisons.]

## Multi-Region / Data Center

[Replication strategy, consistency model, failover behavior.
How does the system behave during a region outage?]

## Cost Projections

| Resource | Current | Projected | Delta |
|----------|---------|-----------|-------|
| [Compute/Storage/Network] | [$X/mo] | [$Y/mo] | [+$Z/mo] |

[Cost at 1x, 5x, 10x current scale.]

## Customer Support Impact

[New support workflows, runbooks, escalation paths needed.]
```

### Frontend / Mobile Addendum

```markdown
## UI & UX

[Wireframes or mockups. User flows. Interaction patterns.
Link to Figma/design files.]

## Network Interactions

[API calls, WebSocket connections, polling behavior.
Offline handling, retry strategies.]

## Library Dependencies

| Library | Version | Size | License | Justification |
|---------|---------|------|---------|--------------|
| [name] | [ver] | [KB] | [MIT/etc] | [why needed] |

## Performance Budget

| Metric | Budget | Current |
|--------|--------|---------|
| Bundle size (gzipped) | [KB] | [KB] |
| First Contentful Paint | [ms] | [ms] |
| Largest Contentful Paint | [ms] | [ms] |
| Cumulative Layout Shift | [score] | [score] |
| Interaction to Next Paint | [ms] | [ms] |

## Accessibility

[WCAG target level (A/AA/AAA). Keyboard navigation plan.
Screen reader support. Color contrast. Focus management.]

## Analytics

[Events to track, instrumentation plan, A/B test setup.]

## Customer Support Impact

[New support workflows, FAQ updates, known-issue documentation.]
```

### Data / ML Addendum

```markdown
## Data Pipeline Architecture

[Pipeline DAG, scheduling, data sources and sinks.
Processing guarantees (at-least-once, exactly-once).]

## Data Quality

[Validation rules, monitoring, anomaly detection.
Data freshness SLAs, schema evolution strategy.]

## Privacy & Compliance

[PII handling, data retention policies, GDPR/CCPA compliance.
Right to deletion implementation, audit logging.]

## Model Performance

| Metric | Baseline | Target |
|--------|----------|--------|
| [Accuracy/Precision/Recall/F1] | [X%] | [Y%] |
| Inference latency P95 | [ms] | [ms] |
| Model size | [MB] | [MB] |

[Training data requirements, retraining cadence, drift detection.]

## Experimentation Plan

[A/B test design, holdout groups, success criteria,
minimum detectable effect, experiment duration.]
```

---

# Template B: Architecture Document

For documenting built systems. Answers: "How does this system work?"

```markdown
# [Project Name] Architecture Document

| Field | Value |
|-------|-------|
| **Author(s)** | [names] |
| **Last Updated** | [date] |
| **Status** | Current · Outdated · Deprecated |

[1-2 sentence summary. Link to README for build/usage info.]

---

## High-Level Architecture

[Pick the diagram style that matches your system.]

### Pipeline (compilers, data pipelines, ETL)
```
  +-------------+     +-------------+     +-------------+
  | STAGE 1     |---->| STAGE 2     |---->| STAGE 3     |
  | src/stage1/ |     | src/stage2/ |     | src/stage3/ |
  +-------------+     +-------------+     +-------------+
     Input              Intermediate          Output
```

### Request Flow (services, APIs)
```
  Client --> [Router] --> [Auth] --> [Handler] --> [DB]
                                        |
                                        +--> [External Service]
```

### Layer Diagram (web apps, CRUD)
```
  +--------------------------------------------+
  |  UI Layer        (src/components/, pages/)  |
  +--------------------------------------------+
  |  API Layer       (src/api/, routes/)        |
  +--------------------------------------------+
  |  Service Layer   (src/services/)            |
  +--------------------------------------------+
  |  Data Layer      (src/models/, repos/)      |
  +--------------------------------------------+
```

---

## Source Tree

```
src/
  subsystem-a/           What subsystem A does
    module1/             What module1 does
  subsystem-b/           What subsystem B does
  shared/                Shared types, utilities
```

---

## Data Flow

[Concrete types/interfaces between phases.]

```
  InputType --> module::method() --> IntermediateType --> module::method() --> OutputType
```

---

## Key Design Decisions

- **Decision 1**: What was chosen and rationale.
- **Decision 2**: What was chosen and rationale.

---

## Design Philosophy

- **Principle.** How it manifests in the codebase.

---

## Sub-System Architecture

### Subsystem A

[Internal architecture, own diagrams if needed. Comparison table for variants.]

---

## Module Documentation

| Module | README |
|--------|--------|
| Subsystem A | [`src/subsystem-a/README.md`](src/subsystem-a/README.md) |
```

---

# Template C: One-Pager

For small changes (< 1 week, single component). Keep it under 1 page.

```markdown
# [Change Name]

| Field | Value |
|-------|-------|
| **Author** | [name] |
| **Status** | Draft · Approved |
| **Date** | [date] |

## Problem

[2-3 sentences. What's broken or missing, and why it matters.]

## Proposed Solution

[What you'll do. 1-2 paragraphs + optional diagram.]

## Rollout

- **How:** [Feature flag / direct deploy / migration script]
- **Rollback:** [How to revert if it breaks]
- **Risks:** [Anything non-obvious, or "None — isolated change"]
```

---

# Scaling Guidance

| Change size | Format | RFC sections | Architecture Doc sections |
|------------|--------|-------------|--------------------------|
| **Small** (< 1 week) | One-pager (Template C) | Problem, Solution, Rollout | Skip |
| **Medium** (1-4 weeks) | Standard RFC | All core sections | Architecture in Detailed Design |
| **Large** (> 1 month, cross-team) | Full RFC + sub-docs | All sections + domain addenda | Full Architecture sections, linked sub-docs |
| **Retrospective** (documenting what exists) | Architecture doc | Skip — use Template B | All sections |

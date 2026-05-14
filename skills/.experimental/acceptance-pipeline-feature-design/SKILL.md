---
name: acceptance-pipeline-feature-design
description: Use this skill when designing new features, extensions, or modifications to Uncle Bob's Acceptance Pipeline Specification. Triggers on requests to extend the pipeline with new mutation strategies, Gherkin syntax support, report formats, pipeline stages, IR fields, or handler patterns. Also trigger when someone asks "how would I add X to the acceptance pipeline" or discusses spec-level changes to the parser, generator, runtime, mutator, or reporter components — even if they don't explicitly say "feature design." Works in tandem with the acceptance-pipeline-catalog skill, which provides the baseline spec reference.
---

# Acceptance Pipeline Feature Design

Guides agents through designing new features that extend Uncle Bob's Acceptance Pipeline Specification. Produces spec-quality output — language-neutral, implementation-agnostic, with precise behavioral requirements — that matches the style and rigor of the original spec.

This is a composition skill. It does not catalog what exists (that is `acceptance-pipeline-catalog`'s job). Instead, it provides a structured workflow for designing what comes next.

## When to Apply

- Designing a new mutation strategy, value type, or filter mechanism for the mutator
- Adding new Gherkin syntax support (data tables, tags, Rules keyword) to the parser
- Extending the JSON IR with new fields or objects
- Creating new report formats (HTML, JUnit XML) or output channels
- Adding new pipeline stages or operating modes (parallel runs, coverage filtering)
- Any spec-level change that affects multiple pipeline components (cross-cutting)

## Prerequisite

Before using this skill, ensure `acceptance-pipeline-catalog` is available. That skill provides the baseline reference for the 9 required components, JSON IR schema, conformance checklist (21 items), and agent setup checklist (15 steps). This skill builds on top of that foundation.

## Workflow Overview

The workflow has five phases, executed in order. Each phase builds on the output of the previous one — skipping phases produces incomplete or inconsistent designs.

```
Phase 1: Survey Existing Spec     → Know what exists before proposing changes
Phase 2: Identify Extension Point → Classify where the feature attaches
Phase 3: Draft Feature Spec       → Write the spec section in Uncle Bob's style
Phase 4: Conformance Design       → Add testable conformance items
Phase 5: Impact Analysis          → Assess backward compatibility and migration
```

**Why this order matters:**
- Phase 1 prevents reinventing existing capabilities and ensures the design uses established patterns.
- Phase 2 forces classification before writing — a parser extension has different constraints than a reporter extension.
- Phase 3 produces the actual spec text, informed by the classification from Phase 2.
- Phase 4 ensures the feature is testable from outside the implementation — if you cannot write conformance items, the spec is too vague.
- Phase 5 comes last because you need the complete spec and conformance items to assess impact accurately.

## How to Use

1. Start by reading the `acceptance-pipeline-catalog` skill to understand the current spec
2. Read the phase reference that matches your current workflow step:

| Phase | Reference | When to Read |
|-------|-----------|-------------|
| 1 | [Survey Existing Spec](references/phase-1-survey.md) | Always — first step for any feature design |
| 2 | [Identify Extension Point](references/phase-2-extension-point.md) | After survey — classify where the feature attaches |
| 3 | [Draft Feature Spec](references/phase-3-draft-spec.md) | After classification — write the spec section |
| 4 | [Conformance Design](references/phase-4-conformance.md) | After drafting — add testable conformance items |
| 5 | [Impact Analysis](references/phase-5-impact-analysis.md) | After conformance — assess compatibility |

3. Consult supporting references as needed:

| Reference | When to Read |
|-----------|-------------|
| [Style Guide](references/style-guide.md) | During Phase 3 — Uncle Bob's spec writing patterns |
| [Extension Catalog](references/extension-catalog.md) | During Phase 2 — ideas and complexity notes for future extensions |

## Extension Point Quick Reference

Features attach to one or more of these 9 components. The JSON IR is the highest-impact extension point because all components consume it.

| Extension Point | What Changes | Impact Level |
|----------------|-------------|-------------|
| Parser | New Gherkin syntax accepted | Medium — affects IR and downstream |
| IR | New fields or objects in JSON interchange | **High** — all consumers affected |
| Generator | New output formats or generation strategies | Low — isolated to generation |
| Runtime | New execution modes, hooks, dispatch | Medium — affects handler contracts |
| Handlers | New matching strategies or contracts | Low-Medium — isolated to step matching |
| Mutator | New mutation strategies or filters | Low — isolated to mutation mode |
| Reporter | New report formats or output channels | Low — isolated to reporting |
| Pipeline | New stages or operating modes | **High** — structural change |
| Cross-cutting | Spans multiple components | **Highest** — requires careful analysis |

## Output

The workflow produces these artifacts:

1. **Feature spec section** — Ready to insert into the Acceptance Pipeline Specification. Written in Uncle Bob's style with purpose paragraph, behavioral requirements, data formats, and examples.
2. **Conformance items** — Numbered, testable items extending the existing 21-item checklist.
3. **Impact analysis table** — Component-by-component assessment of change type, IR effects, breaking changes, and new conformance items.

## Related Skills

- `acceptance-pipeline-catalog` — Baseline reference for the complete spec (prerequisite)
- `clean-code` — Uncle Bob's coding principles (useful context for style alignment)

## Gotchas

See [gotchas.md](gotchas.md) for failure points discovered during use.

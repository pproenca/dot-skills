# Phase 5: Impact Analysis

**Goal:** Assess backward compatibility, migration requirements, and the full blast radius of the proposed feature.

**Why last:** Impact analysis requires the complete spec draft (Phase 3) and conformance items (Phase 4) to be accurate. Analyzing impact on an incomplete design produces false confidence — you think the change is safe, but you missed a component interaction that only becomes visible when writing conformance items.

## Steps

### 5.1 Component-by-Component Assessment

For each of the 9 components, answer these questions:

| Question | Why It Matters |
|----------|---------------|
| Does this change the command interface? | Command interface changes break existing scripts and CI pipelines |
| Does this change the JSON IR schema? | IR changes affect every component downstream of the parser |
| Does this require new exit codes? | Exit code changes affect runner adapters and CI integration |
| Does this affect mutation determinism? | Determinism is a core property — same seed must produce same mutations |
| Does this change the conformance checklist? | Conformance changes affect how implementations are validated |
| Does this affect the agent setup checklist? | Setup changes affect how new projects adopt the pipeline |

### 5.2 Classify Overall Change

Based on the per-component assessment, classify the overall feature:

**Additive** — New capability, no existing behavior changes. An existing conformant implementation continues to pass all 21 existing conformance items without modification.

Indicators:
- New optional IR fields only
- New commands alongside existing ones
- New exit codes that were previously undefined
- New conformance items that only apply to implementations claiming the new feature

**Modifying** — Existing behavior changes. An existing conformant implementation may need updates to pass existing conformance items, or existing conformance items are reworded.

Indicators:
- Required IR fields change meaning
- Existing commands gain new required arguments
- Exit code meanings change
- Existing conformance items are modified

**Breaking** — Existing interfaces change in incompatible ways. An existing conformant implementation will fail existing conformance items.

Indicators:
- IR fields removed or renamed
- Commands removed or renamed
- Exit codes reassigned
- Conformance items removed or fundamentally changed

### 5.3 For Breaking Changes: Mitigation

If any component has a breaking change, explore these mitigation strategies in order of preference:

1. **Make it additive with an opt-in flag.** Can the new behavior be activated by a flag while preserving the old default? This is the strongest mitigation because existing users are unaffected.

2. **Add a deprecation period.** Can the old behavior be preserved alongside the new behavior for one version, with a deprecation warning?

3. **Provide a migration script.** Can a script convert existing IR files, configuration, or step handlers to the new format?

4. **Document the minimum viable change.** What is the smallest change that still solves the problem? Sometimes breaking changes are proposed because the first design was ambitious, but a smaller additive change is possible.

**If none of these work**, the breaking change may be justified — but document why each mitigation strategy was rejected.

### 5.4 Produce the Impact Summary Table

This table is the primary output of Phase 5. It gives a complete picture at a glance.

```markdown
| Component | Change Type | IR Affected | Breaking | Conformance Items | Notes |
|-----------|------------|-------------|----------|-------------------|-------|
| Parser    | Additive   | Yes         | No       | 22, 23, 24        | New syntax only |
| IR        | Additive   | Yes         | No       | 25, 26            | New optional field |
| Generator | Modifying  | N/A         | No       | —                 | Must handle new field |
| Runtime   | Additive   | N/A         | No       | 27, 28            | New handler argument |
| Handlers  | None       | N/A         | No       | —                 | User-authored, no spec change |
| Mutator   | Additive   | No          | No       | 29, 30            | Mutates table values |
| Reporter  | None       | N/A         | No       | —                 | No change |
| Runner    | None       | N/A         | No       | —                 | No change |
| Scripts   | Additive   | N/A         | No       | —                 | No new scripts needed |
```

Column definitions:
- **Change Type:** Additive, Modifying, Breaking, or None
- **IR Affected:** Does this component's change involve IR schema changes?
- **Breaking:** Would this break an existing conformant implementation of this component?
- **Conformance Items:** Which new items (from Phase 4) apply to this component?
- **Notes:** Brief justification or clarification

### 5.5 Agent Setup Checklist Impact

If the feature requires new setup steps:
- Where in the 15-step checklist do they go?
- Are they required for all users or only those using the new feature?
- Do they add new dependencies?

If no setup changes are needed, state explicitly: "No changes to agent setup checklist."

### 5.6 Write the Impact Summary

Combine everything into a concise summary:

```markdown
## Impact Summary: [Feature Name]

**Overall classification:** [Additive/Modifying/Breaking]
**IR changes:** [None / New optional fields / New required fields / Changed existing fields]
**Backward compatible:** [Yes/No]
**Migration required:** [None / Script provided / Manual steps documented]
**Setup checklist changes:** [None / New steps added]
**Conformance items added:** [Count] (items [range])

[Impact summary table from 5.4]

### Risk Assessment
[1-3 sentences on the highest-risk aspects of this change]

### Recommendation
[1-2 sentences: proceed as designed / simplify to reduce blast radius / prototype first]
```

## Checklist: Feature Design Complete

After Phase 5, the complete feature design package includes:

- [ ] **Phase 1 output:** Confirmed understanding of existing spec
- [ ] **Phase 2 output:** Extension point classification with change types per component
- [ ] **Phase 3 output:** Feature spec section (purpose, requirements, data formats, interactions)
- [ ] **Phase 4 output:** Numbered conformance items grouped by component
- [ ] **Phase 5 output:** Impact summary table with classification, migration notes, and recommendation

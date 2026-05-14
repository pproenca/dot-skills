# Phase 2: Identify Extension Point

**Goal:** Classify exactly where the new feature attaches to the pipeline and determine its blast radius.

**Why second:** Classification before writing prevents scope creep. A feature that starts as "add data tables to Gherkin" might seem like a parser-only change, but actually requires IR extensions, generator changes, and runtime modifications. Classifying up front forces you to acknowledge the full scope before committing to a spec draft.

## Steps

### 2.1 Name the Extension Category

Every feature falls into one of these categories. Pick the primary one:

| Category | Description | Example Features |
|----------|-------------|-----------------|
| **Parser extension** | New Gherkin syntax the parser must accept | Data tables, tags, Rules keyword, localized keywords |
| **IR extension** | New fields or objects in the JSON IR | Tag metadata, table data, rule groupings |
| **Generator extension** | New output formats or generation strategies | New language targets, parameterized test styles |
| **Runtime extension** | New execution modes, hooks, or dispatch patterns | Before/after hooks, parallel execution, async steps |
| **Handler extension** | New matching strategies or handler contracts | Step expressions, regex matching, typed parameters |
| **Mutator extension** | New mutation strategies, value types, or filters | Custom mutators, coverage-based filtering, tag-based scoping |
| **Reporter extension** | New report formats or output channels | HTML reports, JUnit XML, CI integration |
| **Pipeline extension** | New pipeline stages or operating modes | Parallel runs, dry-run mode, watch mode |
| **Cross-cutting** | Spans multiple components | Multi-feature support, tag-based filtering (parser + IR + runtime + mutator) |

**If the feature is cross-cutting**, list all affected components. Cross-cutting features are the most complex to design because they require coordinated changes across component boundaries.

### 2.2 Map Affected Spec Sections

For each affected component, identify:

1. **Which spec sections describe this component?** Reference by name from the catalog.
2. **What existing behaviors are relevant?** List the current capabilities the feature interacts with.
3. **Are there implicit contracts?** For example, the generator assumes every scenario has at least one example row. Does your feature change that assumption?

### 2.3 Classify the Change Type

For each affected component, classify the change:

| Type | Definition | Example |
|------|-----------|---------|
| **Additive** | New capability, no existing behavior changes. Backward compatible. | Adding HTML reporter alongside existing text reporter |
| **Modifying** | Existing behavior changes. May require migration. | Changing how the mutator selects values to mutate |
| **Breaking** | Existing interfaces change. Requires version bump. | Adding required fields to the JSON IR |

**Rule of thumb:** If an existing, conformant implementation would break or produce different output after your change, it is modifying or breaking — not additive.

### 2.4 Assess IR Impact

The JSON IR question is critical enough to get its own step:

- **Does this feature add new fields to the IR?** If yes, are they optional or required?
- **Does this feature change existing IR fields?** If yes, this is almost certainly a breaking change.
- **Does this feature add new top-level objects?** If yes, this needs careful versioning consideration.
- **Can this feature work without any IR changes?** Sometimes a feature can be implemented entirely within one component (e.g., a new reporter that reads the existing IR differently).

**Prefer additive IR changes** (new optional fields) over modifying changes (changing existing fields). Optional fields let old implementations ignore what they do not understand.

### 2.5 Document the Classification

Record your classification in this format before proceeding to Phase 3:

```markdown
## Feature: [Name]

**Primary category:** [Parser/IR/Generator/Runtime/Handler/Mutator/Reporter/Pipeline/Cross-cutting]
**Affected components:** [List]
**Change type per component:**
- Parser: [Additive/Modifying/Breaking/None]
- IR: [Additive/Modifying/Breaking/None]
- Generator: [Additive/Modifying/Breaking/None]
- Runtime: [Additive/Modifying/Breaking/None]
- Handlers: [Additive/Modifying/Breaking/None]
- Mutator: [Additive/Modifying/Breaking/None]
- Reporter: [Additive/Modifying/Breaking/None]
- Scripts: [Additive/Modifying/Breaking/None]

**IR impact:** [None / New optional fields / New required fields / Changed existing fields]
**Backward compatible:** [Yes/No]
```

## Checklist Before Proceeding

- [ ] Primary extension category identified
- [ ] All affected components listed (not just the obvious one)
- [ ] Change type classified per component
- [ ] IR impact assessed explicitly
- [ ] Classification documented in the format above

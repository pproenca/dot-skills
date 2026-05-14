# Phase 1: Survey Existing Spec

**Goal:** Build a mental model of the complete Acceptance Pipeline Specification before proposing any changes.

**Why first:** Designing a feature without understanding the existing spec leads to proposals that duplicate existing capabilities, contradict established patterns, or break implicit contracts between components. The spec is tightly integrated — the JSON IR connects everything — so changes in one component ripple through others.

## Steps

### 1.1 Load the Baseline

Read the `acceptance-pipeline-catalog` skill. Focus on understanding, not memorizing. You need to internalize the architecture, not recite it.

### 1.2 Map the 9 Required Components

Confirm you can describe what each component does and what it consumes/produces:

| Component | Input | Output | Key Constraints |
|-----------|-------|--------|-----------------|
| **Parser** | `.feature` files (Gherkin subset) | JSON IR | Supported Gherkin subset is intentionally limited |
| **IR Reader/Writer** | JSON IR files | In-memory IR / JSON files | All example values are strings; the IR is the canonical interchange format |
| **Generator** | JSON IR | Language-specific test files | Generated tests call into the runtime |
| **Runtime** | Generated test calls | Step handler dispatch | Handles Given/When/Then dispatch and example injection |
| **Step Handlers** | Step text + parameters | Side effects / assertions | User-authored; matched by text pattern |
| **Runner Adapter** | Test files | Exit codes + output | Delegates to the project's test runner |
| **Mutator** | JSON IR + seed | Mutated JSON IR | 8 value mutation rules in priority order; deterministic with seed |
| **Reporter** | Mutation run results | Report output | Classification: killed, survived, skipped, errored |
| **Convenience Scripts** | CLI arguments | Pipeline orchestration | POSIX shell; compose the above components |

### 1.3 Understand the Two Operating Modes

**Normal acceptance run:**
```
feature file → parser → JSON IR → generator → test files → runner → pass/fail
```

**Mutation run:**
```
JSON IR → mutator (mutate values) → generator → test files → runner → classify each mutant
```

The mutation mode reuses the normal pipeline but inserts the mutator before generation. Any feature you design must work in both modes unless it explicitly only applies to one.

### 1.4 Understand the JSON IR

The JSON IR is the hub of the pipeline. Every component either produces it, consumes it, or both. Key properties:

- **Structure:** Feature → Scenarios → Steps + Examples
- **All example values are strings** — the mutator operates on string representations
- **The IR is the canonical interchange format** — changing it affects every component downstream
- **IR changes are the highest-impact changes** in the spec

### 1.5 Review the Conformance Checklist

The spec defines 21 testable conformance items. Each is:
- Observable from outside the implementation
- Binary (pass/fail)
- Grouped by component

Any new feature must add conformance items to remain testable. Review the existing items to understand the pattern and numbering.

### 1.6 Review the Agent Setup Checklist

The spec defines 15 steps for installing the pipeline in a new project. If your feature adds setup requirements, they must be added to this checklist.

## Checklist Before Proceeding

Before moving to Phase 2, confirm:

- [ ] You can name all 9 components and their roles
- [ ] You understand both operating modes (normal + mutation)
- [ ] You know the JSON IR structure and that all values are strings
- [ ] You have reviewed the conformance checklist numbering (currently ends at 21)
- [ ] You know which Gherkin features are intentionally unsupported (and why)
- [ ] You understand the 8 value mutation rules and their priority order

If any of these are unclear, re-read the relevant section of `acceptance-pipeline-catalog` before proceeding.

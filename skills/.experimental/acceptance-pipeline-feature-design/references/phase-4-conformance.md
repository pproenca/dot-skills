# Phase 4: Conformance Design

**Goal:** Define testable conformance items for every new capability introduced by the feature.

**Why fourth:** Conformance items are the spec's enforcement mechanism. A feature without conformance items is a suggestion, not a requirement. Writing them after the spec draft ensures they test what was actually specified, not what you intended to specify. If you cannot write a conformance item for a requirement, the requirement is too vague — go back to Phase 3 and tighten it.

## What Makes a Good Conformance Item

Each conformance item must be:

| Property | Meaning | Test |
|----------|---------|------|
| **Observable** | Can be verified from outside the implementation | Would a black-box tester be able to check this? |
| **Binary** | Pass or fail, no partial credit | Is the result unambiguous? |
| **Specific** | Tests one capability, not a combination | Could this fail for only one reason? |
| **Numbered** | Sequential from the last existing item | Currently ends at 21; start from 22 |

## Writing Pattern

Conformance items follow this grammar:

```
[Component] [verb] [what] [condition/constraint].
```

**Good examples:**
```
22. Parser accepts pipe-delimited data tables immediately following a step line.
23. Parser rejects data tables with inconsistent column counts and emits a diagnostic.
24. IR writer includes dataTable object in step output when a data table is present.
25. IR writer omits dataTable field when no data table is attached to a step.
26. Runtime passes data table contents to step handler as a structured argument.
```

**Bad examples:**
```
22. Data tables work correctly.                    — Not specific, not binary
23. The parser should handle data tables well.     — Subjective, uses "should"
24. Implementation supports data table parsing.    — "Implementation" is vague
```

## Process

### 4.1 Extract Testable Requirements

Go through each behavioral requirement from Phase 3 and ask: "How would an external tester verify this?" If the answer involves inspecting internal state, the requirement needs to be rephrased as an observable behavior.

| Requirement (Phase 3) | Conformance Item | Observable Via |
|----------------------|-----------------|----------------|
| Parser must accept data tables | Parser produces IR with dataTable field | Check JSON IR output |
| Rows must have consistent column count | Parser rejects inconsistent rows | Check parser exit code + stderr |
| Runtime passes table data to handlers | Handler receives table argument | Check handler invocation |

### 4.2 Add Negative Cases

For every positive conformance item, consider the negative:
- What input should be **rejected**? (Parser rejects X)
- What output should be **absent**? (IR omits X when Y)
- What behavior should **not change**? (Mutator ignores dataTable field)

Negative cases catch regressions. If you only test that data tables work when present, you miss bugs where data tables appear when they should not.

### 4.3 Consider Mutation Mode

If the feature affects mutation mode:
- Does the mutator interact with new IR fields? Add conformance items for mutation behavior.
- Does the feature change how mutants are classified? Add items for classification accuracy.
- Does the feature affect mutation determinism? Add items verifying deterministic output with the same seed.

### 4.4 Number and Group

- Number sequentially from 22 (the next available after the existing 21)
- Group by component for readability
- Keep the numbering continuous — do not leave gaps

**Output format:**
```markdown
## New Conformance Items

### Parser
22. Parser accepts pipe-delimited data tables immediately following a step line.
23. Parser rejects data tables with inconsistent column counts and emits a line-number diagnostic.
24. Parser strips leading and trailing whitespace from data table cell values.

### IR
25. IR writer includes dataTable object with headers and rows arrays when data table is present.
26. IR writer omits dataTable field entirely when no data table is attached to a step.

### Runtime
27. Runtime passes data table contents to step handler as a structured argument.
28. Runtime raises an error if a step handler expects a data table but none is attached.

### Mutator
29. Mutator applies value mutation rules to data table cell values.
30. Mutator preserves data table structure (headers unchanged, row count unchanged).
```

## Estimating Count

A well-specified feature typically produces 2-5 conformance items per affected component. If you have fewer than 2 per component, you may be under-specifying. If you have more than 5 per component, you may be over-specifying — consider whether some items are testing the same capability from different angles.

| Feature Scope | Expected Items |
|--------------|---------------|
| Single-component, additive | 2-4 items |
| Multi-component, additive | 5-10 items |
| Cross-cutting, modifying | 8-15 items |
| Breaking change | 10-20 items (includes migration verification) |

## Checklist Before Proceeding

- [ ] Every behavioral requirement from Phase 3 has at least one conformance item
- [ ] Negative cases included (rejection, absence, no-change)
- [ ] Mutation mode impact covered (or explicitly noted as not affected)
- [ ] Items are numbered sequentially from 22
- [ ] Items are grouped by component
- [ ] Each item is observable, binary, and specific

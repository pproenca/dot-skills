# Phase 3: Draft Feature Spec

**Goal:** Write the feature specification section in Uncle Bob's style, ready to insert into the Acceptance Pipeline Specification.

**Why third:** Writing the spec after classification ensures you know the scope and constraints. Writing before classification leads to specs that discover new requirements mid-draft, producing inconsistent or incomplete sections.

## Spec Section Structure

Every feature spec section follows this structure. Not all subsections apply to every feature — omit those that do not apply, but follow this order for those that do.

### 1. Purpose Paragraph

One paragraph explaining what problem this feature solves and why it matters. Written in present tense.

**Pattern:**
```
[Component] [verb: accepts/produces/supports] [what]. This [enables/prevents/simplifies]
[user benefit]. Without this, [what problem exists].
```

**Good example:**
> The parser accepts data tables attached to steps using pipe-delimited rows. This enables parameterized step definitions that operate on structured data without encoding everything as example values. Without data tables, complex test data must be hardcoded in step handlers or split across multiple steps.

**Bad example:**
> This feature will add data table support to the parser. Data tables are useful for testing.

The purpose paragraph is the most important sentence in the section. A reader should understand the value proposition without reading further.

### 2. Command Interface (if applicable)

For features that add or modify CLI commands:

```
USAGE
    command [options] <required-arg> [optional-arg]

OPTIONS
    --flag    Description (default: value)

EXIT CODES
    0    Success description
    1    Failure description
    2    Specific failure description
```

Use POSIX shell conventions. Document every exit code — these are part of the contract.

### 3. Behavioral Requirements

Numbered list using RFC 2119 keywords (must, should, may):

```markdown
1. The parser must accept pipe-delimited data tables immediately following a step line.
2. Each data table row must contain the same number of cells as the header row.
3. The parser must strip leading and trailing whitespace from cell values.
4. An empty data table (header only, no data rows) must be accepted without error.
5. The parser should reject data tables with inconsistent column counts with a diagnostic message.
```

**Writing rules for requirements:**
- Use present tense ("The parser accepts..." not "The parser will accept...")
- Use "must" for requirements, "should" for recommendations, "may" for options
- One requirement per numbered item — do not combine requirements
- Each requirement must be independently testable
- Include edge cases explicitly (empty inputs, boundary values, error conditions)
- Reference existing spec terminology consistently (use "JSON IR" not "intermediate representation")

### 4. Data Format (if applicable)

For features that add or change data structures:

1. Show the JSON schema with types
2. Provide a concrete example with realistic values
3. Document every field — type, whether required or optional, default value if optional
4. Show how the new structure nests within the existing IR

**Pattern:**
```json
{
  "steps": [
    {
      "keyword": "Given",
      "text": "the following users exist",
      "dataTable": {
        "headers": ["name", "email", "role"],
        "rows": [
          ["Alice", "alice@example.com", "admin"],
          ["Bob", "bob@example.com", "member"]
        ]
      }
    }
  ]
}
```

Then document:
```
dataTable (object, optional): Attached data table for this step.
  headers (array of string, required): Column names from the first pipe-delimited row.
  rows (array of array of string, required): Data rows. Each inner array has the same
    length as headers. May be empty (header-only table).
```

**Critical:** All values in the IR are strings. Even if a value looks like a number, it is stored and transmitted as a string. The mutator depends on this — it applies string-based mutation rules.

### 5. Error Handling

For each failure mode:
- What triggers it (input condition)
- What the component produces (error message, exit code)
- Whether processing continues or halts

**Pattern:**
```markdown
**Inconsistent column count:** If a data row contains fewer or more cells than the header
row, the parser must emit a diagnostic referencing the line number and expected column
count, then skip the malformed row. Parsing continues — this is a warning, not a fatal error.
```

Do not silently swallow errors. Every error condition must produce observable output.

### 6. Interaction with Existing Components

Describe how this feature changes the pipeline flow. For each affected component, state:
- What new input it receives (if any)
- What new output it produces (if any)
- What existing behavior changes (if any)
- What remains unchanged (explicitly)

This section prevents hidden coupling. If you cannot describe the interaction, the feature is under-specified.

## Style Checklist

Before finalizing the spec draft, verify it follows the style guide (see [style-guide.md](style-guide.md)):

- [ ] Language-neutral — no language-specific syntax or idioms
- [ ] Implementation-agnostic — describes what, not how
- [ ] POSIX shell for all script examples
- [ ] JSON for all data format examples
- [ ] Gherkin for all feature file examples
- [ ] Present tense throughout
- [ ] Must/should/may used consistently per RFC 2119
- [ ] Concrete examples for every data format
- [ ] Each section is self-contained (readable without the rest of the spec)
- [ ] Edge cases addressed explicitly, not left to "implementation discretion"
- [ ] Exit codes documented for any CLI-facing behavior
- [ ] No vague phrases ("appropriate error", "relevant information", "as needed")

## Common Mistakes

**Specifying implementation details:** The spec says WHAT, not HOW. "The parser must produce a dataTable object" is correct. "The parser must use a recursive descent approach to parse data tables" is implementation detail.

**Forgetting mutation mode:** Every IR change must be evaluated for mutation impact. If you add a `dataTable` field, does the mutator mutate table cell values? If yes, specify the mutation rules. If no, specify that the mutator ignores it.

**Assuming optional means ignorable:** Optional IR fields still need behavior specified for when they are absent vs present. "If `dataTable` is absent, the step has no attached data. If present, the runtime must pass table data to the step handler."

**Under-specifying string encoding:** All IR values are strings. If your feature introduces values that look like numbers or booleans, specify that they are stored as strings and any type interpretation happens at the consumer, not in the IR.

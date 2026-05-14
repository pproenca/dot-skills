# Uncle Bob's Spec Writing Style Guide

This guide extracts the writing patterns used in the Acceptance Pipeline Specification. Use it during Phase 3 to ensure your feature spec reads as a natural extension of the original.

## Document Structure Patterns

### Section Organization

The spec organizes each component with this consistent structure:

1. **Component name as heading** — e.g., "Gherkin Parser", "Mutation Engine"
2. **Purpose paragraph** — What the component does and why it exists
3. **Interface** — Commands, arguments, exit codes (where applicable)
4. **Behavioral requirements** — Numbered must/should/may statements
5. **Data formats** — JSON schemas and concrete examples
6. **Edge cases and errors** — Explicit handling for boundary conditions

Every section is self-contained. A reader should understand the section without having read the rest of the spec. Cross-references are used sparingly and only to connect related concepts, not to avoid repetition.

### Heading Hierarchy

```
# Spec Title
## Component Name
### Subsection (e.g., "Command Interface", "Data Format")
#### Sub-subsection (rare, only for complex data structures)
```

Do not go deeper than `####`. If you need more depth, the section is too complex — split it.

## Terminology Conventions

### RFC 2119 Keywords

| Keyword | Meaning | Use When |
|---------|---------|----------|
| **must** | Absolute requirement | The feature does not work without this |
| **must not** | Absolute prohibition | Doing this breaks the spec contract |
| **should** | Recommended but not required | Strong default, but implementations may deviate with reason |
| **should not** | Discouraged but not prohibited | Usually wrong, but edge cases exist |
| **may** | Optional | Implementation can include or omit this |

Use lowercase throughout. The spec does not use ALL CAPS RFC 2119 keywords.

### Pipeline Terminology

Use these terms consistently — they are established in the spec:

| Term | Use | Do Not Use |
|------|-----|------------|
| JSON IR | The intermediate representation | "IR file", "intermediate format", "JSON output" |
| feature file | A `.feature` Gherkin source file | "test file", "spec file", "Gherkin file" |
| step handler | User-authored function matching a step | "step definition", "step implementation" |
| example value | A string value in an Examples table | "parameter", "test data" |
| mutant | A single mutation of one example value | "mutation", "variant" |
| killed | A mutant detected by a failing test | "caught", "detected" |
| survived | A mutant not detected (tests still pass) | "missed", "escaped" |
| convenience script | A POSIX shell script composing pipeline tools | "wrapper script", "helper script" |

### Portable vs Project-Specific

The spec distinguishes between:
- **Portable commands** — Work anywhere (POSIX shell, standard tools)
- **Project-specific commands** — Depend on the project's test runner, language, or framework

Spec examples always use portable commands. Project-specific behavior is described abstractly: "The runner adapter invokes the project's test runner" — not "The runner adapter runs `pytest`."

## Code Block Conventions

### POSIX Shell for Scripts

All script examples use POSIX shell (`sh`), not Bash. This means:
- No `[[ ]]` — use `[ ]`
- No arrays — use positional parameters
- No `local` keyword in functions (not POSIX) — use subshells for scope
- No `source` — use `.`
- Always include `set -e` at the top

```sh
#!/bin/sh
set -e

feature_file="$1"
output_dir="$2"

if [ -z "$feature_file" ]; then
  echo "Usage: acceptance-run <feature-file> [output-dir]" >&2
  exit 1
fi
```

### JSON for Data Formats

All data format examples use JSON with realistic values — not placeholders:

**Good:**
```json
{
  "feature": "User Login",
  "scenarios": [
    {
      "name": "valid credentials",
      "steps": [
        {"keyword": "Given", "text": "a user with email <email>"}
      ],
      "examples": {
        "headers": ["email", "password"],
        "rows": [
          ["alice@example.com", "correct-password"],
          ["bob@example.com", "also-correct"]
        ]
      }
    }
  ]
}
```

**Bad:**
```json
{
  "feature": "...",
  "scenarios": [{"...": "..."}]
}
```

### Gherkin for Feature Files

Feature file examples use the supported Gherkin subset only:

```gherkin
Feature: User Login

  Scenario Outline: valid credentials
    Given a user with email <email>
    When the user logs in with password <password>
    Then the response status is <status>

    Examples:
      | email             | password         | status |
      | alice@example.com | correct-password | 200    |
      | bob@example.com   | wrong-password   | 401    |
```

## Writing Good vs Bad Spec Prose

### Present Tense

**Good:** "The parser accepts pipe-delimited data tables."
**Bad:** "The parser will accept pipe-delimited data tables."
**Bad:** "The parser should be able to accept pipe-delimited data tables."

### Specific Over Vague

**Good:** "The mutator replaces the string `true` with `false` and vice versa."
**Bad:** "The mutator handles boolean values appropriately."

**Good:** "Exit code 0 indicates all scenarios passed. Exit code 1 indicates one or more scenarios failed. Exit code 2 indicates a parser error."
**Bad:** "The script returns an appropriate exit code."

### Behavioral Over Structural

**Good:** "The parser emits a diagnostic on stderr when encountering an unsupported keyword, including the line number and the keyword found."
**Bad:** "The parser has error handling for unsupported keywords."

### Self-Contained Sections

Each section should be understandable without reading the full spec. This means:
- Define terms on first use within a section (or reference the terminology section)
- Do not rely on "as described above" — name the specific section
- Include a concrete example even if a similar one appears elsewhere

### Requirements as Observable Behaviors

**Good:** "When the feature file contains a Background section, the parser includes background steps in every scenario's step list in the JSON IR."
**Bad:** "The parser handles Background sections correctly."

The first version tells you exactly what to test. The second requires you to already know what "correctly" means.

## Exit Code Conventions

The spec uses a consistent exit code scheme:

| Code | Meaning |
|------|---------|
| 0 | Success — all operations completed as expected |
| 1 | Test failure — at least one scenario or assertion failed |
| 2 | Input error — parse error, missing file, invalid arguments |
| 3+ | Tool-specific — document each code explicitly |

New features should reuse these codes where they apply and allocate new codes only for genuinely new failure modes. Document new exit codes in the command interface section.

## Field Requirement Documentation

When documenting JSON fields, use this format:

```
fieldName (type, required|optional [, default: value]): Description.
  Constraints or notes on a new indented line.
```

Example:
```
dataTable (object, optional): Attached data table for this step.
  headers (array of string, required): Column names from the header row.
    Must contain at least one element.
  rows (array of array of string, required): Data rows, each with length equal to headers.
    May be empty (header-only table is valid).
```

This format is scannable, consistent, and makes it easy to verify that every field is documented with type, optionality, and constraints.

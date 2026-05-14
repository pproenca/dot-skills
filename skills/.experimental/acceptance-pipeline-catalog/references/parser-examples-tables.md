---
title: Parse Pipe-Delimited Examples Tables
impact: CRITICAL
impactDescription: malformed table parsing produces wrong example data for every scenario execution, corrupting all downstream mutation and test results
tags: parser, examples, tables, pipe-delimited, header
---

## Parse Pipe-Delimited Examples Tables

Examples tables provide the concrete data that parameterized scenarios run against. Each row becomes one scenario execution, and each cell becomes a value the runtime substitutes into step text. Correct table parsing is critical because every downstream tool — runtime, generator, mutator — depends on these values.

### Spec Requirements

An examples section starts with:

```gherkin
Examples:
```

It must appear inside a scenario.

Rows are pipe-delimited:

```gherkin
| name | count |
| one  | 1     |
| two  | 2     |
```

### Parsing Rules

1. A row is recognized only when the trimmed line starts with `|`.
2. Leading and trailing `|` characters are removed.
3. The remaining text is split on `|`.
4. Each cell is trimmed.
5. The first row after `Examples:` is the **header row**.
6. Every data row must have the **same number of cells** as the header row (mismatch = error, exit code 1).
7. Header names become JSON object keys.
8. **All cell values are stored as strings** — even numbers, booleans, and other types.

### Why All Values Are Strings

Storing everything as strings is a deliberate portability choice. The parser does not know the target language's type system. A value like `42` might be an integer, a string, or a port number — that decision belongs to the step handler, not the parser. String storage means no information is lost and no premature type coercion occurs.

This also simplifies the mutator: it applies string-based mutation rules (integer detection, boolean detection, etc.) to values that are always strings, without needing to handle mixed types.

### Why Cell Count Must Match

A row with fewer or more cells than the header indicates either a formatting error or missing data. Rather than silently padding with empty strings or truncating, the parser rejects the mismatch. This catches feature file errors early, before they propagate as mysterious runtime failures.

### Examples

**Incorrect (cell count mismatch silently padded with empty string):**

```gherkin
Examples:
  | name | count |
  | one  |
```

```json
[{ "name": "one", "count": "" }]
```

**Correct (cell count mismatch rejected with exit code 1):**

```text
Parse error: row 2 has 1 cell(s), expected 2 (matching header row)
Exit code: 1
```

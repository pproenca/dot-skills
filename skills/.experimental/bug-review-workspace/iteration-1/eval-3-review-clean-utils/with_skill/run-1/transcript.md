# Bug Review Transcript: clean-utils.ts

## Task Understanding

Review `evals/fixtures/clean-utils.ts` for bugs using the bug-review skill's multi-pass workflow. The file contains 5 utility functions: `formatCurrency`, `safeJsonParse`, `debounce`, `chunk`, and `retry`. Since this is a simulated eval (no real GitHub PR), the workflow was adapted: file read directly, 3 review passes simulated sequentially with distinct focus areas, then aggregation/voting/validation performed per the skill spec.

## Steps Taken

### Step 1: Setup & Context Gathering

1. Read `SKILL.md` to understand the bug-review workflow
2. Read `references/review-passes.md` for exact pass prompts and focus areas
3. Read `references/categories.md` for bug category definitions and severity weights
4. Read `config.json` for configuration (3 passes, vote threshold 2)
5. Read the fixture file `clean-utils.ts` (77 lines, 5 functions)
6. No `.bug-review.md` repo rules file exists (not applicable for eval)

**Tools used**: Read (6 calls)

### Step 2: Three Parallel Review Passes (Simulated Sequentially)

#### Pass 1: Logic & Edge Cases

Focus: logic errors, boundary conditions, off-by-one, null/undefined, missing edge cases.

**Method**: Traced each function's logic paths, tested edge case inputs mentally (NaN, Infinity, negative numbers, empty inputs, null).

Findings:
- **F1a** (`chunk`, lines 43-53, boundary): `NaN` size bypasses `size < 1` guard because `NaN < 1` is false in JS. Loop index becomes NaN, loop never executes, returns `[]` for non-empty arrays. Silent data loss.
- **F1b** (`retry`, lines 55-77, boundary): Negative `maxRetries` means loop never runs. `lastError` stays `undefined`. `throw undefined` at line 76.
- **F1c** (`safeJsonParse`, lines 10-16, api-contract): `as T` cast provides no runtime validation. More importantly, `JSON.parse("null")` returns `null` and parse failure also returns `null` -- ambiguous.

#### Pass 2: Security & Data Integrity

Focus: injection, data corruption, resource exhaustion, sensitive data exposure.

**Method**: Traced data flows from inputs to outputs, checked for attacker-controlled input reaching sinks, looked for data integrity gaps.

Findings:
- **F2a** (`chunk`, lines 43-53, data-loss): NaN size silently drops all array elements. Data integrity violation.
- **F2b** (`safeJsonParse`, lines 10-16, data-loss): No runtime type validation means callers may act on data with wrong shape.

No security vulnerabilities found -- these are pure utility functions with no injection surfaces, auth concerns, or external system interactions.

#### Pass 3: Error Handling & API Contracts

Focus: error swallowing, resource leaks, API contract violations, race conditions, async patterns.

**Method**: Checked every error path, catch block, and return type contract. Examined async patterns in retry and timer patterns in debounce.

Findings:
- **F3a** (`safeJsonParse`, lines 10-16, error-swallow/api-contract): catch returns `null` -- ambiguous with valid JSON null. Error is completely discarded.
- **F3b** (`retry`, lines 55-77, error-swallow): Negative maxRetries leads to `throw undefined`. Broken error contract.
- **F3c** (`chunk`, lines 43-53, data-loss): NaN size causes silent empty return.

### Step 3: Aggregate & Vote

Grouped 8 raw findings into 3 unique issues by file + line proximity + category overlap:

| # | Finding | Lines | Votes | Passes |
|---|---------|-------|-------|--------|
| 1 | chunk NaN bypass | 43-53 | 3/3 | Pass 1, 2, 3 |
| 2 | safeJsonParse null ambiguity | 10-16 | 3/3 | Pass 1, 2, 3 |
| 3 | retry throw undefined | 55-77 | 2/3 | Pass 1, 3 |

All findings meet the vote threshold of 2+.

Ranked by `votes * severity_weight`:
1. chunk NaN bypass: 3 * 4 (CRITICAL) = 12
2. safeJsonParse null ambiguity: 3 * 2 (MEDIUM) = 6
3. retry throw undefined: 2 * 2 (MEDIUM) = 4

### Step 4: Validate Findings

Each finding was validated against 4 tests:

**Finding 1: chunk NaN bypass**
- Trigger test: PASS -- `chunk([1,2,3], NaN)` is callable, NaN is a valid JS number
- Evidence test: PASS -- `NaN < 1` is false (line 44), `i += NaN` makes i=NaN (line 49), `NaN < 3` is false (loop exits)
- Existing coverage: PASS -- TypeScript accepts NaN as `number`, no linter catches this
- Rules test: N/A (no .bug-review.md)
- **VALIDATED**

**Finding 2: safeJsonParse null ambiguity**
- Trigger test: PASS -- `safeJsonParse("null")` returns null, `safeJsonParse("{bad")` returns null
- Evidence test: PASS -- JSON.parse("null") === null per JSON spec, catch returns null on line 14
- Existing coverage: PASS -- TypeScript return type `T | null` does not distinguish the two cases
- Rules test: N/A
- **VALIDATED**

**Finding 3: retry throw undefined**
- Trigger test: PASS -- `retry(fn, { maxRetries: -1 })` is callable
- Evidence test: PASS -- Loop condition `0 <= -1` false, lastError stays undefined, line 76 throws it
- Existing coverage: PASS -- TypeScript does not enforce non-negative number constraints
- Rules test: N/A
- **VALIDATED**

### Step 5: Dedup

No prior reviews exist (first eval run). All findings retained.

## Final Validated Findings

| # | Severity | File | Line | Title | Votes |
|---|----------|------|------|-------|-------|
| 1 | CRITICAL | clean-utils.ts | 44 | chunk() size guard does not catch NaN, causing silent data loss | 3/3 |
| 2 | MEDIUM | clean-utils.ts | 10 | safeJsonParse() cannot distinguish valid JSON null from parse failure | 3/3 |
| 3 | MEDIUM | clean-utils.ts | 60 | retry() throws undefined when maxRetries is negative | 2/3 |

### Functions with no bugs found

- **formatCurrency**: Clean. Correctly delegates to Intl.NumberFormat. Edge cases (NaN, Infinity) produce readable strings which is acceptable behavior.
- **debounce**: Clean. Timer management is correct. Closure captures are immutable parameters. cancel() properly clears timeout and resets state.

## Output Files

- `findings.json`: Full structured findings with metadata, trigger scenarios, and suggested fixes
- `transcript.md`: This file

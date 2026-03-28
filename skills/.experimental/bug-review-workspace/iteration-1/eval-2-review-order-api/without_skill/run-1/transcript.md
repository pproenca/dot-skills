# Bug Review Transcript - Order API (Baseline, No Skill)

## Task Understanding

I was asked to perform a bug review of an Express REST API for orders located at `evals/fixtures/api-orders.ts`. The goal was to identify bugs, security vulnerabilities, logic errors, and other issues, then output structured findings as JSON. This is a baseline evaluation run (no skill loaded).

## Steps Taken

### Step 1: Read the fixture file
- **Tool used**: Read
- **Why**: To get the full source code of the API for review.
- **Result**: Successfully read all 81 lines of `api-orders.ts`. The file contains an Express router with four endpoints: POST /orders, GET /orders, GET /orders/:id, and DELETE /orders/:id.

### Step 2: Verify output directory exists
- **Tool used**: Bash (ls)
- **Why**: To confirm the output directory structure was in place before writing results.
- **Result**: The `outputs` subdirectory existed.

### Step 3: Create output directory
- **Tool used**: Bash (mkdir -p)
- **Why**: To ensure the full output path existed.

### Step 4: Systematic code review
- **Approach**: Reviewed each endpoint line-by-line, checking for:
  - Security vulnerabilities (SQL injection, authorization, input validation)
  - Logic errors (off-by-one, missing data operations)
  - Error handling (unhandled promises, missing try/catch, resource leaks)
  - Data integrity issues (client-trusted prices, missing item inserts)
  - API design issues (missing validation, unbounded queries)

### Step 5: Write findings
- **Tool used**: Write
- **Output**: `findings.json` with 14 findings across severity levels (critical, high, medium, low).

## Issues Encountered

None. The file was straightforward to read and review.

## Summary of Findings

| Severity | Count | Key Issues |
|----------|-------|------------|
| Critical | 1     | SQL injection in INSERT statement |
| High     | 3     | Client-trusted prices, undefined email field, connection pool leak |
| Medium   | 8     | Off-by-one pagination, missing error handling (x3), no auth on DELETE, missing input validation (x2), order items never inserted |
| Low      | 1     | No upper bound on pagination limit |

### Findings by Category
- **Security**: 4 (SQL injection, client prices, no auth, unbounded limit)
- **Logic**: 4 (undefined email, fire-and-forget email, pagination offset, missing order_items inserts)
- **Error handling**: 4 (no try/catch on 3 endpoints, connection pool leak)
- **Validation**: 2 (missing field validation, missing item validation)

## Output Produced

- **Findings**: `/Users/pedroproenca/Documents/Projects/dot-skills/skills/.experimental/bug-review-workspace/iteration-1/eval-2-review-order-api/without_skill/run-1/outputs/findings.json`
- **Transcript**: This file.

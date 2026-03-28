# Eval 3 - Review clean-utils.ts (without skill, run 1)

## Task Understanding

Review the file `evals/fixtures/clean-utils.ts` for bugs. The file contains five utility functions: `formatCurrency`, `safeJsonParse`, `debounce`, `chunk`, and `retry`. Produce a thorough bug review and save findings as JSON.

## Steps Taken

### Step 1: Read the fixture file

Used the Read tool to load the full contents of `clean-utils.ts` (78 lines, 5 exported functions).

### Step 2: Analyze each function

Reviewed each function individually for correctness, edge cases, type safety, and potential runtime issues.

**formatCurrency (lines 1-8)**
- Uses `Intl.NumberFormat` with currency style and fixed 2 decimal places.
- Considered edge cases: NaN, Infinity, negative numbers. `Intl.NumberFormat.format()` handles these gracefully (produces string representations), so no bugs here.
- Clean implementation, no issues found.

**safeJsonParse (lines 10-16)**
- Wraps `JSON.parse` in try/catch, returns null on failure.
- Identified a type-safety concern: the `as T` cast is unchecked. The function promises type T but performs no runtime validation. This gives callers a false sense of safety.
- Classified as low severity since it is a design/type-safety issue, not a runtime crash bug.

**debounce (lines 18-41)**
- Returns an object with `call` and `cancel` methods.
- Properly clears previous timeout before setting a new one.
- Sets `timeoutId` to null after the function executes.
- `cancel` properly clears and nullifies the timeout.
- No bugs found.

**chunk (lines 43-53)**
- Validates `size < 1` but does NOT validate non-integer sizes.
- Traced through the behavior with `size = 1.5`: the fractional loop increment `i += 1.5` produces indices `0, 1.5, 3, 4.5, ...`. Since `Array.prototype.slice` floors its arguments, this causes overlapping chunks.
- Verified the overlap: `slice(0, 1.5)` -> `slice(0,1)` = `[1]`, then `slice(1.5, 3)` -> `slice(1,3)` = `[2,3]` -- element at index 1 was already in the first chunk conceptually but is included in the second.
- Classified as medium severity -- produces incorrect output silently.

**retry (lines 55-77)**
- Exponential backoff with `baseDelay * 2^attempt`.
- Loop runs from attempt 0 to maxRetries inclusive, giving maxRetries+1 total attempts (1 initial + maxRetries retries). This matches the semantics of the parameter name.
- Delay is only applied when `attempt < maxRetries`, avoiding a needless sleep after the final failure.
- `lastError` is properly constructed and re-thrown.
- No bugs found.

### Step 3: Write findings

Saved 2 findings to `findings.json`:
1. Medium: `chunk()` non-integer size validation gap
2. Low: `safeJsonParse()` unchecked type cast

## Tools Used

- **Read**: To load the fixture file contents
- **Bash**: To check/create output directories
- **Write**: To save findings.json and this transcript

## Issues Encountered

None. The file was straightforward to read and analyze.

## Output Produced

- `findings.json`: 2 findings (1 medium, 1 low)
- `transcript.md`: This file

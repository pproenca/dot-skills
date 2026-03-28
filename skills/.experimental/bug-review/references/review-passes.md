# Review Pass Prompts

This file contains prompts for the 5 parallel review passes and the independent validator. Each pass receives the same PR context but with **shuffled diff ordering** (via `scripts/shuffle-diff.sh`) and different focus areas to maximize attention diversity.

## Common Context (All Passes)

All passes receive:
- PR diff with file changes (**shuffled per pass** — different file ordering creates different attention patterns)
- Extended context from `scripts/gather-context.sh` (callers, types, tests)
- Bug category definitions (from categories.md)
- Repo-specific rules (from .bug-review.md, if exists)
- Category weights from config.json (categories with low resolution rates are deprioritized)

All passes must output a **JSON array** of findings. Each finding:
```json
{
  "file": "src/auth.ts",
  "line": 42,
  "endLine": 45,
  "severity": "CRITICAL",
  "category": "null-access",
  "title": "Unchecked null return from getUserSession()",
  "description": "getUserSession() returns null when session expired, but line 42 accesses .userId without checking. This crashes for any user with an expired session.",
  "triggerScenario": "User with expired session token calls /api/profile -> getUserSession returns null -> TypeError: Cannot read property 'userId' of null",
  "suggestedFix": "Add null check: if (!session) return res.status(401)"
}
```

If no bugs found, output `[]`.

---

## Pass 1: Logic & Edge Cases

**Focus**: Logic errors, boundary conditions, off-by-one errors, null/undefined handling, incorrect boolean logic, missing edge cases.

**Diff ordering**: Shuffled with seed 1 via `scripts/shuffle-diff.sh 1`.

**Prompt**:

```
You are a code reviewer focused on logic errors and edge cases.

Review this PR diff and surrounding context. Find bugs that would cause incorrect behavior at runtime.

Focus areas:
- Null/undefined access without guards
- Off-by-one errors in loops, slices, or ranges
- Boolean logic errors (wrong operator, inverted condition, missing case)
- Missing edge cases (empty arrays, zero values, negative numbers, NaN, unicode, concurrent access)
- Incorrect state transitions
- Return value mishandling (ignoring errors, wrong type assumptions)

Rules:
- Only report bugs introduced or exposed by THIS PR's changes
- You MUST provide a concrete trigger scenario for every finding
- If you cannot construct a plausible trigger, do NOT report it
- Do not report style issues, documentation gaps, or TODOs
- Do not report issues the compiler/type checker would catch
- Check surrounding code before reporting — the "bug" may be handled elsewhere
- Review unchanged code only when needed to understand if a change creates a bug

Output: JSON array of findings. Empty array [] if no bugs found.
```

---

## Pass 2: Security & Data Integrity

**Focus**: Security vulnerabilities, data integrity issues, authentication/authorization bypasses, injection attacks, data corruption.

**Diff ordering**: Shuffled with seed 2 via `scripts/shuffle-diff.sh 2`.

**Prompt**:

```
You are a security-focused code reviewer finding vulnerabilities and data integrity bugs.

Review this PR diff and surrounding context. Find security issues and data corruption bugs.

Focus areas:
- Injection attacks (SQL injection, XSS, command injection, path traversal)
- Authentication/authorization bypasses (missing checks, wrong order of operations)
- Data corruption (race conditions on shared state, missing transactions, partial writes)
- Sensitive data exposure (logging secrets, leaking PII, insecure storage)
- Resource exhaustion (unbounded allocations, missing rate limits, ReDoS)
- Cryptographic misuse (weak algorithms, hardcoded keys, improper randomness)

Rules:
- Only report vulnerabilities introduced or exposed by THIS PR's changes
- Trace attacker-controlled input to the actual sink — do not guess
- Verify existing controls don't already block the attack path
- You MUST provide a concrete trigger/attack scenario for every finding
- If you cannot construct a plausible attack, do NOT report it
- Do not report theoretical risks without code evidence
- Do not report issues already caught by security linters (if configured)

Output: JSON array of findings. Empty array [] if no bugs found.
```

---

## Pass 3: Error Handling & API Contracts

**Focus**: Error handling gaps, API contract violations, resource leaks, type mismatches.

**Diff ordering**: Shuffled with seed 3 via `scripts/shuffle-diff.sh 3`.

**Prompt**:

```
You are a code reviewer focused on error handling, API contracts, and resource management.

Review this PR diff and surrounding context. Find bugs related to error handling gaps, API misuse, and resource leaks.

Focus areas:
- Swallowed exceptions (catch blocks that ignore errors)
- Missing error propagation (async errors not awaited, callbacks without error params)
- Resource leaks (unclosed file handles, database connections, event listeners, timers)
- API contract violations (wrong argument types, missing required fields, incorrect return types)
- Incorrect async patterns (missing await, unhandled promise rejections)
- Stale closures or references (capturing mutable state in callbacks/effects)

Rules:
- Only report bugs introduced or exposed by THIS PR's changes
- You MUST provide a concrete trigger scenario for every finding
- If you cannot construct a plausible trigger, do NOT report it
- Check if error handling exists elsewhere (middleware, higher-level catch, framework guarantees)
- Do not report defensive programming suggestions — only actual bugs
- Do not report style issues or missing type annotations

Output: JSON array of findings. Empty array [] if no bugs found.
```

---

## Pass 4: Concurrency & State

**Focus**: Shared state mutations, async ordering problems, event loop blocking, deadlocks, cache invalidation.

**Diff ordering**: Shuffled with seed 4 via `scripts/shuffle-diff.sh 4`.

**Prompt**:

```
You are a code reviewer specialized in concurrency bugs and state management.

Review this PR diff and surrounding context. Find bugs where concurrent or asynchronous operations interact incorrectly with shared state.

Focus areas:
- TOCTOU (time-of-check to time-of-use) where state changes between check and action
- Non-atomic read-modify-write sequences on shared data (balances, counters, flags)
- Event loop blocking (synchronous I/O, CPU-heavy computation on main thread)
- Deadlocks and lock ordering violations
- Cache invalidation bugs (stale data served after mutation, missing cache busting)
- Promise/async ordering assumptions that break under load (parallel requests, retries)
- Shared mutable state across request handlers without isolation

Rules:
- Only report bugs introduced or exposed by THIS PR's changes
- You MUST describe the specific interleaving or ordering that triggers the bug
- If you cannot construct a concrete race/ordering scenario, do NOT report it
- Check if atomic operations, transactions, or locks are already in place
- Do not report theoretical concurrency issues in single-threaded code

Output: JSON array of findings. Empty array [] if no bugs found.
```

---

## Pass 5: Data Flow & Contracts

**Focus**: Data transformation correctness, type narrowing gaps, serialization fidelity, implicit contract violations.

**Diff ordering**: Shuffled with seed 5 via `scripts/shuffle-diff.sh 5`.

**Prompt**:

```
You are a code reviewer focused on data flow correctness and implicit contracts.

Review this PR diff and surrounding context. Find bugs where data is transformed, serialized, or passed across boundaries incorrectly.

Focus areas:
- Type narrowing gaps (value asserted as type X but can actually be type Y at runtime)
- Serialization round-trip bugs (data lost or corrupted through JSON.parse/stringify, URL encoding, base64)
- Implicit contract violations (function returns different shape than callers expect, optional fields treated as required)
- Numeric precision loss (floating point in currency, integer overflow, string-to-number coercion)
- Encoding mismatches (UTF-8 vs ASCII, URL encoding, HTML entities)
- Schema drift (API response shape changed but consumers not updated)
- Partial object updates that leave state inconsistent

Rules:
- Only report bugs introduced or exposed by THIS PR's changes
- You MUST show the specific data path where information is lost or corrupted
- If you cannot trace the data flow to a concrete failure, do NOT report it
- Check if validation or type guards exist at the boundary
- Do not report type annotation gaps that TypeScript would catch

Output: JSON array of findings. Empty array [] if no bugs found.
```

---

## Validator (Independent — Runs After Voting)

The validator is a **separate agent** using a **different model** (Opus by default) from the review passes (Sonnet by default). This prevents "grading your own homework" — the validator has not seen the code review before and evaluates each finding from scratch.

**Trigger**: Runs after Step 3 (Aggregate & Vote), receives only the findings that survived majority voting.

**Model**: `config.json → validator_model` (default: "opus")

**Prompt**:

```
You are a precision-focused validator. Your job is to REDUCE FALSE POSITIVES.

You are reviewing findings from a multi-pass code review. Each finding was identified by multiple independent reviewers and passed majority voting. Your job is to verify each finding is a real bug, not a false alarm.

For each finding, read the code at the specified location and determine:

KEEP if ALL of these are true:
1. The trigger scenario describes a reachable code path — trace from a real entry point (HTTP handler, event listener, public function) to the bug
2. The code at the specified lines actually exhibits the described issue — not a misread or misunderstanding
3. No existing mechanism already handles this (middleware, framework guarantees, parent try-catch, type system)
4. This is a real correctness/security bug, not a style preference, missing optimization, or defensive programming suggestion
5. The compiler, linter, or type checker would NOT already catch this

DISCARD if ANY of these are true:
1. The trigger scenario requires preconditions that are impossible or extremely unlikely in production
2. The code has been misread — the described issue is not present when you re-read the actual lines
3. An existing safeguard handles this case (check the full call chain, not just the immediate function)
4. It is a style/readability concern, not a bug
5. Static analysis would catch it before runtime

For EACH finding, output:
{
  "id": "<finding ID>",
  "verdict": "KEEP" or "DISCARD",
  "confidence": 0.0 to 1.0,
  "reasoning": "One sentence explaining why"
}

Output: JSON array of verdicts. Err on the side of DISCARD — false positives destroy trust faster than missed bugs.
```

---

## How Passes Are Launched

The main agent launches all 5 passes as **parallel Agent subprocesses**, each with a shuffled diff:

```
# Prepare shuffled diffs (one per pass)
for seed in 1 2 3 4 5:
  scripts/shuffle-diff.sh $seed < pr.diff > pass-$seed.diff

# Launch passes in parallel
Agent(prompt=pass1_prompt + pass-1.diff + context, model=config.agent_model)
Agent(prompt=pass2_prompt + pass-2.diff + context, model=config.agent_model)
Agent(prompt=pass3_prompt + pass-3.diff + context, model=config.agent_model)
Agent(prompt=pass4_prompt + pass-4.diff + context, model=config.agent_model)
Agent(prompt=pass5_prompt + pass-5.diff + context, model=config.agent_model)

# After voting aggregation, launch validator
Agent(prompt=validator_prompt + voted_findings + code, model=config.validator_model)
```

Each review pass agent has access to Read, Grep, and Glob tools to pull additional context as needed (dynamic context discovery). The validator also has these tools to verify code at finding locations.

None of these agents have Edit, Write, or Bash access — they are read-only.

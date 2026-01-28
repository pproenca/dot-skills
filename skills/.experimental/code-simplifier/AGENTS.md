<!-- Version: 0.1.0 | Organization: Community | Date: January 2026 -->
<!-- NOTE: This is a compiled document. Edit source files in references/ directory. -->

# Code Simplification Best Practices

> **Note:** This document is designed for AI agents and LLMs. It provides structured, actionable guidelines for code simplification that can be applied programmatically during code generation and refactoring tasks.

## Abstract

Comprehensive code simplification guide for AI agents and LLMs. Contains 45 rules across 8 categories, prioritized by impact from critical (context discovery, behavior preservation) to incremental (language idioms). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

## Table of Contents

1. [Context Discovery (CRITICAL)](#1-context-discovery-critical)
   1. [Always Read CLAUDE.md Before Simplifying](#11-always-read-claudemd-before-simplifying)
   2. [Check for Linting and Formatting Configs](#12-check-for-linting-and-formatting-configs)
   3. [Match Existing Code Style in File and Project](#13-match-existing-code-style-in-file-and-project)
   4. [Project Conventions Override Generic Best Practices](#14-project-conventions-override-generic-best-practices)
   5. [Identify Recently Modified Code as Default Scope](#15-identify-recently-modified-code-as-default-scope)
2. [Behavior Preservation (CRITICAL)](#2-behavior-preservation-critical)
   1. [Preserve All Return Values and Outputs](#21-preserve-all-return-values-and-outputs)
   2. [Preserve Error Messages, Types, and Handling](#22-preserve-error-messages-types-and-handling)
   3. [Preserve Public Function Signatures and Types](#23-preserve-public-function-signatures-and-types)
   4. [Preserve Side Effects (Logging, I/O, State Changes)](#24-preserve-side-effects-logging-io-state-changes)
   5. [Forbid Subtle Semantic Changes](#25-forbid-subtle-semantic-changes)
   6. [Verify Behavior Preservation Before Finalizing Changes](#26-verify-behavior-preservation-before-finalizing-changes)
3. [Scope Management (HIGH)](#3-scope-management-high)
   1. [Focus on Recently Modified Code Only](#31-focus-on-recently-modified-code-only)
   2. [Keep Changes Small and Reviewable](#32-keep-changes-small-and-reviewable)
   3. [No Unrelated Refactors](#33-no-unrelated-refactors)
   4. [Avoid Global Rewrites and Architectural Changes](#34-avoid-global-rewrites-and-architectural-changes)
   5. [Respect Module and Component Boundaries](#35-respect-module-and-component-boundaries)
4. [Control Flow Simplification (HIGH)](#4-control-flow-simplification-high)
   1. [Use Early Returns to Reduce Nesting](#41-use-early-returns-to-reduce-nesting)
   2. [Use Guard Clauses for Preconditions](#42-use-guard-clauses-for-preconditions)
   3. [Never Use Nested Ternary Operators](#43-never-use-nested-ternary-operators)
   4. [Prefer Explicit Control Flow Over Dense Expressions](#44-prefer-explicit-control-flow-over-dense-expressions)
   5. [Flatten Deep Nesting to Maximum 2-3 Levels](#45-flatten-deep-nesting-to-maximum-2-3-levels)
   6. [Each Code Block Should Do One Thing](#46-each-code-block-should-do-one-thing)
   7. [Prefer Positive Conditions Over Double Negatives](#47-prefer-positive-conditions-over-double-negatives)
5. [Naming and Clarity (MEDIUM-HIGH)](#5-naming-and-clarity-medium-high)
   1. [Use Intention-Revealing Names](#51-use-intention-revealing-names)
   2. [Use Nouns for Data, Verbs for Actions](#52-use-nouns-for-data-verbs-for-actions)
   3. [Avoid Cryptic Abbreviations](#53-avoid-cryptic-abbreviations)
   4. [Use Consistent Vocabulary Throughout](#54-use-consistent-vocabulary-throughout)
   5. [Avoid Generic Names](#55-avoid-generic-names)
6. [Duplication Reduction (MEDIUM)](#6-duplication-reduction-medium)
   1. [Apply the Rule of Three](#61-apply-the-rule-of-three)
   2. [Avoid Single-Use Helper Functions](#62-avoid-single-use-helper-functions)
   3. [Extract Only When It Improves Clarity](#63-extract-only-when-it-improves-clarity)
   4. [Prefer Duplication Over Premature Abstraction](#64-prefer-duplication-over-premature-abstraction)
   5. [Use Data-Driven Patterns Over Repetitive Conditionals](#65-use-data-driven-patterns-over-repetitive-conditionals)
7. [Dead Code Elimination (MEDIUM)](#7-dead-code-elimination-medium)
   1. [Delete Unused Code Artifacts](#71-delete-unused-code-artifacts)
   2. [Delete Code, Never Comment It Out](#72-delete-code-never-comment-it-out)
   3. [Remove Comments That State the Obvious](#73-remove-comments-that-state-the-obvious)
   4. [Remove Stale TODO/FIXME Comments](#74-remove-stale-todofixme-comments)
   5. [Keep Comments That Explain Why, Not What](#75-keep-comments-that-explain-why-not-what)
8. [Language Idioms (LOW-MEDIUM)](#8-language-idioms-low-medium)
   1. [Use Strict Types Over any (TypeScript)](#81-use-strict-types-over-any-typescript)
   2. [Use const Assertions and readonly for Immutability (TypeScript)](#82-use-const-assertions-and-readonly-for-immutability-typescript)
   3. [Use ? for Error Propagation (Rust)](#83-use--for-error-propagation-rust)
   4. [Use Iterator Chains When Clearer Than Loops (Rust)](#84-use-iterator-chains-when-clearer-than-loops-rust)
   5. [Use Comprehensions for Simple Transforms (Python)](#85-use-comprehensions-for-simple-transforms-python)
   6. [Handle Errors Immediately After the Call (Go)](#86-handle-errors-immediately-after-the-call-go)
   7. [Prefer Language and Standard Library Builtins](#87-prefer-language-and-standard-library-builtins)

---

## 1. Context Discovery (CRITICAL)

Before making any changes, understand project conventions by reading CLAUDE.md, linting configs, and existing patterns. Project standards override generic guidance.

### 1.1 Always Read CLAUDE.md Before Simplifying

Project-specific instructions in CLAUDE.md define how code should be written, tested, and structured. Ignoring these instructions leads to simplifications that violate project standards, causing rework and rejected changes. Reading CLAUDE.md first ensures your simplifications align with the team's established practices.

**Incorrect (simplifying without reading project instructions):**

```typescript
// Developer simplifies by removing "unnecessary" error handling
// Not knowing CLAUDE.md requires explicit error boundaries
function fetchUser(id: string) {
  return api.get(`/users/${id}`);
}
```

**Correct (reading CLAUDE.md first, respecting error handling requirement):**

```typescript
// CLAUDE.md specifies: "All API calls must have explicit error handling"
function fetchUser(id: string) {
  try {
    return api.get(`/users/${id}`);
  } catch (error) {
    throw new UserFetchError(id, error);
  }
}
```

**When NOT to use:**

- When CLAUDE.md does not exist in the project
- For exploratory analysis where no changes will be made

**Benefits:**

- Simplifications are accepted on first review
- Maintains consistency with team expectations
- Avoids introducing patterns the team has explicitly rejected

**References:**

- Check `.claude/CLAUDE.md`, `CLAUDE.md`, and parent directory CLAUDE.md files
- Look for `AGENTS.md` or similar instruction files

### 1.2 Check for Linting and Formatting Configs

Linting and formatting tools enforce project-wide code standards automatically. Simplifications that ignore these configs will fail CI checks or introduce inconsistent formatting. Always detect and respect ESLint, Prettier, rustfmt, Biome, and similar tool configurations before making changes.

**Incorrect (ignoring project's Prettier config):**

```javascript
// Simplified code uses single quotes, but project's .prettierrc specifies double quotes
const message = 'Hello, world';
const items = ['one', 'two', 'three'];

function greet(name) {
  return 'Hello, ' + name;
}
```

**Correct (matching project's Prettier config with double quotes):**

```javascript
// .prettierrc: { "singleQuote": false }
const message = "Hello, world";
const items = ["one", "two", "three"];

function greet(name) {
  return "Hello, " + name;
}
```

**Config files to check:**

- JavaScript/TypeScript: `.eslintrc.*`, `.prettierrc.*`, `biome.json`, `.editorconfig`
- Rust: `rustfmt.toml`, `.rustfmt.toml`
- Python: `pyproject.toml`, `.flake8`, `.black`, `ruff.toml`
- Go: `.golangci.yml`

**Benefits:**

- CI passes on first push
- Code matches existing project formatting
- No manual reformatting required after review

**References:**

- Run `npm run lint` or equivalent before committing
- Use editor integrations to auto-format on save

### 1.3 Match Existing Code Style in File and Project

Every codebase develops its own idioms and patterns over time. Simplifications that introduce foreign patterns, even if technically better, create jarring inconsistencies. Before simplifying, study the surrounding code to understand naming conventions, error handling approaches, and structural patterns already in use.

**Incorrect (introducing arrow functions in a file using function declarations):**

```javascript
// Existing file uses function declarations throughout
function validateEmail(email) {
  return email.includes("@");
}

function validatePhone(phone) {
  return phone.length === 10;
}

// New simplified code introduces arrow functions
const validateName = (name) => name.length > 0;

const validateAge = (age) => age >= 0 && age <= 150;
```

**Correct (matching existing function declaration pattern):**

```javascript
// Existing file uses function declarations throughout
function validateEmail(email) {
  return email.includes("@");
}

function validatePhone(phone) {
  return phone.length === 10;
}

// Simplified code follows existing pattern
function validateName(name) {
  return name.length > 0;
}

function validateAge(age) {
  return age >= 0 && age <= 150;
}
```

**Patterns to observe:**

- Function declaration style (arrow vs function keyword)
- Naming conventions (camelCase, snake_case, prefixes)
- Import organization and grouping
- Error handling approach (try/catch, Result types, error callbacks)
- Comment style and documentation format

**When NOT to use:**

- When explicitly refactoring to modernize the entire file
- When existing patterns are acknowledged anti-patterns by the team

**Benefits:**

- Code reads as if written by one author
- Easier to maintain and understand
- Reduces cognitive load during code review

### 1.4 Project Conventions Override Generic Best Practices

Generic best practices are starting points, not absolute rules. Teams adopt specific conventions for good reasons: domain requirements, performance constraints, team preferences, or historical decisions. When project conventions conflict with generic guidance, always follow the project's established approach.

**Incorrect (applying generic "early return" pattern against project convention):**

```python
# Project convention: use guard clauses with explicit else blocks for clarity
# Developer applies generic "early return" simplification

def process_order(order):
    if not order.is_valid():
        return None
    if not order.has_items():
        return None
    if order.is_cancelled():
        return None

    return calculate_total(order)
```

**Correct (following project's explicit else block convention):**

```python
# Project convention documented: "Use explicit if-else for business logic clarity"
# This team values explicitness over brevity for audit trails

def process_order(order):
    if not order.is_valid():
        return None
    else:
        if not order.has_items():
            return None
        else:
            if order.is_cancelled():
                return None
            else:
                return calculate_total(order)
```

**Common conflicts:**

- Early returns vs explicit else blocks
- Inline conditionals vs extracted functions
- ORM usage vs raw SQL (some teams mandate one)
- Dependency injection style
- Test naming conventions

**When to propose changes to conventions:**

- Open a discussion with the team first
- Document the reasoning for the change
- Apply consistently across the codebase, not piecemeal

**Benefits:**

- Respects team decisions and domain knowledge
- Avoids religious debates about style
- Simplifications are accepted without friction

**References:**

- Check team wikis, ADRs (Architecture Decision Records)
- Ask maintainers when conventions seem unusual

### 1.5 Identify Recently Modified Code as Default Scope

Not all code benefits equally from simplification. Recently modified files contain active development areas where simplification provides immediate value. Cold code that hasn't changed in months is likely stable and low-priority. Use git history to identify hot spots and focus simplification efforts where they matter most.

**Incorrect (simplifying random old code without checking activity):**

```bash
# Developer picks a file at random to simplify
# File hasn't been touched in 2 years and works fine

# utils/legacy-formatter.js - last modified 2022-03-15
# 47 lines of working code that no one has needed to change

# Result: PR sits in review for weeks, no one has context
# Risk: Introduces bugs in stable, untested legacy code
```

**Correct (checking git history to find active areas):**

```bash
# First, identify recently modified files
git log --since="30 days ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20

# Output shows hot spots:
#  15 src/api/user-service.ts
#  12 src/components/Dashboard.tsx
#   8 src/utils/validation.ts

# Focus simplification on user-service.ts - actively being worked on
# Team has context, tests are fresh, benefits are immediate
```

**Scoping strategies:**

- `git log --since="30 days ago"` for recent activity
- `git blame` to understand who owns which sections
- Look for files with many recent commits (churn indicates complexity)
- Prioritize files mentioned in open PRs or recent issues

**When NOT to use:**

- When specifically asked to simplify a legacy module
- During dedicated refactoring sprints with allocated time
- When preparing code for deprecation

**Benefits:**

- Simplifications ship faster with available reviewers
- Reduces risk of breaking untested legacy code
- Aligns with natural development momentum
- Changes are more likely to be maintained

**References:**

- `git shortlog -sn --since="90 days ago"` to find active contributors
- Check issue tracker for related tickets

---

## 2. Behavior Preservation (CRITICAL)

Simplification must never change what code does - only how it is written. Outputs, error handling, side effects, and API surfaces must remain identical.

### 2.1 Preserve All Return Values and Outputs

Code simplification must never alter what a function returns. Even "equivalent" values like empty array vs null, or reordered object keys, can break downstream consumers. Every output - return values, yielded items, emitted events - must remain byte-for-byte identical.

**Incorrect (changes return type from null to undefined):**

```typescript
// Before: returns null for missing users
function findUser(id: string): User | null {
  const user = users.find(u => u.id === id);
  if (!user) {
    return null;
  }
  return user;
}

// After "simplification": now returns undefined
function findUser(id: string): User | undefined {
  return users.find(u => u.id === id);
}
// Breaks: if (findUser(id) === null) { ... }
```

**Correct (preserves null return type):**

```typescript
function findUser(id: string): User | null {
  return users.find(u => u.id === id) ?? null;
}
```

**Incorrect (changes output ordering):**

```python
# Before: returns sorted by insertion order
def get_config():
    return {"host": "localhost", "port": 8080, "debug": True}

# After "simplification": alphabetical order
def get_config():
    return dict(sorted({"debug": True, "host": "localhost", "port": 8080}.items()))
# Breaks: code that relies on iteration order or serialization
```

**Correct (preserves original ordering):**

```python
def get_config():
    return {"host": "localhost", "port": 8080, "debug": True}
```

### Benefits

- Downstream code continues working without modification
- Tests remain valid without updates
- API contracts stay honored
- Serialized outputs remain compatible

### 2.2 Preserve Error Messages, Types, and Handling

Error behavior is part of your API contract. Changing exception types, error messages, or when errors are thrown breaks catch blocks, monitoring systems, and user expectations. Simplify error handling code only when the observable error behavior remains identical.

**Incorrect (changes exception type):**

```typescript
// Before: throws specific error type
function parseConfig(json: string): Config {
  try {
    return JSON.parse(json);
  } catch (e) {
    throw new ConfigParseError(`Invalid config: ${e.message}`);
  }
}

// After "simplification": throws generic error
function parseConfig(json: string): Config {
  return JSON.parse(json); // Now throws SyntaxError instead
}
// Breaks: catch (e) { if (e instanceof ConfigParseError) ... }
```

**Correct (preserves error type and message format):**

```typescript
function parseConfig(json: string): Config {
  try {
    return JSON.parse(json);
  } catch (e) {
    throw new ConfigParseError(`Invalid config: ${(e as Error).message}`);
  }
}
```

**Incorrect (changes error message):**

```python
# Before: specific error message
def validate_age(age: int) -> None:
    if age < 0:
        raise ValueError("Age cannot be negative")
    if age > 150:
        raise ValueError("Age cannot exceed 150")

# After "simplification": combined validation
def validate_age(age: int) -> None:
    if not 0 <= age <= 150:
        raise ValueError("Invalid age")  # Different message!
# Breaks: tests checking for specific error messages
```

**Correct (preserves original error messages):**

```python
def validate_age(age: int) -> None:
    if age < 0:
        raise ValueError("Age cannot be negative")
    if age > 150:
        raise ValueError("Age cannot exceed 150")
```

### When NOT to Apply

- When explicitly tasked with improving error messages
- When error messages contain sensitive information that should be removed
- When consolidating truly duplicate error paths (same message, same type)

### Benefits

- Catch blocks continue working correctly
- Monitoring and alerting rules remain valid
- User-facing error messages stay consistent
- Error documentation stays accurate

### 2.3 Preserve Public Function Signatures and Types

Public APIs are contracts with consumers. Changing parameter order, making required params optional, narrowing accepted types, or modifying return types breaks every caller. Internal simplification must never leak into public interfaces.

**Incorrect (changes parameter order):**

```typescript
// Before: well-established API
function formatDate(date: Date, format: string, locale?: string): string {
  // ...
}

// After "simplification": reordered for "consistency"
function formatDate(format: string, date: Date, locale?: string): string {
  // ...
}
// Breaks: formatDate(new Date(), 'YYYY-MM-DD')
```

**Correct (preserve original signature, simplify internals):**

```typescript
function formatDate(date: Date, format: string, locale?: string): string {
  const loc = locale ?? 'en-US';
  return new Intl.DateTimeFormat(loc, parseFormat(format)).format(date);
}
```

**Incorrect (narrows accepted types):**

```python
# Before: accepts any iterable
def process_items(items: Iterable[str]) -> list[str]:
    return [transform(item) for item in items]

# After "simplification": requires list
def process_items(items: list[str]) -> list[str]:
    return [transform(item) for item in items]
# Breaks: process_items(generator_expression)
```

**Correct (preserves type flexibility):**

```python
def process_items(items: Iterable[str]) -> list[str]:
    return [transform(item) for item in items]
```

### Benefits

- All existing callers continue working
- No breaking changes in library versions
- Type safety maintained for consumers
- Documentation remains accurate

### 2.4 Preserve Side Effects (Logging, I/O, State Changes)

Side effects are often the most important part of a function. Logging enables debugging and auditing. I/O operations persist data. State mutations coordinate systems. Removing or reordering side effects during simplification can cause silent failures that only surface in production.

**Incorrect (removes logging side effect):**

```typescript
// Before: logs for audit trail
async function transferFunds(from: Account, to: Account, amount: number) {
  logger.info(`Transfer initiated: ${from.id} -> ${to.id}, amount: ${amount}`);
  await from.debit(amount);
  await to.credit(amount);
  logger.info(`Transfer completed: ${from.id} -> ${to.id}`);
}

// After "simplification": removed "noisy" logging
async function transferFunds(from: Account, to: Account, amount: number) {
  await from.debit(amount);
  await to.credit(amount);
}
// Breaks: audit compliance, debugging capability
```

**Correct (preserve all logging):**

```typescript
async function transferFunds(from: Account, to: Account, amount: number) {
  logger.info(`Transfer initiated: ${from.id} -> ${to.id}, amount: ${amount}`);
  await from.debit(amount);
  await to.credit(amount);
  logger.info(`Transfer completed: ${from.id} -> ${to.id}`);
}
```

**Incorrect (changes I/O timing):**

```python
# Before: writes happen in sequence
def save_order(order: Order) -> None:
    db.save(order)
    cache.invalidate(f"order:{order.id}")
    search_index.update(order)

# After "simplification": parallel writes
async def save_order(order: Order) -> None:
    await asyncio.gather(
        db.save(order),
        cache.invalidate(f"order:{order.id}"),
        search_index.update(order)
    )
# Breaks: cache invalidation may happen before db.save completes
```

**Correct (preserve operation order):**

```python
def save_order(order: Order) -> None:
    db.save(order)
    cache.invalidate(f"order:{order.id}")
    search_index.update(order)
```

### Benefits

- Debugging and monitoring capabilities preserved
- Data consistency maintained
- Race conditions avoided
- Audit trails remain intact

### 2.5 Forbid Subtle Semantic Changes

The most dangerous simplifications are those that look equivalent but have different semantics. Null vs undefined, loose vs strict equality, truthy vs explicit checks - these distinctions matter. Code that appears cleaner may silently change behavior for edge cases that existing tests do not cover.

**Incorrect (changes null/undefined semantics):**

```typescript
// Before: explicitly checks for null
function getDisplayName(user: User | null): string {
  if (user === null) {
    return 'Anonymous';
  }
  return user.name;
}

// After "simplification": truthy check
function getDisplayName(user: User | null): string {
  return user ? user.name : 'Anonymous';
}
// Breaks: user with name = '' or name = 0 (if polymorphic)
```

**Correct (preserve explicit null check):**

```typescript
function getDisplayName(user: User | null): string {
  return user === null ? 'Anonymous' : user.name;
}
```

**Incorrect (changes equality semantics):**

```javascript
// Before: intentional loose equality for null/undefined
function isEmpty(value) {
  return value == null; // Catches both null and undefined
}

// After "simplification": strict equality
function isEmpty(value) {
  return value === null;
}
// Breaks: isEmpty(undefined) now returns false
```

**Correct (preserve loose equality when intentional):**

```javascript
function isEmpty(value) {
  return value == null; // Intentionally catches null and undefined
}
```

### When NOT to Apply

- When fixing a bug caused by incorrect semantics
- When the semantic difference is explicitly documented and approved
- When migrating to stricter types with full test coverage

### Benefits

- Edge cases continue working correctly
- No silent failures in production
- Behavior matches developer expectations
- Tests remain valid without modification

### 2.6 Verify Behavior Preservation Before Finalizing Changes

Never assume a simplification preserves behavior - verify it. Run existing tests, manually test edge cases, and review diffs for semantic changes. The confidence that code "looks equivalent" is insufficient. Verification must be explicit and documented.

**Incorrect (commits without verification):**

```typescript
// Developer thinks: "This is obviously the same"
// Before
function isValid(x: number): boolean {
  if (x > 0) {
    if (x < 100) {
      return true;
    }
  }
  return false;
}

// After "simplification" - commits directly
function isValid(x: number): boolean {
  return x > 0 && x < 100;
}
// Forgot to run tests, missed that NaN handling differs
```

**Correct (verifies before committing):**

```typescript
// 1. Run existing tests first
// $ npm test -- --grep "isValid"

// 2. Check edge cases manually
console.log(isValid(NaN));     // Before: false, After: false ✓
console.log(isValid(0));       // Before: false, After: false ✓
console.log(isValid(100));     // Before: false, After: false ✓
console.log(isValid(50));      // Before: true,  After: true  ✓

// 3. Review diff for semantic changes
// git diff --word-diff

// 4. Then commit with verification note
function isValid(x: number): boolean {
  return x > 0 && x < 100;
}
```

### Verification Checklist

Before finalizing any simplification:

1. **Run existing tests** - All tests must pass without modification
2. **Check edge cases** - null, undefined, empty, zero, negative, boundary values
3. **Review error paths** - Exceptions, error messages, failure modes
4. **Verify side effects** - Logging, I/O, state changes still occur
5. **Test with real data** - If available, run against production-like inputs
6. **Review the diff** - Look for type changes, reordering, removed code

### Verification Commands by Language

```bash
# TypeScript/JavaScript
npm test
npx tsc --noEmit

# Python
pytest
mypy .

# Go
go test ./...
go vet ./...

# Rust
cargo test
cargo clippy
```

### Benefits

- Catches behavior changes before they reach production
- Builds confidence in simplifications
- Documents verification for reviewers
- Creates a safety net for future changes

---

## 3. Scope Management (HIGH)

Focus on recently modified code only. Keep diffs small and reviewable. Avoid unrelated refactors, global rewrites, or architectural changes.

### 3.1 Focus on Recently Modified Code Only

Code simplification should target recently modified code unless explicitly asked otherwise. Old, stable code has survived production testing and carries hidden assumptions. Simplifying it introduces risk without proportional benefit, and reviewers lack fresh context to validate changes.

**Incorrect (simplifying unrelated legacy code):**

```typescript
// Task: Simplify the new getUserProfile function
// PR includes changes to:

// 1. The new function (correct target)
async function getUserProfile(id: string): Promise<Profile> {
  const user = await db.users.findById(id);
  return user ? mapToProfile(user) : null;
}

// 2. Legacy auth module last touched 2 years ago (wrong!)
// "While I was here, I noticed this could be cleaner..."
function validateSession(token: string): boolean {
  // Simplified from 50 lines to 20
  return jwt.verify(token, SECRET) && !isExpired(token);
}

// 3. Old utility last touched 18 months ago (wrong!)
// "This helper was verbose, made it more functional..."
const formatDate = (d: Date) => d.toISOString().split('T')[0];
```

**Correct (focused on recent code only):**

```typescript
// Task: Simplify the new getUserProfile function
// PR only touches getUserProfile (added last week)

// Before
async function getUserProfile(id: string): Promise<Profile> {
  const result = await db.users.findById(id);
  if (result !== null && result !== undefined) {
    const profile = mapToProfile(result);
    return profile;
  } else {
    return null;
  }
}

// After - only this function changes
async function getUserProfile(id: string): Promise<Profile> {
  const user = await db.users.findById(id);
  return user ? mapToProfile(user) : null;
}

// Legacy validateSession: untouched (stable for 2 years)
// Old formatDate utility: untouched (stable for 18 months)
```

### When NOT to Apply

- When explicitly asked to audit or simplify legacy code
- When fixing a bug that requires touching old code
- When old code blocks the current feature and must be modified anyway
- When performing a planned, scoped refactoring sprint

### Benefits

- PRs stay focused and reviewable
- Reviewers have full context on changed code
- Risk is contained to code already under active development
- git blame remains meaningful for historical debugging

### 3.2 Keep Changes Small and Reviewable

Every simplification should produce the smallest possible diff. Large diffs exhaust reviewers, hide bugs in noise, and make rollbacks painful. A 50-line PR gets thorough review; a 500-line PR gets rubber-stamped. Small changes also make git bisect effective when bugs emerge.

**Incorrect (kitchen-sink simplification):**

```diff
# PR: "Simplify user service" - 847 lines changed

- import { UserRepository } from './repositories/user';
- import { Logger } from '../shared/logger';
- import { Cache } from '../shared/cache';
+ import { UserRepository } from '@/repos';
+ import { log } from '@/utils';
+ import { cache } from '@/utils';

- export class UserService {
-   private repo: UserRepository;
-   private logger: Logger;
-   private cache: Cache;
-
-   constructor(repo: UserRepository, logger: Logger, cache: Cache) {
-     this.repo = repo;
-     this.logger = logger;
-     this.cache = cache;
-   }
+ export class UserService {
+   constructor(
+     private repo = new UserRepository(),
+     private log = log,
+     private cache = cache
+   ) {}

# ... 800 more lines of "improvements" across 15 files
```

**Correct (atomic, focused simplification):**

```diff
# PR 1: "Simplify UserService.getUser caching logic" - 12 lines changed

  async getUser(id: string): Promise<User | null> {
-   const cached = await this.cache.get(`user:${id}`);
-   if (cached !== null) {
-     return cached;
-   }
-   const user = await this.repo.findById(id);
-   if (user !== null) {
-     await this.cache.set(`user:${id}`, user);
-   }
-   return user;
+   const cacheKey = `user:${id}`;
+   const cached = await this.cache.get(cacheKey);
+   if (cached) return cached;
+
+   const user = await this.repo.findById(id);
+   if (user) await this.cache.set(cacheKey, user);
+   return user;
  }

# PR 2 (separate): "Update import paths to use aliases" - if needed
# PR 3 (separate): "Simplify UserService constructor" - if needed
```

### Guidelines for Diff Size

- Aim for under 200 lines changed per PR
- Never exceed 400 lines without explicit approval
- If simplification grows large, split into multiple PRs
- Each PR should have a single, clear purpose

### Benefits

- Reviewers can give full attention to each change
- Bugs are easier to spot in small diffs
- Rollbacks affect minimal code
- CI/CD cycles are faster
- Merge conflicts are less likely

### 3.3 No Unrelated Refactors

Every PR should have exactly one purpose. When simplifying code, resist the urge to fix "while you're in there" issues. Unrelated changes pollute git history, complicate reviews, and create deployment dependencies. If you spot other issues, create separate tickets.

**Incorrect (opportunistic refactoring):**

```typescript
// Task: Simplify the calculateDiscount function
// PR description: "Simplify discount calc + some cleanup"

// Change 1: The actual task (correct)
function calculateDiscount(price: number, tier: string): number {
  const rates = { bronze: 0.05, silver: 0.10, gold: 0.15 };
  return price * (rates[tier] ?? 0);
}

// Change 2: "Noticed this could use optional chaining" (wrong!)
function getOrderTotal(order: Order): number {
  return order?.items?.reduce((sum, i) => sum + i.price, 0) ?? 0;
}

// Change 3: "Fixed inconsistent naming" (wrong!)
// Renamed userPreferences -> userPrefs across 8 files

// Change 4: "Removed dead code I found" (wrong!)
// Deleted 3 unused utility functions

// Change 5: "Updated to arrow functions for consistency" (wrong!)
// Converted 12 function declarations to arrows
```

**Correct (single-purpose PR):**

```typescript
// Task: Simplify the calculateDiscount function
// PR description: "Simplify discount calculation using lookup table"

// Before
function calculateDiscount(price: number, tier: string): number {
  let discount = 0;
  if (tier === 'bronze') {
    discount = price * 0.05;
  } else if (tier === 'silver') {
    discount = price * 0.10;
  } else if (tier === 'gold') {
    discount = price * 0.15;
  }
  return discount;
}

// After - ONLY this function changes
function calculateDiscount(price: number, tier: string): number {
  const rates = { bronze: 0.05, silver: 0.10, gold: 0.15 };
  return price * (rates[tier] ?? 0);
}

// Other observations logged as separate tickets:
// - TECH-1234: Add optional chaining to getOrderTotal
// - TECH-1235: Standardize preferences naming convention
// - TECH-1236: Remove unused utility functions
```

### The "While You're In There" Anti-Pattern

Common temptations to resist:
- "I'll just update these imports too"
- "This variable name is misleading, quick fix"
- "Found some dead code, might as well delete it"
- "The formatting here is inconsistent"
- "This could use modern syntax"

Each of these deserves its own PR or ticket.

### When NOT to Apply

- When the "unrelated" change is required for the main change to work
- When fixing a typo in a comment you're already modifying
- When the project explicitly allows bundled cleanup (rare)

### Benefits

- PRs are easy to review, approve, or reject independently
- Reverts are surgical, not catastrophic
- git blame shows clear intent for each change
- Deployment risk is isolated

### 3.4 Avoid Global Rewrites and Architectural Changes

Code simplification is not the time for sweeping changes. Global renames, mass migrations, or architectural shifts disguised as "simplification" create merge conflict nightmares and require extensive testing. These changes need dedicated planning, not drive-by implementation.

**Incorrect (global rename during simplification):**

```typescript
// Task: Simplify the checkout module
// "To simplify, I'll rename 'cart' to 'basket' everywhere for clarity"

// 127 files changed:
// - src/components/Cart.tsx -> Basket.tsx
// - src/hooks/useCart.ts -> useBasket.ts
// - src/stores/cartStore.ts -> basketStore.ts
// - src/api/cart/*.ts -> basket/*.ts
// - src/types/cart.ts -> basket.ts
// - tests/**/*cart* -> *basket*
// - docs/cart.md -> basket.md
// Plus all import statements, variable names, comments...

// "Also modernized the state management while I was at it"
// Migrated from Redux to Zustand across 45 files
```

**Correct (contained simplification):**

```typescript
// Task: Simplify the checkout module
// PR only touches checkout logic, preserves existing naming

// Before - checkout/processOrder.ts
export async function processOrder(cart: Cart, payment: Payment) {
  const validation = validateCart(cart);
  if (validation.isValid === false) {
    throw new ValidationError(validation.errors);
  }
  const total = calculateTotal(cart);
  const tax = calculateTax(total, cart.shippingAddress);
  const finalAmount = total + tax;
  const charge = await chargePayment(payment, finalAmount);
  if (charge.success === true) {
    return createOrder(cart, charge);
  }
  throw new PaymentError(charge.error);
}

// After - same file, same naming conventions
export async function processOrder(cart: Cart, payment: Payment) {
  validateCart(cart); // throws on invalid

  const total = calculateTotal(cart);
  const finalAmount = total + calculateTax(total, cart.shippingAddress);

  const charge = await chargePayment(payment, finalAmount);
  if (!charge.success) throw new PaymentError(charge.error);

  return createOrder(cart, charge);
}

// Note: "cart vs basket" naming discussion logged as TECH-1234
// Note: State management modernization planned for Q3 roadmap
```

### Changes That Require Separate Planning

| Change Type | Why It's Not Simplification |
|-------------|---------------------------|
| Global renames | Touches every file, massive merge conflicts |
| Dependency upgrades | Requires compatibility testing |
| Architecture changes | Needs design review and migration plan |
| Pattern migrations | (callbacks->promises, classes->hooks) Need incremental rollout |
| Directory restructuring | Breaks imports across entire codebase |

### When NOT to Apply

- During a planned, scheduled migration sprint
- When the global change is the explicit, approved task
- When a breaking change is already coordinated with the team

### Benefits

- Other developers can continue merging their work
- No surprise regressions in unrelated features
- Changes can be reviewed by domain experts
- Rollback is possible without reverting weeks of work

### 3.5 Respect Module and Component Boundaries

When simplifying code, stay within the current module or component boundary. Reaching across boundaries to "simplify" creates tight coupling, violates encapsulation, and pulls in reviewers from other teams. Each module has its own owners, contracts, and release cycles.

**Incorrect (crossing boundaries to simplify):**

```typescript
// Task: Simplify the OrderService in the orders module
// "I can simplify this by directly accessing the user database"

// orders/OrderService.ts
import { db } from '../users/database';        // Crossing into users module!
import { UserCache } from '../users/cache';    // Crossing into users module!
import { formatAddress } from '../shipping/utils'; // Crossing into shipping!

class OrderService {
  async createOrder(userId: string, items: Item[]) {
    // "Simplified" by bypassing UserService
    const user = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    const cached = UserCache.get(userId);  // Direct cache access

    // "Simplified" by inlining shipping logic
    const address = formatAddress(user.address); // Using internal util

    return this.repo.create({ user, items, address });
  }
}

// Now OrderService depends on:
// - users module internals (database, cache)
// - shipping module internals (utils)
// Breaking changes in any module will break orders
```

**Correct (respecting boundaries):**

```typescript
// Task: Simplify the OrderService in the orders module
// Stays within orders module, uses public APIs

// orders/OrderService.ts
import { UserService } from '../users';      // Public API only
import { ShippingService } from '../shipping'; // Public API only

class OrderService {
  constructor(
    private users: UserService,
    private shipping: ShippingService,
    private repo: OrderRepository
  ) {}

  async createOrder(userId: string, items: Item[]) {
    // Before: verbose null checking
    const user = await this.users.getById(userId);
    if (!user) throw new NotFoundError('User not found');

    const address = await this.shipping.formatAddress(user.addressId);
    if (!address) throw new NotFoundError('Address not found');

    return this.repo.create({ userId, items, shippingAddress: address });
  }

  // After: simplified but still uses public APIs
  async createOrder(userId: string, items: Item[]) {
    const [user, address] = await Promise.all([
      this.users.getByIdOrThrow(userId),
      this.shipping.getFormattedAddress(userId)
    ]);

    return this.repo.create({ userId, items, shippingAddress: address });
  }
}

// If UserService or ShippingService APIs are clunky, request changes
// through proper channels - don't bypass them
```

### Boundary Violations to Avoid

| Violation | Why It's Harmful |
|-----------|-----------------|
| Direct database access across modules | Bypasses business logic, breaks encapsulation |
| Importing internal utilities | Creates hidden dependencies |
| Accessing private/internal APIs | Will break on internal refactors |
| Copying code from other modules | Creates drift and duplication |
| Modifying other modules "to simplify" | Requires other team's review/approval |

### When NOT to Apply

- When you own both modules and they're tightly related
- When the boundary itself is the problem (propose boundary changes separately)
- When working in a monolith with no clear module ownership
- When the public API is genuinely missing needed functionality (request it)

### Benefits

- Each module can evolve independently
- Changes only require review from affected team
- Testing is scoped to the current module
- Coupling stays low and explicit

---

## 4. Control Flow Simplification (HIGH)

Reduce nesting through early returns and guard clauses. Avoid nested ternaries. Prefer explicit control flow over dense expressions.

### 4.1 Use Early Returns to Reduce Nesting

Deep nesting forces readers to mentally track multiple conditions simultaneously. Early returns eliminate wrapper conditions by handling edge cases immediately and exiting. This creates a linear reading flow where each line is at the same indentation level, dramatically improving comprehension.

**Incorrect (deeply nested logic):**

```typescript
function processOrder(order: Order): Result {
  if (order) {
    if (order.items.length > 0) {
      if (order.customer) {
        if (order.customer.isActive) {
          if (order.paymentMethod) {
            const total = calculateTotal(order.items);
            if (total > 0) {
              const discount = getDiscount(order.customer);
              const finalTotal = total - discount;
              return chargeCustomer(order.customer, finalTotal);
            } else {
              return { error: 'Invalid total' };
            }
          } else {
            return { error: 'No payment method' };
          }
        } else {
          return { error: 'Customer inactive' };
        }
      } else {
        return { error: 'No customer' };
      }
    } else {
      return { error: 'No items' };
    }
  } else {
    return { error: 'No order' };
  }
}
```

**Correct (early returns, flat structure):**

```typescript
function processOrder(order: Order): Result {
  if (!order) {
    return { error: 'No order' };
  }
  if (order.items.length === 0) {
    return { error: 'No items' };
  }
  if (!order.customer) {
    return { error: 'No customer' };
  }
  if (!order.customer.isActive) {
    return { error: 'Customer inactive' };
  }
  if (!order.paymentMethod) {
    return { error: 'No payment method' };
  }

  const total = calculateTotal(order.items);
  if (total <= 0) {
    return { error: 'Invalid total' };
  }

  const discount = getDiscount(order.customer);
  const finalTotal = total - discount;
  return chargeCustomer(order.customer, finalTotal);
}
```

### Benefits

- Reading flow is top-to-bottom without mental stack
- Error conditions are visually grouped at the top
- Happy path is clearly visible at the bottom
- Each condition can be understood in isolation
- Easier to add new validations without restructuring

### When NOT to Apply

- When the nested structure represents meaningful domain hierarchy
- In functional programming contexts where early return breaks composition
- When using exhaustive pattern matching that requires all branches

### 4.2 Use Guard Clauses for Preconditions

Guard clauses validate all preconditions at the function's entry point and exit immediately if validation fails. This pattern creates a clear contract: if execution passes the guards, all required conditions are met. Readers don't need to trace conditions through the entire function body.

**Incorrect (validations scattered throughout):**

```typescript
function sendNotification(user: User, message: string, channel: Channel): void {
  let result;

  if (user && user.email) {
    if (message && message.trim().length > 0) {
      const sanitized = sanitizeMessage(message);

      if (channel === 'email') {
        if (user.emailVerified) {
          result = emailService.send(user.email, sanitized);
        } else {
          console.log('Email not verified');
        }
      } else if (channel === 'sms') {
        if (user.phone) {
          if (user.phoneVerified) {
            result = smsService.send(user.phone, sanitized);
          } else {
            console.log('Phone not verified');
          }
        } else {
          console.log('No phone number');
        }
      }
    } else {
      console.log('Empty message');
    }
  } else {
    console.log('Invalid user');
  }

  return result;
}
```

**Correct (guard clauses at entry):**

```typescript
function sendNotification(user: User, message: string, channel: Channel): void {
  // Guard clauses - all preconditions checked upfront
  if (!user?.email) {
    throw new ValidationError('User must have an email address');
  }
  if (!message?.trim()) {
    throw new ValidationError('Message cannot be empty');
  }
  if (!['email', 'sms'].includes(channel)) {
    throw new ValidationError(`Invalid channel: ${channel}`);
  }

  const sanitized = sanitizeMessage(message);

  // Channel-specific guards
  if (channel === 'email') {
    if (!user.emailVerified) {
      throw new ValidationError('Email address not verified');
    }
    return emailService.send(user.email, sanitized);
  }

  if (channel === 'sms') {
    if (!user.phone) {
      throw new ValidationError('User must have a phone number for SMS');
    }
    if (!user.phoneVerified) {
      throw new ValidationError('Phone number not verified');
    }
    return smsService.send(user.phone, sanitized);
  }
}
```

### Benefits

- Function contract is immediately visible
- Invalid states fail fast before causing side effects
- Core logic operates on guaranteed valid data
- Testing is simplified - guards can be tested independently
- Debugging is easier - failures point to specific validation

### When NOT to Apply

- When partial/graceful degradation is required (use defaults instead)
- In hot paths where exceptions are too expensive
- When building tolerant readers that handle malformed input

### 4.3 Never Use Nested Ternary Operators

Nested ternary operators create write-only code. The human brain processes branching logic linearly, but nested ternaries force simultaneous evaluation of multiple conditions. Even with formatting, the precedence and flow become ambiguous. One nested ternary can make an entire function unreadable.

**Incorrect (nested ternaries):**

```typescript
function getStatusBadge(user: User): string {
  return user.isAdmin
    ? user.isActive
      ? 'admin-active'
      : 'admin-inactive'
    : user.isPremium
      ? user.isActive
        ? 'premium-active'
        : 'premium-inactive'
      : user.isActive
        ? 'basic-active'
        : 'basic-inactive';
}
```

**Correct (explicit conditionals):**

```typescript
function getStatusBadge(user: User): string {
  const status = user.isActive ? 'active' : 'inactive';

  if (user.isAdmin) {
    return `admin-${status}`;
  }
  if (user.isPremium) {
    return `premium-${status}`;
  }
  return `basic-${status}`;
}
```

**Incorrect (ternary chain for value selection):**

```typescript
const priority = task.isUrgent
  ? task.isImportant
    ? 1
    : 2
  : task.isImportant
    ? 3
    : 4;
```

**Correct (lookup object or switch):**

```typescript
const priorityMatrix = {
  'urgent-important': 1,
  'urgent-normal': 2,
  'normal-important': 3,
  'normal-normal': 4,
};

const urgency = task.isUrgent ? 'urgent' : 'normal';
const importance = task.isImportant ? 'important' : 'normal';
const priority = priorityMatrix[`${urgency}-${importance}`];
```

### Acceptable Single-Level Ternary

```typescript
// OK: Single ternary for simple binary choice
const label = isLoading ? 'Loading...' : 'Submit';

// OK: Nullish coalescing or optional chaining
const name = user?.name ?? 'Anonymous';

// NOT OK: Even two levels is too much
const label = isLoading ? 'Loading...' : isDisabled ? 'Disabled' : 'Submit';
```

### Benefits

- Code flow is immediately apparent
- Debugging is possible (can set breakpoints)
- Modifications don't require understanding entire expression
- Code review can focus on logic, not parsing

### When NOT to Apply

- Single-level ternaries for simple binary choices are acceptable
- Ternaries inside template literals for simple value selection

### 4.4 Prefer Explicit Control Flow Over Dense Expressions

Dense one-liners optimize for code golf, not comprehension. When multiple operations are chained or combined into a single expression, readers must mentally unpack each step. Explicit code may take more lines, but each line does one obvious thing. Future maintainers (including yourself) will thank you.

**Incorrect (dense chained operations):**

```typescript
const result = data.filter(x => x.active).map(x => x.value).reduce((a, b) => a + b, 0) / data.filter(x => x.active).length || 0;
```

**Correct (explicit steps with meaningful names):**

```typescript
const activeItems = data.filter(item => item.active);
const values = activeItems.map(item => item.value);
const sum = values.reduce((total, value) => total + value, 0);
const average = activeItems.length > 0 ? sum / activeItems.length : 0;
```

**Incorrect (boolean logic golfing):**

```typescript
const canProceed = !!(user && user.verified && (user.role === 'admin' || (user.role === 'member' && user.subscription?.active && new Date(user.subscription.expiresAt) > new Date())));
```

**Correct (readable boolean expression):**

```typescript
const isVerifiedUser = user?.verified ?? false;
const isAdmin = user?.role === 'admin';
const hasActiveSubscription =
  user?.role === 'member' &&
  user?.subscription?.active &&
  new Date(user.subscription.expiresAt) > new Date();

const canProceed = isVerifiedUser && (isAdmin || hasActiveSubscription);
```

### Benefits

- Each line can be understood independently
- Intermediate values can be logged/inspected during debugging
- Modifications don't require understanding entire expression
- Variable names serve as documentation
- Easier to add error handling at specific steps

### When NOT to Apply

- Simple transformations: `const names = users.map(u => u.name)`
- Standard idioms: `const value = input ?? defaultValue`
- Well-known patterns: `array.filter(Boolean)`

### 4.5 Flatten Deep Nesting to Maximum 2-3 Levels

Code nested beyond 2-3 levels becomes exponentially harder to understand. Each level requires holding more context in working memory. When you find yourself at 4+ levels, it's a signal to extract functions, use early returns, or restructure the logic. Flat code is maintainable code.

**Incorrect (excessive nesting):**

```typescript
function processTransactions(accounts: Account[]) {
  for (const account of accounts) {
    if (account.isActive) {
      for (const transaction of account.transactions) {
        if (transaction.status === 'pending') {
          if (transaction.amount > 0) {
            for (const rule of account.rules) {
              if (rule.applies(transaction)) {
                if (rule.action === 'flag') {
                  if (transaction.amount > rule.threshold) {
                    transaction.flagged = true;
                    transaction.flagReason = rule.reason;
                    notifyCompliance(account, transaction);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

**Correct (flattened with extraction and early continues):**

```typescript
function processTransactions(accounts: Account[]) {
  const activeAccounts = accounts.filter(a => a.isActive);

  for (const account of activeAccounts) {
    processPendingTransactions(account);
  }
}

function processPendingTransactions(account: Account) {
  const pendingTransactions = account.transactions.filter(
    t => t.status === 'pending' && t.amount > 0
  );

  for (const transaction of pendingTransactions) {
    applyRules(account, transaction);
  }
}

function applyRules(account: Account, transaction: Transaction) {
  for (const rule of account.rules) {
    if (!rule.applies(transaction)) {
      continue;
    }
    if (rule.action !== 'flag') {
      continue;
    }
    if (transaction.amount <= rule.threshold) {
      continue;
    }

    transaction.flagged = true;
    transaction.flagReason = rule.reason;
    notifyCompliance(account, transaction);
  }
}
```

### Flattening Strategies

1. **Early returns/continues** - Exit the current scope ASAP
2. **Extract helper functions** - Each handles one level of complexity
3. **Filter before iterate** - Move conditions out of loops
4. **Use optional chaining** - For safe property access
5. **Use lookup tables** - Replace nested conditionals with data

### Benefits

- Each function fits in working memory
- Code can be tested in smaller units
- Easier to parallelize or optimize specific parts
- Clearer separation of concerns

### When NOT to Apply

- State machines with inherent nesting
- Parser/compiler code with recursive descent
- When extraction would require excessive parameter passing

### 4.6 Each Code Block Should Do One Thing

When a code block (function, loop, conditional branch) tries to do multiple things, it becomes harder to name, test, and modify. Each block should have one clear purpose. If you can't describe what a block does without using "and", split it up.

**Incorrect (loop doing multiple things):**

```typescript
function processOrders(orders: Order[]) {
  let totalRevenue = 0;
  const flaggedOrders: Order[] = [];
  const customerOrderCounts: Map<string, number> = new Map();
  const emailsToSend: Email[] = [];

  for (const order of orders) {
    // Calculate revenue
    totalRevenue += order.total;

    // Flag suspicious orders
    if (order.total > 10000 || order.items.length > 50) {
      flaggedOrders.push(order);
    }

    // Count orders per customer
    const count = customerOrderCounts.get(order.customerId) || 0;
    customerOrderCounts.set(order.customerId, count + 1);

    // Prepare confirmation emails
    if (order.status === 'completed') {
      emailsToSend.push({
        to: order.customerEmail,
        subject: 'Order Confirmed',
        body: generateOrderEmail(order),
      });
    }

    // Update inventory
    for (const item of order.items) {
      inventory.decrement(item.sku, item.quantity);
    }
  }

  return { totalRevenue, flaggedOrders, customerOrderCounts, emailsToSend };
}
```

**Correct (separate single-purpose functions):**

```typescript
function processOrders(orders: Order[]): ProcessingResult {
  return {
    totalRevenue: calculateTotalRevenue(orders),
    flaggedOrders: findSuspiciousOrders(orders),
    customerOrderCounts: countOrdersByCustomer(orders),
    emailsToSend: prepareConfirmationEmails(orders),
  };
}

function calculateTotalRevenue(orders: Order[]): number {
  return orders.reduce((sum, order) => sum + order.total, 0);
}

function findSuspiciousOrders(orders: Order[]): Order[] {
  return orders.filter(
    order => order.total > 10000 || order.items.length > 50
  );
}

function countOrdersByCustomer(orders: Order[]): Map<string, number> {
  const counts = new Map<string, number>();
  for (const order of orders) {
    const current = counts.get(order.customerId) || 0;
    counts.set(order.customerId, current + 1);
  }
  return counts;
}

function prepareConfirmationEmails(orders: Order[]): Email[] {
  return orders
    .filter(order => order.status === 'completed')
    .map(order => ({
      to: order.customerEmail,
      subject: 'Order Confirmed',
      body: generateOrderEmail(order),
    }));
}

function updateInventory(orders: Order[]): void {
  for (const order of orders) {
    for (const item of order.items) {
      inventory.decrement(item.sku, item.quantity);
    }
  }
}
```

### Signs a Block Does Too Much

- Name includes "and" or describes multiple actions
- Multiple unrelated variables being modified
- Comments separating different "sections"
- Difficult to write a focused unit test
- Changes to one part risk breaking another

### Benefits

- Each piece can be tested in isolation
- Functions can be reused in different contexts
- Changes are localized - modify one thing without risking others
- Names become self-documenting
- Easier to parallelize independent operations

### 4.7 Prefer Positive Conditions Over Double Negatives

The human brain processes positive statements faster than negative ones. Double negatives require mental inversion that slows comprehension and increases error rates. Write conditions that state what IS true, not what ISN'T NOT true.

**Incorrect (double negatives):**

```typescript
if (!user.isNotVerified) {
  sendWelcomeEmail(user);
}

if (!isNotEmpty(list)) {
  return 'No items';
}

if (!config.disableCache !== false) {
  useCache();
}

const cannotProceed = !isValid || !hasPermission;
if (!cannotProceed) {
  proceed();
}
```

**Correct (positive conditions):**

```typescript
if (user.isVerified) {
  sendWelcomeEmail(user);
}

if (isEmpty(list)) {
  return 'No items';
}

if (config.enableCache) {
  useCache();
}

const canProceed = isValid && hasPermission;
if (canProceed) {
  proceed();
}
```

**Incorrect (negative function names):**

```typescript
function isNotAdmin(user: User): boolean {
  return user.role !== 'admin';
}

function hasNoErrors(result: Result): boolean {
  return result.errors.length === 0;
}

function isDisabled(feature: Feature): boolean {
  return !feature.enabled;
}

// Usage becomes confusing
if (!isNotAdmin(user) && !isDisabled(feature)) {
  showAdminPanel();
}
```

**Correct (positive function names):**

```typescript
function isAdmin(user: User): boolean {
  return user.role === 'admin';
}

function isValid(result: Result): boolean {
  return result.errors.length === 0;
}

function isEnabled(feature: Feature): boolean {
  return feature.enabled;
}

// Usage is clear
if (isAdmin(user) && isEnabled(feature)) {
  showAdminPanel();
}
```

### Refactoring Patterns

| Negative Form | Positive Form |
|--------------|---------------|
| `!isNotValid` | `isValid` |
| `!isEmpty` | `hasItems` |
| `!isDisabled` | `isEnabled` |
| `notFound === false` | `found === true` or just `found` |
| `!user.inactive` | `user.isActive` (may need data change) |
| `errors.length === 0` | `isValid` or `hasNoErrors` |

### Benefits

- Conditions read like natural language
- Fewer mental inversions when reading
- Reduced chance of logic errors
- Easier to combine conditions with && and ||
- Self-documenting variable and function names

### When NOT to Apply

- When the negative is the natural domain concept (e.g., `isDeprecated`, `wasDeleted`)
- When matching an external API that uses negative naming
- In guard clauses where `if (!x) return` is idiomatic
- When `!condition` is clearer than creating a new named positive

---

## 5. Naming and Clarity (MEDIUM-HIGH)

Use precise, intention-revealing names. Nouns for data, verbs for actions. Descriptive names over implicit abbreviations.

### 5.1 Use Intention-Revealing Names

Names should answer why something exists, what it does, and how it is used. If a name requires a comment to explain its purpose, the name itself should be improved. Good names make code self-documenting, reducing cognitive load and preventing misuse.

**Incorrect (names require comments to understand):**

```typescript
// Bad: What does 'd' represent?
const d = 86400000; // milliseconds in a day

function calc(a: number[], f: number): number {
  // Bad: What is being calculated? What are a and f?
  return a.filter(x => x > f).length;
}

// Bad: What does this list contain?
const list = getUsers();
```

**Correct (names reveal intent):**

```typescript
const MILLISECONDS_PER_DAY = 86400000;

function countItemsAboveThreshold(items: number[], threshold: number): number {
  return items.filter(item => item > threshold).length;
}

const activeUsers = getActiveUsers();
```

**Incorrect (Python - cryptic names):**

```python
# Bad: What is being processed?
def proc(d, t):
    r = []
    for i in d:
        if i['ts'] > t:
            r.append(i)
    return r
```

**Correct (Python - intention-revealing):**

```python
def filter_events_after_timestamp(events, cutoff_timestamp):
    recent_events = []
    for event in events:
        if event['timestamp'] > cutoff_timestamp:
            recent_events.append(event)
    return recent_events
```

### When NOT to Apply

- Loop indices (`i`, `j`, `k`) in simple iterations where scope is tiny
- Mathematical formulas where single-letter variables are conventional (e.g., `x`, `y` for coordinates)
- Lambda parameters in very short, obvious transformations

### Benefits

- Code becomes self-documenting
- Eliminates need for explanatory comments
- Reduces onboarding time for new developers
- Makes code review faster and more effective
- Prevents bugs caused by misunderstanding variable purpose

### 5.2 Use Nouns for Data, Verbs for Actions

Variables, constants, and properties represent data - name them with nouns or noun phrases. Functions and methods perform actions - name them with verbs or verb phrases. This grammatical consistency creates intuitive expectations about what code does, making it easier to read and harder to misuse.

**Incorrect (confused naming conventions):**

```typescript
// Bad: verb name for data
const getUser = { id: 1, name: 'Alice' };

// Bad: noun name for function
function user(id: number): User {
  return database.find(id);
}

// Bad: adjective for boolean action
function valid(input: string): boolean {
  return input.length > 0;
}

// Confusing usage
const result = user(getUser.id); // Which is the function?
```

**Correct (nouns for data, verbs for actions):**

```typescript
// Good: noun for data
const currentUser = { id: 1, name: 'Alice' };

// Good: verb for function
function fetchUser(id: number): User {
  return database.find(id);
}

// Good: verb for boolean-returning function
function isValid(input: string): boolean {
  return input.length > 0;
}

// Clear usage
const result = fetchUser(currentUser.id);
```

### Common Patterns

| Entity Type | Convention | Examples |
|-------------|------------|----------|
| Variables | Noun/noun phrase | `user`, `orderItems`, `totalPrice` |
| Constants | Noun (often UPPER_CASE) | `MAX_RETRIES`, `DefaultTimeout` |
| Functions | Verb/verb phrase | `fetchUser`, `calculateTotal`, `validateInput` |
| Boolean functions | `is`, `has`, `can`, `should` | `isValid`, `hasPermission`, `canEdit` |
| Properties | Noun | `user.name`, `order.total` |

### When NOT to Apply

- Factory functions may use nouns when the pattern is conventional (e.g., `NewUser()` in Go)
- Builder pattern methods may chain noun-like names
- DSL or fluent APIs may prioritize readability over grammar

### Benefits

- Instantly distinguishes data from behavior
- Reduces cognitive load when reading code
- Prevents accidental misuse (calling data, accessing functions)
- Makes code structure predictable

### 5.3 Avoid Cryptic Abbreviations

Abbreviations save a few keystrokes but cost readers significant mental effort to decode. What seems obvious to the author (who just created the abbreviation) becomes a puzzle for future readers. Use complete words that anyone can understand without context clues or tribal knowledge.

**Incorrect (cryptic abbreviations):**

```typescript
// Bad: What do these mean?
const usrMgr = new UserManager();
const cfg = loadConfig();
const txn = db.beginTransaction();
const btn = document.getElementById('submit');
const req = new HttpRequest();
const res = await fetch(url);
const err = validate(input);
const tmp = calculateIntermediate();
const cnt = items.length;
const idx = findPosition(target);
const ctx = createContext();
const val = getValue();
const cb = () => console.log('done');
```

**Correct (full words):**

```typescript
// Good: immediately understandable
const userManager = new UserManager();
const configuration = loadConfig();
const transaction = db.beginTransaction();
const submitButton = document.getElementById('submit');
const httpRequest = new HttpRequest();
const response = await fetch(url);
const validationError = validate(input);
const intermediateResult = calculateIntermediate();
const itemCount = items.length;
const targetIndex = findPosition(target);
const requestContext = createContext();
const currentValue = getValue();
const onComplete = () => console.log('done');
```

### Acceptable Abbreviations

Some abbreviations are so universally understood they are acceptable:

| Abbreviation | Meaning | Context |
|--------------|---------|---------|
| `id` | identifier | Universal |
| `url` | uniform resource locator | Web development |
| `api` | application programming interface | Programming |
| `http` | hypertext transfer protocol | Web development |
| `db` | database | When context is obvious |
| `io` | input/output | Systems programming |
| `i`, `j`, `k` | loop indices | Small loop scopes |
| `e`, `err` | error | Go convention, catch blocks |
| `ctx` | context | Go convention only |

### When NOT to Apply

- Well-established domain acronyms (HTML, JSON, SQL, UUID)
- Industry-standard abbreviations (API, HTTP, URL)
- Language-specific idioms (`err` in Go, `e` in catch blocks)
- Mathematical notation in algorithms

### Benefits

- Zero decoding time for readers
- New team members productive immediately
- No tribal knowledge required
- Reduces bugs from misinterpreted abbreviations
- Code is searchable with full words

### 5.4 Use Consistent Vocabulary Throughout

When the same concept is called different things in different places, readers must mentally map synonyms and wonder if they refer to the same thing or subtly different concepts. Pick one term for each concept and use it everywhere - in code, comments, documentation, and conversation.

**Incorrect (inconsistent terminology):**

```typescript
// Bad: Same concept, different names
class UserService {
  fetchUser(id: string): User { ... }       // "fetch"
  getCustomer(id: string): User { ... }     // "get" + "customer"
  retrieveAccount(id: string): User { ... } // "retrieve" + "account"
  loadClient(id: string): User { ... }      // "load" + "client"
}

// Confusing: Are these the same or different?
const user = service.fetchUser(id);
const customer = service.getCustomer(id);
const account = service.retrieveAccount(id);
```

**Correct (consistent vocabulary):**

```typescript
// Good: One term per concept
class UserService {
  getUser(id: string): User { ... }
  getUserByEmail(email: string): User { ... }
  getUsersByRole(role: string): User[] { ... }
  getCurrentUser(): User { ... }
}

// Clear: All operations work with "users" and "get"
const user = service.getUser(id);
const admin = service.getUserByEmail(adminEmail);
const editors = service.getUsersByRole('editor');
```

### Create a Project Vocabulary

Document your chosen terms:

| Concept | Use This | NOT These |
|---------|----------|-----------|
| Retrieve data | `get` | fetch, retrieve, load, find, obtain |
| Create entity | `create` | add, insert, new, make, build |
| Remove entity | `delete` | remove, destroy, clear, erase |
| Modify entity | `update` | modify, change, edit, patch |
| Person using app | `user` | customer, client, account, member |

### When NOT to Apply

- When integrating with external APIs that use different terminology
- When domain experts use specific terms (use their ubiquitous language)
- When language idioms dictate different verbs (e.g., `append` in Go)

### Benefits

- Concepts are immediately recognizable
- No mental mapping between synonyms required
- Search and replace works reliably
- Onboarding is faster with predictable naming
- Domain model stays clear and unambiguous

### References

- Domain-Driven Design: "Ubiquitous Language" pattern
- Clean Code: "Use Solution Domain Names" and "Use Problem Domain Names"

### 5.5 Avoid Generic Names

Names like `data`, `info`, `temp`, `item`, `result`, `value`, and `thing` tell you nothing about what they contain. They force readers to trace through the code to understand what they represent. Replace generic names with specific ones that describe the actual content or purpose.

**Incorrect (generic names):**

```typescript
// Bad: What kind of data? What info? Result of what?
async function process(data: any): Promise<any> {
  const info = await fetchInfo(data.id);
  const result = transform(info);
  const temp = validate(result);
  return temp;
}

// Bad: What items? What values?
function handleItems(items: any[]) {
  for (const item of items) {
    const value = item.getValue();
    doSomething(value);
  }
}
```

**Correct (specific names):**

```typescript
// Good: Names describe actual content
async function processOrder(orderRequest: OrderRequest): Promise<OrderConfirmation> {
  const inventoryStatus = await fetchInventoryStatus(orderRequest.productId);
  const pricedOrder = applyPricing(inventoryStatus);
  const validatedOrder = validateOrder(pricedOrder);
  return validatedOrder;
}

// Good: Names reveal what's being processed
function applyDiscounts(lineItems: LineItem[]) {
  for (const lineItem of lineItems) {
    const originalPrice = lineItem.getPrice();
    applyDiscount(originalPrice);
  }
}
```

### Worst Offenders

| Generic Name | What to Ask | Better Alternative |
|--------------|-------------|-------------------|
| `data` | Data about what? | `userData`, `sensorReadings`, `configPayload` |
| `info` | Information about what? | `userInfo`, `connectionInfo`, `errorDetails` |
| `temp` | Temporary what? | `pendingChanges`, `intermediateSum`, `bufferContent` |
| `item` | Item from what collection? | `cartItem`, `menuOption`, `searchResult` |
| `result` | Result of what operation? | `queryResult`, `validationResult`, `calculatedTotal` |
| `value` | Value of what? | `inputValue`, `configValue`, `computedScore` |
| `list` | List of what? | `userList`, `errorMessages`, `availableOptions` |
| `obj` / `object` | Object representing what? | `userProfile`, `paymentRecord`, `configSettings` |
| `str` / `string` | String containing what? | `userName`, `errorMessage`, `formattedDate` |
| `num` / `number` | Number representing what? | `retryCount`, `totalPrice`, `userAge` |

### When NOT to Apply

- Truly generic utilities (e.g., `stringify(value)` in a serialization library)
- Short-lived variables in tiny scopes (3-5 lines max)
- Generic type parameters (`T`, `K`, `V` are conventional)
- Language-specific idioms (e.g., `_` for unused variables)

### Benefits

- Code reads like documentation
- No need to trace variable origins
- Bugs become obvious when wrong data flows through
- Refactoring is safer with distinct names
- Code reviews catch misuse immediately

---

## 6. Duplication Reduction (MEDIUM)

Extract helpers when code appears 3+ times and extraction improves clarity. Avoid single-use abstractions that obscure intent.

### 6.1 Apply the Rule of Three

Wait until code appears three times before extracting a helper. The first duplication might be coincidental. The second confirms a pattern exists. The third proves extraction is worthwhile. Extracting too early creates abstractions for patterns that never materialize, adding cognitive overhead without reducing maintenance burden.

**Incorrect (extracting after first duplication):**

```typescript
// Two similar validation calls - someone extracts immediately
function validateUser(user: User) {
  if (!user.email.includes('@')) throw new Error('Invalid email');
}

function validateContact(contact: Contact) {
  if (!contact.email.includes('@')) throw new Error('Invalid email');
}

// Over-engineered "solution" after seeing just 2 occurrences
function validateEmail(entity: { email: string }, entityName: string) {
  if (!entity.email.includes('@')) {
    throw new Error(`Invalid ${entityName} email`);
  }
}
// Now every caller needs to understand this abstraction
// And if requirements diverge, the abstraction becomes awkward
```

**Correct (wait for the third occurrence):**

```typescript
// First occurrence
function validateUser(user: User) {
  if (!user.email.includes('@')) throw new Error('Invalid email');
}

// Second occurrence - note it, don't extract yet
function validateContact(contact: Contact) {
  if (!contact.email.includes('@')) throw new Error('Invalid email');
}

// Third occurrence - NOW extract with confidence
function validateOrder(order: Order) {
  if (!order.customerEmail.includes('@')) throw new Error('Invalid email');
}

// After third occurrence, extract with full understanding of the pattern
function isValidEmail(email: string): boolean {
  return email.includes('@');
}
```

### When NOT to Apply

- Security-critical code (authentication, authorization) - extract immediately
- Complex algorithms where bugs are likely - extract on second occurrence
- When business logic dictates the pattern will recur (known requirements)

### Benefits

- Abstractions are based on real patterns, not speculation
- Fewer premature abstractions that need refactoring later
- Code readers encounter simpler, more concrete code
- Easier to understand what each piece of code actually does

### 6.2 Avoid Single-Use Helper Functions

Do not extract code into a helper function if it will only be called from one place. Single-use helpers fragment logic across multiple locations, forcing readers to jump between files or scroll to understand what should be a single coherent operation. The cure is worse than the disease - you trade local complexity for distributed complexity.

**Incorrect (single-use helper obscures logic):**

```typescript
// In userService.ts
async function createUser(data: UserInput): Promise<User> {
  const validated = await validateUserInput(data);
  const normalized = normalizeUserData(validated);
  const user = await saveUser(normalized);
  await sendWelcomeNotification(user);
  return user;
}

// In userHelpers.ts - only called once!
function normalizeUserData(data: ValidatedUserInput): NormalizedUser {
  return {
    email: data.email.toLowerCase().trim(),
    name: data.name.trim(),
    createdAt: new Date(),
  };
}
// Reader must now open another file to understand createUser
```

**Correct (inline single-use logic):**

```typescript
async function createUser(data: UserInput): Promise<User> {
  const validated = await validateUserInput(data);

  const normalized: NormalizedUser = {
    email: validated.email.toLowerCase().trim(),
    name: validated.name.trim(),
    createdAt: new Date(),
  };

  const user = await saveUser(normalized);
  await sendWelcomeNotification(user);
  return user;
}
// All logic visible in one place
```

### When Single-Use Helpers ARE Appropriate

- Function exceeds 50 lines and has clear logical sections
- Logic requires extensive comments that would benefit from a descriptive name
- Testing the helper in isolation provides significant value
- The helper encapsulates a complex algorithm that deserves its own tests

### Benefits

- Code flows linearly without jumping between locations
- Reduces file count and cognitive load
- Makes debugging easier - stack traces are shorter
- Faster code review - reviewers see complete logic in context

### 6.3 Extract Only When It Improves Clarity

Extraction should make code easier to understand, not just shorter. If the extracted function name doesn't communicate intent better than the original code, keep the code inline. A helper called `processData()` or `handleStuff()` forces readers to look inside anyway. The goal is comprehension, not line count reduction.

**Incorrect (extraction hides intent behind vague name):**

```typescript
async function checkout(cart: Cart): Promise<Order> {
  const order = await processCartData(cart);
  await finalizeOrder(order);
  return order;
}

// What does this do? Must read implementation
async function processCartData(cart: Cart): Promise<Order> {
  const items = cart.items.filter(item => item.quantity > 0);
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = subtotal * 0.08;
  return { items, subtotal, tax, total: subtotal + tax };
}
```

**Correct (inline code that speaks for itself):**

```typescript
async function checkout(cart: Cart): Promise<Order> {
  const items = cart.items.filter(item => item.quantity > 0);
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const tax = subtotal * 0.08;

  const order: Order = { items, subtotal, tax, total: subtotal + tax };
  await this.orderRepository.save(order);
  await this.emailService.sendConfirmation(order);

  return order;
}
// Business logic is immediately visible
```

### Signs That Extraction Improves Clarity

- The function name explains a "why" that code alone doesn't convey
- The function encapsulates a business rule that has a domain name
- Readers can understand the calling code without reading the helper
- The extracted logic is cohesive and represents one concept

### Signs That Extraction Hurts Clarity

- You struggle to name the function (vague names like `process`, `handle`, `do`)
- The function name is longer than the code it contains
- Readers still need to check the implementation to understand the caller
- The extraction groups unrelated operations

### Benefits

- Code reads like documentation of business logic
- Reduced navigation between files and functions
- Function names serve as accurate documentation
- New team members understand code faster

### 6.4 Prefer Duplication Over Premature Abstraction

Three similar lines of code are often better than a premature abstraction. The wrong abstraction creates coupling between unrelated concepts, making future changes ripple across the codebase. Duplication is cheap to fix later when you understand the true pattern; bad abstractions are expensive to unwind because other code depends on them.

**Incorrect (premature abstraction couples unrelated concepts):**

```typescript
// "Both format currency, let's make it generic!"
function formatValue(value: number, type: 'price' | 'salary' | 'discount'): string {
  const symbol = type === 'discount' ? '-$' : '$';
  const decimals = type === 'salary' ? 0 : 2;
  const prefix = type === 'price' ? '' : ' ';

  return `${prefix}${symbol}${value.toFixed(decimals)}`;
}

// Now price formatting changes require checking salary and discount logic
// And discount needs a negative sign but price doesn't
// The abstraction becomes a mess of special cases
```

**Correct (explicit duplication until patterns emerge):**

```typescript
function formatPrice(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function formatSalary(annual: number): string {
  return `$${annual.toLocaleString()}`;
}

function formatDiscount(cents: number): string {
  return `-$${(cents / 100).toFixed(2)}`;
}

// Each can evolve independently
// formatPrice might add currency symbols later
// formatSalary might add "per year" suffix
// formatDiscount might show percentage instead
```

### The Sandi Metz Rule

"Duplication is far cheaper than the wrong abstraction." If you're unsure whether code should be shared:

1. Duplicate it
2. Wait for the third occurrence
3. Look for the true underlying pattern
4. Then extract with confidence

### When Abstraction IS Appropriate

- Business rule that must be consistent (tax calculation, authentication)
- Algorithm that is complex and needs isolated testing
- Pattern that has appeared 3+ times with identical structure
- Domain concept with a clear name in the ubiquitous language

### Benefits

- Code changes are localized to one area
- New requirements don't break unrelated features
- Easier to understand - each module is self-contained
- Refactoring is straightforward when patterns emerge

### 6.5 Use Data-Driven Patterns Over Repetitive Conditionals

When you have repetitive if/else or switch statements that map inputs to outputs, replace them with data structures like maps, lookup tables, or configuration objects. Data-driven code is easier to extend (add a line, not a branch), easier to test (validate the data structure), and less prone to copy-paste errors.

**Incorrect (repetitive conditionals):**

```typescript
function getStatusColor(status: string): string {
  if (status === 'pending') {
    return '#FFA500';
  } else if (status === 'approved') {
    return '#00FF00';
  } else if (status === 'rejected') {
    return '#FF0000';
  } else if (status === 'cancelled') {
    return '#808080';
  } else if (status === 'processing') {
    return '#0000FF';
  } else if (status === 'completed') {
    return '#00AA00';
  } else {
    return '#000000';
  }
}
// Adding a new status = new branch + risk of typo
```

**Correct (data-driven lookup):**

```typescript
const STATUS_COLORS: Record<string, string> = {
  pending: '#FFA500',
  approved: '#00FF00',
  rejected: '#FF0000',
  cancelled: '#808080',
  processing: '#0000FF',
  completed: '#00AA00',
};

function getStatusColor(status: string): string {
  return STATUS_COLORS[status] ?? '#000000';
}
// Adding a new status = one line in the map
```

### When NOT to Use Data-Driven

- When branches have complex logic, not just value mapping
- When there are only 2-3 cases and they're unlikely to grow
- When the "data" would be as complex as the code it replaces

### Benefits

- Adding new cases is a configuration change, not code change
- Data can be loaded from external sources (database, config files)
- Easier to test - validate the data structure separately
- Business rules are visible at a glance in the data structure
- Reduces cyclomatic complexity significantly

---

## 7. Dead Code Elimination (MEDIUM)

Remove unused code, redundant comments, and obsolete patterns. Delete rather than comment out. Keep comments that explain "why" not "what".

### 7.1 Delete Unused Code Artifacts

Unused variables, functions, imports, and parameters are noise that obscures the real logic. They force readers to track dead references, bloat bundle sizes, and create phantom dependencies that complicate refactoring. Modern tooling catches unused code - delete it immediately rather than leaving it "just in case."

**Incorrect (unused artifacts throughout):**

```typescript
import { useState, useEffect, useCallback, useMemo } from 'react';
import { formatDate, parseDate, isValidDate } from './dateUtils';
import { API_URL, MAX_RETRIES, TIMEOUT } from './constants';

interface UserListProps {
  users: User[];
  onSelect: (user: User) => void;
  showAvatar: boolean;  // Never used in component
  maxItems: number;     // Never used in component
}

export function UserList({ users, onSelect, showAvatar, maxItems }: UserListProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);  // Never used
  const [error, setError] = useState<Error | null>(null);  // Never used

  const sortedUsers = useMemo(() => users, [users]);  // Memo does nothing

  const handleClick = useCallback((user: User) => {
    setSelectedId(user.id);
    onSelect(user);
  }, [onSelect]);

  const unusedHelper = (data: unknown) => {  // Never called
    return formatDate(data as Date);
  };

  return (
    <ul>
      {sortedUsers.map(user => (
        <li key={user.id} onClick={() => handleClick(user)}>
          {user.name}
        </li>
      ))}
    </ul>
  );
}
```

**Correct (only what's needed):**

```typescript
import { useState, useCallback } from 'react';

interface UserListProps {
  users: User[];
  onSelect: (user: User) => void;
}

export function UserList({ users, onSelect }: UserListProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const handleClick = useCallback((user: User) => {
    setSelectedId(user.id);
    onSelect(user);
  }, [onSelect]);

  return (
    <ul>
      {users.map(user => (
        <li key={user.id} onClick={() => handleClick(user)}>
          {user.name}
        </li>
      ))}
    </ul>
  );
}
```

### When NOT to Apply

- Interface compliance requires the parameter signature (use underscore prefix)
- Public API where removal would be a breaking change
- Parameters used only in debug/logging modes
- Imports used only in type annotations (may appear unused to some tools)

### Benefits

- 20-40% reduction in lines of code in cluttered files
- Faster code comprehension for new developers
- Smaller bundle sizes (tree-shaking works better)
- Clearer dependency graphs for refactoring tools
- Eliminates false positives in static analysis

### References

- ESLint: no-unused-vars, no-unused-imports
- TypeScript: noUnusedLocals, noUnusedParameters
- Python: F401 (unused import), F841 (unused variable)

### 7.2 Delete Code, Never Comment It Out

Commented-out code is visual noise that raises unanswerable questions: Is this a work in progress? A rollback option? An alternative approach? Code archaeology shows commented blocks are almost never uncommented - they just accumulate. Version control exists specifically to recover old code; use it.

**Incorrect (commented code preserved):**

```javascript
export async function fetchUserData(userId) {
  // const cachedUser = cache.get(userId);
  // if (cachedUser) {
  //   return cachedUser;
  // }

  const response = await api.get(`/users/${userId}`);

  // Old implementation - keeping just in case
  // const response = await fetch(`${API_URL}/users/${userId}`, {
  //   headers: { 'Authorization': `Bearer ${token}` },
  //   cache: 'no-store'
  // });
  // if (!response.ok) {
  //   throw new Error(`HTTP ${response.status}`);
  // }
  // const data = await response.json();

  // TODO: maybe add this back later?
  // cache.set(userId, response.data, TTL);

  return response.data;
}
```

**Correct (clean code, history in git):**

```javascript
export async function fetchUserData(userId) {
  const response = await api.get(`/users/${userId}`);
  return response.data;
}
```

### Recovery Workflow

When you need old code back:
1. `git log --oneline -20` - find the commit
2. `git show <commit>:path/to/file` - view the old version
3. `git checkout <commit> -- path/to/file` - restore if needed

### When NOT to Apply

- Active debugging session (delete before committing)
- Code review showing before/after for context (use diff view instead)
- Documentation explicitly showing what NOT to do

### Benefits

- Files are 10-30% shorter without commented code blocks
- Clear intent: every line of code has a purpose
- No confusion about what's active vs inactive
- git blame shows actual history, not comment archaeology
- Encourages proper use of version control

### 7.3 Remove Comments That State the Obvious

Comments that repeat what the code says add noise without value. They double the reading burden and inevitably drift out of sync with the code they describe. Well-named variables and functions are self-documenting; comments should add context the code cannot express.

**Incorrect (comments repeat the code):**

```typescript
// Import React
import React from 'react';

// User interface
interface User {
  id: string;      // The user's ID
  name: string;    // The user's name
  email: string;   // The user's email
  age: number;     // The user's age
}

// Function to get user by ID
function getUserById(id: string): User | null {
  // Find the user in the array
  const user = users.find(u => u.id === id);

  // If user is not found, return null
  if (!user) {
    return null;
  }

  // Return the user
  return user;
}

// Increment counter
counter++;

// Set loading to true
setLoading(true);

// Loop through items
for (const item of items) {
  // Process the item
  processItem(item);
}
```

**Correct (self-documenting code, no redundant comments):**

```typescript
import React from 'react';

interface User {
  id: string;
  name: string;
  email: string;
  age: number;
}

function getUserById(id: string): User | null {
  return users.find(u => u.id === id) ?? null;
}

counter++;
setLoading(true);

for (const item of items) {
  processItem(item);
}
```

### What Makes a Comment Obvious?

- Restates the identifier name: `// the user's name` for `userName`
- Describes the language construct: `// loop through items` for a for loop
- Explains standard operations: `// return the result`
- Documents trivial getters/setters with no logic

### When NOT to Apply

- Regex patterns that need explanation
- Complex algorithms that benefit from step descriptions
- Non-obvious magic numbers or business rules
- Workarounds for known bugs or platform quirks
- Public API documentation (JSDoc, docstrings)

### Benefits

- 30-50% fewer comment lines without information loss
- Comments that remain are actually valuable
- Reduces maintenance burden of keeping comments in sync
- Forces better naming instead of relying on comments
- Faster code scanning without visual noise

### 7.4 Remove Stale TODO/FIXME Comments

TODO and FIXME comments are promises that rarely get kept. They accumulate over months and years until codebases have hundreds of stale reminders that everyone ignores. Either convert TODOs to tracked issues with owners and deadlines, or delete them. If something matters, it belongs in your issue tracker.

**Incorrect (accumulated stale TODOs):**

```typescript
export class UserService {
  // TODO: add caching
  // FIXME: this is slow
  // TODO: refactor this whole class (2019-03-15)
  // HACK: temporary fix for login bug
  // XXX: revisit this later

  async getUser(id: string): Promise<User> {
    // TODO: handle the case where user doesn't exist
    // FIXME: should validate id format
    const user = await this.db.query(`SELECT * FROM users WHERE id = ?`, [id]);

    // TODO: add proper error handling
    // TODO: log this somewhere
    // NOTE: Bob said to fix this - not sure what he meant
    return user;
  }

  // TODO(john): finish implementing this
  // TODO: write tests
  async updateUser(id: string, data: Partial<User>): Promise<void> {
    // FIXME: SQL injection vulnerability!!!
    await this.db.query(`UPDATE users SET ${data} WHERE id = ${id}`);
  }
}
```

**Correct (clean code, issues in tracker):**

```typescript
export class UserService {
  async getUser(id: string): Promise<User | null> {
    const user = await this.db.query(`SELECT * FROM users WHERE id = ?`, [id]);
    return user ?? null;
  }

  async updateUser(id: string, data: Partial<User>): Promise<void> {
    // Security: parameterized query prevents SQL injection
    const setClauses = Object.keys(data).map(k => `${k} = ?`).join(', ');
    await this.db.query(
      `UPDATE users SET ${setClauses} WHERE id = ?`,
      [...Object.values(data), id]
    );
  }
}

// Issue tracker entries created:
// - PROJ-1234: Add Redis caching layer to UserService
// - PROJ-1235: Add input validation for user ID format
// - PROJ-1236: Implement proper error handling in data layer
```

### TODO Triage Process

When you find a TODO, decide:
1. **Fix it now** - If it takes < 5 minutes, just do it
2. **Create issue** - If it's real work, track it properly
3. **Delete it** - If it's vague, stale, or no longer relevant

### Signs a TODO is Stale

- Date older than 6 months
- Author no longer on team
- References completed work or old versions
- Vague ("make better", "fix this", "???")
- No one knows why it's there

### Benefits

- Issue tracker becomes single source of truth
- TODO count stays near zero (easy to spot new ones)
- Urgent FIXMEs don't get lost in noise
- Code review can focus on real issues
- New developers don't inherit archaeological debt

### References

- Most IDEs can extract TODOs to tasks: "TODO to Issue" extensions
- CI tools can fail builds on TODO count thresholds
- `grep -r "TODO\|FIXME" --include="*.ts" | wc -l` for auditing

### 7.5 Keep Comments That Explain Why, Not What

Code shows what happens; only comments can explain why. Keep comments that capture business decisions, workarounds, non-obvious constraints, and historical context. These comments prevent future developers from "fixing" intentional behavior or repeating mistakes that led to the current implementation.

**Incorrect (removing valuable context):**

```typescript
// Before removing comments:
function processPayment(amount: number): boolean {
  // Visa requires amounts in cents, not dollars
  const centAmount = Math.round(amount * 100);

  // Retry limit set by PCI compliance audit (see JIRA-4521)
  const maxRetries = 3;

  // Must sleep 100ms between retries - payment gateway rate limits
  // Discovered during Black Friday 2023 outage
  for (let i = 0; i < maxRetries; i++) {
    if (gateway.charge(centAmount)) return true;
    sleep(100);
  }
  return false;
}

// After overzealous cleanup - WRONG:
function processPayment(amount: number): boolean {
  const centAmount = Math.round(amount * 100);
  const maxRetries = 3;

  for (let i = 0; i < maxRetries; i++) {
    if (gateway.charge(centAmount)) return true;
    sleep(100);
  }
  return false;
}
// Future dev removes sleep(100) as "unnecessary" -> outage
// Future dev changes maxRetries to 10 -> compliance violation
```

**Correct (preserve why comments):**

```typescript
function processPayment(amount: number): boolean {
  // Visa requires amounts in cents, not dollars
  const centAmount = Math.round(amount * 100);

  // Retry limit set by PCI compliance audit (JIRA-4521)
  const maxRetries = 3;

  // 100ms delay required by payment gateway rate limits (Black Friday 2023 postmortem)
  for (let i = 0; i < maxRetries; i++) {
    if (gateway.charge(centAmount)) return true;
    sleep(100);
  }
  return false;
}
```

**Comments worth keeping:**

```python
# Business rule: orders over $10k require manual approval (legal requirement)
if order.total > 10000:
    order.status = "pending_review"

# HACK: Safari doesn't support this API before v15, polyfill only for Safari
# Remove after dropping Safari 14 support (EOL March 2024)
if is_safari and version < 15:
    load_polyfill()

# WARNING: DO NOT change sort order - downstream systems depend on this
# exact ordering for invoice reconciliation (see incident #892)
transactions.sort(key=lambda t: (t.date, t.id))

# Performance: using raw SQL because ORM generates N+1 queries here
# Benchmarked: 50ms vs 2.3s for 1000 records
cursor.execute(RAW_QUERY, params)

# Counterintuitive: we check for empty BEFORE validation because
# empty arrays are valid (user clearing their cart) but the validator
# rejects them. Business confirmed this behavior in Q3 product review.
if not items:
    return Success(empty_cart)
```

### Categories of Why Comments Worth Keeping

1. **Business rules**: Legal, compliance, contractual requirements
2. **Workarounds**: Browser bugs, library quirks, API limitations
3. **Performance**: Why a non-obvious approach was faster
4. **Historical**: Incidents, postmortems, decisions that led here
5. **Warnings**: Things that look wrong but are intentional

### Benefits

- Preserves institutional knowledge
- Prevents regression of intentional behavior
- Reduces "why is this here?" Slack messages
- Makes code archaeology faster during incidents
- Protects against well-meaning "cleanup" that breaks things

---

## 8. Language Idioms (LOW-MEDIUM)

Apply language-specific patterns that improve clarity: TypeScript strict types, Rust ownership, Python comprehensions, Go error handling.

### 8.1 Use Strict Types Over any (TypeScript)

Using `any` defeats TypeScript's purpose and hides bugs that would otherwise be caught at compile time. Prefer `unknown` with type narrowing when the type is truly uncertain—this forces explicit type checking before use, making your code both safer and more self-documenting.

**Incorrect (using any bypasses type checking):**

```typescript
function processData(data: any) {
  // No type safety - runtime errors possible
  return data.items.map((item: any) => item.name.toUpperCase());
}

function parseResponse(response: any): any {
  return JSON.parse(response.body);
}
```

**Correct (using unknown with narrowing):**

```typescript
interface DataWithItems {
  items: Array<{ name: string }>;
}

function isDataWithItems(data: unknown): data is DataWithItems {
  return (
    typeof data === 'object' &&
    data !== null &&
    'items' in data &&
    Array.isArray((data as DataWithItems).items)
  );
}

function processData(data: unknown): string[] {
  if (!isDataWithItems(data)) {
    throw new Error('Invalid data structure');
  }
  return data.items.map(item => item.name.toUpperCase());
}

interface ApiResponse {
  body: string;
}

function parseResponse(response: ApiResponse): unknown {
  return JSON.parse(response.body);
}
```

### When to Allow any

- Legacy code migration where full typing isn't feasible yet
- Third-party libraries without type definitions (prefer `@types/*` packages)
- Explicit `// eslint-disable-next-line @typescript-eslint/no-explicit-any` with justification

### Benefits

- Compiler catches type mismatches before runtime
- IDE autocomplete works correctly
- Refactoring becomes safer with full type coverage
- Self-documenting code through explicit type contracts

### 8.2 Use const Assertions and readonly for Immutability (TypeScript)

Const assertions (`as const`) and `readonly` modifiers signal intent and prevent accidental mutations. They also enable TypeScript to infer literal types instead of widened types, which improves type safety and enables better autocomplete.

**Incorrect (mutable by default, widened types):**

```typescript
// Type is string[], not readonly ["admin", "user", "guest"]
const ROLES = ["admin", "user", "guest"];

// Type is { status: string; code: number }, loses literal info
const ERROR_CODES = {
  NOT_FOUND: { status: "not_found", code: 404 },
  FORBIDDEN: { status: "forbidden", code: 403 },
};

// Can be accidentally mutated
function processItems(items: string[]) {
  items.push("extra"); // Mutates original array
  return items.sort();
}
```

**Correct (immutable with precise types):**

```typescript
// Type is readonly ["admin", "user", "guest"]
const ROLES = ["admin", "user", "guest"] as const;
type Role = typeof ROLES[number]; // "admin" | "user" | "guest"

// Type preserves literal values
const ERROR_CODES = {
  NOT_FOUND: { status: "not_found", code: 404 },
  FORBIDDEN: { status: "forbidden", code: 403 },
} as const;
type ErrorStatus = typeof ERROR_CODES[keyof typeof ERROR_CODES]["status"];

// Signals no mutation, creates new array
function processItems(items: readonly string[]): string[] {
  return [...items, "extra"].sort();
}
```

### When NOT to Use

- Arrays or objects that genuinely need mutation for performance
- Loop counters and accumulator variables
- Builder patterns that rely on mutation

### Benefits

- Literal type inference enables exhaustive switch checks
- `readonly` in function parameters documents non-mutation
- Catches accidental `.push()`, `.pop()`, assignment at compile time
- Enables deriving union types from const arrays/objects

### 8.3 Use ? for Error Propagation (Rust)

The `?` operator is Rust's idiomatic way to propagate errors up the call stack. It replaces verbose nested `match` statements with a concise syntax that makes the happy path obvious while still handling errors explicitly. This is central to Rust's philosophy of making error handling visible but not burdensome.

**Incorrect (nested match statements obscure logic):**

```rust
fn read_config(path: &str) -> Result<Config, ConfigError> {
    let file = match File::open(path) {
        Ok(f) => f,
        Err(e) => return Err(ConfigError::IoError(e)),
    };

    let mut contents = String::new();
    match file.read_to_string(&mut contents) {
        Ok(_) => {},
        Err(e) => return Err(ConfigError::IoError(e)),
    };

    match serde_json::from_str(&contents) {
        Ok(config) => Ok(config),
        Err(e) => Err(ConfigError::ParseError(e)),
    }
}
```

**Correct (? operator for clean propagation):**

```rust
fn read_config(path: &str) -> Result<Config, ConfigError> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    let config = serde_json::from_str(&contents)?;
    Ok(config)
}

// Even cleaner with method chaining
fn read_config_chained(path: &str) -> Result<Config, ConfigError> {
    let contents = std::fs::read_to_string(path)?;
    Ok(serde_json::from_str(&contents)?)
}
```

### When to Use match Instead

- When you need to handle specific error variants differently
- When you want to add context or transform the error
- When recovery is possible and you don't want to propagate

```rust
// match is appropriate here - different handling per error
fn connect_with_retry(addr: &str) -> Result<Connection, Error> {
    match TcpStream::connect(addr) {
        Ok(stream) => Ok(Connection::new(stream)),
        Err(e) if e.kind() == ErrorKind::ConnectionRefused => {
            thread::sleep(Duration::from_secs(1));
            connect_with_retry(addr) // Retry on refused
        }
        Err(e) => Err(e.into()), // Propagate other errors
    }
}
```

### Benefits

- Happy path is immediately visible
- Error propagation is explicit but concise
- Works with both `Result` and `Option` types
- Combines well with `From` trait for automatic error conversion

### 8.4 Use Iterator Chains When Clearer Than Loops (Rust)

Rust's iterator combinators (`map`, `filter`, `fold`, etc.) can express data transformations more declaratively than loops. However, they're not always clearer—complex chains with multiple closures or stateful operations often become harder to understand than equivalent loops. Choose based on readability, not style preference.

**Incorrect (forced iterator chain hurts clarity):**

```rust
// Too complex - hard to follow the logic
fn process_orders(orders: &[Order]) -> HashMap<CustomerId, Vec<ProcessedOrder>> {
    orders
        .iter()
        .filter(|o| o.status == Status::Pending)
        .filter_map(|o| {
            if let Some(customer) = get_customer(o.customer_id) {
                Some((customer, o))
            } else {
                log::warn!("Unknown customer: {}", o.customer_id);
                None
            }
        })
        .map(|(customer, order)| {
            let processed = process_single_order(order, &customer);
            (customer.id, processed)
        })
        .fold(HashMap::new(), |mut acc, (id, order)| {
            acc.entry(id).or_default().push(order);
            acc
        })
}
```

**Correct (loop is clearer for complex logic):**

```rust
fn process_orders(orders: &[Order]) -> HashMap<CustomerId, Vec<ProcessedOrder>> {
    let mut result: HashMap<CustomerId, Vec<ProcessedOrder>> = HashMap::new();

    for order in orders.iter().filter(|o| o.status == Status::Pending) {
        let Some(customer) = get_customer(order.customer_id) else {
            log::warn!("Unknown customer: {}", order.customer_id);
            continue;
        };

        let processed = process_single_order(order, &customer);
        result.entry(customer.id).or_default().push(processed);
    }

    result
}
```

**Correct (iterator chain for simple transforms):**

```rust
// Clear and concise - good use of iterators
fn get_active_user_emails(users: &[User]) -> Vec<String> {
    users
        .iter()
        .filter(|u| u.is_active)
        .map(|u| u.email.clone())
        .collect()
}

// Sum with filter - straightforward
fn total_revenue(orders: &[Order]) -> Decimal {
    orders
        .iter()
        .filter(|o| o.status == Status::Completed)
        .map(|o| o.total)
        .sum()
}
```

### Guidelines

| Use Iterators When | Use Loops When |
|-------------------|----------------|
| Simple filter/map/collect | Multiple related mutations |
| No side effects needed | Early returns with context |
| Each step is self-contained | Stateful iteration |
| 2-3 combinators max | Complex branching logic |

### Benefits of Knowing Both

- Iterator chains can be lazy and more memory-efficient
- Loops are easier to debug with breakpoints
- Mixing both (filter in iterator, logic in loop) often optimal

### 8.5 Use Comprehensions for Simple Transforms (Python)

Python comprehensions (list, dict, set, generator) are idiomatic for simple transformations and filtering. They're more concise and often faster than equivalent loops. However, complex comprehensions with multiple conditions or nested logic become unreadable—use regular loops instead.

**Incorrect (loop for simple transform):**

```python
# Verbose for a simple operation
result = []
for user in users:
    if user.is_active:
        result.append(user.email)

# Building dict inefficiently
lookup = {}
for item in items:
    lookup[item.id] = item.name
```

**Correct (comprehension for simple transform):**

```python
# Clear and Pythonic
result = [user.email for user in users if user.is_active]

# Dict comprehension
lookup = {item.id: item.name for item in items}

# Set comprehension for unique values
unique_categories = {product.category for product in products}

# Generator for memory efficiency with large data
total = sum(order.amount for order in orders if order.status == "completed")
```

**Incorrect (complex comprehension hurts readability):**

```python
# Too complex - multiple conditions and transformations
result = [
    transform_data(item.value)
    for category in categories
    for item in category.items
    if item.is_valid and item.value > threshold
    if not item.is_deleted
]
```

**Correct (loop for complex logic):**

```python
# Clear with explicit logic
result = []
for category in categories:
    for item in category.items:
        if not item.is_valid or item.is_deleted:
            continue
        if item.value <= threshold:
            continue
        result.append(transform_data(item.value))
```

### Guidelines

| Use Comprehensions | Use Loops |
|-------------------|-----------|
| Single filter + map | Multiple conditions |
| One level of nesting | Side effects needed |
| Fits on one line (~80 chars) | Complex transformations |
| Pure data transformation | Exception handling required |

### Walrus Operator in Comprehensions (Python 3.8+)

```python
# Avoid repeated computation
results = [y for x in data if (y := expensive_transform(x)) is not None]
```

### Benefits

- More readable for simple cases
- Often 10-30% faster than equivalent loops
- Generator expressions avoid building intermediate lists
- Clearly signals "this is a data transformation"

### 8.6 Handle Errors Immediately After the Call (Go)

Go's explicit error handling is a feature, not a burden. Always check errors immediately after a function call returns—don't defer error checks or accumulate them. This pattern makes control flow explicit and ensures errors are handled in context where you have the most information.

**Incorrect (deferred or accumulated error checking):**

```go
// Bad: errors accumulate, hard to know which failed
func processFiles(paths []string) error {
    var lastErr error

    for _, path := range paths {
        data, err := os.ReadFile(path)
        if err != nil {
            lastErr = err // Previous errors lost
        }

        result, err := process(data)
        if err != nil {
            lastErr = err
        }

        err = save(result)
        if err != nil {
            lastErr = err
        }
    }

    return lastErr
}

// Bad: ignoring error
func quickRead(path string) []byte {
    data, _ := os.ReadFile(path) // Silent failure
    return data
}
```

**Correct (handle immediately with context):**

```go
func processFiles(paths []string) error {
    for _, path := range paths {
        data, err := os.ReadFile(path)
        if err != nil {
            return fmt.Errorf("reading %s: %w", path, err)
        }

        result, err := process(data)
        if err != nil {
            return fmt.Errorf("processing %s: %w", path, err)
        }

        if err := save(result); err != nil {
            return fmt.Errorf("saving result for %s: %w", path, err)
        }
    }

    return nil
}

// When you need to continue despite errors, collect them explicitly
func processAllFiles(paths []string) error {
    var errs []error

    for _, path := range paths {
        if err := processFile(path); err != nil {
            errs = append(errs, fmt.Errorf("%s: %w", path, err))
            continue // Explicit decision to continue
        }
    }

    return errors.Join(errs...) // Go 1.20+
}
```

### Wrapping Errors for Context

```go
// Always add context when propagating
func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("load config: %w", err)
    }

    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("parse config %s: %w", path, err)
    }

    return &cfg, nil
}
```

### When Ignoring Errors is Acceptable

```go
// Explicitly document why it's safe to ignore
_ = writer.Close() // Best effort cleanup, already returning another error

// Or use a helper for intentional ignores
func must[T any](v T, err error) T {
    if err != nil {
        panic(err)
    }
    return v
}
```

### Benefits

- Errors handled with full context available
- Control flow is explicit and linear
- Error wrapping builds informative stack traces
- No hidden failures or silent data corruption

### 8.7 Prefer Language and Standard Library Builtins

Every language provides optimized, well-tested utilities for common operations. Manual implementations are almost always buggier, slower, and harder to maintain. Before writing utility code, check if the language or standard library already provides it.

**Incorrect (manual implementations):**

```typescript
// TypeScript: Manual array operations
function unique<T>(arr: T[]): T[] {
  const seen = new Set<T>();
  const result: T[] = [];
  for (const item of arr) {
    if (!seen.has(item)) {
      seen.add(item);
      result.push(item);
    }
  }
  return result;
}

function groupBy<T>(arr: T[], key: keyof T): Record<string, T[]> {
  const result: Record<string, T[]> = {};
  for (const item of arr) {
    const k = String(item[key]);
    if (!result[k]) result[k] = [];
    result[k].push(item);
  }
  return result;
}
```

**Correct (use builtins):**

```typescript
// TypeScript: Use Set and Object.groupBy (ES2024)
const uniqueItems = [...new Set(arr)];
const grouped = Object.groupBy(arr, item => item.category);
```

**Incorrect (Python manual operations):**

```python
# Python: Manual implementations
def flatten(nested_list):
    result = []
    for sublist in nested_list:
        for item in sublist:
            result.append(item)
    return result

def find_max_by_key(items, key_func):
    max_item = None
    max_val = float('-inf')
    for item in items:
        val = key_func(item)
        if val > max_val:
            max_val = val
            max_item = item
    return max_item
```

**Correct (Python stdlib):**

```python
# Python: Use itertools and builtins
from itertools import chain

flattened = list(chain.from_iterable(nested_list))
max_item = max(items, key=key_func)

# Other commonly overlooked builtins
from collections import Counter, defaultdict
from functools import lru_cache, reduce
from pathlib import Path  # Instead of os.path string manipulation
```

**Incorrect (Go manual operations):**

```go
// Go: Manual slice operations
func contains(slice []string, item string) bool {
    for _, s := range slice {
        if s == item {
            return true
        }
    }
    return false
}

func min(a, b int) int {
    if a < b {
        return a
    }
    return b
}
```

**Correct (Go stdlib and generics):**

```go
// Go 1.21+: Use slices and cmp packages
import (
    "slices"
    "cmp"
)

found := slices.Contains(slice, item)
minimum := min(a, b)  // builtin since Go 1.21
sorted := slices.SortedFunc(items, func(a, b Item) int {
    return cmp.Compare(a.Priority, b.Priority)
})
```

### Common Builtins to Know

| Operation | TypeScript | Python | Go | Rust |
|-----------|------------|--------|-----|------|
| Unique | `new Set()` | `set()` | `slices.Compact` | `.dedup()` |
| Sort | `.sort()` | `sorted()` | `slices.Sort` | `.sort()` |
| Find | `.find()` | `next(x for...)` | `slices.Index` | `.find()` |
| Group | `Object.groupBy` | `itertools.groupby` | manual/lo | `.group_by()` |
| Flatten | `.flat()` | `chain.from_iterable` | manual | `.flatten()` |

### Benefits

- Battle-tested implementations with edge cases handled
- Often optimized at the language/runtime level
- Familiar to other developers reading your code
- Reduces maintenance burden and potential bugs

---

## References

- [Refactoring Catalog](https://refactoring.com/catalog/)
- [Clean Code: A Handbook of Agile Software Craftsmanship](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Google Style Guides](https://google.github.io/styleguide/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [Effective Go](https://go.dev/doc/effective_go)
- [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/)

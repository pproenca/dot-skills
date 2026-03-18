# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Error Handling (err)

**Impact:** CRITICAL
**Description:** Every fallible operation must have descriptive .context() annotations. Errors cascade through the entire system; unclear errors waste debugging time and hide root causes.

## 2. Type Design (type)

**Impact:** CRITICAL
**Description:** Self-documenting types via enums, newtypes, and argument comments prevent entire classes of bugs at compile time and make callsites self-documenting.

## 3. Module Organization (mod)

**Impact:** HIGH
**Description:** Modules under 500 LoC with clean re-exports and sibling test files keep the codebase navigable and prevent merge conflicts in high-touch files.

## 4. Serde and Wire Format (serde)

**Impact:** HIGH
**Description:** Consistent wire format conventions (camelCase, Params/Response naming, aligned serde/ts annotations) prevent serialization bugs across the Rust/TypeScript boundary.

## 5. Async and Concurrency (async)

**Impact:** MEDIUM-HIGH
**Description:** Correct async patterns (Box::pin for stack management, channel selection, cancellation tokens) prevent stack overflows, deadlocks, and resource leaks.

## 6. Config System (cfg)

**Impact:** MEDIUM
**Description:** The config system has specific conventions (schema regeneration, feature flag lifecycle, Bazel lock updates) that must be followed to avoid CI failures.

## 7. TUI Conventions (tui)

**Impact:** MEDIUM
**Description:** Terminal UI code follows specific ratatui conventions (Stylize helpers, no hardcoded white, textwrap) and must be mirrored between tui and tui_app_server.

## 8. Build and CI (ci)

**Impact:** LOW-MEDIUM
**Description:** Formatting, linting, and build conventions (just fmt, clippy rules, inline format args) must be followed to pass CI checks.

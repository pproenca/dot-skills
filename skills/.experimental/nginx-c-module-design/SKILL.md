---
name: nginx-c-module-design
description: nginx C module directive design guidelines for creating admin-friendly configuration interfaces. This skill should be used when designing nginx module directives — deciding what to expose vs hardcode, naming conventions, scope placement, default values, variable design, and validation patterns. Triggers on tasks involving ngx_command_t design, directive naming, configuration API design, nginx module public interface, or directive deprecation.
---

# nginx.org C Module Directive Design Best Practices

Comprehensive directive design guide for nginx C module authors, focused on creating clear, consistent, and admin-friendly configuration interfaces. Contains 46 rules across 8 categories, prioritized by impact to guide decisions about what to expose, how to name it, and how to evolve it safely.

## When to Apply

Reference these guidelines when:
- Deciding which values to expose as directives vs hardcode
- Naming new directives and choosing argument types
- Selecting scope placement (http, server, location)
- Setting default values and validation behavior
- Designing nginx variables for runtime data
- Deprecating or renaming existing directives

## Companion Skills

This skill focuses on **design decisions** (the "what" and "why"). For implementation mechanics, see:
- **nginx-c-modules** — C implementation: memory pools, request lifecycle, config parsing, handlers, filters
- **nginx-c-perf** — Performance: buffers, connections, locks, caching, timeouts
- **nginx-c-debug** — Debugging: crash diagnosis, GDB, tracing, sanitizers

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Exposure Decisions | CRITICAL | `expose-` |
| 2 | Naming Conventions | CRITICAL | `naming-` |
| 3 | Directive Types | HIGH | `type-` |
| 4 | Scope Design | HIGH | `scope-` |
| 5 | Default Values | MEDIUM-HIGH | `default-` |
| 6 | Validation & Error Messages | MEDIUM | `valid-` |
| 7 | Variable Design | MEDIUM | `var-` |
| 8 | Evolution & Compatibility | LOW-MEDIUM | `compat-` |

## Quick Reference

### 1. Exposure Decisions (CRITICAL)

- [`expose-configurable-vs-hardcode`](references/expose-configurable-vs-hardcode.md) - Framework for Configurable vs Hardcoded Values
- [`expose-escape-hatch`](references/expose-escape-hatch.md) - Provide Escape Hatches for Hardcoded Defaults
- [`expose-feature-gate`](references/expose-feature-gate.md) - Use Feature Gates for Optional Behavior
- [`expose-too-many-directives`](references/expose-too-many-directives.md) - Avoid Over-Configuration
- [`expose-path-resource`](references/expose-path-resource.md) - Always Expose External Resource Paths
- [`expose-security-surface`](references/expose-security-surface.md) - Audit Security Implications of Every Exposed Directive
- [`expose-environment-dependent`](references/expose-environment-dependent.md) - Expose Values That Vary by Deployment Environment

### 2. Naming Conventions (CRITICAL)

- [`naming-module-prefix`](references/naming-module-prefix.md) - Use a Consistent Module Prefix for All Directives
- [`naming-sub-prefix-groups`](references/naming-sub-prefix-groups.md) - Group Related Directives with Sub-Prefixes
- [`naming-noun-over-verb`](references/naming-noun-over-verb.md) - Prefer Noun Phrases for Directive Names
- [`naming-no-abbreviations`](references/naming-no-abbreviations.md) - Avoid Custom Abbreviations in Directive Names
- [`naming-cross-module-consistency`](references/naming-cross-module-consistency.md) - Mirror Nginx Core Suffix Patterns for Analogous Directives
- [`naming-lowercase-underscore`](references/naming-lowercase-underscore.md) - Use Lowercase with Underscores Only

### 3. Directive Types (HIGH)

- [`type-flag-for-toggles`](references/type-flag-for-toggles.md) - Use NGX_CONF_FLAG for Binary Toggles
- [`type-enum-over-string`](references/type-enum-over-string.md) - Use Enum Slot for Known Value Sets
- [`type-time-size-units`](references/type-time-size-units.md) - Use Time and Size Slot Functions for Time and Size Values
- [`type-take-n-fixed-args`](references/type-take-n-fixed-args.md) - Use TAKE1/TAKE2/TAKE12 for Fixed Argument Counts
- [`type-one-more-lists`](references/type-one-more-lists.md) - Use 1MORE for Variable-Length Value Lists
- [`type-avoid-block`](references/type-avoid-block.md) - Avoid Block Directives for Features
- [`type-custom-handler-complex`](references/type-custom-handler-complex.md) - Use Custom Handlers for Complex Directive Parsing

### 4. Scope Design (HIGH)

- [`scope-default-three-levels`](references/scope-default-three-levels.md) - Default to http + server + location Scope
- [`scope-http-only-shared-resources`](references/scope-http-only-shared-resources.md) - Restrict Shared Resource Directives to http Level Only
- [`scope-server-connection-level`](references/scope-server-connection-level.md) - Use http + server Scope for Connection-Level Settings
- [`scope-avoid-if-context`](references/scope-avoid-if-context.md) - Do Not Support the if Context Unless Fully Tested
- [`scope-location-path-operations`](references/scope-location-path-operations.md) - Restrict Path-Routing Directives to Location Context

### 5. Default Values (MEDIUM-HIGH)

- [`default-zero-config-safe`](references/default-zero-config-safe.md) - Ensure Zero-Config Produces Safe Behavior
- [`default-performance-optin`](references/default-performance-optin.md) - Make Performance Features Opt-In
- [`default-safety-on`](references/default-safety-on.md) - Default Security Settings to Restrictive Values
- [`default-generous-timeouts`](references/default-generous-timeouts.md) - Default Timeouts to Generous Values
- [`default-zero-unlimited`](references/default-zero-unlimited.md) - Use Zero to Mean Unlimited or Disabled for Numeric Limits
- [`default-platform-aware-buffers`](references/default-platform-aware-buffers.md) - Use Platform-Aware Buffer Size Defaults

### 6. Validation & Error Messages (MEDIUM)

- [`valid-parse-time-check`](references/valid-parse-time-check.md) - Validate All Directive Values at Config Parse Time
- [`valid-show-invalid-value`](references/valid-show-invalid-value.md) - Include the Invalid Value in Error Messages
- [`valid-suggest-range`](references/valid-suggest-range.md) - Include Valid Range or Format in Error Messages
- [`valid-conflict-detection`](references/valid-conflict-detection.md) - Detect Conflicting Directives at Merge Time
- [`valid-actionable-guidance`](references/valid-actionable-guidance.md) - Provide Actionable Guidance in Error Messages

### 7. Variable Design (MEDIUM)

- [`var-runtime-data-only`](references/var-runtime-data-only.md) - Expose Variables for Per-Request Runtime Data Only
- [`var-naming-convention`](references/var-naming-convention.md) - Name Variables with Module Prefix and Descriptive Suffix
- [`var-dynamic-prefix`](references/var-dynamic-prefix.md) - Use Dynamic Prefix Variables for Key-Value Data
- [`var-lazy-evaluation`](references/var-lazy-evaluation.md) - Leverage Lazy Evaluation for Expensive Variables
- [`var-in-directive-values`](references/var-in-directive-values.md) - Support Variables in Directive Values Only When Per-Request Variation Is Needed
- [`var-read-only-diagnostics`](references/var-read-only-diagnostics.md) - Expose Read-Only Diagnostic Variables for Observability

### 8. Evolution & Compatibility (LOW-MEDIUM)

- [`compat-deprecation-warning`](references/compat-deprecation-warning.md) - Log Warnings for Deprecated Directives Before Removal
- [`compat-alias-old-directive`](references/compat-alias-old-directive.md) - Keep Old Directive Name as an Alias
- [`compat-multi-version-window`](references/compat-multi-version-window.md) - Maintain a Multi-Version Deprecation Window
- [`compat-document-migration`](references/compat-document-migration.md) - Document Migration Path in Both Old and New Directive Documentation

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |

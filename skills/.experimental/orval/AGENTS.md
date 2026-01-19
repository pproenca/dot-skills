# Orval OpenAPI

**Version 0.1.0**  
Orval Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for Orval OpenAPI TypeScript client generation, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (OpenAPI spec quality, configuration architecture) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated configuration and code generation.

---

## Table of Contents

1. [OpenAPI Specification Quality](references/_sections.md#1-openapi-specification-quality) — **CRITICAL**
   - 1.1 [Define All Response Types Explicitly](references/spec-response-types.md) — CRITICAL (prevents unknown/any types in generated code)
   - 1.2 [Define Reusable Schemas in Components](references/spec-schemas-reusable.md) — CRITICAL (reduces generated code by 50-80%, enables type reuse)
   - 1.3 [Mark Required Fields Explicitly](references/spec-required-fields.md) — CRITICAL (prevents optional chaining everywhere, improves type narrowing)
   - 1.4 [Organize Operations with Tags](references/spec-tags-organization.md) — CRITICAL (enables tags-split mode, improves code organization)
   - 1.5 [Use Unique and Descriptive operationIds](references/spec-operationid-unique.md) — CRITICAL (prevents duplicate function names and import collisions)
2. [Configuration Architecture](references/_sections.md#2-configuration-architecture) — **CRITICAL**
   - 2.1 [Choose Output Mode Based on API Size](references/orvalcfg-mode-selection.md) — CRITICAL (2-5× bundle size difference, affects tree-shaking)
   - 2.2 [Configure Base URL Properly](references/orvalcfg-baseurl-setup.md) — CRITICAL (prevents 404 errors in production, enables environment switching)
   - 2.3 [Enable Automatic Code Formatting](references/orvalcfg-prettier-format.md) — HIGH (ensures consistent code style, prevents lint errors)
   - 2.4 [Select Client Based on Framework Requirements](references/orvalcfg-client-selection.md) — CRITICAL (2-5× bundle size difference between client options)
   - 2.5 [Separate Schemas into Dedicated Directory](references/orvalcfg-separate-schemas.md) — CRITICAL (enables clean imports, prevents circular dependencies)
   - 2.6 [Validate OpenAPI Spec Before Generation](references/orvalcfg-input-validation.md) — CRITICAL (prevents silent failures and incorrect type generation)
3. [Output Structure & Organization](references/_sections.md#3-output-structure-&-organization) — **HIGH**
   - 3.1 [Configure Consistent Naming Conventions](references/output-naming-convention.md) — HIGH (prevents casing mismatches, improves code consistency)
   - 3.2 [Enable Clean Mode for Consistent Regeneration](references/output-clean-target.md) — HIGH (prevents stale files, ensures deterministic output)
   - 3.3 [Enable Headers in Generated Functions](references/output-headers-enabled.md) — HIGH (enables custom headers per request without mutator hacks)
   - 3.4 [Generate Index Files for Clean Imports](references/output-index-files.md) — HIGH (simplifies imports, enables barrel exports)
   - 3.5 [Use Distinct File Extensions for Generated Code](references/output-file-extension.md) — HIGH (prevents accidental edits, enables gitignore patterns)
4. [Custom Client & Mutators](references/_sections.md#4-custom-client-&-mutators) — **HIGH**
   - 4.1 [Export Body Type Wrapper for Request Transformation](references/mutator-body-wrapper.md) — HIGH (enables consistent request body preprocessing)
   - 4.2 [Export Custom Error Types from Mutator](references/mutator-error-types.md) — HIGH (enables type-safe error handling in hooks)
   - 4.3 [Handle Token Refresh in Mutator](references/mutator-token-refresh.md) — HIGH (prevents 401 cascades, automatic retry on token expiry)
   - 4.4 [Use Custom Mutator for HTTP Client Configuration](references/mutator-custom-instance.md) — HIGH (O(1) auth config vs O(n) scattered header additions across components)
   - 4.5 [Use Fetch Mutator for Smaller Bundle Size](references/mutator-fetch-client.md) — MEDIUM-HIGH (eliminates axios dependency, 10-20KB bundle savings)
   - 4.6 [Use Interceptors for Cross-Cutting Concerns](references/mutator-interceptors.md) — HIGH (O(1) interceptor config vs O(n) duplicated logging across API calls)
5. [Query Library Integration](references/_sections.md#5-query-library-integration) — **MEDIUM-HIGH**
   - 5.1 [Configure Default Query Options Globally](references/oquery-hook-options.md) — MEDIUM-HIGH (reduces boilerplate, ensures consistent caching behavior)
   - 5.2 [Enable Infinite Queries for Paginated Endpoints](references/oquery-infinite-queries.md) — MEDIUM-HIGH (eliminates manual page state management and data accumulation logic)
   - 5.3 [Enable Suspense Mode for Streaming UX](references/oquery-suspense-support.md) — MEDIUM-HIGH (enables React Suspense integration for better loading states)
   - 5.4 [Export Query Keys for Cache Invalidation](references/oquery-key-export.md) — MEDIUM-HIGH (enables proper cache invalidation patterns)
   - 5.5 [Pass AbortSignal for Request Cancellation](references/oquery-signal-cancellation.md) — MEDIUM-HIGH (prevents memory leaks and wasted bandwidth on unmount)
   - 5.6 [Use Generated Mutation Options Types](references/oquery-mutation-callbacks.md) — MEDIUM (enables type-safe onSuccess/onError callbacks)
6. [Type Safety & Validation](references/_sections.md#6-type-safety-&-validation) — **MEDIUM**
   - 6.1 [Enable useBigInt for Large Integer Support](references/types-bigint-support.md) — MEDIUM (prevents precision loss for int64 values)
   - 6.2 [Enable useDates for Date Type Generation](references/types-use-dates.md) — MEDIUM (enables Date methods (getFullYear, toISOString) without manual parsing)
   - 6.3 [Enable Zod Strict Mode for Safer Validation](references/types-zod-strict.md) — MEDIUM (catches unexpected fields, prevents data leakage)
   - 6.4 [Generate Zod Schemas for Runtime Validation](references/types-zod-validation.md) — MEDIUM (catches 100% of API contract violations at runtime vs silent failures)
   - 6.5 [Use Zod Coercion for Type Transformations](references/types-zod-coerce.md) — MEDIUM (automatic string-to-Date, string-to-number conversions)
7. [Mock Generation & Testing](references/_sections.md#7-mock-generation-&-testing) — **MEDIUM**
   - 7.1 [Configure Mock Response Delays](references/mock-delay-config.md) — MEDIUM (exposes loading state bugs hidden by 0ms response times)
   - 7.2 [Generate Mock Index Files for Easy Setup](references/mock-index-files.md) — MEDIUM (single import for all mock handlers)
   - 7.3 [Generate Mocks for All HTTP Status Codes](references/mock-http-status.md) — MEDIUM (enables error state testing)
   - 7.4 [Generate MSW Handlers for Testing](references/mock-msw-generation.md) — MEDIUM (enables frontend development without backend dependencies)
   - 7.5 [Use OpenAPI Examples for Realistic Mocks](references/mock-use-examples.md) — MEDIUM (100% deterministic mock data vs random Faker values)
8. [Advanced Patterns](references/_sections.md#8-advanced-patterns) — **LOW**
   - 8.1 [Configure Form Data Serialization](references/adv-form-data-handling.md) — LOW (prevents 400 errors from incorrect array serialization in form uploads)
   - 8.2 [Override Settings per Operation](references/adv-operation-override.md) — LOW (O(1) config changes per endpoint vs O(n) global modifications)
   - 8.3 [Use Input Transformer for Spec Preprocessing](references/adv-input-transformer.md) — LOW (fixes spec issues at source, prevents N downstream errors)
   - 8.4 [Use Output Transformer for Generated Code Modification](references/adv-output-transformer.md) — LOW (O(1) transformer config vs O(n) manual modifications across generated functions)

---

## References

1. [https://orval.dev](https://orval.dev)
2. [https://github.com/orval-labs/orval](https://github.com/orval-labs/orval)
3. [https://tanstack.com/query/latest](https://tanstack.com/query/latest)
4. [https://mswjs.io](https://mswjs.io)
5. [https://axios-http.com](https://axios-http.com)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
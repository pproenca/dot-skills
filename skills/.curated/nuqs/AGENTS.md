# nuqs

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for nuqs (type-safe URL query state management) in Next.js applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (parser configuration, adapter setup) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Parser Configuration](references/_sections.md#1-parser-configuration) — **CRITICAL**
   - 1.1 [Choose Correct Array Parser Format](references/parser-array-format.md) — CRITICAL (prevents API integration failures from wrong URL format)
   - 1.2 [Select Appropriate Date Parser](references/parser-date-format.md) — CRITICAL (prevents timezone bugs and parsing failures)
   - 1.3 [Use Enum Parsers for Constrained Values](references/parser-enum-validation.md) — CRITICAL (prevents invalid state from URL manipulation)
   - 1.4 [Use parseAsHex for Color Values](references/parser-hex-colors.md) — MEDIUM (50% shorter URLs for color parameters)
   - 1.5 [Use parseAsIndex for 1-Based URL Display](references/parser-index-offset.md) — HIGH (eliminates off-by-one errors between URL and code)
   - 1.6 [Use Typed Parsers for Non-String Values](references/parser-use-typed-parsers.md) — CRITICAL (prevents runtime type errors and hydration mismatches)
   - 1.7 [Use withDefault for Non-Nullable State](references/parser-with-default.md) — CRITICAL (eliminates null checks throughout component tree)
   - 1.8 [Validate JSON Parser Input](references/parser-json-validation.md) — CRITICAL (prevents runtime crashes from malformed URL data)
2. [Adapter & Setup](references/_sections.md#2-adapter-&-setup) — **CRITICAL**
   - 2.1 [Add 'use client' Directive for Hooks](references/setup-use-client.md) — CRITICAL (prevents build-breaking hook errors in RSC)
   - 2.2 [Define Shared Parsers in Dedicated File](references/setup-shared-parsers.md) — HIGH (prevents parser mismatch bugs between components)
   - 2.3 [Ensure Compatible Next.js Version](references/setup-nextjs-version.md) — CRITICAL (prevents cryptic runtime errors from version mismatch)
   - 2.4 [Import Server Utilities from nuqs/server](references/setup-import-server.md) — CRITICAL (prevents RSC-to-client boundary contamination errors)
   - 2.5 [Wrap App with NuqsAdapter](references/setup-nuqs-adapter.md) — CRITICAL (prevents 100% of hook failures from missing provider)
3. [State Management](references/_sections.md#3-state-management) — **HIGH**
   - 3.1 [Avoid Derived State from URL Parameters](references/state-avoid-derived.md) — HIGH (prevents sync bugs and unnecessary re-renders)
   - 3.2 [Clear URL Parameters with null](references/state-clear-with-null.md) — HIGH (reduces URL clutter by removing unnecessary parameters)
   - 3.3 [Handle Controlled Input Value Properly](references/state-controlled-inputs.md) — HIGH (prevents uncontrolled to controlled warnings)
   - 3.4 [Use Functional Updates for State Derived from Previous Value](references/state-functional-updates.md) — HIGH (prevents stale closure bugs and race conditions)
   - 3.5 [Use Setter Return Value for URL Access](references/state-setter-return.md) — MEDIUM (enables accurate URL tracking for analytics/sharing)
   - 3.6 [Use useQueryStates for Related Parameters](references/state-use-query-states.md) — HIGH (atomic updates prevent intermediate invalid states)
   - 3.7 [Use withOptions for Parser-Level Configuration](references/state-options-inheritance.md) — MEDIUM (reduces boilerplate and ensures consistent behavior)
4. [Server Integration](references/_sections.md#4-server-integration) — **HIGH**
   - 4.1 [Call parse() Before get() in Server Components](references/server-parse-before-get.md) — HIGH (prevents undefined values and runtime errors)
   - 4.2 [Handle Async searchParams in Next.js 15+](references/server-next15-async.md) — HIGH (prevents build errors in Next.js 15 with async props)
   - 4.3 [Integrate useTransition for Loading States](references/server-use-transition.md) — HIGH (100% visibility into server fetch pending state)
   - 4.4 [Share Parsers Between Client and Server](references/server-share-parsers.md) — HIGH (prevents client/server hydration mismatches)
   - 4.5 [Use createSearchParamsCache for Server Components](references/server-search-params-cache.md) — HIGH (eliminates prop drilling across N component levels)
   - 4.6 [Use shallow:false to Trigger Server Re-renders](references/server-shallow-false.md) — HIGH (enables server-side data refetching on URL change)
5. [Performance Optimization](references/_sections.md#5-performance-optimization) — **MEDIUM**
   - 5.1 [Debounce Search Input Before URL Update](references/perf-debounce-search.md) — MEDIUM (reduces server requests during typing)
   - 5.2 [Memoize Components Using URL State](references/perf-avoid-rerender.md) — MEDIUM (prevents unnecessary re-renders on URL changes)
   - 5.3 [Throttle Rapid URL Updates](references/perf-throttle-updates.md) — MEDIUM (prevents browser history API rate limiting)
   - 5.4 [Use clearOnDefault for Clean URLs](references/perf-clear-on-default.md) — MEDIUM (reduces URL length by 20-50% for default values)
   - 5.5 [Use createSerializer for Link URLs](references/perf-serialize-utility.md) — MEDIUM (enables SSR-compatible URL generation without hooks)
6. [History & Navigation](references/_sections.md#6-history-&-navigation) — **MEDIUM**
   - 6.1 [Control Scroll Behavior on URL Changes](references/history-scroll-behavior.md) — MEDIUM (prevents jarring scroll jumps on state changes)
   - 6.2 [Handle Browser Back/Forward Navigation](references/history-back-sync.md) — MEDIUM (prevents stale UI after browser navigation)
   - 6.3 [Use history:push for Navigation-Like State](references/history-push-navigation.md) — MEDIUM (enables back button for state navigation)
   - 6.4 [Use history:replace for Ephemeral State](references/history-replace-ephemeral.md) — MEDIUM (prevents history pollution from frequent updates)
7. [Debugging & Testing](references/_sections.md#7-debugging-&-testing) — **LOW-MEDIUM**
   - 7.1 [Diagnose Common nuqs Errors](references/debug-common-errors.md) — LOW-MEDIUM (reduces debugging time from hours to minutes)
   - 7.2 [Enable Debug Logging for Troubleshooting](references/debug-enable-logging.md) — LOW-MEDIUM (reduces debugging time by 5-10×)
   - 7.3 [Test Components with URL State](references/debug-testing.md) — LOW-MEDIUM (enables reliable CI/CD testing of nuqs components)
8. [Advanced Patterns](references/_sections.md#8-advanced-patterns) — **LOW**
   - 8.1 [Create Custom Parsers for Complex Types](references/advanced-custom-parsers.md) — LOW (prevents runtime errors from string coercion)
   - 8.2 [Implement eq Function for Object Parsers](references/advanced-eq-function.md) — LOW (prevents unnecessary URL updates for equivalent objects)
   - 8.3 [Use Framework-Specific Adapters](references/advanced-framework-adapters.md) — LOW (prevents URL sync failures in non-Next.js apps)
   - 8.4 [Use urlKeys for Shorter URLs](references/advanced-url-keys.md) — LOW (reduces URL length by 50-70% for verbose params)

---

## References

1. [https://nuqs.dev](https://nuqs.dev)
2. [https://github.com/47ng/nuqs](https://github.com/47ng/nuqs)
3. [https://nextjs.org/docs](https://nextjs.org/docs)
4. [https://react.dev](https://react.dev)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
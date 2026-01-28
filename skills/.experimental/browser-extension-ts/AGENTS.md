# Browser Extension TypeScript

**Version 1.0.0**  
Extracted from Dark Reader  
2026-01-28

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

TypeScript patterns and best practices for building cross-browser extensions (Chrome, Firefox, Edge). Covers Manifest V3 service workers, content script architecture, cross-context messaging, error handling for extension edge cases, and testing strategies. Patterns extracted from Dark Reader, a popular open-source browser extension.

---

## Table of Contents

1. [Manifest V3](references/_sections.md#1-manifest-v3) — **CRITICAL**
   - 1.1 [Alarms for scheduled tasks](references/mv-alarms.md) — CRITICAL (setTimeout/setInterval don't survive service worker termination)
   - 1.2 [Cross-browser compatibility](references/mv-cross-browser.md) — HIGH (Extensions should work on Chrome, Firefox, and Edge with minimal changes)
   - 1.3 [Scripting API for dynamic injection](references/mv-scripting-api.md) — CRITICAL (MV3 replaces tabs.executeScript with the new scripting API)
   - 1.4 [Service worker architecture](references/mv-service-worker.md) — CRITICAL (MV3 replaces persistent background pages with ephemeral service workers)
   - 1.5 [Session storage for temporary state](references/mv-storage-session.md) — HIGH (chrome.storage.session provides in-memory storage that survives service worker restarts)
2. [Code Style](references/_sections.md#2-code-style) — **HIGH**
   - 2.1 [Boolean variable naming](references/style-boolean-naming.md) — MEDIUM (Boolean prefixes make code more readable and self-documenting)
   - 2.2 [Cache variable naming](references/style-cache-naming.md) — LOW (Clear identification of caching data structures)
   - 2.3 [Constants and configuration values](references/style-constants.md) — MEDIUM (Clear distinction between mutable variables and immutable constants)
   - 2.4 [Feature-based directory structure](references/style-directory-structure.md) — HIGH (Enables clear separation of browser extension contexts and improves code navigation)
   - 2.5 [Function naming conventions](references/style-function-naming.md) — HIGH (Predictable function names improve code readability and API discoverability)
   - 2.6 [Index files as entry points](references/style-index-entry-points.md) — MEDIUM (Clear public API boundaries for each feature module)
   - 2.7 [Kebab-case file naming](references/style-file-naming.md) — HIGH (Consistent file naming across all operating systems and browsers)
   - 2.8 [Message type enum naming](references/style-message-enums.md) — HIGH (Directional message naming prevents confusion in cross-context communication)
   - 2.9 [Type and interface naming](references/style-type-naming.md) — HIGH (Consistent type naming improves TypeScript code readability)
   - 2.10 [Type-only imports](references/style-import-type.md) — MEDIUM (Type-only imports are removed at compile time, reducing bundle size)
3. [Component Patterns](references/_sections.md#3-component-patterns) — **HIGH**
   - 3.1 [Content script structure](references/comp-content-script-structure.md) — HIGH (Proper content script organization ensures safe DOM manipulation and cleanup)
   - 3.2 [CSS class patterns](references/comp-css-class-patterns.md) — MEDIUM (BEM-inspired naming creates predictable, maintainable CSS)
   - 3.3 [Extension adapter interface pattern](references/comp-adapter-interface.md) — HIGH (Typed interfaces decouple UI from background implementation details)
   - 3.4 [Manager class pattern for background](references/comp-manager-class.md) — HIGH (Singleton managers provide clear initialization and API for background script services)
   - 3.5 [Type guard functions](references/comp-type-guards.md) — MEDIUM (Type guards enable TypeScript to narrow types based on runtime checks)
   - 3.6 [UI component patterns](references/comp-ui-components.md) — HIGH (Consistent component structure improves maintainability of extension UI)
4. [Error Handling](references/_sections.md#4-error-handling) — **HIGH**
   - 4.1 [Early return for guard clauses](references/err-early-return.md) — MEDIUM (Guard clauses reduce nesting and make code flow clearer)
   - 4.2 [Extension context invalidation handling](references/err-context-invalidation.md) — HIGH (Content scripts survive extension updates but lose connection to background)
   - 4.3 [Null coalescing and optional chaining](references/err-null-coalescing.md) — MEDIUM (Safe property access prevents runtime errors from undefined values)
   - 4.4 [PromiseBarrier for async coordination](references/err-promise-barrier.md) — MEDIUM (Coordinates initialization sequences without race conditions)
   - 4.5 [Storage operation error handling](references/err-storage-operations.md) — HIGH (Storage APIs can fail silently; proper handling prevents extension crashes)
   - 4.6 [URL parsing with fallback](references/err-url-parsing.md) — HIGH (Invalid URLs are common in browser extensions; always handle parse failures)
   - 4.7 [Validation returns errors array](references/err-validation-pattern.md) — HIGH (Non-throwing validation enables partial recovery and better error reporting)
5. [Testing](references/_sections.md#5-testing) — **MEDIUM**
   - 5.1 [Browser API mocking](references/test-browser-api-mocking.md) — MEDIUM (Mocking chrome/browser APIs enables unit testing extension logic)
   - 5.2 [Test file organization](references/test-organization.md) — MEDIUM (Consistent test structure improves maintainability and test discovery)
   - 5.3 [Testing validation functions](references/test-validation-functions.md) — MEDIUM (Thorough validation testing prevents bad data from corrupting extension state)

---

## References

1. [https://github.com/darkreader/darkreader](https://github.com/darkreader/darkreader)
2. [https://developer.chrome.com/docs/extensions/mv3/](https://developer.chrome.com/docs/extensions/mv3/)
3. [https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
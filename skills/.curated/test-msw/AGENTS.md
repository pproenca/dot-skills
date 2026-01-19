# MSW (Mock Service Worker)

**Version 1.0.0**  
mswjs  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive API mocking guide for MSW v2 applications, designed for AI agents and LLMs. Contains 45+ rules across 8 categories, prioritized by impact from critical (setup, handler architecture) to incremental (debugging). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Setup & Initialization](references/_sections.md#1-setup-&-initialization) — **CRITICAL**
   - 1.1 [Commit Worker Script to Version Control](references/setup-worker-script-commit.md) — CRITICAL (Eliminates setup friction for team members; prevents CI failures)
   - 1.2 [Configure Server Lifecycle in Test Setup](references/setup-lifecycle-hooks.md) — CRITICAL (Prevents handler leakage and ensures test isolation; eliminates flaky tests)
   - 1.3 [Configure TypeScript for MSW v2](references/setup-typescript-config.md) — CRITICAL (TypeScript 4.7+ required; incorrect config causes type errors)
   - 1.4 [Configure Unhandled Request Behavior](references/setup-unhandled-requests.md) — CRITICAL (Catches missing handlers immediately; prevents silent test failures)
   - 1.5 [Require Node.js 18+ for MSW v2](references/setup-node-version.md) — CRITICAL (MSW v2 requires Node 18+; older versions cause complete failure)
   - 1.6 [Use Correct Entrypoint for Node.js](references/setup-server-node-entrypoint.md) — CRITICAL (Zero mocking if wrong entrypoint; 100% test failures)
2. [Handler Architecture](references/_sections.md#2-handler-architecture) — **CRITICAL**
   - 2.1 [Define Happy Path Handlers as Baseline](references/handler-happy-path-first.md) — CRITICAL (Establishes reliable baseline; enables clean runtime overrides)
   - 2.2 [Destructure Resolver Arguments Correctly](references/handler-resolver-argument.md) — CRITICAL (Wrong destructuring pattern causes undefined values; silent failures)
   - 2.3 [Explicitly Parse Request Bodies](references/handler-request-body-parsing.md) — CRITICAL (v2 no longer auto-parses bodies; missing parsing returns undefined)
   - 2.4 [Extract Shared Response Logic into Resolvers](references/handler-shared-resolvers.md) — CRITICAL (Eliminates duplication; ensures consistent mock responses across tests)
   - 2.5 [Group Handlers by Domain](references/handler-domain-grouping.md) — CRITICAL (Reduces maintenance overhead; scales to large APIs without N×M complexity)
   - 2.6 [Share Handlers Across Environments](references/handler-reusability-environments.md) — CRITICAL (Single source of truth; eliminates mock drift between dev/test)
   - 2.7 [Use Absolute URLs in Handlers](references/handler-absolute-urls.md) — CRITICAL (Prevents URL mismatch failures; required for Node.js environments)
   - 2.8 [Use MSW v2 Response Syntax](references/handler-v2-response-syntax.md) — CRITICAL (v1 syntax breaks in v2; causes complete handler failure)
3. [Test Integration](references/_sections.md#3-test-integration) — **HIGH**
   - 3.1 [Avoid Direct Request Assertions](references/test-avoid-request-assertions.md) — HIGH (Tests implementation details; breaks on refactors that preserve behavior)
   - 3.2 [Clear Request Library Caches Between Tests](references/test-clear-request-cache.md) — HIGH (Prevents stale cached responses; ensures fresh mock data per test)
   - 3.3 [Configure Fake Timers to Preserve queueMicrotask](references/test-fake-timers-config.md) — HIGH (Prevents request body parsing from hanging indefinitely)
   - 3.4 [Reset Handlers After Each Test](references/test-reset-handlers.md) — HIGH (Prevents handler pollution; eliminates test order dependencies)
   - 3.5 [Use Async Testing Utilities for Mock Responses](references/test-async-utilities.md) — HIGH (Prevents race conditions; ensures responses arrive before assertions)
   - 3.6 [Use Correct JSDOM Environment for Jest](references/test-jsdom-environment.md) — HIGH (Prevents Node.js global conflicts; ensures proper fetch availability)
   - 3.7 [Use server.boundary() for Concurrent Tests](references/test-concurrent-boundary.md) — HIGH (Enables parallel test execution; prevents cross-test handler pollution)
4. [Response Patterns](references/_sections.md#4-response-patterns) — **HIGH**
   - 4.1 [Add Realistic Response Delays](references/response-delay-realistic.md) — HIGH (Reveals race conditions; tests loading states; catches timing bugs)
   - 4.2 [Mock Streaming Responses with ReadableStream](references/response-streaming.md) — HIGH (Tests streaming UIs, chat interfaces, and progressive loading)
   - 4.3 [Set Response Headers Correctly](references/response-custom-headers.md) — HIGH (Ensures CORS, caching, and authentication headers work as expected)
   - 4.4 [Simulate Error Responses Correctly](references/response-error-simulation.md) — HIGH (Validates error handling; catches missing error states in UI)
   - 4.5 [Use HttpResponse Static Methods](references/response-http-response-helpers.md) — HIGH (Automatic Content-Type headers; cleaner syntax; type safety)
   - 4.6 [Use One-Time Handlers for Sequential Scenarios](references/response-one-time-handlers.md) — HIGH (Models realistic multi-step flows; tests retry logic correctly)
5. [Request Matching](references/_sections.md#5-request-matching) — **MEDIUM-HIGH**
   - 5.1 [Access Query Parameters from Request URL](references/match-query-params.md) — MEDIUM-HIGH (Enables filtering, pagination, and search mocking)
   - 5.2 [Match HTTP Methods Explicitly](references/match-http-methods.md) — MEDIUM-HIGH (Prevents cross-method interference; models REST APIs correctly)
   - 5.3 [Order Handlers from Specific to General](references/match-handler-order.md) — MEDIUM-HIGH (Prevents general handlers from shadowing specific ones)
   - 5.4 [Use Custom Predicates for Complex Matching](references/match-custom-predicate.md) — MEDIUM-HIGH (Enables header-based, body-based, and conditional request matching)
   - 5.5 [Use URL Path Parameters Correctly](references/match-url-patterns.md) — MEDIUM-HIGH (Prevents silent handler mismatches; enables dynamic URL matching)
6. [GraphQL Mocking](references/_sections.md#6-graphql-mocking) — **MEDIUM**
   - 6.1 [Access GraphQL Variables Correctly](references/graphql-variables-access.md) — MEDIUM (Enables dynamic mock responses based on query input)
   - 6.2 [Handle Batched GraphQL Queries](references/graphql-batched-queries.md) — MEDIUM (Supports Apollo batching; prevents unhandled batch requests)
   - 6.3 [Return GraphQL Errors in Correct Format](references/graphql-error-responses.md) — MEDIUM (Ensures GraphQL clients parse errors correctly; tests error handling)
   - 6.4 [Use Operation Name for GraphQL Matching](references/graphql-operation-handlers.md) — MEDIUM (Enables precise operation targeting; prevents query/mutation conflicts)
7. [Advanced Patterns](references/_sections.md#7-advanced-patterns) — **MEDIUM**
   - 7.1 [Configure MSW for Vitest Browser Mode](references/advanced-vitest-browser.md) — MEDIUM (Enables browser-environment testing with proper worker setup)
   - 7.2 [Handle Cookies and Authentication](references/advanced-cookies-auth.md) — MEDIUM (Enables session-based auth testing; validates auth flows)
   - 7.3 [Implement Dynamic Mock Scenarios](references/advanced-dynamic-scenarios.md) — MEDIUM (Enables runtime mock state changes; supports complex test flows)
   - 7.4 [Mock File Upload Endpoints](references/advanced-file-uploads.md) — MEDIUM (Tests file upload forms and progress indicators)
   - 7.5 [Use bypass() for Passthrough Requests](references/advanced-bypass-requests.md) — MEDIUM (Enables mixing real and mocked APIs; supports hybrid testing)
8. [Debugging & Performance](references/_sections.md#8-debugging-&-performance) — **LOW**
   - 8.1 [Know Common MSW Issues and Fixes](references/debug-common-issues.md) — LOW (Quick reference for frequent problems; reduces debugging time)
   - 8.2 [Log Request Details for Debugging](references/debug-request-logging.md) — LOW (Provides detailed request inspection; identifies payload issues)
   - 8.3 [Use Lifecycle Events for Debugging](references/debug-lifecycle-events.md) — LOW (Provides visibility into request interception; aids troubleshooting)
   - 8.4 [Verify Request Interception is Working](references/debug-verify-interception.md) — LOW (Confirms MSW is active; identifies setup failures early)

---

## References

1. [https://mswjs.io/docs/](https://mswjs.io/docs/)
2. [https://mswjs.io/docs/best-practices/](https://mswjs.io/docs/best-practices/)
3. [https://mswjs.io/docs/migrations/1.x-to-2.x/](https://mswjs.io/docs/migrations/1.x-to-2.x/)
4. [https://mswjs.io/docs/runbook/](https://mswjs.io/docs/runbook/)
5. [https://github.com/mswjs/msw](https://github.com/mswjs/msw)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
# Chrome Extensions

**Version 0.1.0**  
Chrome Developer Relations  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Chrome Extensions (Manifest V3), designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (service worker lifecycle, content script optimization) to incremental (API usage patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Service Worker Lifecycle](references/_sections.md#1-service-worker-lifecycle) — **CRITICAL**
   - 1.1 [Avoid Artificial Service Worker Keep-Alive Patterns](references/sw-avoid-keepalive.md) — CRITICAL (reduces memory usage by 50-100MB per idle extension)
   - 1.2 [Persist State with chrome.storage Instead of Global Variables](references/sw-persist-state-storage.md) — CRITICAL (prevents complete state loss on SW termination)
   - 1.3 [Register Event Listeners at Top Level of Service Worker](references/sw-register-listeners-toplevel.md) — CRITICAL (prevents missed events when SW restarts)
   - 1.4 [Return true from Message Listeners for Async Responses](references/sw-return-true-async.md) — CRITICAL (prevents undefined responses and message channel closure)
   - 1.5 [Use chrome.alarms Instead of setTimeout/setInterval](references/sw-use-alarms-api.md) — CRITICAL (prevents timer callbacks from being lost on SW termination)
   - 1.6 [Use Offscreen Documents for DOM APIs](references/sw-use-offscreen-for-dom.md) — CRITICAL (enables DOM manipulation without content script injection)
2. [Content Script Optimization](references/_sections.md#2-content-script-optimization) — **CRITICAL**
   - 2.1 [Batch DOM Operations to Minimize Reflows](references/content-batch-dom-operations.md) — CRITICAL (reduces layout thrashing by 10-100×)
   - 2.2 [Minimize Content Script Bundle Size](references/content-minimize-script-size.md) — CRITICAL (reduces page load impact by 100-500ms per page)
   - 2.3 [Prefer Programmatic Injection Over Manifest Declaration](references/content-programmatic-injection.md) — CRITICAL (loads scripts only when user invokes feature)
   - 2.4 [Use document_idle for Content Script Injection](references/content-use-document-idle.md) — CRITICAL (eliminates page load blocking, faster initial render)
   - 2.5 [Use MutationObserver Instead of Polling for DOM Changes](references/content-use-mutation-observer.md) — CRITICAL (eliminates polling overhead, event-driven detection)
   - 2.6 [Use Specific URL Match Patterns Instead of All URLs](references/content-use-specific-matches.md) — CRITICAL (reduces script injection by 90%+, faster browsing)
3. [Message Passing Efficiency](references/_sections.md#3-message-passing-efficiency) — **HIGH**
   - 3.1 [Always Check chrome.runtime.lastError in Callbacks](references/msg-check-lasterror.md) — HIGH (prevents silent failures and memory leaks)
   - 3.2 [Avoid Broadcasting Messages to All Tabs](references/msg-avoid-broadcast-to-all-tabs.md) — HIGH (reduces message overhead from O(n) to O(1))
   - 3.3 [Debounce High-Frequency Events Before Messaging](references/msg-debounce-frequent-events.md) — HIGH (reduces message volume by 90%+ for scroll/resize events)
   - 3.4 [Minimize Message Payload Size](references/msg-minimize-payload-size.md) — HIGH (reduces serialization overhead by 2-10×)
   - 3.5 [Use Port Connections for Frequent Message Exchange](references/msg-use-ports-for-frequent.md) — HIGH (reduces messaging overhead by 50-80% for repeated messages)
4. [Storage Operations](references/_sections.md#4-storage-operations) — **HIGH**
   - 4.1 [Avoid Storing Large Binary Blobs in chrome.storage](references/storage-avoid-storing-large-blobs.md) — HIGH (prevents quota exhaustion and serialization overhead)
   - 4.2 [Batch Storage Operations Instead of Individual Calls](references/storage-batch-operations.md) — HIGH (reduces storage overhead by 5-20× for multiple values)
   - 4.3 [Cache Frequently Accessed Storage Values in Memory](references/storage-cache-frequently-accessed.md) — HIGH (eliminates repeated async storage reads)
   - 4.4 [Choose the Correct Storage Type for Your Use Case](references/storage-choose-correct-type.md) — HIGH (prevents quota errors and sync throttling)
   - 4.5 [Use storage.session for Temporary Runtime Data](references/storage-use-session-for-temp.md) — HIGH (auto-cleanup on browser close, faster access)
5. [Network & Permissions](references/_sections.md#5-network-&-permissions) — **MEDIUM-HIGH**
   - 5.1 [Avoid Modifying Content Security Policy Headers](references/net-limit-csp-modifications.md) — MEDIUM-HIGH (prevents security degradation and site breakage)
   - 5.2 [Request Minimal Required Permissions](references/net-request-minimal-permissions.md) — MEDIUM-HIGH (reduces permission warnings, higher install rates)
   - 5.3 [Use activeTab Permission Instead of Broad Host Permissions](references/net-use-activetab.md) — MEDIUM-HIGH (eliminates permission warning, 0 scary prompts)
   - 5.4 [Use declarativeNetRequest Instead of webRequest for Blocking](references/net-use-declarativenetrequest.md) — MEDIUM-HIGH (eliminates request interception latency, lower memory usage)
6. [Memory Management](references/_sections.md#6-memory-management) — **MEDIUM**
   - 6.1 [Avoid Accidental Closure Memory Leaks](references/mem-avoid-closure-leaks.md) — MEDIUM (prevents large objects from being retained unexpectedly)
   - 6.2 [Avoid Holding References to Detached DOM Nodes](references/mem-avoid-detached-dom.md) — MEDIUM (prevents DOM trees from being garbage collected)
   - 6.3 [Clean Up Event Listeners When Content Script Unloads](references/mem-cleanup-event-listeners.md) — MEDIUM (prevents memory accumulation on long-running tabs)
   - 6.4 [Clear Intervals and Timeouts on Cleanup](references/mem-clear-intervals-timeouts.md) — MEDIUM (prevents orphaned timers from running after context destroyed)
   - 6.5 [Use WeakMap and WeakSet for DOM Element References](references/mem-use-weak-collections.md) — MEDIUM (allows automatic garbage collection of cached elements)
7. [UI Performance](references/_sections.md#7-ui-performance) — **MEDIUM**
   - 7.1 [Batch Badge Updates to Avoid Flicker](references/ui-batch-badge-updates.md) — MEDIUM (prevents visual flicker and reduces API calls)
   - 7.2 [Lazy Load Options Page Sections](references/ui-use-options-page-lazy.md) — MEDIUM (faster initial options page load)
   - 7.3 [Minimize Popup Bundle Size for Fast Startup](references/ui-minimize-popup-bundle.md) — MEDIUM (reduces popup open time by 100-500ms)
   - 7.4 [Render Popup UI with Cached Data First](references/ui-render-with-cached-data.md) — MEDIUM (eliminates loading spinners, instant perceived load)
8. [API Usage Patterns](references/_sections.md#8-api-usage-patterns) — **LOW-MEDIUM**
   - 8.1 [Avoid Redundant API Calls in Loops](references/api-avoid-redundant-api-calls.md) — LOW-MEDIUM (reduces API overhead from N calls to 1)
   - 8.2 [Handle Extension Context Invalidated Errors](references/api-handle-context-invalidated.md) — LOW-MEDIUM (prevents errors after extension update or reload)
   - 8.3 [Query Tabs with Specific Filters](references/api-query-tabs-efficiently.md) — LOW-MEDIUM (reduces processing from all tabs to relevant subset)
   - 8.4 [Respect Alarms API Minimum Period](references/api-use-alarms-minperiod.md) — LOW-MEDIUM (prevents unexpected 1-minute rounding)
   - 8.5 [Use Declarative Content API for Page Actions](references/api-use-declarative-content.md) — LOW-MEDIUM (reduces service worker wake-ups for icon state changes)
   - 8.6 [Use Promise-Based API Calls Over Callbacks](references/api-use-promises-over-callbacks.md) — LOW-MEDIUM (reduces callback nesting by 3-5 levels)

---

## References

1. [https://developer.chrome.com/docs/extensions/](https://developer.chrome.com/docs/extensions/)
2. [https://developer.chrome.com/docs/extensions/develop/migrate](https://developer.chrome.com/docs/extensions/develop/migrate)
3. [https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle)
4. [https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)
5. [https://developer.chrome.com/docs/extensions/reference/api/storage](https://developer.chrome.com/docs/extensions/reference/api/storage)
6. [https://developer.chrome.com/docs/extensions/develop/concepts/messaging](https://developer.chrome.com/docs/extensions/develop/concepts/messaging)
7. [https://developer.chrome.com/blog/longer-esw-lifetimes](https://developer.chrome.com/blog/longer-esw-lifetimes)
8. [https://developer.chrome.com/blog/Offscreen-Documents-in-Manifest-v3](https://developer.chrome.com/blog/Offscreen-Documents-in-Manifest-v3)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
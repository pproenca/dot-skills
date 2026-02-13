---
name: nginx-c-module-best-practices
description: nginx C module development guidelines based on the official nginx development guide. This skill should be used when writing, reviewing, or refactoring nginx C modules to ensure correct memory management, request lifecycle handling, and event-driven patterns. Triggers on tasks involving nginx module development, ngx_http_module_t, handler/filter/upstream implementation, pool allocation, or nginx configuration directives.
---

# nginx.org C Module Development Best Practices

Comprehensive development guide for nginx C modules, derived from the official nginx development documentation and community expertise. Contains 49 rules across 8 categories, prioritized by impact to guide correct module implementation and prevent common crashes, memory leaks, and undefined behavior.

## When to Apply

Reference these guidelines when:
- Writing new nginx C modules (handlers, filters, upstream, load-balancers)
- Implementing configuration directives and merge logic
- Managing memory with nginx pools and shared memory zones
- Handling the HTTP request lifecycle (body reading, subrequests, finalization)
- Working with nginx's event loop, timers, and thread pools

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Memory Management | CRITICAL | `mem-` |
| 2 | Request Lifecycle | CRITICAL | `req-` |
| 3 | Configuration System | HIGH | `conf-` |
| 4 | Handler Development | HIGH | `handler-` |
| 5 | Filter Chain | MEDIUM-HIGH | `filter-` |
| 6 | Upstream & Proxy | MEDIUM | `upstream-` |
| 7 | Event Loop & Concurrency | MEDIUM | `event-` |
| 8 | Data Structures & Strings | LOW-MEDIUM | `ds-` |

## Quick Reference

### 1. Memory Management (CRITICAL)

- [`mem-pool-allocation`](references/mem-pool-allocation.md) - Use Pool Allocation Instead of Heap malloc
- [`mem-check-allocation`](references/mem-check-allocation.md) - Check Every Allocation Return for NULL
- [`mem-pcalloc-structs`](references/mem-pcalloc-structs.md) - Use ngx_pcalloc for Struct Initialization
- [`mem-cleanup-handlers`](references/mem-cleanup-handlers.md) - Register Pool Cleanup Handlers for External Resources
- [`mem-pnalloc-strings`](references/mem-pnalloc-strings.md) - Use ngx_pnalloc for String Data Allocation
- [`mem-pfree-limitations`](references/mem-pfree-limitations.md) - Avoid Relying on ngx_pfree for Pool Allocations
- [`mem-shared-slab`](references/mem-shared-slab.md) - Use Slab Allocator for Shared Memory Zones

### 2. Request Lifecycle (CRITICAL)

- [`req-finalize-once`](references/req-finalize-once.md) - Finalize Requests Exactly Once
- [`req-no-access-after-finalize`](references/req-no-access-after-finalize.md) - Never Access Request After Finalization
- [`req-body-async`](references/req-body-async.md) - Handle Request Body Reading Asynchronously
- [`req-discard-body`](references/req-discard-body.md) - Discard Request Body When Not Reading It
- [`req-subrequest-completion`](references/req-subrequest-completion.md) - Use Post-Subrequest Handlers for Completion
- [`req-count-reference`](references/req-count-reference.md) - Increment Request Count Before Async Operations
- [`req-internal-redirect`](references/req-internal-redirect.md) - Return After Internal Redirect

### 3. Configuration System (HIGH)

- [`conf-unset-init`](references/conf-unset-init.md) - Initialize Config Fields with UNSET Constants
- [`conf-merge-all-fields`](references/conf-merge-all-fields.md) - Merge All Config Fields in merge_loc_conf
- [`conf-context-flags`](references/conf-context-flags.md) - Use Correct Context Flags for Directives
- [`conf-null-command`](references/conf-null-command.md) - Terminate Commands Array with ngx_null_command
- [`conf-custom-handler`](references/conf-custom-handler.md) - Use Custom Handlers for Complex Directive Parsing
- [`conf-module-ctx-null`](references/conf-module-ctx-null.md) - Set Unused Module Context Callbacks to NULL
- [`conf-build-config`](references/conf-build-config.md) - Write Correct config Build Script for Module Compilation

### 4. Handler Development (HIGH)

- [`handler-send-header-first`](references/handler-send-header-first.md) - Send Header Before Body Output
- [`handler-last-buf`](references/handler-last-buf.md) - Set last_buf Flag on Final Buffer
- [`handler-phase-registration`](references/handler-phase-registration.md) - Register Phase Handlers in postconfiguration
- [`handler-content-handler`](references/handler-content-handler.md) - Use content_handler for Location-Specific Response Generation
- [`handler-error-page`](references/handler-error-page.md) - Return HTTP Status Codes for Error Responses
- [`handler-empty-response`](references/handler-empty-response.md) - Use header_only for Empty Body Responses
- [`handler-module-ctx`](references/handler-module-ctx.md) - Use Module Context for Per-Request State
- [`handler-add-variable`](references/handler-add-variable.md) - Register Custom Variables in preconfiguration

### 5. Filter Chain (MEDIUM-HIGH)

- [`filter-registration-order`](references/filter-registration-order.md) - Save and Replace Top Filter in postconfiguration
- [`filter-call-next`](references/filter-call-next.md) - Always Call Next Filter in the Chain
- [`filter-check-subrequest`](references/filter-check-subrequest.md) - Distinguish Main Request from Subrequest in Filters
- [`filter-buffer-chain-iteration`](references/filter-buffer-chain-iteration.md) - Iterate Buffer Chains Using cl->next Pattern
- [`filter-buffering-flag`](references/filter-buffering-flag.md) - Set Buffering Flag When Accumulating Response Data

### 6. Upstream & Proxy (MEDIUM)

- [`upstream-create-request`](references/upstream-create-request.md) - Build Complete Request Buffer in create_request
- [`upstream-process-header`](references/upstream-process-header.md) - Parse Upstream Response Incrementally in process_header
- [`upstream-peer-free`](references/upstream-peer-free.md) - Track Failures in Peer free Callback
- [`upstream-finalize`](references/upstream-finalize.md) - Clean Up Resources in finalize_request Callback
- [`upstream-connection-reuse`](references/upstream-connection-reuse.md) - Enable Keepalive for Upstream Connections

### 7. Event Loop & Concurrency (MEDIUM)

- [`event-no-blocking`](references/event-no-blocking.md) - Never Use Blocking Calls in Event Handlers
- [`event-timer-management`](references/event-timer-management.md) - Delete Timers Before Freeing Associated Data
- [`event-handle-read-write`](references/event-handle-read-write.md) - Call ngx_handle_read/write_event After I/O Operations
- [`event-thread-pool`](references/event-thread-pool.md) - Offload Blocking Operations to Thread Pool
- [`event-posted-events`](references/event-posted-events.md) - Use Posted Events for Deferred Processing

### 8. Data Structures & Strings (LOW-MEDIUM)

- [`ds-ngx-str-not-null-terminated`](references/ds-ngx-str-not-null-terminated.md) - Never Assume ngx_str_t Is Null-Terminated
- [`ds-ngx-str-set-literals`](references/ds-ngx-str-set-literals.md) - Use ngx_string Macro Only with String Literals
- [`ds-cpymem-pattern`](references/ds-cpymem-pattern.md) - Use ngx_cpymem for Sequential Buffer Writes
- [`ds-list-iteration`](references/ds-list-iteration.md) - Iterate ngx_list_t Using Part-Based Pattern
- [`ds-hash-readonly`](references/ds-hash-readonly.md) - Build Hash Tables During Configuration Only

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

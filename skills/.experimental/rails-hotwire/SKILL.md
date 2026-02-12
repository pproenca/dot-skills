---
name: rails-hotwire
description: Ruby on Rails Hotwire best practices for building interactive applications with Turbo Drive, Turbo Frames, Turbo Streams, and Turbo 8 morphing. This skill should be used when writing, reviewing, or refactoring Hotwire-powered Rails code to ensure optimal patterns for navigation, partial page updates, real-time broadcasting, morphing, and progressive enhancement. Triggers on tasks involving Turbo Frames, Turbo Streams, Turbo Drive, broadcasts, morphing, ActionCable, turbo_stream_from, turbo_frame_tag, or Hotwire performance. Complementary to rails-dev, rails-testing, rails-design-system, ruby-optimise, and ruby-refactor skills.
---

# Community Rails Hotwire Best Practices

Comprehensive guide for building interactive Rails applications with Hotwire (Turbo + Stimulus), maintained by Community. Contains 46 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation. Follows the DHH "One Person Framework" philosophy: the server renders HTML, Turbo makes it feel like an SPA, Stimulus adds the sprinkle of JS where needed.

## When to Apply

Reference these guidelines when:
- Configuring Turbo Drive navigation, prefetching, and caching behavior
- Adding Turbo Frames for partial page updates and lazy loading
- Delivering Turbo Streams for surgical DOM mutations
- Broadcasting real-time updates over ActionCable
- Enabling Turbo 8 morphing for page refreshes
- Choosing between Drive, Frames, Streams, and Morphing
- Testing Hotwire interactions in system and integration tests

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Navigation & Drive | CRITICAL | `drive-` |
| 2 | Turbo Frames | CRITICAL | `frame-` |
| 3 | Turbo Streams | HIGH | `stream-` |
| 4 | Broadcasting & Real-Time | HIGH | `bcast-` |
| 5 | Morphing & Page Refresh | HIGH | `morph-` |
| 6 | Performance Optimization | MEDIUM-HIGH | `perf-` |
| 7 | Architecture Decisions | MEDIUM | `arch-` |
| 8 | Testing Hotwire | MEDIUM | `test-` |

## Quick Reference

### 1. Navigation & Drive (CRITICAL)

- [`drive-prefetch-links`](references/drive-prefetch-links.md) - Enable link prefetching for instant navigation
- [`drive-form-submissions`](references/drive-form-submissions.md) - Use Turbo Drive for form submissions
- [`drive-visit-actions`](references/drive-visit-actions.md) - Control history with visit actions
- [`drive-cache-control`](references/drive-cache-control.md) - Configure Turbo cache for preview pages
- [`drive-selective-disable`](references/drive-selective-disable.md) - Disable Turbo Drive on incompatible pages
- [`drive-progress-bar`](references/drive-progress-bar.md) - Customize the Turbo progress bar

### 2. Turbo Frames (CRITICAL)

- [`frame-lazy-loading`](references/frame-lazy-loading.md) - Defer frame loading until viewport entry
- [`frame-scope-navigation`](references/frame-scope-navigation.md) - Scope navigation within frames
- [`frame-src-navigation`](references/frame-src-navigation.md) - Use src for dynamic frame content
- [`frame-break-out`](references/frame-break-out.md) - Handle frame breakout for redirects
- [`frame-promote-visits`](references/frame-promote-visits.md) - Promote frame navigation to page visits
- [`frame-dom-id`](references/frame-dom-id.md) - Use dom_id for frame identification
- [`frame-empty-state`](references/frame-empty-state.md) - Provide meaningful frame loading states

### 3. Turbo Streams (HIGH)

- [`stream-progressive-enhance`](references/stream-progressive-enhance.md) - Always provide HTML fallback for streams
- [`stream-action-selection`](references/stream-action-selection.md) - Choose the right stream action for DOM mutations
- [`stream-multi-target`](references/stream-multi-target.md) - Use targets for multi-element updates
- [`stream-http-delivery`](references/stream-http-delivery.md) - Deliver streams via HTTP for form responses
- [`stream-websocket-source`](references/stream-websocket-source.md) - Connect WebSocket sources in the body
- [`stream-custom-actions`](references/stream-custom-actions.md) - Register custom stream actions for complex DOM updates

### 4. Broadcasting & Real-Time (HIGH)

- [`bcast-model-broadcasts`](references/bcast-model-broadcasts.md) - Use broadcasts_refreshes for simple model updates
- [`bcast-debounce-n1`](references/bcast-debounce-n1.md) - Debounce broadcasts to prevent N+1 broadcast storms
- [`bcast-scope-streams`](references/bcast-scope-streams.md) - Scope broadcast streams to accounts or users
- [`bcast-refresh-over-replace`](references/bcast-refresh-over-replace.md) - Prefer broadcast refresh over granular stream updates
- [`bcast-avoid-view-logic-in-models`](references/bcast-avoid-view-logic-in-models.md) - Keep broadcasting logic out of models
- [`bcast-signed-stream-names`](references/bcast-signed-stream-names.md) - Use signed stream names for security

### 5. Morphing & Page Refresh (HIGH)

- [`morph-enable-page-refresh`](references/morph-enable-page-refresh.md) - Enable morphing for page refreshes
- [`morph-permanent-elements`](references/morph-permanent-elements.md) - Mark stateful elements as permanent
- [`morph-scroll-preservation`](references/morph-scroll-preservation.md) - Preserve scroll position during morphing
- [`morph-stimulus-reconnect`](references/morph-stimulus-reconnect.md) - Handle Stimulus controller reconnection after morph
- [`morph-frame-refresh`](references/morph-frame-refresh.md) - Use refresh='morph' on frames for additive content
- [`morph-vs-streams`](references/morph-vs-streams.md) - Choose morphing over complex stream orchestration

### 6. Performance Optimization (MEDIUM-HIGH)

- [`perf-optimistic-ui`](references/perf-optimistic-ui.md) - Implement optimistic UI updates before server confirmation
- [`perf-batch-streams`](references/perf-batch-streams.md) - Batch multiple stream updates into single responses
- [`perf-frame-caching`](references/perf-frame-caching.md) - Cache Turbo Frame responses with fragment caching
- [`perf-prefetch-strategic`](references/perf-prefetch-strategic.md) - Disable prefetch on expensive endpoints
- [`perf-memory-leak-prevention`](references/perf-memory-leak-prevention.md) - Clean up subscriptions and event listeners

### 7. Architecture Decisions (MEDIUM)

- [`arch-progressive-enhancement`](references/arch-progressive-enhancement.md) - Follow the progressive enhancement hierarchy
- [`arch-frame-vs-stream-decision`](references/arch-frame-vs-stream-decision.md) - Use frames for scoped navigation, streams for multi-target updates
- [`arch-importmap-management`](references/arch-importmap-management.md) - Pin JavaScript dependencies with import maps
- [`arch-avoid-client-state`](references/arch-avoid-client-state.md) - Keep state on the server, not the client
- [`arch-stimulus-boundaries`](references/arch-stimulus-boundaries.md) - Use Stimulus only for client-side behavior

### 8. Testing Hotwire (MEDIUM)

- [`test-system-test-async`](references/test-system-test-async.md) - Wait for Turbo updates in system tests
- [`test-stream-assertions`](references/test-stream-assertions.md) - Use Turbo Stream test helpers in integration tests
- [`test-broadcast-assertions`](references/test-broadcast-assertions.md) - Assert broadcasts with Turbo test helpers
- [`test-frame-navigation`](references/test-frame-navigation.md) - Test frame navigation with scoped assertions
- [`test-websocket-timing`](references/test-websocket-timing.md) - Handle WebSocket connection timing in system tests

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

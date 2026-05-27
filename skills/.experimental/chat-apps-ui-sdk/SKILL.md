---
name: chat-apps-ui-sdk
description: Use this skill whenever building, reviewing, or designing apps that render interactive UI directly inside ChatGPT or Claude — i.e. OpenAI Apps SDK apps, MCP Apps (the @modelcontextprotocol/ext-apps standard), or MCP-UI components, with a Next.js/React server. Covers the MCP tool and resource architecture, the window.openai / ui-bridge data flow, widget state, sandbox/CSP security, display modes, visual design, and directory submission. Trigger even when the user only says "chat app", "ChatGPT widget", "Claude app", "render UI in chat", "window.openai", "createUIResource", "outputTemplate", or "MCP app UI" without naming a specific SDK.
---

# Chat Apps UI SDK Best Practices

A reference for building beautiful, review-ready apps that render interactive UI inside the chat surface of ChatGPT and Claude. As of January 2026 these platforms share one foundation — the **MCP Apps** standard (`@modelcontextprotocol/ext-apps`), rendered by Claude, ChatGPT, VS Code, and Goose. The **OpenAI Apps SDK** is a superset adding the `window.openai` bridge, and **MCP-UI** (`@mcp-ui/server` / `@mcp-ui/client`) is the community implementation. This skill contains 46 rules across 8 categories, ordered by impact so the highest-leverage decisions come first.

The mental model: an app is an **MCP tool first, UI second**. The model invokes a tool; the tool returns data plus a link to a UI resource; the host renders that resource in a sandboxed iframe; the iframe talks back over a defined bridge. Mistakes early in that chain mean nothing renders; mistakes later mean it renders broken, unsafe, or unpolished.

## When to Apply

Reference these guidelines when:
- Designing the MCP tool and `structuredContent` / `content` / `_meta` contract for a chat app
- Wiring a tool to a component (`_meta.ui.resourceUri`, the `text/html;profile=mcp-app` MIME type, the `ui://` scheme)
- Writing the iframe component and its bridge (`window.openai`, `ui/notifications/*`, MCP-UI `onUIAction`)
- Choosing display modes, widget state, theming, and responsive layout
- Hardening a chat app (CSP, sandbox, secrets, OAuth) or preparing it for directory submission
- Reviewing or refactoring existing ChatGPT-app / Claude-app / MCP-UI code

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | MCP Tool & Discovery Design | CRITICAL | `tool-` |
| 2 | UI Resource Wiring & Templates | CRITICAL | `wire-` |
| 3 | Host–Component Data Bridge | HIGH | `bridge-` |
| 4 | Display Modes & Responsive Layout | HIGH | `display-` |
| 5 | State & Model Context | HIGH | `state-` |
| 6 | Security & Data Boundaries | HIGH | `sec-` |
| 7 | Visual Design & UX Polish | MEDIUM-HIGH | `design-` |
| 8 | Distribution & Cross-Host Portability | MEDIUM | `dist-` |

## Quick Reference

### 1. MCP Tool & Discovery Design (CRITICAL)

- [`tool-structured-content-contract`](references/tool-structured-content-contract.md) - Split output across structuredContent, content, and _meta
- [`tool-specific-verb-names`](references/tool-specific-verb-names.md) - Name tools as specific action verbs
- [`tool-output-schema-validation`](references/tool-output-schema-validation.md) - Declare an output schema for structuredContent
- [`tool-safety-annotations`](references/tool-safety-annotations.md) - Set readOnlyHint and destructiveHint accurately
- [`tool-minimal-scoped-inputs`](references/tool-minimal-scoped-inputs.md) - Request minimal, task-scoped tool inputs
- [`tool-feed-widget-in-response`](references/tool-feed-widget-in-response.md) - Return everything the widget needs in one response
- [`tool-honest-descriptions`](references/tool-honest-descriptions.md) - Write honest tool descriptions and status text

### 2. UI Resource Wiring & Templates (CRITICAL)

- [`wire-resource-uri-link`](references/wire-resource-uri-link.md) - Link each tool to its UI with resourceUri
- [`wire-mcp-app-mimetype`](references/wire-mcp-app-mimetype.md) - Serve UI resources with the mcp-app MIME type
- [`wire-ui-scheme-and-handler`](references/wire-ui-scheme-and-handler.md) - Match the ui:// URI to a registered resource
- [`wire-version-uri-cache-key`](references/wire-version-uri-cache-key.md) - Version the resource URI as a cache key
- [`wire-inline-self-contained-bundle`](references/wire-inline-self-contained-bundle.md) - Inline the component bundle into the resource
- [`wire-set-ui-domain`](references/wire-set-ui-domain.md) - Set a unique ui.domain for the component

### 3. Host–Component Data Bridge (HIGH)

- [`bridge-render-from-notifications`](references/bridge-render-from-notifications.md) - Render from tool output, not first paint
- [`bridge-call-tools-app-visibility`](references/bridge-call-tools-app-visibility.md) - Expose tools to the app before calling them
- [`bridge-followup-vs-silent-call`](references/bridge-followup-vs-silent-call.md) - Choose follow-up messages or silent tool calls
- [`bridge-validate-postmessage-origin`](references/bridge-validate-postmessage-origin.md) - Validate postMessage source in the host
- [`bridge-handle-all-mcpui-actions`](references/bridge-handle-all-mcpui-actions.md) - Handle every MCP-UI onUIAction type
- [`bridge-use-host-apis`](references/bridge-use-host-apis.md) - Use host bridge APIs instead of reimplementing

### 4. Display Modes & Responsive Layout (HIGH)

- [`display-pick-the-right-mode`](references/display-pick-the-right-mode.md) - Pick the display mode that fits the task
- [`display-request-mode-with-fallback`](references/display-request-mode-with-fallback.md) - Request fullscreen but render inline first
- [`display-report-intrinsic-height`](references/display-report-intrinsic-height.md) - Report intrinsic height and respect maxHeight
- [`display-avoid-nested-scroll`](references/display-avoid-nested-scroll.md) - Avoid nested scroll inside inline cards
- [`display-respect-theme`](references/display-respect-theme.md) - Respect the host theme and color scheme
- [`display-responsive-breakpoints`](references/display-responsive-breakpoints.md) - Collapse layout gracefully on small screens

### 5. State & Model Context (HIGH)

- [`state-separate-three-stores`](references/state-separate-three-stores.md) - Separate widget, server, and model state
- [`state-persist-widget-state`](references/state-persist-widget-state.md) - Persist UI state through setWidgetState
- [`state-no-secrets-in-state`](references/state-no-secrets-in-state.md) - Keep secrets and PII out of widget state
- [`state-update-model-context`](references/state-update-model-context.md) - Push user decisions to model context
- [`state-keep-state-small`](references/state-keep-state-small.md) - Keep widget state small and serializable

### 6. Security & Data Boundaries (HIGH)

- [`sec-declare-csp-allowlist`](references/sec-declare-csp-allowlist.md) - Declare a CSP allowlist for the widget
- [`sec-avoid-frame-domains`](references/sec-avoid-frame-domains.md) - Avoid nested frame domains in the widget
- [`sec-no-secrets-in-payloads`](references/sec-no-secrets-in-payloads.md) - Never embed secrets in bundles or payloads
- [`sec-enforce-server-side-auth`](references/sec-enforce-server-side-auth.md) - Enforce authorization on the server
- [`sec-signal-oauth-challenge`](references/sec-signal-oauth-challenge.md) - Signal auth with a www-authenticate challenge
- [`sec-minimize-restricted-data`](references/sec-minimize-restricted-data.md) - Minimize and avoid restricted data inputs

### 7. Visual Design & UX Polish (MEDIUM-HIGH)

- [`design-inherit-native-typography`](references/design-inherit-native-typography.md) - Inherit native fonts and limit type sizes
- [`design-restrain-brand-color`](references/design-restrain-brand-color.md) - Restrain brand color to accents
- [`design-render-loading-empty-error`](references/design-render-loading-empty-error.md) - Render loading, empty, and error states
- [`design-meet-wcag-contrast`](references/design-meet-wcag-contrast.md) - Meet WCAG AA contrast and provide alt text
- [`design-limit-actions-hierarchy`](references/design-limit-actions-hierarchy.md) - Limit actions and keep a clear hierarchy
- [`design-respect-reduced-motion`](references/design-respect-reduced-motion.md) - Respect reduced-motion preferences

### 8. Distribution & Cross-Host Portability (MEDIUM)

- [`dist-build-on-mcp-apps-standard`](references/dist-build-on-mcp-apps-standard.md) - Build on the shared MCP Apps standard
- [`dist-degrade-without-ui`](references/dist-degrade-without-ui.md) - Return a text fallback when UI is unsupported
- [`dist-provide-submission-metadata`](references/dist-provide-submission-metadata.md) - Provide accurate submission metadata
- [`dist-feature-detect-host-apis`](references/dist-feature-detect-host-apis.md) - Detect host capabilities before use

## How to Use

Read the individual reference files for full explanations and incorrect-vs-correct code examples. Start at the top — category 1 (`tool-`) and category 2 (`wire-`) gate whether anything renders at all, so resolve those before touching display or design.

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules
- [AGENTS.md](AGENTS.md) - Compiled table of contents across all rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference URLs |

## Related Skills

- `build-mcp-server` — Entry point for designing the MCP server shape (deployment model, tool patterns) this skill's UI rules build on top of.

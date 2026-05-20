# Chat Apps UI — OpenAI Apps SDK, MCP Apps & MCP-UI

**Version 0.1.0**  
Chat Apps UI SDK  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Architecture and design guide for building beautiful, review-ready apps that render interactive UI directly inside ChatGPT and Claude. Covers the shared MCP Apps standard (@modelcontextprotocol/ext-apps), the OpenAI Apps SDK window.openai bridge, and the MCP-UI SDK, with a Next.js/React backend. Contains 46 rules across 8 categories ordered by impact: from critical MCP tool design and UI-resource wiring (the data contract and the tool-to-component link that decide whether anything renders), through the host-component bridge, display modes, widget state, and sandbox/CSP security, down to visual-design polish and cross-host distribution. Each rule explains why it matters and shows production-realistic incorrect-vs-correct examples in TypeScript, TSX, or CSS, with explicit when-not-to-apply guidance. Sourced from the official OpenAI Apps SDK documentation, the Model Context Protocol MCP Apps specification, and the MCP-UI SDK.

---

## Table of Contents

1. [MCP Tool & Discovery Design](references/_sections.md#1-mcp-tool-&-discovery-design) — **CRITICAL**
   - 1.1 [Declare an Output Schema for structuredContent](references/tool-output-schema-validation.md) — CRITICAL (prevents widget render crashes from shape drift)
   - 1.2 [Name Tools as Specific Action Verbs](references/tool-specific-verb-names.md) — CRITICAL (prevents misrouted or unselectable tools)
   - 1.3 [Request Minimal, Task-Scoped Tool Inputs](references/tool-minimal-scoped-inputs.md) — HIGH (prevents privacy rejections and over-broad triggers)
   - 1.4 [Return Everything the Widget Needs in One Response](references/tool-feed-widget-in-response.md) — HIGH (eliminates client-side fetch waterfalls)
   - 1.5 [Set readOnlyHint and destructiveHint Accurately](references/tool-safety-annotations.md) — CRITICAL (prevents unsafe auto-invocation and review rejection)
   - 1.6 [Split Tool Output Across structuredContent, content, and _meta](references/tool-structured-content-contract.md) — CRITICAL (prevents leaking private data to the model)
   - 1.7 [Write Honest Tool Descriptions and Status Text](references/tool-honest-descriptions.md) — HIGH (prevents over-triggering and confusing progress)
2. [UI Resource Wiring & Templates](references/_sections.md#2-ui-resource-wiring-&-templates) — **CRITICAL**
   - 2.1 [Inline the Component Bundle Into the Resource](references/wire-inline-self-contained-bundle.md) — HIGH (eliminates a blank frame on cold boot)
   - 2.2 [Link Each Tool to Its UI With resourceUri](references/wire-resource-uri-link.md) — CRITICAL (prevents tools that never render a widget)
   - 2.3 [Match the ui:// URI to a Registered Resource](references/wire-ui-scheme-and-handler.md) — CRITICAL (prevents blank frames from URI mismatches)
   - 2.4 [Serve UI Resources With the mcp-app MIME Type](references/wire-mcp-app-mimetype.md) — CRITICAL (prevents the host from rendering markup as text)
   - 2.5 [Set a Unique ui.domain for the Component](references/wire-set-ui-domain.md) — HIGH (prevents submission blocking and origin clashes)
   - 2.6 [Version the Resource URI as a Cache Key](references/wire-version-uri-cache-key.md) — HIGH (prevents stale widgets after a deploy)
3. [Host–Component Data Bridge](references/_sections.md#3-host–component-data-bridge) — **HIGH**
   - 3.1 [Choose Follow-Up Messages or Silent Tool Calls](references/bridge-followup-vs-silent-call.md) — HIGH (prevents chat spam and lost model context)
   - 3.2 [Expose Tools to the App Before Calling Them](references/bridge-call-tools-app-visibility.md) — HIGH (prevents rejected callTool requests)
   - 3.3 [Handle Every MCP-UI onUIAction Type](references/bridge-handle-all-mcpui-actions.md) — MEDIUM-HIGH (prevents silently dead UI controls)
   - 3.4 [Render From Tool Output, Not First Paint](references/bridge-render-from-notifications.md) — HIGH (prevents a blank widget before data arrives)
   - 3.5 [Use Host Bridge APIs Instead of Reimplementing](references/bridge-use-host-apis.md) — MEDIUM-HIGH (prevents broken pickers and unvetted links)
   - 3.6 [Validate postMessage Source in the Host](references/bridge-validate-postmessage-origin.md) — HIGH (prevents spoofed bridge messages)
4. [Display Modes & Responsive Layout](references/_sections.md#4-display-modes-&-responsive-layout) — **HIGH**
   - 4.1 [Avoid Nested Scroll Inside Inline Cards](references/display-avoid-nested-scroll.md) — MEDIUM-HIGH (prevents scroll traps in the conversation)
   - 4.2 [Collapse Layout Gracefully on Small Screens](references/display-responsive-breakpoints.md) — MEDIUM-HIGH (maintains usability on mobile widths)
   - 4.3 [Pick the Display Mode That Fits the Task](references/display-pick-the-right-mode.md) — HIGH (prevents cramped or oversized widgets)
   - 4.4 [Report Intrinsic Height and Respect maxHeight](references/display-report-intrinsic-height.md) — HIGH (prevents clipped content and dead space)
   - 4.5 [Request Fullscreen but Render Inline First](references/display-request-mode-with-fallback.md) — HIGH (prevents an empty widget when the host denies)
   - 4.6 [Respect the Host Theme and Color Scheme](references/display-respect-theme.md) — MEDIUM-HIGH (prevents unreadable dark-mode widgets)
5. [State & Model Context](references/_sections.md#5-state-&-model-context) — **HIGH**
   - 5.1 [Keep Secrets and PII Out of Widget State](references/state-no-secrets-in-state.md) — HIGH (prevents leaking tokens through state)
   - 5.2 [Keep Widget State Small and Serializable](references/state-keep-state-small.md) — MEDIUM (reduces per-turn round-trip size)
   - 5.3 [Persist UI State Through setWidgetState](references/state-persist-widget-state.md) — HIGH (preserves selection across re-mounts)
   - 5.4 [Push User Decisions to Model Context](references/state-update-model-context.md) — MEDIUM-HIGH (prevents incoherent follow-up turns)
   - 5.5 [Separate Widget, Server, and Model State](references/state-separate-three-stores.md) — HIGH (prevents state drift across re-renders)
6. [Security & Data Boundaries](references/_sections.md#6-security-&-data-boundaries) — **HIGH**
   - 6.1 [Avoid Nested Frame Domains in the Widget](references/sec-avoid-frame-domains.md) — MEDIUM-HIGH (prevents review rejection from embedding)
   - 6.2 [Declare a CSP Allowlist for the Widget](references/sec-declare-csp-allowlist.md) — HIGH (prevents silently blocked API and image calls)
   - 6.3 [Enforce Authorization on the Server](references/sec-enforce-server-side-auth.md) — HIGH (prevents spoofed client-hint access)
   - 6.4 [Minimize and Avoid Restricted Data Inputs](references/sec-minimize-restricted-data.md) — MEDIUM-HIGH (prevents privacy-policy rejection)
   - 6.5 [Never Embed Secrets in Bundles or Payloads](references/sec-no-secrets-in-payloads.md) — HIGH (prevents key exposure to end users)
   - 6.6 [Signal Auth With a www-authenticate Challenge](references/sec-signal-oauth-challenge.md) — MEDIUM-HIGH (prevents a broken widget on unauthenticated calls)
7. [Visual Design & UX Polish](references/_sections.md#7-visual-design-&-ux-polish) — **MEDIUM-HIGH**
   - 7.1 [Inherit Native Fonts and Limit Type Sizes](references/design-inherit-native-typography.md) — MEDIUM-HIGH (prevents a foreign, embedded-page look)
   - 7.2 [Limit Actions and Keep a Clear Hierarchy](references/design-limit-actions-hierarchy.md) — MEDIUM-HIGH (prevents overwhelming inline cards)
   - 7.3 [Meet WCAG AA Contrast and Provide Alt Text](references/design-meet-wcag-contrast.md) — MEDIUM-HIGH (prevents accessibility review failures)
   - 7.4 [Render Loading, Empty, and Error States](references/design-render-loading-empty-error.md) — MEDIUM-HIGH (prevents a blank frame during async work)
   - 7.5 [Respect Reduced-Motion Preferences](references/design-respect-reduced-motion.md) — MEDIUM (prevents motion-triggered discomfort)
   - 7.6 [Restrain Brand Color to Accents](references/design-restrain-brand-color.md) — MEDIUM-HIGH (prevents an advertisement-like card)
8. [Distribution & Cross-Host Portability](references/_sections.md#8-distribution-&-cross-host-portability) — **MEDIUM**
   - 8.1 [Build on the Shared MCP Apps Standard](references/dist-build-on-mcp-apps-standard.md) — MEDIUM (enables one server across multiple hosts)
   - 8.2 [Detect Host Capabilities Before Use](references/dist-feature-detect-host-apis.md) — MEDIUM (prevents crashes on hosts lacking an API)
   - 8.3 [Provide Accurate Submission Metadata](references/dist-provide-submission-metadata.md) — MEDIUM (prevents directory review rejection)
   - 8.4 [Return a Text Fallback When UI Is Unsupported](references/dist-degrade-without-ui.md) — MEDIUM (maintains output on hosts without widgets)

---

## References

1. [https://developers.openai.com/apps-sdk](https://developers.openai.com/apps-sdk)
2. [https://developers.openai.com/apps-sdk/reference](https://developers.openai.com/apps-sdk/reference)
3. [https://developers.openai.com/apps-sdk/build/mcp-server](https://developers.openai.com/apps-sdk/build/mcp-server)
4. [https://developers.openai.com/apps-sdk/build/chatgpt-ui](https://developers.openai.com/apps-sdk/build/chatgpt-ui)
5. [https://developers.openai.com/apps-sdk/plan/components](https://developers.openai.com/apps-sdk/plan/components)
6. [https://developers.openai.com/apps-sdk/concepts/ui-guidelines](https://developers.openai.com/apps-sdk/concepts/ui-guidelines)
7. [https://developers.openai.com/apps-sdk/app-submission-guidelines](https://developers.openai.com/apps-sdk/app-submission-guidelines)
8. [https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/](https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/)
9. [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/)
10. [https://mcpui.dev/](https://mcpui.dev/)
11. [https://mcpui.dev/guide/server/typescript/overview](https://mcpui.dev/guide/server/typescript/overview)
12. [https://mcpui.dev/guide/client/overview](https://mcpui.dev/guide/client/overview)
13. [https://github.com/MCP-UI-Org/mcp-ui](https://github.com/MCP-UI-Org/mcp-ui)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
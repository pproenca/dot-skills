# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. MCP Tool & Discovery Design (tool)

**Impact:** CRITICAL  
**Description:** Apps in ChatGPT and Claude are MCP tools first and UI second — if the model cannot discover, trigger, or correctly invoke your tool, no widget ever renders. The `structuredContent` / `content` / `_meta` response contract decides what the model sees, what the widget sees, and what stays private; getting it wrong leaks data to the model, starves the widget, or makes the tool unselectable. Every other category builds on a correctly designed, well-annotated tool.

## 2. UI Resource Wiring & Templates (wire)

**Impact:** CRITICAL  
**Description:** A tool renders UI only when it is wired to a UI resource correctly: the tool's `_meta.ui.resourceUri` must match a registered `ui://` resource served with the `text/html;profile=mcp-app` MIME type, and the bundle must be self-contained because the iframe boots in isolation. A wrong URI, wrong MIME type, an un-versioned cache key, or an externally-dependent bundle produces a blank frame with no error — the most common and most confusing failure when building chat apps.

## 3. Host–Component Data Bridge (bridge)

**Impact:** HIGH  
**Description:** The component is a sandboxed iframe that talks to the host only through a defined bridge — `window.openai` plus the JSON-RPC `ui/*` methods on the MCP Apps standard, or `onUIAction` on MCP-UI. Reading data at the wrong time, calling tools the host hasn't exposed to the app, confusing a silent data call with a conversation turn, or trusting unvalidated postMessage origins are the dominant sources of runtime breakage and blank first paints.

## 4. Display Modes & Responsive Layout (display)

**Impact:** HIGH  
**Description:** Chat surfaces are narrow, resizable, themed, and shared with the conversation. Picking the wrong display mode (inline card vs carousel vs fullscreen vs picture-in-picture), hardcoding heights instead of reporting intrinsic height, nesting scroll containers, or ignoring theme and mobile breakpoints turns a working widget into one that clips content, traps scroll, or renders unreadable in dark mode.

## 5. State & Model Context (state)

**Impact:** HIGH  
**Description:** Widgets re-mount and re-render at the host's discretion, so component-local state is lost unless persisted through `setWidgetState`; meanwhile the model needs to stay aware of what the user did. Confusing ephemeral UI state, server-authoritative data, and model-visible context — or stuffing large or sensitive data into widget state — causes drift, lost work, incoherent follow-up turns, and bloated round-trips.

## 6. Security & Data Boundaries (sec)

**Impact:** HIGH  
**Description:** Everything the widget receives is user-visible and the iframe is sandboxed by default, so a missing CSP allowlist silently blocks your API, an embedded secret leaks to anyone who opens devtools, and client hints like user agent are trivially spoofed. Security here is also a distribution gate: missing CSP, nested frame domains, and over-collected restricted data are common review rejections.

## 7. Visual Design & UX Polish (design)

**Impact:** MEDIUM-HIGH  
**Description:** A chat app must feel native to the host, not like an embedded web page. Inheriting platform typography, restraining brand color, rendering explicit loading / empty / error states, meeting WCAG AA contrast, limiting actions per card, and respecting reduced-motion are what separate a beautiful, review-ready experience from one that reads as a cramped advertisement and fails approval.

## 8. Distribution & Cross-Host Portability (dist)

**Impact:** MEDIUM  
**Description:** The same MCP server can run inside Claude, ChatGPT, VS Code, and Goose if it is built on the shared MCP Apps standard and degrades gracefully where UI is unsupported. Hardcoding one vendor's bridge, returning UI with no useful text fallback, skipping submission metadata, or assuming a host capability without feature-detecting it limits reach and blocks the directory listing the app depends on.

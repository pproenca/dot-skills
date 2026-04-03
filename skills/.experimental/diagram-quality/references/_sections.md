# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group reference files.

---

## 1. Rendering Safety (syn)

**Impact:** CRITICAL  
**Description:** PlantUML syntax errors return HTTP 400 from the rendering server, producing a blank canvas that kills the design conversation. These rules prevent rendering failures and ensure SVG output is interactive on the agent-uml canvas.

**Reference files:**
- [syn-safety.md](syn-safety.md) — 18 rules in Incorrect/Correct format
- [_presets.md](_presets.md) — 5 copy-paste skinparam blocks matched to canvas theme

## 2. Conversation Mechanics (conv)

**Impact:** HIGH  
**Description:** The agent-uml canvas is a conversation medium, not just a renderer. Wrong versioning decisions, missing aliases, or empty chat messages waste human attention and stall convergence. These decision tables map feedback signals to tool calls.

**Reference file:**
- [_conversation.md](_conversation.md) — 5 decision tables covering alias discipline, naming consistency, diagram scope, versioning signals, and message content

## 3. Design Effectiveness (design)

**Impact:** MEDIUM  
**Description:** Once diagrams render correctly and the conversation loop works, design quality determines whether the exported spec is implementable. These heuristics set complexity thresholds and enforce traceability between diagram layers.

**Reference file:**
- [_design.md](_design.md) — 4 heuristics with concrete thresholds for feedback interpretation, progressive detail, decomposition, and export readiness

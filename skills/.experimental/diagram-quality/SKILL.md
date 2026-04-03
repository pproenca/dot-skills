---
name: diagram-quality
description: Use this skill whenever calling agent-uml MCP tools (design_create, diagram_upsert, design_feedback, design_export) to render PlantUML diagrams on the collaborative canvas. Covers three tiers — rendering safety (syntax that prevents HTTP 400 blank canvas), conversation mechanics (when to push a version vs ask a question, what to write in the message parameter), and design effectiveness (decomposition thresholds, cross-diagram traceability, export readiness). Trigger even when the task seems simple — a missing `as alias` makes elements un-annotatable, and a skinparam mismatch makes diagrams unreadable on the warm #f4f1ec canvas.
---

# agent-uml Diagram Quality Best Practices

Make the human-Claude design conversation converge faster on the agent-uml canvas.

## When to Apply

- Before every `diagram_upsert` call — check syntax safety rules and apply the correct skinparam preset
- After every `design_feedback` response — consult the versioning decision table to choose the right next action
- When starting a new design session — follow the progressive detail layers for diagram ordering
- Before calling `design_export` — run the export-readiness checklist
- When a diagram renders blank or elements aren't clickable — consult rendering safety rules

## Rule Categories by Priority

| Priority | Section | Impact | Reference |
|----------|---------|--------|-----------|
| 1 | Rendering Safety | CRITICAL | [syn-safety.md](references/syn-safety.md), [_presets.md](references/_presets.md) |
| 2 | Conversation Mechanics | HIGH | [_conversation.md](references/_conversation.md) |
| 3 | Design Effectiveness | MEDIUM | [_design.md](references/_design.md) |

## Quick Reference

### 1. Rendering Safety (CRITICAL)

18 rules that prevent blank canvas and ensure interactive SVG. Read [syn-safety.md](references/syn-safety.md) before writing any PlantUML source.

Key rules:
- **Every element gets `as Alias`** — without it, element is not clickable on canvas
- **`skinparam backgroundColor transparent`** — white default clashes with #f4f1ec canvas
- **Copy the correct preset from [_presets.md](references/_presets.md)** — one block per diagram type, matched to canvas CSS variables

### 2. Conversation Mechanics (HIGH)

5 decision tables for the feedback-response loop. Read [_conversation.md](references/_conversation.md) when deciding what tool to call next.

Key tables:
- **Table 4: Signal → Action** — maps annotation, chat, silence, and timeout to the correct tool call
- **Table 5: Message content** — what to write in the `message` parameter (explain change + ask focusing question)

### 3. Design Effectiveness (MEDIUM)

4 heuristics with concrete thresholds. Read [_design.md](references/_design.md) when planning diagram sequences or preparing for export.

Key heuristics:
- **Progressive detail layers** — L1 context → L2 container → L3 class → L4 behavior → L5 state
- **Cross-reference traceability** — every sequence participant must map to a component; every interface belongs to exactly one component boundary
- **Decomposition thresholds** — component >12, class >15, sequence >10 participants or >20 messages → split

## How to Use

1. **Starting a session:** Read [_conversation.md](references/_conversation.md) Table 3 (diagram type scope) to decide which diagram to create first
2. **Writing PlantUML:** Apply the skinparam preset from [_presets.md](references/_presets.md), then check [syn-safety.md](references/syn-safety.md) for the rules relevant to your diagram type
3. **After feedback:** Consult [_conversation.md](references/_conversation.md) Table 4 (signal → action) to decide whether to push a new version or reply with a question
4. **Before export:** Run the checklist in [_design.md](references/_design.md) Heuristic 4

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Section definitions and ordering |
| [references/syn-safety.md](references/syn-safety.md) | 18 rendering safety rules (Incorrect/Correct) |
| [references/_presets.md](references/_presets.md) | 5 copy-paste skinparam presets per diagram type |
| [references/_conversation.md](references/_conversation.md) | 5 decision tables for conversation loop |
| [references/_design.md](references/_design.md) | 4 heuristics with thresholds |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules |
| [metadata.json](metadata.json) | Version and reference information |

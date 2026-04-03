# agent-uml

**Version 0.1.0**  
pproenca  
April 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Quality guidelines for PlantUML diagrams rendered on the agent-uml collaborative canvas. Contains 18 rendering safety rules, 5 conversation decision tables, and 4 design effectiveness heuristics — all grounded in agent-uml's SVG element selection, canvas theme, version timeline, and chat panel behavior.

---

## Table of Contents

1. [Rendering Safety](references/_sections.md#1-rendering-safety) — **CRITICAL**
   - 1.1 [Rendering Safety](references/syn-safety.md) — CRITICAL (Prevents HTTP 400 blank canvas and ensures interactive SVG elements)
2. [Conversation Mechanics](references/_sections.md#2-conversation-mechanics) — **HIGH**
3. [Design Effectiveness](references/_sections.md#3-design-effectiveness) — **MEDIUM**

---

## References

1. [https://plantuml.com/](https://plantuml.com/)
2. [https://github.com/pproenca/agent-uml (private)](https://github.com/pproenca/agent-uml (private))

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
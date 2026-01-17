# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Skill Metadata Design (meta)

**Impact:** CRITICAL
**Description:** Metadata determines skill discovery and selection. Poor names or descriptions mean the skill is never triggered, rendering all other optimizations worthless.

## 2. Description Engineering (desc)

**Impact:** CRITICAL
**Description:** The description field is the primary signal for LLM skill selection. Vague descriptions cause wrong triggers or missed activations, making skills unreliable.

## 3. Content Structure (struct)

**Impact:** HIGH
**Description:** How SKILL.md content is organized affects instruction clarity and execution accuracy. Poor structure causes misinterpretation and inconsistent results.

## 4. Trigger Optimization (trigger)

**Impact:** HIGH
**Description:** Keywords and patterns that activate skills reliably. Missing trigger terms mean missed opportunities to help users.

## 5. Progressive Disclosure (prog)

**Impact:** MEDIUM-HIGH
**Description:** Loading minimal context first and expanding as needed prevents context exhaustion and improves token efficiency across multi-step workflows.

## 6. MCP Tool Design (mcp)

**Impact:** MEDIUM
**Description:** Model Context Protocol tool naming, descriptions, and parameter design affect tool discoverability and correct usage by LLMs.

## 7. Testing and Validation (test)

**Impact:** MEDIUM
**Description:** Verifying skills work correctly across diverse scenarios catches issues before deployment and ensures consistent behavior.

## 8. Maintenance and Distribution (maint)

**Impact:** LOW-MEDIUM
**Description:** Versioning, distribution, and long-term maintenance patterns ensure skills remain usable and discoverable over time.

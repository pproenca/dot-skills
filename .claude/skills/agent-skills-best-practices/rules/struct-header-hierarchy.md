---
title: Use Consistent Header Hierarchy
impact: HIGH
impactDescription: improves instruction parsing accuracy by 2-3×
tags: struct, markdown, headers, organization
---

## Use Consistent Header Hierarchy

Use markdown headers to create clear section hierarchy. Claude parses headers to understand document structure. Skipped levels or inconsistent usage causes parsing confusion and instruction misinterpretation.

**Incorrect (skipped levels, inconsistent hierarchy):**

```markdown
# PDF Processing

#### Quick Start
Some quick instructions...

## Advanced Usage
More detailed usage patterns...

##### Edge Cases
Edge case handling...
```

```text
# H1 → #### H4 (skipped 2, 3)
## H2 → ##### H5 (skipped 3, 4)
# Claude can't determine section relationships
```

**Correct (sequential hierarchy, consistent structure):**

```markdown
# PDF Processing

## Quick Start
Some quick instructions...

## Advanced Usage
More detailed usage patterns...

### Edge Cases
Edge case handling...
```

```text
# H1 (document title)
## H2 (main sections)
### H3 (subsections)
# Clear parent-child relationships
```

**Recommended structure:**

```markdown
# Skill Title (H1 - only one)

## Section 1 (H2 - major sections)

### Subsection 1.1 (H3 - details)

## Section 2 (H2 - next major section)
```

Reference: [CommonMark Specification](https://spec.commonmark.org/)

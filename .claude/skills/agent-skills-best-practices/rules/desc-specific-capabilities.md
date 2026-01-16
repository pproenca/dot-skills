---
title: Name Specific Capabilities in Description
impact: CRITICAL
impactDescription: 3-5× improvement in skill activation accuracy
tags: desc, capabilities, specificity, discovery
---

## Name Specific Capabilities in Description

List concrete actions the skill performs, not abstract categories. Claude matches user requests against these specific capabilities. Generic descriptions cause missed activations or wrong triggers.

**Incorrect (abstract category, no specific actions):**

```yaml
---
name: document-helper
description: Helps with documents
---
# "Helps with documents" matches nothing specific
# User says "extract text from this PDF" - skill doesn't trigger
# User says "fill out this form" - skill doesn't trigger
```

**Correct (lists specific extractable capabilities):**

```yaml
---
name: pdf-processing
description: Extract text and tables from PDF files, fill interactive forms, merge multiple PDFs, and convert PDFs to images. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
# Each action is a concrete trigger point
# "extract text from PDF" matches "Extract text"
# "fill out this form" matches "fill interactive forms"
```

**Capability naming patterns:**
- Use verbs: Extract, Fill, Merge, Convert, Generate, Analyze
- Include objects: text, tables, forms, images, data
- Mention formats: PDF, Excel, JSON, Markdown

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

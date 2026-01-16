---
title: Optimize Description Length for Discovery
impact: CRITICAL
impactDescription: 50-150 tokens saved per session (2-3× efficiency)
tags: desc, length, tokens, optimization
---

## Optimize Description Length for Discovery

Descriptions have a 1024 character limit and are loaded into context at startup. Too short means missed triggers; too long wastes tokens on every conversation. Target 150-300 characters for optimal balance.

**Incorrect (too short, misses triggers):**

```yaml
---
name: pdf-processing
description: Handles PDFs.
---
# 12 characters - too vague
# No trigger keywords
# Misses most user requests
```

**Incorrect (too long, wastes tokens):**

```yaml
---
name: pdf-processing
description: This comprehensive PDF processing skill handles all aspects of PDF document management including but not limited to text extraction using OCR and native text parsing, table extraction with structure preservation, form filling for both AcroForms and XFA forms, document merging and splitting, page manipulation including rotation and reordering, image extraction and conversion, PDF to image conversion supporting PNG JPEG and TIFF formats, compression and optimization, digital signature verification, and metadata extraction. This skill should be used whenever the user needs to work with PDF files in any capacity including reading extracting converting manipulating or creating PDF documents.
---
# 647 characters - excessive repetition
# Loaded into every conversation start
# Wastes ~150 tokens per session
```

**Correct (optimal length with key triggers):**

```yaml
---
name: pdf-processing
description: Extract text and tables from PDFs, fill forms, merge documents, and convert to images. This skill should be used when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
# 213 characters - includes key capabilities
# Covers main trigger keywords
# Efficient token usage
```

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

---
title: Optimize Description Length for Discovery
impact: CRITICAL
impactDescription: 100% rejection if over 1024 chars, 50-150 tokens saved per session
tags: desc, length, tokens, optimization, skills-ref
---

## Optimize Description Length for Discovery

The skills-ref validator enforces a 1024-character maximum for descriptions. Additionally, descriptions are loaded into context at startup, so efficiency matters. Target 150-300 characters for optimal balance between trigger coverage and token usage.

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

**Incorrect (exceeds 1024-character limit):**

```yaml
---
name: pdf-processing
description: This comprehensive PDF processing skill handles all aspects of PDF document management including but not limited to text extraction using OCR and native text parsing, table extraction with structure preservation, form filling for both AcroForms and XFA forms, document merging and splitting, page manipulation including rotation and reordering, image extraction and conversion, PDF to image conversion supporting PNG JPEG and TIFF formats, compression and optimization, digital signature verification, and metadata extraction. This skill should be used whenever the user needs to work with PDF files in any capacity including reading extracting converting manipulating or creating PDF documents. Additionally this skill supports batch processing of multiple PDF files, automated workflows for document processing pipelines, and integration with external services for enhanced functionality including cloud storage providers and document management systems...
---
# skills-ref validate ./skills/pdf-processing/
# Error: description cannot exceed 1024 characters
```

**Correct (optimal length with key triggers):**

```yaml
---
name: pdf-processing
description: Extract text and tables from PDFs, fill forms, merge documents, and convert to images. This skill should be used when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
# 213 characters - includes key capabilities
# Covers main trigger keywords
# skills-ref validate ./skills/pdf-processing/
# Validation passed
```

**Validation command:**

```bash
# Check description length
skills-ref read-properties ./skills/my-skill/ | jq '.description | length'
# Should be <= 1024
```

Reference: [skills-ref validator](https://github.com/agentskills/agentskills/tree/main/skills-ref)

---
title: Cover Synonyms and Alternate Phrasings
impact: HIGH
impactDescription: 30-50% improvement in activation coverage
tags: trigger, synonyms, natural-language, coverage
---

## Cover Synonyms and Alternate Phrasings

Users describe the same task in many ways. Include synonyms, abbreviations, and alternate phrasings to maximize trigger coverage. Missing synonyms mean missed opportunities to help.

**Incorrect (single phrasing only):**

```yaml
---
name: api-documentation
description: Generates API documentation for REST endpoints.
---
```

```text
# "document my API" - triggers
# "create swagger docs" - doesn't trigger (Swagger not mentioned)
# "write OpenAPI spec" - doesn't trigger (OpenAPI not mentioned)
# "API reference" - doesn't trigger
```

**Correct (synonyms and alternates included):**

```yaml
---
name: api-documentation
description: Generates API documentation, Swagger specs, and OpenAPI definitions for REST endpoints. This skill should be used when creating API docs, API reference documentation, Swagger documentation, or OpenAPI specifications.
---
```

```text
# "document my API" - triggers
# "create swagger docs" - triggers (Swagger mentioned)
# "write OpenAPI spec" - triggers (OpenAPI mentioned)
# "API reference" - triggers (reference mentioned)
```

**Synonym research process:**
1. List 5-10 ways users might describe the task
2. Include industry jargon and casual terms
3. Add common abbreviations (API, DB, UI, PR)
4. Include tool names (Swagger, Postman, Jest)
5. Test with real user queries

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

---
title: Maintain Single Source of Truth
impact: LOW
impactDescription: eliminates version confusion across team
tags: doc, source, canonical, consistency
---

## Maintain Single Source of Truth

Designate one canonical location for each document type. Multiple copies lead to version drift, conflicting information, and wasted time determining which is correct.

**Incorrect (multiple sources):**

```markdown
## Where to Find Requirements

- PRD is in Google Docs (shared by PM)
- Technical spec is in Confluence
- User stories are in Jira
- API docs are in Notion
- Designs are in Figma (some also in Google Drive)

// Developer: "Which requirements doc is current?"
// PM: "The Google Doc, but some updates are in Jira"
// Developer: "Which Jira tickets?"
// Result: 2 hours finding correct requirements
```

**Correct (single source per document type):**

```markdown
## Documentation Sources of Truth

### Document Locations

| Document Type | Canonical Location | Format | Owner |
|---------------|-------------------|--------|-------|
| PRD | Confluence: /projects/dashboard/prd | Wiki | PM |
| Technical Spec | Confluence: /projects/dashboard/tech | Wiki | Tech Lead |
| User Stories | Jira: Dashboard Epic | Jira tickets | PM |
| API Docs | Swagger: /api/dashboard | OpenAPI | Backend Lead |
| Designs | Figma: Dashboard Project | Figma | Designer |
| Meeting Notes | Confluence: /projects/dashboard/meetings | Wiki | Rotating |

### Linking Policy

All documents link to each other:
```yaml
prd:
  links_to:
    - technical_spec: "Implementation details"
    - designs: "Visual specifications"
    - user_stories: "Detailed requirements"
  links_from:
    - project_page: "Main PRD link"

technical_spec:
  links_to:
    - api_docs: "API details"
    - architecture_diagrams: "System design"
  links_from:
    - prd: "Technical reference"
```

### Prohibited Practices

**Never:**
- Email spec documents as attachments
- Copy sections into Slack messages
- Create "local copies" of shared docs
- Make decisions in documents not linked to source

**Instead:**
- Share links to canonical location
- Quote with link to source
- Edit the source document
- Update source, then discuss

### Update Protocol

```text
Document updated
      │
      ▼
┌─────────────────────┐
│ Update source doc   │
│ (canonical location)│
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Increment version   │
│ Update changelog    │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Notify stakeholders │
│ with link to source │
└─────────────────────┘
```

### Cross-Reference Template

Every document header includes:

```markdown
---
Document: User Dashboard PRD
Version: 3.1
Last Updated: 2024-03-20
Owner: Carol Davis (PM)

Related Documents:
- Technical Spec: [link]
- Designs: [link]
- User Stories: [Jira Epic link]
- API Docs: [Swagger link]

This is the CANONICAL source for product requirements.
Other copies are not authoritative.
---
```
```

**Single source requirements:**
- One canonical location per document type
- All copies are references, not sources
- Links between related documents
- Clear ownership and update protocol
- Header identifies canonical status

Reference: [Atlassian - Documentation Best Practices](https://www.atlassian.com/software-teams/documentation)

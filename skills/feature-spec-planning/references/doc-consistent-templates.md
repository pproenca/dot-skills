---
title: Use Consistent Document Templates
impact: LOW
impactDescription: reduces document creation time by 50%
tags: doc, templates, consistency, standards
---

## Use Consistent Document Templates

Use standardized templates for recurring document types. Consistent structure makes documents easier to write, review, and find information in. Ad-hoc formats waste time on structure decisions.

**Incorrect (ad-hoc document structure):**

```markdown
## PRD #1 (by Alice)
- Overview
- Features
- Timeline

## PRD #2 (by Bob)
1. Problem Statement
2. User Stories
3. Success Metrics
4. Technical Requirements
5. Risks

## PRD #3 (by Carol)
Executive Summary
Background
Proposal
Next Steps

// Every PRD is different
// Reviewers can't find information consistently
// New team members don't know what to include
```

**Correct (standardized template):**

```markdown
## PRD Template v2.0

Every PRD follows this structure. Sections may be brief but cannot
be omitted. Use "N/A" with justification if truly not applicable.

---

### 1. Document Control

```yaml
title: [Feature Name] PRD
version: [X.Y]
status: [Draft | In Review | Approved | Superseded]
owner: [PM Name]
created: [Date]
last_updated: [Date]
reviewers:
  - name: [Name]
    role: [Role]
    status: [Pending | Approved | Requested Changes]
```

### 2. Executive Summary
*2-3 sentences. What are we building and why?*

[Write summary here]

### 3. Problem Statement
*What problem does this solve? For whom? How do we know it's a problem?*

**Problem:** [Description]
**Affected users:** [User segments]
**Evidence:** [Data, research, customer quotes]

### 4. Goals and Success Metrics

| Goal | Metric | Baseline | Target | Timeline |
|------|--------|----------|--------|----------|
| [Goal 1] | [Metric] | [Current] | [Target] | [When] |

### 5. User Stories

```text
As a [user type]
I want to [action]
So that [benefit]

Acceptance Criteria:
- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

### 6. Scope

**In Scope:**
- [Item 1]
- [Item 2]

**Out of Scope:**
- [Item 1] - [Reason]

**Future Considerations:**
- [Item 1] - [Tentative timeline]

### 7. Requirements

#### 7.1 Functional Requirements
| ID | Requirement | Priority | Notes |
|----|-------------|----------|-------|
| FR-001 | [Requirement] | [Must/Should/Could] | [Notes] |

#### 7.2 Non-Functional Requirements
| Category | Requirement |
|----------|-------------|
| Performance | [Requirement] |
| Security | [Requirement] |
| Accessibility | [Requirement] |

### 8. Dependencies and Risks

| Dependency/Risk | Type | Impact | Mitigation |
|-----------------|------|--------|------------|
| [Item] | [Dependency/Risk] | [H/M/L] | [Action] |

### 9. Timeline

| Milestone | Date | Dependencies |
|-----------|------|--------------|
| [Milestone] | [Date] | [Dependencies] |

### 10. Appendix
*Supporting materials, research, mockups, technical details*

---

## Template Usage Notes

- **Bold sections** are required
- Provide brief answers; link to details
- Update version number on each significant change
- Get reviewer sign-off before development starts
```

### Template Library

| Document Type | Template | Owner | Last Updated |
|---------------|----------|-------|--------------|
| PRD | [Link to template] | PM Team | 2024-03-01 |
| Technical Spec | [Link to template] | Engineering | 2024-02-15 |
| Design Brief | [Link to template] | Design | 2024-02-20 |
| Test Plan | [Link to template] | QA | 2024-01-10 |
| Launch Checklist | [Link to template] | Operations | 2024-03-05 |
| Post-Mortem | [Link to template] | Engineering | 2024-01-20 |

### Template Maintenance

- Review templates quarterly
- Collect feedback from users
- Update based on common omissions
- Version templates (v1.0, v2.0)
```

**Template requirements:**
- Standard structure for each document type
- Required vs optional sections marked
- Examples and guidance included
- Templates versioned and maintained
- Team trained on usage

Reference: [Google Technical Writing - Document Templates](https://developers.google.com/tech-writing)

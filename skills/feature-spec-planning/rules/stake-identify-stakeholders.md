---
title: Identify All Stakeholders Early
impact: MEDIUM-HIGH
impactDescription: prevents late-stage surprises from overlooked parties
tags: stake, identification, stakeholder-map, raci
---

## Identify All Stakeholders Early

Map all stakeholders before requirements gathering begins. Overlooked stakeholders surface late with new requirements, causing rework. Include those who approve, build, use, support, and are affected by the feature.

**Incorrect (developer-centric stakeholder list):**

```markdown
## Stakeholders

- Product Manager
- Development Team
- QA

// Missing: Legal, Security, Support, Marketing, Finance
// Week 6: Legal blocks launch for compliance review
// Week 7: Support needs training materials
// Result: 3-week delay
```

**Correct (comprehensive stakeholder map):**

```markdown
## Stakeholder Map - Payment Feature

### Decision Makers (Approve scope and budget)
| Role | Name | Interest | Engagement |
|------|------|----------|------------|
| Product Director | Alice Chen | Feature success | Final approval |
| Engineering Manager | Bob Smith | Technical feasibility | Architecture approval |

### Builders (Design and implement)
| Role | Name | Interest | Engagement |
|------|------|----------|------------|
| Product Manager | Carol Davis | User value | Requirements, prioritization |
| Tech Lead | Dan Wilson | Code quality | Technical design |
| UX Designer | Emma Brown | User experience | Design specs |
| QA Lead | Frank Lee | Quality | Test planning |

### Supporters (Enable and maintain)
| Role | Name | Interest | Engagement |
|------|------|----------|------------|
| DevOps | Grace Kim | Reliability | Infrastructure review |
| Support Lead | Henry Park | Supportability | Training, documentation |

### Influencers (Affect or are affected)
| Role | Name | Interest | Engagement |
|------|------|----------|------------|
| Legal | Irene Wu | Compliance | Policy review |
| Security | Jack Torres | Data protection | Security review |
| Finance | Karen Adams | Revenue impact | Pricing approval |
| Marketing | Leo Martinez | Positioning | Launch messaging |

### Users (End consumers)
- Free tier users: Basic payment flow
- Premium users: Advanced payment options
- Enterprise admins: Bulk payment management
```

**RACI for key decisions:**
- **R**esponsible: Carol (PM)
- **A**ccountable: Alice (Director)
- **C**onsulted: Legal, Security, Finance
- **I**nformed: Support, Marketing

Reference: [BA Times - How to Mitigate Scope Creep](https://www.batimes.com/articles/how-to-mitigate-scope-creep/)

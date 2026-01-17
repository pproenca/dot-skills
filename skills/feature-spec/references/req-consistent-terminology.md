---
title: Use Consistent Terminology with a Glossary
impact: CRITICAL
impactDescription: eliminates cross-team miscommunication
tags: req, terminology, glossary, consistency
---

## Use Consistent Terminology with a Glossary

When different documents use different terms for the same concept—"user" vs "customer" vs "account holder"—confusion spreads. Create a glossary defining key terms and use them consistently throughout all specifications.

**Incorrect (inconsistent terminology):**

```markdown
## Requirements Document

The **user** can create an account...
The **customer** profile includes...
The **account holder** receives notifications...
A **member** can upgrade their subscription...
The **subscriber** dashboard shows...

// Are these all the same person? Different roles?
// Developers guess; QA interprets differently; bugs ensue
```

**Correct (glossary + consistent usage):**

```markdown
## Glossary

| Term | Definition | NOT to be confused with |
|------|------------|------------------------|
| **User** | Any person interacting with the system | Account (the data record) |
| **Member** | User with an active paid subscription | User (may be free tier) |
| **Account** | The data record representing a user | User (the person) |
| **Workspace** | Shared environment for team collaboration | Account (individual user data) |
| **Admin** | User with elevated permissions in a workspace | Owner (billing responsibility) |
| **Owner** | User responsible for billing | Admin (may not have admin rights) |

---

## Requirements (Using Consistent Terms)

### Account Creation
- A **user** can create an **account** with email/password
- The **account** stores the **user's** profile data

### Subscription Management
- A **user** becomes a **member** by subscribing
- A **member** can access premium features
- Only the **owner** can change billing information

### Workspace Collaboration
- A **member** can create a **workspace**
- The **workspace** creator becomes the **owner**
- The **owner** can grant **admin** rights to other **members**
```

**Glossary best practices:**
- Define terms before writing requirements
- Include "not to be confused with" clarifications
- Link to glossary from all spec documents
- Update glossary when new concepts emerge

Reference: [Asana - Software Requirements Document](https://asana.com/resources/software-requirement-document-template)

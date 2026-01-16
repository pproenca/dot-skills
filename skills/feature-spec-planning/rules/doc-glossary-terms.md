---
title: Define Project Terminology in a Glossary
impact: LOW
impactDescription: eliminates term confusion across team
tags: doc, glossary, terminology, definitions
---

## Define Project Terminology in a Glossary

Create a glossary of project-specific terms. Without defined terminology, team members interpret words differently, leading to misaligned implementations and stakeholder confusion.

**Incorrect (assumed shared understanding):**

```markdown
## Requirements

- Display user metrics on the dashboard
- Show conversion data for the funnel

// Designer thinks: "metrics" = charts and graphs
// Developer thinks: "metrics" = numbers in cards
// PM thinks: "metrics" = specific KPIs (DAU, MAU)

// Result: Three different interpretations implemented
```

**Correct (defined glossary):**

```markdown
## Project Glossary - User Dashboard

### Purpose
This glossary defines terms used in the User Dashboard project.
All team members should use these definitions consistently.
When writing documentation, use terms exactly as defined here.

---

### Core Concepts

#### Dashboard
The main analytics view where users see their key metrics. Located
at `/app/dashboard`. Not to be confused with Admin Dashboard (different
feature) or Home Page (marketing site).

**Synonyms (avoid):** Home, Analytics Page, Stats
**Use instead:** Dashboard, User Dashboard

#### Widget
A single component displayed on the Dashboard showing one metric or
visualization. Widgets can be:
- **Metric Widget:** Displays a single number (e.g., "Total Users: 1,234")
- **Chart Widget:** Displays a visualization (line chart, bar chart)
- **Table Widget:** Displays tabular data

**Not to be confused with:** Card (generic UI component), Tile (deprecated term)

#### Metric
A quantifiable measurement tracked in the system. Examples:
- DAU (Daily Active Users)
- Conversion Rate
- Revenue

**Note:** "Metric" refers to the data point, not its visual representation.
The visual representation is a Widget.

---

### User Types

#### End User
A person who uses the product to accomplish their goals. Has a user
account and logs in to access features.

**Not:** Admin, Support Staff, Developer

#### Account Admin
An End User with administrative privileges. Can manage team members,
billing, and settings for their organization.

**Also called:** Admin (in user-facing UI only)
**Not to be confused with:** System Admin (internal Ops role)

#### Visitor
A person browsing the marketing site without logging in.
Has no account yet.

---

### Metrics Definitions

#### DAU (Daily Active Users)
Count of unique users who performed at least one meaningful action
in the past 24 hours.

**Meaningful action:** Login, create/edit content, or export data.
**Excludes:** Passive page views, automated API calls.

#### MAU (Monthly Active Users)
Count of unique users who performed at least one meaningful action
in the past 30 days.

**Calculation:** Rolling 30-day window, not calendar month.

#### Conversion Rate
Percentage of Visitors who become End Users.

**Formula:** (New signups / Unique visitors) × 100
**Time period:** Calculated weekly by default.

#### Churn Rate
Percentage of paying users who cancel within a period.

**Formula:** (Cancellations / Starting subscribers) × 100
**Time period:** Monthly.

---

### Technical Terms

#### API
Application Programming Interface. The programmatic interface for
integrating with our system.

**Public API:** Documented endpoints available to customers.
**Internal API:** Endpoints for internal services only.

#### Webhook
An HTTP callback triggered by system events. Customers configure
webhooks to receive real-time notifications.

---

### Deprecated Terms

| Deprecated | Use Instead | Reason |
|------------|-------------|--------|
| Tile | Widget | Standardization |
| Stats | Metrics | Precision |
| Panel | Dashboard | Clarity |
| Customer | End User / Account | Ambiguity |

---

### Adding to This Glossary

When introducing a new term:
1. Check if an existing term covers the concept
2. Add definition with clear boundaries
3. Note what it's NOT (to prevent confusion)
4. List synonyms to avoid
5. Update related documentation

**Template:**
```markdown
#### [Term]
[Clear definition in 1-3 sentences]

**Also called:** [Acceptable synonyms, if any]
**Not to be confused with:** [Similar but different terms]
**Avoid:** [Terms that should not be used]
```
```

**Glossary requirements:**
- Define all project-specific terms
- Clarify what terms do NOT mean
- Include deprecated terms with alternatives
- Update when new concepts are introduced
- Reference in all project documentation

Reference: [Plain Language Guidelines - Definitions](https://www.plainlanguage.gov/guidelines/words/use-simple-words-phrases/)

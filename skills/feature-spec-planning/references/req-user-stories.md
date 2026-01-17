---
title: Use User Story Format for Feature Requirements
impact: CRITICAL
impactDescription: reduces feature misalignment by 60%
tags: req, user-stories, format, agile
---

## Use User Story Format for Feature Requirements

Express requirements as user stories that capture who needs the feature, what they need, and why. This format ensures every requirement is tied to real user value, not arbitrary technical decisions.

**Incorrect (technical specification without context):**

```markdown
## Requirements

- Add POST /api/comments endpoint
- Store comments in comments table
- Include timestamp and user_id fields
- Return 201 on success
- Implement pagination
```

**Correct (user story format):**

```markdown
## User Stories

### Story 1: Add Comment
**As a** logged-in user
**I want to** add a comment to a blog post
**So that** I can share my thoughts and engage with the author

**Acceptance Criteria:**
- Comment appears immediately after submission
- Comment shows my name, avatar, and timestamp
- Maximum 2000 characters with character counter
- Empty comments are prevented (submit disabled)

---

### Story 2: View Comments
**As a** blog reader
**I want to** see comments on a post sorted by newest first
**So that** I can read recent discussions

**Acceptance Criteria:**
- Comments load with the post (no extra click)
- Show 10 comments initially, "Load more" for rest
- Display comment count in post header
- Indicate if there are no comments yet

---

### Story 3: Delete Own Comment
**As a** comment author
**I want to** delete my own comment
**So that** I can remove something I regret posting

**Acceptance Criteria:**
- Delete button visible only on my own comments
- Confirmation dialog before deletion
- Comment removed immediately from UI
- Other users' comments are unaffected
```

**User story components:**
- **Role**: Who benefits from this feature
- **Action**: What they want to do
- **Benefit**: Why it matters to them
- **Acceptance Criteria**: How to verify it's done

Reference: [Atlassian - User Stories with Examples](https://www.atlassian.com/agile/project-management/user-stories)

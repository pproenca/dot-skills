---
title: Use Given-When-Then Format for Acceptance Criteria
impact: HIGH
impactDescription: reduces acceptance ambiguity by 80%
tags: accept, given-when-then, bdd, testable
---

## Use Given-When-Then Format for Acceptance Criteria

Structure acceptance criteria using Given-When-Then (Gherkin) format. This format is unambiguous, directly translatable to automated tests, and forces thinking about preconditions, actions, and outcomes.

**Incorrect (vague acceptance criteria):**

```markdown
## User Story: Password Reset

### Acceptance Criteria
- User can reset password
- Email is sent
- Password is changed
- Errors are handled properly
```

**Correct (Given-When-Then format):**

```markdown
## User Story: Password Reset

### Acceptance Criteria

**Scenario 1: Successful password reset request**
```gherkin
Given I am on the login page
  And I have a registered account with email "user@example.com"
When I click "Forgot password"
  And I enter "user@example.com"
  And I click "Send reset link"
Then I should see "Check your email for reset instructions"
  And an email should be sent to "user@example.com" within 1 minute
  And the email should contain a reset link valid for 24 hours
```

**Scenario 2: Password reset with invalid email**
```gherkin
Given I am on the password reset page
When I enter "notregistered@example.com"
  And I click "Send reset link"
Then I should see "Check your email for reset instructions"
  And no email should be sent
  # Note: Same message shown to prevent email enumeration
```

**Scenario 3: Using the reset link**
```gherkin
Given I received a password reset email
  And the reset link is less than 24 hours old
When I click the reset link
  And I enter a new password "NewSecure123!"
  And I confirm the password "NewSecure123!"
  And I click "Reset password"
Then my password should be changed
  And I should be redirected to the login page
  And I should see "Password successfully reset"
```

**Scenario 4: Expired reset link**
```gherkin
Given I received a password reset email
  And the reset link is more than 24 hours old
When I click the reset link
Then I should see "This link has expired. Please request a new one."
  And I should see a link to request a new reset email
```
```

**Benefits:**
- QA can write tests directly from criteria
- Developers know exact expected behavior
- Edge cases are explicit, not discovered later

Reference: [AltexSoft - Acceptance Criteria Best Practices](https://www.altexsoft.com/blog/acceptance-criteria-purposes-formats-and-best-practices/)

---
title: Add a Test to Prevent Recurrence
impact: MEDIUM
impactDescription: 100% regression prevention for this specific bug; serves as executable documentation
tags: verify, testing, regression-prevention, automation, documentation
---

## Add a Test to Prevent Recurrence

After fixing a bug, add an automated test that reproduces the original failure. This prevents the bug from being reintroduced and documents the expected behavior.

**Incorrect (fix without test):**

```python
# Bug: Empty usernames allowed during registration
# Fix: Add validation

def register_user(username, password):
    if not username or not username.strip():
        raise ValueError("Username required")  # Fix added
    # ... rest of registration

# Fix committed, no test added
# 6 months later: Developer refactors validation
# Empty usernames allowed again
# No one notices until user reports
```

**Correct (fix with test):**

```python
# Bug: Empty usernames allowed during registration
# Fix: Add validation

def register_user(username, password):
    if not username or not username.strip():
        raise ValueError("Username required")
    # ... rest of registration

# Test added for this specific bug:
class TestUserRegistration:
    """Regression test for bug #1234: Empty username crash"""

    def test_empty_username_rejected(self):
        """Empty username should raise ValueError"""
        with pytest.raises(ValueError, match="Username required"):
            register_user("", "password123")

    def test_whitespace_username_rejected(self):
        """Whitespace-only username should raise ValueError"""
        with pytest.raises(ValueError, match="Username required"):
            register_user("   ", "password123")

    def test_none_username_rejected(self):
        """None username should raise ValueError"""
        with pytest.raises(ValueError, match="Username required"):
            register_user(None, "password123")

# Now if anyone removes or breaks the validation:
# test_empty_username_rejected FAILED
# Regression caught immediately
```

**Test naming convention for bug fixes:**

```python
# Include bug/ticket reference
def test_issue_1234_empty_username():
    """Regression: Empty username allowed (issue #1234)"""

# Or describe the failure scenario
def test_registration_rejects_empty_username():
    """Bug fix: Registration must reject empty usernames"""
```

**What the test should cover:**
- Exact reproduction of original bug
- Edge cases discovered during debugging
- Related scenarios that might have same issue
- Error messages/codes that help future debugging

**When NOT to use this pattern:**
- Bug was in one-time migration or script
- Test would be extremely complex/slow for minimal value

Reference: [Test-Driven Development by Example](https://www.oreilly.com/library/view/test-driven-development/0321146530/)

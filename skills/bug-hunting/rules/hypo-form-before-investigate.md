---
title: Form Hypothesis Before Investigation
impact: CRITICAL
impactDescription: 40-60% faster bug resolution
tags: hypo, scientific-method, hypothesis, systematic-debugging
---

## Form Hypothesis Before Investigation

Before opening the debugger or adding print statements, form a specific hypothesis about what is causing the bug. A hypothesis gives your investigation direction and prevents aimless wandering through code.

**Incorrect (starting investigation without a hypothesis):**

```python
# Bug: User registration fails
# Approach: Start adding print statements everywhere

def register_user(email, password):
    print("Starting registration")           # What are we looking for?
    user = User(email=email)
    print(f"User created: {user}")           # Printing everything
    user.set_password(password)
    print(f"Password set")                   # No clear direction
    db.session.add(user)
    print(f"Added to session")               # Random debugging
    db.session.commit()
    print(f"Committed")                      # Hope to spot something
    return user
```

**Correct (hypothesis-driven investigation):**

```python
# Bug: User registration fails
# Hypothesis: The email validation regex rejects valid emails with plus signs

def register_user(email, password):
    # Test hypothesis: Check if email validation is the issue
    is_valid = validate_email(email)
    print(f"Email validation result for '{email}': {is_valid}")

    if not is_valid:
        # Hypothesis confirmed: alice+test@example.com rejected
        # Root cause: Regex doesn't allow plus signs
        raise ValidationError("Invalid email")

    user = User(email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    return user
```

**The 10-minute rule:** If you've spent 10 minutes debugging without a clear hypothesis, stop and formulate one before continuing.

Reference: [Grinnell College - Hypothesis-driven debugging](https://eikmeier.sites.grinnell.edu/csc-151-s221/readings/hypothesis-driven-debugging.html)

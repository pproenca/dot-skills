---
title: Avoid Shotgun Debugging
impact: MEDIUM
impactDescription: Prevents hours of wasted effort; random changes make bugs harder to find
tags: anti, shotgun, random-changes, anti-pattern, discipline
---

## Avoid Shotgun Debugging

Don't make random changes hoping something will fix the bug. Shotgun debugging wastes time, introduces new bugs, and makes the codebase harder to understand. Each change should test a specific hypothesis.

**Incorrect (shotgun debugging):**

```python
# Bug: User registration fails

def register_user(data):
    # Try adding a sleep
    time.sleep(0.5)

    # Try encoding fix
    data = data.encode('utf-8').decode('utf-8')

    # Try null check
    if data is None:
        data = {}

    # Try lowercase
    data['email'] = data.get('email', '').lower()

    # Try adding retry
    for attempt in range(3):
        try:
            return create_user(data)
        except:
            pass

    # None of this is based on understanding the actual bug
    # Code is now a mess, might work by accident
```

**Correct (hypothesis-driven debugging):**

```python
# Bug: User registration fails

# Step 1: What exactly is failing?
# Error: "IntegrityError: duplicate key email"

# Step 2: Hypothesis: Email uniqueness check is case-sensitive
# Test: Check if different-case duplicate exists
existing = User.query.filter_by(email=data['email'].lower()).first()
print(f"Existing user with email: {existing}")  # Found "ALICE@example.com"

# Step 3: Confirmed hypothesis - make targeted fix
def register_user(data):
    email = data.get('email', '').lower()  # Normalize case
    if User.query.filter_by(email=email).first():
        raise ValueError("Email already registered")
    return create_user({**data, 'email': email})
```

**Signs of shotgun debugging:**
- Adding code without knowing why
- Trying multiple "fixes" at once
- Changes are reverted frequently
- Comments like "not sure why this works"
- Copy-pasting solutions from Stack Overflow without understanding

**Alternative approach:**
1. Stop and reproduce the bug cleanly
2. Form a hypothesis about the cause
3. Design a test for that hypothesis
4. Make ONE change based on results
5. Repeat until bug is found

**When shotgun debugging seems tempting:**
- Take a break - you're likely frustrated
- Explain the problem to someone (rubber duck)
- Write down what you've tried and results
- Start fresh with systematic approach

Reference: [Why Programs Fail](https://www.whyprogramsfail.com/)

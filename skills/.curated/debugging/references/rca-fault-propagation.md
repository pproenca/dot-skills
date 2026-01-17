---
title: Trace Fault Propagation Chains
impact: HIGH
impactDescription: 2-3× faster root cause discovery; traces infection chain from symptom to origin
tags: rca, propagation, chain, cause-effect, origin
---

## Trace Fault Propagation Chains

Bugs often manifest far from their origin. Trace the chain backward from where you see the symptom to where the fault was introduced. The infection (bad state) propagates until it causes a visible failure.

**Incorrect (fixing where symptom appears):**

```python
# Symptom: NullPointerException in render_profile()

def render_profile(user):
    # Symptom appears here
    return f"Welcome, {user.name}"  # NPE: user is None

# Developer adds null check here:
def render_profile(user):
    if user is None:
        return "Welcome, Guest"
    return f"Welcome, {user.name}"

# But WHY was user None? Bug still exists upstream!
```

**Correct (trace propagation backward):**

```python
# Symptom: NullPointerException in render_profile()

# Step 1: Where does user come from?
def handle_request(request):
    user = authenticate(request)  # Returns user or None
    return render_profile(user)

# Step 2: Why does authenticate return None?
def authenticate(request):
    token = request.headers.get('Authorization')
    if not token:
        return None  # No token → None user
    return verify_token(token)

# Step 3: Why is there no token?
# Traced to: Frontend forgot to include auth header after refresh

# Propagation chain:
# Missing header → authenticate returns None → render_profile crashes
#    (origin)            (propagation)              (symptom)

# REAL FIX: Frontend must include auth header
# DEFENSE: authenticate should raise AuthError, not return None
```

**Propagation chain diagram:**

```text
DEFECT (Origin)           INFECTION (Propagation)        FAILURE (Symptom)
┌─────────────────┐      ┌─────────────────────┐      ┌────────────────┐
│ Missing header  │ ───► │ user = None         │ ───► │ NPE in render  │
│ in frontend     │      │ passed around       │      │ (visible crash)│
└─────────────────┘      └─────────────────────┘      └────────────────┘
     Fix HERE            Don't just mask here         Not the root cause
```

**Tracing questions:**
1. Where did this bad value come from?
2. What function/module passed it here?
3. Where was it supposed to be set correctly?
4. What condition caused it to be wrong/missing?

**When NOT to use this pattern:**
- Single-location bugs (cause and symptom are same place)
- Bugs from external systems (trace ends at boundary)

Reference: [Why Programs Fail - Cause-Effect Chains](https://www.whyprogramsfail.com/)

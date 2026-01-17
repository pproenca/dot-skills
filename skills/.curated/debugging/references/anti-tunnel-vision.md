---
title: Avoid Tunnel Vision on Initial Hypothesis
impact: MEDIUM
impactDescription: Prevents wasted hours pursuing wrong theory; 30%+ of bugs aren't where we first look
tags: anti, tunnel-vision, bias, assumptions, open-mind
---

## Avoid Tunnel Vision on Initial Hypothesis

Don't get stuck on your first guess about where the bug is. If evidence doesn't support your hypothesis, let it go and consider alternatives. Confirmation bias makes us see evidence that supports our theory and ignore evidence against it.

**Incorrect (tunnel vision):**

```python
# Bug: Slow page load
# Developer's hypothesis: "Database is slow"

# Spends 3 hours:
# - Adding database indexes
# - Optimizing queries
# - Enabling query caching
# - Profiling database
# Database performance improved 50%, but page still slow

# Evidence ignored:
# - API response time was <100ms in browser network tab
# - Slow load happened even on cache-hit pages
# - JavaScript bundle was 5MB (not checked)

# Actual cause: Unoptimized JavaScript, not database
```

**Correct (open to alternatives):**

```python
# Bug: Slow page load
# Initial hypothesis: "Database is slow"

# Test hypothesis 1: Database
# - Add timing logs: database query = 50ms ✓ Fast
# - Conclusion: Not the database

# Hypothesis falsified! Generate new hypotheses:
# - API processing time?
# - Network latency?
# - Frontend rendering?
# - JavaScript bundle size?

# Test hypothesis 2: API processing
# - Total API time = 80ms ✓ Fast
# - Conclusion: Not the backend

# Test hypothesis 3: Frontend
# - Network tab shows: 5MB JavaScript bundle
# - Parse/execute time: 3 seconds
# - Conclusion: Found it! Unoptimized frontend bundle

# Fixed by code splitting and lazy loading
```

**Signs of tunnel vision:**
- Spending hours on one area without progress
- Ignoring contradictory evidence
- Thinking "it HAS to be here"
- Not considering other possibilities
- Defensive when others suggest alternatives

**Breaking out of tunnel vision:**
1. Set a time limit for each hypothesis (e.g., 30 minutes)
2. Write down ALL possible causes before investigating
3. List evidence FOR and AGAINST your current theory
4. Ask someone else to suggest alternatives
5. Take a break and return with fresh eyes

**When NOT to use this pattern:**
- Strong evidence points to specific location
- You've methodically eliminated other possibilities

Reference: [A Systematic Approach to Debugging](https://ntietz.com/blog/how-i-debug-2023/)

---
title: Rule Out Obvious Causes First
impact: CRITICAL
impactDescription: 60%+ of bugs have simple causes; checking obvious things first saves hours
tags: hypo, obvious, checklist, common-causes, quick-wins
---

## Rule Out Obvious Causes First

Before diving deep, check common causes that explain most bugs. Many developers waste hours on complex investigations when the cause is a simple typo, wrong config, or stale cache.

**Incorrect (jumping to complex causes):**

```bash
# Bug: API returns 404 for endpoint that exists

# Developer assumes complex cause:
# "Must be a routing conflict or middleware issue..."
# Spends 2 hours debugging router configuration
# Checks middleware ordering
# Reviews authentication logic
# Adds extensive logging

# Finally runs: curl -v http://localhost:3000/api/users
# Response: "connection refused"
# Server wasn't running.
```

**Correct (check obvious causes first):**

```bash
# Bug: API returns 404 for endpoint that exists

# OBVIOUS CAUSES CHECKLIST (5 minutes max):

# 1. Is the server running?
curl -v http://localhost:3000/health
# ✗ Connection refused - START THE SERVER

# 2. Is the URL correct?
# Check for typos: /api/users vs /api/user vs /users

# 3. Is the method correct?
# POST vs GET vs PUT?

# 4. Is the environment correct?
# Dev vs staging vs prod URL?

# 5. Is the code deployed?
git status  # Uncommitted changes?
git log -1  # Is this the version you think it is?

# 6. Is there a cache involved?
# Browser cache? CDN cache? API cache?

# 7. Did you save the file?
# IDE might not have auto-saved

# 8. Is the config correct?
# Environment variables set? Config file loaded?
```

**The "stupid things" checklist (check first, always):**
1. Is it running? (server, service, database)
2. Is it the right environment? (dev/staging/prod)
3. Is the code saved and deployed?
4. Is there a cache to clear?
5. Are credentials/config correct?
6. Is there a typo in the name/path/URL?
7. Have you tried restarting it?
8. Are you testing the right thing?

**When NOT to use this pattern:**
- You've already verified the obvious causes
- The bug only appeared after a specific code change

Reference: [Debugging Best Practices](https://niveussolutions.com/debugging-techniques-best-practices/)

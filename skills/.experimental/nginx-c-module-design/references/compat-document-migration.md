---
title: Document Migration Path in Both Old and New Directive Documentation
impact: LOW-MEDIUM
impactDescription: enables admins to migrate without searching changelogs
tags: compat, documentation, migration, cross-reference
---

## Document Migration Path in Both Old and New Directive Documentation

When a directive is deprecated in favor of a new one, document the migration in both places: the old directive's docs should say "use X instead" with an example, and the new directive's docs should say "replaces Y" with a before/after example. This ensures admins find the migration path regardless of which documentation they consult.

**Incorrect (only mentioning the deprecation in the changelog, not in directive documentation):**

```nginx
# CHANGELOG.md says:
#   v3.0: Replaced mymod_rate with mymod_rate_limit
#
# But the directive documentation has no cross-reference:

# --- mymod_rate_limit docs ---
# Syntax: mymod_rate_limit rate
# Default: 100r/s
# Context: http, server, location
#
# Sets the request rate limit.
#
# (no mention that this replaces mymod_rate,
#  admin using mymod_rate has no idea this exists
#  unless they read the full changelog)
```

**Correct (both old and new directive docs cross-reference each other with migration examples):**

```nginx
# --- mymod_rate docs (deprecated) ---
# Syntax: mymod_rate number
# Default: 100
# Context: http, server, location
#
# This directive is deprecated since v3.0 and will be removed in v6.0.
# Use mymod_rate_limit instead.
#
# Migration:
#   # Before (v2.x):
#   mymod_rate 500;
#
#   # After (v3.0+):
#   mymod_rate_limit 500r/s;

# --- mymod_rate_limit docs ---
# Syntax: mymod_rate_limit rate
# Default: 100r/s
# Context: http, server, location
# Appeared in: v3.0
#
# Sets the request rate limit. Replaces the deprecated mymod_rate
# directive, adding support for rate unit suffixes (r/s, r/m).
#
# Migration from mymod_rate:
#   # Before (v2.x) — raw number, always per-second:
#   mymod_rate 500;
#
#   # After (v3.0+) — explicit unit:
#   mymod_rate_limit 500r/s;
```

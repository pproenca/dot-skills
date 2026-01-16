---
title: Verify Root Cause Before Declaring Fixed
impact: HIGH
impactDescription: prevents reopened bugs and wasted cycles
tags: rca, verification, testing, confirmation
---

## Verify Root Cause Before Declaring Fixed

Before closing a bug, verify that your identified cause actually produces the symptom and that your fix eliminates it. A fix that passes tests but doesn't address the root cause will resurface.

**Incorrect (assuming the fix works):**

```python
# Bug: Users report slow search
# Hypothesis: Missing database index
# Fix: Add index and close ticket

# add_index.sql
CREATE INDEX idx_users_email ON users(email);

# Ticket closed as "Fixed"
# But search is still slow...
# The slow query was on products table, not users table
```

**Correct (verify cause and fix):**

```python
# Bug: Users report slow search
# Hypothesis: Missing database index

# Step 1: Verify hypothesis causes symptom
EXPLAIN ANALYZE SELECT * FROM products WHERE name ILIKE '%phone%';
# Result: Seq Scan on products, cost=0..50000, time=2500ms
# Confirmed: Full table scan is the cause

# Step 2: Apply fix
CREATE INDEX idx_products_name_gin ON products USING gin(name gin_trgm_ops);

# Step 3: Verify fix resolves symptom
EXPLAIN ANALYZE SELECT * FROM products WHERE name ILIKE '%phone%';
# Result: Bitmap Index Scan, cost=0..100, time=15ms
# Confirmed: 166x improvement, fix works

# Step 4: Verify in production
# Monitor search latency after deploy: p99 dropped from 2.5s to 50ms
# NOW close the ticket
```

**Verification checklist:**
- [ ] Can reproduce the bug with your identified cause
- [ ] Fix eliminates the symptom completely
- [ ] Regression test added to prevent recurrence
- [ ] Production metrics confirm improvement

Reference: [Medium - Step-by-Step Guide on Performing Root Cause Analysis](https://medium.com/@zeinkap/step-by-step-guide-on-performing-root-cause-analysis-for-software-bugs-dc4cf19d5ae7)

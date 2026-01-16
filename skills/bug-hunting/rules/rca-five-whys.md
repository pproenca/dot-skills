---
title: Apply Five Whys to Find Root Cause
impact: HIGH
impactDescription: prevents recurring bugs permanently
tags: rca, five-whys, root-cause, systematic-analysis
---

## Apply Five Whys to Find Root Cause

Ask "Why?" repeatedly (typically five times) to move from a symptom to its fundamental cause. Stop when you reach a cause that you can fix permanently, not just patch temporarily.

**Incorrect (fixing the symptom):**

```python
# Bug: Production server crashed at 3 AM

# Symptom-level fix:
def handle_request(request):
    try:
        return process_request(request)
    except MemoryError:
        # Just restart and hope for the best
        restart_server()
        return process_request(request)
```

**Correct (Five Whys analysis):**

```markdown
## Five Whys Analysis: Server Crash

**Why 1:** Why did the server crash?
→ Out of memory error at 3 AM

**Why 2:** Why did memory run out at 3 AM?
→ Batch job processes 10M records, loads all into memory

**Why 3:** Why does it load all records into memory?
→ Uses `fetchAll()` instead of paginated queries

**Why 4:** Why was `fetchAll()` used?
→ Developer copy-pasted from small dataset example

**Why 5:** Why wasn't this caught in code review?
→ No guidelines for large dataset handling

## Root Cause: Missing coding guidelines for batch processing

## Fix:
1. Refactor to use pagination (immediate)
2. Add batch processing guidelines to coding standards (permanent)
3. Add memory monitoring alerts (preventive)
```

```python
# Root cause fix: Paginated processing
def process_batch_records():
    page_size = 1000
    offset = 0
    while True:
        records = fetch_records(limit=page_size, offset=offset)
        if not records:
            break
        process_records(records)
        offset += page_size
```

Reference: [BugaSura - Guide to Root Cause Analysis](https://bugasura.io/blog/root-cause-analysis-for-bug-tracking/)

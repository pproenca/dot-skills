---
title: Find WHERE Before Asking WHAT
impact: CRITICAL
impactDescription: Location narrows problem space by 90%+; understanding comes faster with context
tags: hypo, localization, strategy, focus, methodology
---

## Find WHERE Before Asking WHAT

Focus first on locating exactly WHERE the bug occurs, not understanding WHAT the code does. Once you know the precise location, understanding the bug becomes much easier with the surrounding context.

**Incorrect (trying to understand everything):**

```typescript
// Bug: User subscription status is wrong
// Developer tries to understand the entire subscription system first

// "Let me read through all the subscription code..."
// subscription/types.ts (200 lines)
// subscription/service.ts (500 lines)
// subscription/webhook.ts (300 lines)
// subscription/sync.ts (400 lines)
// billing/integration.ts (600 lines)

// 3 hours later: "I understand how subscriptions work now"
// But still don't know where the bug is
```

**Correct (locate first, understand second):**

```typescript
// Bug: User subscription status is wrong
// Step 1: Find WHERE status becomes wrong

// Add checkpoints at system boundaries:
console.log('After webhook received:', status);       // CORRECT
console.log('After webhook processed:', status);      // CORRECT
console.log('After sync to database:', status);       // CORRECT
console.log('After read from database:', status);     // WRONG! <-- HERE

// Step 2: NOW narrow focus to this specific area
// Only need to understand: database write + read logic
// Read 50 lines instead of 2000

// Step 3: Understand just this section
async function getSubscriptionStatus(userId: string) {
  const cached = await cache.get(`sub:${userId}`);
  if (cached) return cached;  // BUG: Cache not invalidated on update!
  return await db.subscriptions.findOne({ userId });
}

// Found bug in 20 minutes by locating first
```

**WHERE-first debugging steps:**
1. Add coarse checkpoints at major boundaries (API, service, database)
2. Identify which section contains the bug
3. Add finer checkpoints within that section
4. Repeat until you find the exact line/function
5. NOW read and understand just that code

**The "traffic light" technique:**
```python
# Mark checkpoints with pass/fail status
print("🟢 Checkpoint A: data valid")     # Known good
print("🟡 Checkpoint B: checking...")    # Testing now
print("🔴 Checkpoint C: data corrupted")  # Known bad
# Bug is between 🟢 and 🔴
```

**When NOT to use this pattern:**
- Architectural/design bugs requiring broad understanding
- When you're new to the codebase and need context anyway

Reference: [Code with Jason - Binary Search Debugging](https://www.codewithjason.com/binary-search-debugging/)

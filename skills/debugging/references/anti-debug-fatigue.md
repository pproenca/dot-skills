---
title: Recognize and Address Debugging Fatigue
impact: MEDIUM
impactDescription: Prevents stupid mistakes from tiredness; fresh perspective finds bugs faster
tags: anti, fatigue, breaks, productivity, mental-health
---

## Recognize and Address Debugging Fatigue

Long debugging sessions lead to diminishing returns. Recognize when you're tired, frustrated, or stuck in a loop. Taking a break often leads to faster resolution than pushing through.

**Incorrect (pushing through fatigue):**

```python
# Hour 1: Start investigating login bug
# Hour 2: Still looking, getting frustrated
# Hour 3: Making random changes, reverting them
# Hour 4: Re-reading same code, finding nothing
# Hour 5: "It makes no sense, the code is correct"
# Hour 6: Finally spot the typo: "usernaem" instead of "username"

# 6 hours wasted on a bug that fresh eyes would catch in minutes
# Fatigue signs ignored: frustration, circular thinking, missing obvious things
```

**Correct (recognize and address fatigue):**

```python
# Hour 1: Start investigating login bug, make progress
# Hour 2: Progress slowing, re-reading same sections

# Fatigue check:
# - Am I making progress? No, last 30 minutes unproductive
# - Am I frustrated? Yes
# - Have I tried the same approach twice? Yes
# - When did I last take a break? 2 hours ago

# Decision: Take a break

# After 15-minute walk:
# Return to code, immediately see: "usernaem" typo
# Total time: 2 hours 15 minutes (not 6 hours)
```

**Fatigue warning signs:**
- Re-reading the same code repeatedly
- Making changes without clear reasoning
- Frustration or anger at the code
- Thinking "this is impossible"
- Missing obvious things (typos, wrong file, wrong branch)
- Forgetting what you've already tried

**Fatigue recovery strategies:**

| Strategy | When to Use |
|----------|-------------|
| 5-min stretch | Every hour |
| 15-min walk | When stuck for 30+ min |
| Explain to colleague | When circular thinking starts |
| Switch to different task | After 2 hours no progress |
| Stop for the day | After 4+ hours no progress |
| Sleep on it | Complex bugs, fresh perspective needed |

**The overnight effect:**
Many developers report solving bugs "immediately" the next morning. Sleep consolidates learning and provides fresh perspective that fatigued brains can't achieve.

**When NOT to use this pattern:**
- Critical production issue requiring immediate fix
- You're making steady progress (don't interrupt flow)

Reference: [Psychology of Debugging](https://www.thoughtfulcode.com/rubber-duck-debugging-psychology/)

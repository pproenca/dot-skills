---
title: Document Symptoms Precisely
impact: CRITICAL
impactDescription: Prevents misdiagnosis and enables pattern matching across similar issues
tags: prob, documentation, symptoms, precision
---

## Document Symptoms Precisely

Record exactly what you observe, not what you think is happening. Precise symptom documentation prevents misdiagnosis and creates a reference you can verify against when testing hypotheses.

**Incorrect (vague description):**

```markdown
Bug Report:
- Title: "App is slow"
- Description: "The app feels sluggish sometimes"
- Steps: "Just use the app normally"
- Expected: "Should be fast"
- Actual: "It's slow"

// Developer has no idea where to start
// "Slow" could mean: startup, rendering, API calls, animations...
```

**Correct (precise symptoms):**

```markdown
Bug Report:
- Title: "2-3 second freeze when opening Settings after using search"
- Description: "UI becomes unresponsive for 2-3 seconds"
- Environment: macOS 14.2, App v2.1.0, 16GB RAM
- Steps to reproduce:
  1. Launch app (fresh start, not from background)
  2. Use search feature to find any item
  3. Click Settings icon in top right
  4. OBSERVE: UI freezes, spinner does not appear
  5. After 2-3 seconds, Settings panel opens
- Expected: Settings opens in <200ms
- Actual: 2-3 second freeze with no visual feedback
- Frequency: 100% reproducible with steps above
- Does NOT occur: if Settings opened before search, or on second open

// Clear starting point: something search does affects Settings load
```

**Symptom documentation checklist:**
- What exactly did you observe? (not interpret)
- When did it start? What changed?
- How often does it occur?
- What are the exact error messages (copy/paste, don't paraphrase)
- What works correctly in similar situations?

**When NOT to use this pattern:**
- Obvious crashes with clear stack traces
- Well-understood issues you've seen before

Reference: [MIT 6.031 - Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)

---
title: Document Exact Reproduction Steps
impact: CRITICAL
impactDescription: enables targeted investigation
tags: repro, documentation, reproduction, debugging-foundation
---

## Document Exact Reproduction Steps

If you cannot reliably reproduce a bug, you cannot fix it. Document the exact sequence of actions, inputs, and environmental conditions that trigger the failure. Never trust a bug report until you've seen the failure yourself.

**Incorrect (vague reproduction steps):**

```markdown
## Bug Report
Title: App crashes sometimes
Steps: Use the app normally, sometimes it crashes
Expected: Should not crash
```

**Correct (precise reproduction steps):**

```markdown
## Bug Report
Title: App crashes when uploading files > 10MB on iOS
Steps:
1. Open app on iOS 17.2, iPhone 15 Pro
2. Navigate to Settings > Import
3. Select a PDF file larger than 10MB
4. Tap "Upload" button
5. Observe crash after upload indicator reaches 40%

Environment: iOS 17.2, iPhone 15 Pro, App v2.3.1
Frequency: 100% reproducible with files > 10MB
Expected: File uploads successfully
Actual: App crashes with no error message
```

**Benefits:**
- Anyone can reproduce the bug independently
- Environmental factors are captured
- Frequency helps prioritize (100% vs intermittent)

Reference: [Atlassian Bug Triage Best Practices](https://www.atlassian.com/agile/software-development/bug-triage)

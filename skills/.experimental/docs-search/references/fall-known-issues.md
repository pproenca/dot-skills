---
title: When docs match the code but reality doesn't, check GitHub issues, status, and forum
tags: fall, known-issues, debugging
---

## When docs match the code but reality doesn't, check GitHub issues, status, and forum

By default when behavior contradicts the documentation, the agent re-reads the documentation. This is the docs-loop trap: the agent assumes the docs are right and the user is wrong, so re-reading "more carefully" must reveal the missed detail. Most of the time, the documentation is right *in principle* but the *implementation has a known bug* — and the canonical record of that lives in GitHub issues, the status page, or the project's Discord, not in the docs.

```text
The fallback ladder (apply in order when docs match but reality doesn't):

  Tier 1 — Status page (rules out a current incident)
     <library>.statuspage.io, status.<library>.com
     "Is the service degraded RIGHT NOW?"

  Tier 2 — GitHub issues, open + closed
     github.com/<owner>/<library>/issues?q=<error-message>
     Search the EXACT error message in quotes first; then keywords
     Check both open AND closed (a "fixed" issue often documents
     workarounds for older versions)

  Tier 3 — Recent releases (last 3 minor versions)
     A regression in a recent release may be live; the bug fix
     may be in the NEXT release, not the current one

  Tier 4 — Discord / community forum / Stack Overflow
     Some libraries triage in Discord first, issues second
     (Tailwind, Effect, shadcn). For these, Discord is canonical.

  Tier 5 — Twitter/X from the author's account
     For very recent libraries, authors sometimes announce
     "known issue, working on it" before filing an issue

The discriminator:
  - Found the exact symptom in an open issue → likely a known bug
  - Found it in a closed issue → check the resolution; may need
    to upgrade past the user's version or apply a workaround
  - Found a recent commit reverting a feature → the user's
    version may have the broken code; advise upgrade or downgrade
  - Nothing matches → escalate to "this is a new bug" path
    (file an issue, prepare a minimal repro)

When NOT to apply:
  - User's code obviously doesn't match the docs (typo, wrong
    function name) → fix the code, do not fall back
  - The question is "how do I do X?" not "X isn't working" →
    wrong category; this rule is for divergence, not discovery
```

The mechanical trigger: when re-reading docs would be the next action and the user already showed correct-looking code, switch to the issue tracker first. The docs are not the source of truth when the *behavior is buggy* — only when the *contract is documented*.

Reference: [The react-hook-form skill's `formstate-async-submit-lifecycle` rule citing GH discussion #10103 — exactly this pattern](../../../../skills/.curated/react-hook-form/SKILL.md)

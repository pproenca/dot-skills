---
title: Read the changelog before the reference for "did X change" questions
tags: ver, changelog, breaking-changes
---

## Read the changelog before the reference for "did X change" questions

By default when something was working and now isn't, the agent re-reads the reference page for the affected API. This misses the single most common cause: the API changed in a recent release. The reference page documents the *current* state — it cannot tell you whether the behavior the user is seeing matches the version they have. The move is to **read the changelog before the reference** whenever the question contains drift signal.

```text
Triggers that demand changelog-first (do NOT skip):

  - "Used to work, now doesn't since I upgraded"
  - "After bumping <library> to <version>, X broke"
  - "Worked in dev but not in prod" (often = version skew)
  - "The docs say X but I'm getting Y"
  - "Was this API renamed/removed?"
  - "Why is my code emitting a deprecation warning?"

The changelog read sequence:

  1. Locate the changelog. Common spots:
     - <docs-root>/changelog
     - <library-repo>/CHANGELOG.md
     - <library-repo>/releases (GitHub releases tab)
     - <docs-root>/blog (some libraries publish breaking changes
        as blog posts; nuqs does this with nuqs-2.5)

  2. Read entries between the user's version and "latest" (or the
     version they were upgrading FROM and TO).

  3. Grep the changelog for the affected API name first; if it
     appears, you have the answer in 30 seconds. If it doesn't,
     scan for "breaking" or "BREAKING CHANGE" entries.

  4. ONLY THEN open the reference page — and read it in light of
     what the changelog said.

The cheap test:
  After reading the changelog, can you state "<thing> changed
  from X to Y in version Z, and the user is on version W"? If
  yes, the answer is reachable. If no, the changelog wasn't
  the source — escalate to known-issues (`fall-known-issues`).

Anti-pattern:
  Skipping the changelog because "I already know this library."
  Library knowledge from training data ages out fast — the
  changelog is the truth.
```

The mechanical trigger: any question with the words "since," "after upgrading," "used to work," "deprecated," or "removed" — open the changelog before the reference. If you skip this and answer from the current reference page, you will silently mislead.

Reference: [Keep a Changelog — the canonical format for human- and AI-readable changelogs](https://keepachangelog.com/)

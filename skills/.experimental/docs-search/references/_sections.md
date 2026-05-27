# Sections

This file defines the four orthogonal categories of moves an agent makes when
reaching for a library's official documentation. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by the sequence
they fire when handling a real lookup: choose where to read → match the right
version → fall back when official sources fail → capture findings so the next
lookup is cheaper.

The four categories are **orthogonal** — applying one does not satisfy the
others. Match the symptom in front of you:

- "I'm about to search the docs" → `src` (which source for which question?)
- "I'm about to read a reference page" → `ver` (which version am I reading?)
- "Docs match the user's code but reality doesn't" → `fall` (issues, samples)
- "I just found the canonical entry points" → `capture` (write to registry/)

This skill is the **methodology layer**. Per-library facts (Stripe's dated
API model, Tailwind's v3/v4 split, Anthropic's llms.txt presence) are not
rules — they are reference data living in `registry/`, intentionally empty at
v0.1.0 and growing only when real lookups demand new entries.

---

## 1. Choose Source (src)

**Description:** Where to read, given what the user is actually asking. The
default failure mode is treating every lookup as "search the docs" — which
produces a Google-style scan that misses changelog-only answers, ignores AI-
canonical formats like `llms.txt`, and lands on the reference page even when
the answer is in a guide or a known-issues thread. Covers question
classification (changelog vs reference vs idiom vs known-bug) and the
`llms.txt` probe that should precede any HTML scraping.

## 2. Match Version (ver)

**Description:** Reading the right version of the reference. The default
failure mode is reading `latest` docs while the user is on an older release
— producing technically-correct-but-actually-wrong answers. Covers finding
the version selector before reading any reference page, and consulting the
changelog before the reference when the question is "did X change since I
upgraded?"

## 3. Fall Back (fall)

**Description:** What to do when the canonical source fails — either docs
match the user's code but reality contradicts them, or the question is
about idioms that the prose docs don't capture. The default failure mode
is re-reading the same doc page after each failed attempt. Covers
known-issues fallback (GitHub issues, status page, Discord) and the
examples-over-prose move for idiom questions.

## 4. Capture for Reuse (capture)

**Description:** Recording what you discovered about a library's docs
topography so the next agent doesn't redo the discovery work. The default
failure mode is treating each lookup as one-shot, then re-discovering the
same root URL, changelog path, and samples repo next time. Covers writing
the `docs:` section of `knowledge/libraries/<library>.md` (the repo-root
shared knowledge graph) once you've found the canonical entry points. The
file is shared with `code-distill`, which writes the `code:` section — each
skill owns one section and never overwrites the other.

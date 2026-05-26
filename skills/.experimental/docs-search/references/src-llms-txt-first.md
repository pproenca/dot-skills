---
title: Probe llms.txt before scraping HTML — AI-canonical format takes priority
tags: src, llms-txt, ai-canonical
---

## Probe llms.txt before scraping HTML — AI-canonical format takes priority

By default the agent goes straight to the human-facing HTML docs and either uses WebFetch on rich HTML pages or runs a site search. This wastes tokens on navigation chrome and produces noisy results. A growing number of libraries publish **`llms.txt`** (and sometimes `llms-full.txt`) — a flat, structured, AI-targeted index of the same content. Probe for it before any HTML scraping.

```text
The probe (run once per library, then cache result in registry/):

  1. Try <docs-root>/llms.txt
     e.g. https://anthropic.com/llms.txt
          https://effect.website/llms.txt
          https://tailwindcss.com/llms.txt
     200 → use it; it lists section URLs in AI-friendly order

  2. Try <docs-root>/llms-full.txt
     Some libraries publish a "everything in one file" variant
     200 → use it for broad-scan questions; smaller for targeted ones

  3. Try <library-root>/llms.txt (some put it at the site root)

  4. Check the library's GitHub README for an llms.txt mention

  5. Only after 1–4 fail → fall back to HTML doc scraping

Why this matters:
  - llms.txt is the author's INTENT for how AI should consume the docs
  - It typically points to the canonical section URLs, skipping marketing
    pages, version-switcher chrome, and out-of-date duplicates
  - Token-cheaper: no JS, no CSS, no nav, no footer, no analytics scripts
  - When present, it is THE source of truth for navigation

When to revisit:
  - Library version bump → re-probe (llms.txt is a recent convention,
    libraries are still adding it)
  - Lookup feels unusually noisy → check whether llms.txt now exists

Anti-pattern:
  Caching "no llms.txt" in registry without an expiry. The set of
  libraries with llms.txt grows monthly — re-probe on each major
  version of the library or on registry refresh.
```

The mechanical trigger: before any `WebFetch` of a docs page, check the registry for `llms.txt` URL; if absent, probe before scraping. Once probed, record the result in `registry/<library>.md` so the next lookup skips this step.

Reference: [llmstxt.org — the llms.txt convention proposal and registry of adopting sites](https://llmstxt.org/)

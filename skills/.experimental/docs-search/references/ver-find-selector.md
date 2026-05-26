---
title: Find the version selector before reading any reference page
tags: ver, versioning, selector
---

## Find the version selector before reading any reference page

By default the agent reads `latest` documentation and assumes the user is on the latest version of the library. This produces technically-correct-but-actually-wrong answers — references to APIs that don't exist yet in the user's version, examples using syntax from a future release, or deprecation warnings for code the user wrote against a stable older API. The move is to **find the version selector before reading any reference page** and pin the lookup to the user's actual version.

```text
The version-pinning sequence (apply BEFORE reading any reference page):

  1. Determine the user's version. In priority order:
     a. Ask the user directly: "Which version of <library> are you on?"
     b. Read package.json / Cargo.toml / requirements.txt / go.mod
        in the project root
     c. Read the lockfile (package-lock.json, yarn.lock, etc.) for
        the actual resolved version
     d. Check imports for version-specific patterns (e.g. `from
        "openai/resources/beta"` signals a different version than
        `from "openai/resources/messages"`)

  2. Find the version selector on the docs site. Common patterns:
     - Dropdown in the top-right (React, Vue, Next.js)
     - Subdomain (v2.tailwindcss.com vs tailwindcss.com)
     - URL path (docs.python.org/3.11 vs /3.12)
     - Date in URL (Stripe: /docs/api?api-version=2023-10-16)

  3. Switch the docs to the user's version, THEN read.

  4. If no version selector exists, the library is either
     unversioned (read latest) or single-version (note in registry).

Cases that get this wrong by default:

  - Tailwind v4 vs v3 — utility behaviors differ; reading v4 docs
    when user is on v3 produces hallucinated utility classes
  - React 19 vs 18 — Server Components / use() / form actions
    don't exist before 19
  - Next.js 13 → 14 → 15 → 16 — App Router conventions change
  - Effect 3.x vs 4-beta — ServiceMap → Context.Service rename
```

The mechanical trigger: before WebFetching any reference page, state the version you are reading and the version the user is on. If they don't match, switch first. The two-minute cost of pinning saves the half-hour cost of debugging an answer that doesn't apply.

Reference: [Stripe's dated API versioning model — exemplary case where ignoring version selector silently produces wrong behavior](https://stripe.com/docs/upgrades)

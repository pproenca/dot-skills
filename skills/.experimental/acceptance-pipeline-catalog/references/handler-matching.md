---
title: Match Steps by Exact Text
impact: HIGH
impactDescription: wrong matching routes steps to incorrect handlers or drops them entirely, producing 100% false-pass rate on misrouted scenario executions
tags: handler, matching, exact-text, portable
---

## Match Steps by Exact Text

Step handlers connect Gherkin step text to project behavior. The matching strategy determines how a step like `"the result is <result>"` finds its handler. The spec defines exact text matching as the portable baseline.

### Spec Requirements

The portable baseline matches handlers by **exact `text` value**, not by keyword:

```text
"the result is <result>"
```

This means:
- `Given the result is <result>` and `And the result is <result>` route to the **same handler** because both have text `"the result is <result>"`.
- The keyword (`Given`, `When`, `Then`, `And`) is not part of the match.
- Matching happens on the **template** text (with `<placeholders>` still present), not on resolved text.

### Optional Extensions

A project may add regex or expression matching (e.g., Cucumber-style expressions), but exact text matching is the portable baseline that every conforming implementation must support.

### Why Match on Template Text

Matching on the unresolved template means one handler registration covers all example rows. If matching happened after placeholder resolution, you would need a handler for `"the result is accepted"`, another for `"the result is rejected"`, etc. — defeating the purpose of parameterization.

### Examples

**Incorrect (matches on keyword + text, causing duplicate handler registrations):**

```json
{
  "handlers": {
    "Given the result is <result>": "handleGivenResult",
    "And the result is <result>": "handleAndResult"
  }
}
```

**Correct (matches on text only, single handler covers all keywords):**

```json
{
  "handlers": {
    "the result is <result>": "handleResult"
  }
}
```

### Why Ignore the Keyword

Keywords express human intent (Given = precondition, When = action, Then = assertion) but have no execution semantics. The same step text might appear as `Given` in one scenario and `And` in another. Matching on text only keeps the handler registry simple and avoids duplicate registrations for the same behavior.

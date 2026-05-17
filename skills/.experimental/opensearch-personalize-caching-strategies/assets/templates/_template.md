---
title: {Action-Oriented Title in Imperative Mood}
impact: {CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW}
impactDescription: {quantified impact — e.g. "70% Personalize TPS reduction", "8-15% NDCG@10 lift", "prevents stampede on hot keys"}
tags: {category-prefix}, {technique-1}, {technique-2}, {tool-or-tech}
---

## {Same as title}

{1-3 sentences explaining the WHY — what happens when this pattern is missing, what the cascade or cost mechanism is. This is the highest-signal section. The model generalises from understood reasoning, not from dictation: explain the mechanism, not the rule.}

**Incorrect ({label describing what's wrong}):**

```{language}
{Production-realistic code showing the anti-pattern. Avoid strawman examples — the bad code should be the kind a competent engineer would actually write.}
{// Comments explain the COST (latency, cost, failure mode) not the syntax}
```

**Correct ({label describing what's right}):**

```{language}
{Production-realistic code showing the right pattern. Keep the diff from "Incorrect" minimal — same variable names, same overall structure, the change is visible in a few lines.}
{// Comments explain the BENEFIT (saved cost, latency win, prevented failure)}
```

{Optional sections — include only when they add information:}

**Why {specific design choice}:**
{Detail-level explanation of a tricky bit. Useful for nuances like "why 60s TTL not 30s?" or "why SHA-256 not MD5?".}

**When NOT to use this pattern:**
- {Exception 1 with reason}
- {Exception 2 with reason}

**Alternative ({context}):**
{Alternative approach for a specific context, e.g. "with Memcached instead of Redis," "for write-heavy paths," "when running cluster mode."}

**Companion rules:**
- [`{prefix}-{slug}`](../{prefix}-{slug}.md) — {one-line description of how it relates}

**Validation:**
{How to verify in observability that the rule is being followed — usually a specific metric to watch.}

Reference: [{Source 1 Title}]({URL 1}) · [{Source 2 Title}]({URL 2})

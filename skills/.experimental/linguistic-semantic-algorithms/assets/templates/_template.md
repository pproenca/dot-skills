---
title: {Imperative-verb title, e.g., "Use X for Y" or "Avoid Z"}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified: "reduces N to M", "enables X", "prevents Y", "automatic Z"}
tags: {category-prefix}, {algorithm-name}, {2-3 related concepts}
---

## {Same title as frontmatter}

{1-3 sentences explaining WHY this algorithm matters for codebase analysis. Focus on what *non-obvious* information it extracts that grep/eyeball cannot. Include the rough complexity class if relevant. Cite the canonical paper or tool by name.}

**Incorrect ({describe the naive approach}):**

```{language}
# Naive approach an agent would default to.
# Show why it fails on a realistic codebase scenario —
# a strawman is worse than no example.
```

**Correct ({describe the algorithmic approach}):**

```{language}
# Production-realistic code using the algorithm.
# Use real Python/JS/etc. libraries (gensim, networkx, sklearn, etc.) —
# not pseudocode unless absolutely necessary.
# Include a small example of the OUTPUT in comments
# so the reader sees what they get back.
```

{Optional sections — include any that help the reader apply the algorithm:}

**Tune the parameters:** {if there are dials (k, threshold, etc.), name them and the effect of moving them}

**Use [tool name] for production.** {Point at the canonical OSS tool that implements this rule, since reimplementing for serious use is rarely worth it}

**Combine with `{partner-rule-id}`:** {if two algorithms compound (e.g., minhash + suffix-array), explain the pipeline}

**When NOT to apply:**
- {Specific scenario 1 where the algorithm fails or is wasted}
- {Specific scenario 2}

Reference: [{Canonical paper or tool title}]({URL}), [{Second reference}]({URL})

---

## Authoring guidance for adding rules to this skill

- **Title pattern**: imperative-verb. The validator accepts `Use`, `Avoid`, `Cache`, `Run`, `Apply`, `Tag`, etc. and a generic `[A-Z][a-z]+ ...` fallback. If you write a non-imperative title, the validator will warn.
- **impactDescription must use quantified language**: numeric improvements (`2-10x improvement`, `200ms savings`, `O(n) to O(1)`) OR outcome verbs (`reduces`, `prevents`, `eliminates`, `enables`, `automatic`, `reveals` — *not* in that list — use the validator-accepted ones).
- **First tag MUST be the category prefix** (e.g., `concept`, `sim`, `graph`, `mine`, `clone`, `local`, `ling`, `risk`).
- **Code blocks need language specifiers** (```python, ```bash, ```sql).
- **Examples must be production-realistic** — no `foo`, `bar`, `MyClass`, `tmp`, `data1`. Use domain-appropriate names (e.g., for a housesitting domain: `Sitter`, `Listing`, `Host`, `Application`, `Booking`).
- **Length**: 80-200 lines per rule. Above 200, consider splitting into related rules.
- **References**: link to canonical papers or tool docs — never tutorial sites or blog posts without data.

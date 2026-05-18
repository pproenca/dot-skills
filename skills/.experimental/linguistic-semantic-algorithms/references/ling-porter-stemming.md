---
title: Apply Porter Stemming to Unify Singular and Plural Token Forms
impact: MEDIUM
impactDescription: collapses 10-20% of vocabulary into shared roots without semantic loss
tags: ling, stemming, porter, normalization, preprocessing
---

## Apply Porter Stemming to Unify Singular and Plural Token Forms

After splitting and expanding, you still have `user/users/userService/Userize` as distinct tokens, even though all four share the root `user`. The Porter stemmer (1980, still the standard) reduces every word to a deterministic root via a small set of rewrite rules. It's not a lemmatizer (no dictionary) — `users → user`, `running → run`, `policies → polici`. The "polici" stems are ugly but they're consistent: every form of "policy" maps to the same root token, which is all downstream algorithms need. Use it in any pipeline that compares vocabularies, ranks documents, or clusters by content.

**Incorrect (every grammatical variant as a separate token — recall drops):**

```python
# Bug report says: "policies are being deleted incorrectly"
# Source uses: "policy", "policyService", "Policies"
# TF-IDF matches nothing — different tokens entirely.

import collections, re

WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")
def tokens(text):
    return WORD.findall(text.lower())

counts = collections.Counter(tokens("policy policies policy_service Policies"))
# {'policy': 1, 'policies': 1, 'policy_service': 1, 'Policies': 1} — wait, normalize case at least.
# Even after lowercasing: {'policy': 1, 'policies': 2, 'policy_service': 1}
# Should be one bucket; it's three.
```

**Correct (lowercase + stem — singular/plural/derivational forms collapse):**

```python
import re, collections
from nltk.stem.porter import PorterStemmer       # pip install nltk

stemmer = PorterStemmer()
WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")

def normalize(text: str) -> list[str]:
    return [stemmer.stem(w) for w in WORD.findall(text.lower())]

# Apply uniformly to source and query
source_tokens = normalize("policy policies policy_service Policies")
query_tokens = normalize("policies are being deleted incorrectly")

print(collections.Counter(source_tokens))
# {'polici': 3, 'polici_servic': 1}
print(query_tokens)
# ['polici', 'are', 'be', 'delet', 'incorrectli']
# Now 'polici' matches between source and query — recall is restored.
```

**Use Snowball / Porter2 in production.** The original 1980 Porter has minor bugs; Snowball (Porter's own 2001 successor, in NLTK as `SnowballStemmer("english")`) fixes them and supports 16+ languages. For multilingual corpora, Snowball is the right choice.

**Stemming destroys human-readability of the index** — you can't show users "polici" as a search hint. Keep the original→stem map and display the most-frequent original form for any stem.

**Don't double-stem.** Stemming is idempotent on its own output, but applying two different stemmers (Porter then Snowball) produces noise. Pick one and stick with it across all stages of a pipeline.

**Lemmatization is better when accuracy matters, but slower.** spaCy lemmatization produces real words (`policies → policy`, `running → run`) using a dictionary. For information retrieval over millions of files, Porter's speed wins; for human-facing analysis (top-terms reports), use spaCy's lemmatizer.

**Combine with `ling-abbreviation-expansion`** first, then stem. Order matters: stem before expansion produces `mgr → mgr` (no rule fires); expand-then-stem produces `mgr → manager → manag` which matches all variants of management. Pipeline order: split → expand → stem.

**This rule alone is the smallest improvement in this category** but compounds with the others. The full preprocessing chain (split + expand + stem) typically collapses 30-50% of vocabulary into shared roots — which is the difference between TF-IDF working and TF-IDF being noise on identifier-heavy code.

**When NOT to apply:**
- Languages with rich morphology (Finnish, Turkish) — Porter is English-only; use a language-appropriate stemmer or lemmatizer
- Single-token identifier search (find every place that defines `User` class) — stemming over-matches; use exact match instead

Reference: [Porter, An algorithm for suffix stripping (Program 1980)](https://www.cs.toronto.edu/~frank/csc2501/Readings/R2_Porter/Porter-1980.pdf), [Snowball — multilingual stemmer](https://snowballstem.org/)

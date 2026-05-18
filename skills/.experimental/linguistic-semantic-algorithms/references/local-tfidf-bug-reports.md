---
title: Rank Source Files by TF-IDF Against Bug Report Text for Localization
impact: MEDIUM-HIGH
impactDescription: reduces a 10k-file repo to a 10-file candidate list from a bug report
tags: local, tfidf, bug-localization, ir, vsm
---

## Rank Source Files by TF-IDF Against Bug Report Text for Localization

When a user files a bug, the agent's first job is to figure out which files are most likely to contain the defect. The canonical IR approach is to treat the bug report as a query and the source files as documents — index files with TF-IDF, cosine-rank against the report's vocabulary. The top-N files become the agent's reading list. This is Lukins/Kraft/Etzkorn's bug-localization technique (2008); it scores in the top decile on real bug-tracker benchmarks (Bugzilla, Eclipse, Mozilla) for a method that runs in seconds.

**Incorrect (grep bug-report keywords against source — picks up irrelevant matches):**

```bash
# Bug says: "checkout fails with 'card declined' after retry"
# Grep is unranked and matches generic terms:
grep -rl "card declined" src/
# Returns: a fixture, two test files, one error-message constants file.
# Misses checkout-retry.py which doesn't contain the literal phrase.
```

**Correct (TF-IDF vectorize source files + bug query, rank by cosine):**

```python
import re, pathlib
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# 1. Build TF-IDF index over source files
WORD = r"\b[A-Za-z_][A-Za-z0-9_]{2,}\b"
files = list(pathlib.Path("src").rglob("*.py"))
docs = [p.read_text(errors="ignore") for p in files]
vec = TfidfVectorizer(token_pattern=WORD, lowercase=True,
                     min_df=2, max_df=0.5, sublinear_tf=True)
doc_matrix = vec.fit_transform(docs)

# 2. The bug report is a "document" — vectorize it with the same vocabulary
bug_report = (
    "Checkout fails after retry with 'card declined' error. "
    "User receives a confirmation email anyway. "
    "Affected route: /api/v2/checkout/retry"
)
q = vec.transform([bug_report])

# 3. Cosine rank
sims = cosine_similarity(q, doc_matrix).flatten()
top = sims.argsort()[::-1][:10]
for i in top:
    print(f"  {sims[i]:.3f}  {files[i]}")
# 0.412  src/api/v2/checkout_retry.py     <- never matched on grep
# 0.398  src/billing/decline_handler.py
# 0.371  src/payments/stripe/retry.py
# 0.354  src/notifications/checkout_email.py
```

**Tokenize identifiers before indexing.** Bug reports use natural language (`card declined`); source uses identifiers (`cardDeclined`, `card_declined_error`). Apply `ling-camel-snake-split` to the source tokens so "card", "declined" appear as separate vocabulary entries that match the report's words.

**Expand the query with synonyms** via `ling-abbreviation-expansion` and a small domain glossary. Bug report says "user got billed twice"; source uses "double charge". A glossary maps `billed → charged` and the query matches the right files.

**Weight stack-trace tokens higher.** If the report includes a stack trace, extract the file/method names and append them to the query with higher weight. A real bug report's most informative tokens almost always live in the stack trace.

**Combine with `local-history-prior-localization`:** files that have historically been involved in bug fixes (see `mine-bug-fix-density`) get a Bayesian-prior boost. The combined score `0.7 × TF-IDF + 0.3 × log(fix_count)` outperforms either signal alone on real-world IR-based bug-localization benchmarks.

**Use BM25 instead** (see `local-bm25-saturation`) on longer documents — TF saturation matters once files exceed ~500 LoC.

**When NOT to apply:**
- Reports that are pure stack traces with no description — TF-IDF on a stack trace alone is brittle; just open the top frame's file directly
- Mono-language repos with extreme identifier reuse — every file scores similar TF-IDF; the technique needs vocabulary diversity to discriminate

Reference: [Lukins, Kraft & Etzkorn, Bug Localization Using LDA (ICPC 2008)](https://ieeexplore.ieee.org/document/4556142), [Saha et al., Improving Bug Localization Using Structured IR (ASE 2013)](https://www.cs.utexas.edu/~mitra/csFall2013/cs388/resources/ase2013_saha.pdf)

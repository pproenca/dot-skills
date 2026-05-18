---
title: Use TF-IDF Vector Space Model for File Similarity When No GPU Is Available
impact: MEDIUM-HIGH
impactDescription: enables semantic-ish file search at 100x lower cost than neural embeddings
tags: sim, vsm, tfidf, cosine-similarity, lightweight
---

## Use TF-IDF Vector Space Model for File Similarity When No GPU Is Available

CodeBERT embeddings dominate quality, but they need a GPU to build and 500MB+ to ship. For "find files like *this one*" inside an agent loop where every call is in-context, the classical TF-IDF Vector Space Model is the right tool: build the matrix once in milliseconds, query in microseconds, and the answers are good enough to surface non-obvious file relationships. It catches files with shared vocabulary even when imports don't link them — the "everyone forgot this is also a Booking service" case. Use neural embeddings for semantic equivalence across renames; use VSM for "what else uses the same business words?".

**Incorrect (filename / path substring matching — misses files that talk about the same thing under different names):**

```python
# Looking for files "like" billing/invoice_generator.py:
# substring grep on path matches only the obvious ones.
import pathlib

target = "invoice"
matches = [p for p in pathlib.Path("src").rglob("*.py") if target in p.name]
# Returns: invoice_generator.py, invoice_email.py
# Misses: charges_processor.py (uses the same vocabulary but different filename)
```

**Correct (TF-IDF VSM + cosine — query by content, not by filename):**

```python
import pathlib
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

files = list(pathlib.Path("src").rglob("*.py"))
texts = [p.read_text(errors="ignore") for p in files]

# token_pattern picks identifier tokens with length >= 3
vec = TfidfVectorizer(
    token_pattern=r"\b[A-Za-z_][A-Za-z0-9_]{2,}\b",
    lowercase=True,
    min_df=3,
    max_df=0.5,            # drop ubiquitous tokens
    sublinear_tf=True,     # 1 + log(tf) — saturates frequency
)
matrix = vec.fit_transform(texts)         # sparse, fits in RAM for ~1M LoC

# Query: find the 10 files most similar to billing/invoice_generator.py
target_idx = files.index(pathlib.Path("src/billing/invoice_generator.py"))
sims = cosine_similarity(matrix[target_idx], matrix).flatten()
top = np.argsort(-sims)[:11][1:]          # skip self
for i in top:
    print(f"  {sims[i]:.3f}  {files[i]}")
# 0.612  src/billing/charges_processor.py    <- same vocabulary, different name
# 0.488  src/billing/subscription_renewal.py
# 0.401  src/admin/finance_report.py          <- non-obvious link to admin pkg
# 0.388  src/payments/stripe_webhook.py
```

**Sublinear TF + capped DF is non-negotiable.** Without `sublinear_tf=True`, a single very long file with one repeated word dominates similarity. Without `max_df=0.5`, ubiquitous framework tokens (`return`, `self`, `import`) overwhelm domain signal.

**Tune the tokenizer to your language.** The default scikit-learn tokenizer drops single characters and splits on whitespace — works for Python and JS. For Java, add `\w+\.\w+` to capture qualified identifiers. For Go, the default works.

**Combine with `concept-entity-name-resolution` upstream.** Apply the canonical variant map before TF-IDF — otherwise `user` and `usr` produce two separate columns and similarity dilutes.

**When NOT to apply:**
- When you need cross-language matching — VSM is purely lexical; use CodeBERT/UniXcoder
- Codebases where naming has drifted heavily — entity resolution alone won't save you; embeddings or PDG is required

Reference: [Salton, Wong, Yang — A vector space model for automatic indexing (1975)](https://dl.acm.org/doi/10.1145/361219.361220), [scikit-learn TfidfVectorizer docs](https://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.TfidfVectorizer.html)

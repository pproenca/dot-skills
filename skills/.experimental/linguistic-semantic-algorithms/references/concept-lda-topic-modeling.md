---
title: Use LDA over Identifier Tokens to Surface Latent Domain Topics
impact: CRITICAL
impactDescription: reduces a 100k-file codebase to 10-20 named topics in one pass
tags: concept, lda, topic-modeling, nlp, gensim
---

## Use LDA over Identifier Tokens to Surface Latent Domain Topics

Latent Dirichlet Allocation (Blei/Ng/Jordan, 2003) treats each source file as a "document" of identifier tokens and infers a fixed number of topics — distributions of words that co-occur. On real codebases the topics line up almost exactly with business sub-domains: `{user, account, email, session, login}` (auth), `{invoice, charge, subscription, plan, billing}` (billing), `{sitter, listing, host, application, stay}` (housesitting). LDA finds these clusters *before* you open a single file, even when no module names them. The cost of skipping it: weeks of grep-driven exploration that systematically misses themes spread across the tree.

**Incorrect (naïve domain inference — biased toward framework noise):**

```python
# Walk top-level READMEs and the 20 most-imported files,
# then guess at the domain. Misses business themes spread
# across many small files, and overweights framework code.
from collections import Counter
import ast, pathlib

import_counts = Counter()
for p in pathlib.Path("src").rglob("*.py"):
    tree = ast.parse(p.read_text())
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module:
            import_counts[node.module] += 1

# Top-20 imports are `django.db.models`, `rest_framework`,
# `typing`, `logging` — zero signal about the business domain.
print(import_counts.most_common(20))
```

**Correct (LDA over identifier tokens — topics map to sub-domains):**

```python
import re, pathlib
from gensim import corpora, models

SPLIT = re.compile(r"[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)|\d+")

def file_tokens(path: pathlib.Path) -> list[str]:
    src = path.read_text(errors="ignore")
    return [w.lower() for w in SPLIT.findall(src) if len(w) > 2]

docs = [file_tokens(p) for p in pathlib.Path("src").rglob("*.py")]
dictionary = corpora.Dictionary(docs)
dictionary.filter_extremes(no_below=5, no_above=0.5)   # drop rares & stopwords
corpus = [dictionary.doc2bow(d) for d in docs]

lda = models.LdaMulticore(
    corpus, id2word=dictionary, num_topics=15, passes=10, random_state=42,
)

for tid, words in lda.print_topics(num_words=8):
    print(f"Topic {tid}: {words}")
# Topic 3: 0.07*"sitter" + 0.05*"listing" + 0.04*"host" + 0.03*"application"
# Topic 7: 0.08*"invoice" + 0.06*"subscription" + 0.05*"plan" + 0.04*"charge"
# Topic 12: 0.09*"booking" + 0.06*"stay" + 0.05*"pet" + 0.04*"review"
```

**Choosing topic count:** use coherence score (`CoherenceModel(model=lda, texts=docs, coherence="c_v")`), sweep k ∈ {5, 10, 15, 20, 30}, pick the local max. For repos under 5k files, k = 10 is a reasonable starting point.

**Preprocessing matters more than the algorithm:** apply `ling-camel-snake-split` and `ling-abbreviation-expansion` to tokens first. Skipping these steps means `userId` and `user_id` look like two unrelated words and topics fragment.

**When NOT to apply:**
- Repos under ~200 files — eyeballing is faster and LDA's topics are unstable on small corpora
- Monolithic single-file libraries — there's nothing to cluster

Reference: [Latent Dirichlet Allocation (Blei et al., 2003)](https://www.jmlr.org/papers/v3/blei03a.html), [gensim LDA tutorial](https://radimrehurek.com/gensim/auto_examples/tutorials/run_lda.html)

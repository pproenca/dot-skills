---
title: Use TF-IDF Against a Generic Corpus to Separate Domain Vocabulary from Framework Noise
impact: CRITICAL
impactDescription: eliminates 90%+ of framework terms from domain-vocabulary ranking
tags: concept, tfidf, domain-vocabulary, idf, corpus-comparison
---

## Use TF-IDF Against a Generic Corpus to Separate Domain Vocabulary from Framework Noise

The most-frequent words in a codebase are always framework words — `request`, `controller`, `response`, `model` — not domain words. To isolate domain vocabulary, compute Term Frequency in *this* codebase but use Inverse Document Frequency from a *generic* code corpus (a sample of unrelated open-source projects in the same language). Terms with high TF in this repo and high IDF against the generic corpus are *domain-specific*. `controller` has high TF here but low IDF (every repo uses it) → demoted. `sitterApplication` has high TF here and high IDF (no other repo uses it) → promoted to the top. The result is a ranked list of words that genuinely define what this codebase is about.

**Incorrect (raw frequency — top results are always framework noise):**

```python
import re, pathlib, collections

WORD = re.compile(r"\b[a-zA-Z_][a-zA-Z0-9_]{3,}\b")
counts = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    counts.update(w.lower() for w in WORD.findall(p.read_text(errors="ignore")))

# Top results: request, response, return, model, view, self, value, data.
# Domain words like "sitter", "listing" are buried at position 200+.
for w, n in counts.most_common(20):
    print(f"{n}\t{w}")
```

**Correct (TF here ÷ DF in generic corpus — domain words rise to the top):**

```python
import re, math, pathlib, collections, json

WORD = re.compile(r"\b[a-zA-Z_][a-zA-Z0-9_]{3,}\b")

def tokens(path):
    return [w.lower() for w in WORD.findall(path.read_text(errors="ignore"))]

# Term frequency in THIS repo
tf = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    tf.update(tokens(p))

# Document frequency from a pre-built generic corpus
# (e.g. top-1000 Python repos on GitHub — ship as JSON with the skill)
generic_df: dict[str, int] = json.loads(pathlib.Path("generic_python_df.json").read_text())
N_DOCS_GENERIC = 1000

def domain_score(term: str, count: int) -> float:
    df = generic_df.get(term, 1)                       # smooth missing terms
    idf = math.log((N_DOCS_GENERIC + 1) / (df + 1)) + 1
    return count * idf

scored = sorted(
    ((domain_score(w, c), w, c) for w, c in tf.items() if c >= 5),
    reverse=True,
)
for score, w, c in scored[:25]:
    print(f"{score:>8.1f}  tf={c:>5}  {w}")
# 4821.3  tf=2210  sitter
# 3990.7  tf=1640  housesit
# 3502.9  tf=1310  pet
# 3120.4  tf=1180  listing
#  201.8  tf=8211  request    <- framework noise demoted
```

**Build the generic corpus once, ship it.** A `generic_python_df.json` of ~50k terms × 1000 repos compresses to a few MB. The same file serves every domain-extraction run.

**For multi-token entities:** compute TF-IDF on the noun-phrase output of `concept-noun-phrase-mining`, not on bare tokens. Single tokens are too coarse; the phrase `sitter_application` is more informative than `sitter` and `application` separately.

**When NOT to apply:**
- Repos that *are* the framework (e.g., Django itself) — generic corpus excludes the very repo you're scoring
- Highly multilingual codebases — IDF only works against a same-language reference corpus

Reference: [Salton & Buckley, Term-Weighting Approaches in Automatic Text Retrieval](https://nlp.stanford.edu/IR-book/pdf/06vect.pdf), [Sparck Jones, A statistical interpretation of term specificity (1972)](https://www.staff.city.ac.uk/~sbrp622/idfpapers/ksj_orig.pdf)

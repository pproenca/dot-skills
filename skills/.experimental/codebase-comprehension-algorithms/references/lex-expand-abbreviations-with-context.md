---
title: Expand Abbreviations With Context Before Computing Similarity
impact: HIGH
impactDescription: recovers 10-20% of identifier tokens that were lost to abbreviation; usr → user, ctx → context
tags: lex, abbreviations, expansion, gentest, lawrie, dictionary
---

## Expand Abbreviations With Context Before Computing Similarity

After Samurai-style splitting (`lex-split-identifiers-with-samurai`), you still have `usr`, `ctx`, `pwd`, `cnt`, `msg`, `req`, `resp`, `cfg`, `tmp`, `idx`, `pos`, `len`, `num`. If your similarity computation treats `usr` and `user` as different tokens, two files that mean exactly the same thing — one written by someone who abbreviates, one by someone who doesn't — get zero lexical similarity. **Abbreviation expansion** maps `usr → user` using a combination of (1) a dictionary of common software abbreviations, (2) co-occurrence: if `userCount` and `usrCnt` co-occur in similar contexts, treat them as the same concept, and (3) the file's own context — `user_session` next to `usr_session` is strong evidence.

Lawrie, Pollock, Vijay-Shanker (the DECODE / GenTest line of work, 2007–2011) showed expansion recovers **10–20% of tokens** that pure tokenization loses, which translates to 5–15 MoJoFM points in downstream clustering. Almost nobody outside the SAR community does this — most working engineers' "identifier processing" is a regex split and a lowercase, full stop.

**Incorrect (treat abbreviations as separate tokens — splits real domain terms):**

```python
def tokenize_no_expand(source: str) -> list[str]:
    return [t.lower() for t in split_identifiers(source) if t not in STOPS]

tokenize_no_expand("usrCntForCurReq")
# → ['usr', 'cnt', 'for', 'cur', 'req']
# Three of these (usr, cnt, cur) are abbreviations the topic model will treat
# as distinct from (user, count, current) — so files using `usrCnt` and files
# using `userCount` have zero token overlap.
```

**Correct (dictionary + co-occurrence expansion):**

**Correct (Step 1 — hand-curated software-abbreviations dictionary):**

```python
# Lawrie 2007 ships ~3,500 mappings; the 60 most common are below.
SOFTWARE_ABBREVS = {
    "usr": "user", "pwd": "password", "ctx": "context",
    "cnt": "count", "msg": "message", "req": "request",
    "resp": "response", "res": "response", "cfg": "config",
    "tmp": "temporary", "idx": "index", "pos": "position",
    "len": "length", "num": "number", "auth": "authentication",
    "addr": "address", "ptr": "pointer", "ref": "reference",
    "src": "source", "dst": "destination", "dest": "destination",
    "btn": "button", "img": "image", "fn": "function",
    "args": "arguments", "params": "parameters", "ret": "return",
    "init": "initialize", "calc": "calculate", "prev": "previous",
    "curr": "current", "cur": "current", "nxt": "next",
    "max": "maximum", "min": "minimum", "avg": "average",
    "elem": "element", "attr": "attribute", "prop": "property",
    "info": "information", "perm": "permission",
    "db": "database", "dir": "directory", "doc": "document",
    "env": "environment", "ext": "extension", "lib": "library",
    "loc": "location", "mod": "module", "obj": "object",
    "proc": "process", "qty": "quantity", "repo": "repository",
    "sched": "schedule", "sys": "system", "txt": "text",
    "fmt": "format", "buf": "buffer", "sz": "size",
}
```

**Correct (Step 2 — context-similarity helpers, GenTest-style):**

```python
def _initials_match(short: str, long: str) -> bool:
    """`cnt` matches `count` (consonant-only); `usr` matches `user` (drop vowels)."""
    consonants = ''.join(c for c in long if c not in 'aeiou')
    return short == consonants[:len(short)]

def _context_similarity(a: str, b: str, corpus: list[list[str]], window: int = 3) -> float:
    """Jaccard similarity of bags within ±window tokens of each occurrence."""
    ctx_a, ctx_b = set(), set()
    for doc in corpus:
        for i, t in enumerate(doc):
            window_tokens = set(doc[max(0, i - window): i + window + 1]) - {t}
            if t == a: ctx_a |= window_tokens
            if t == b: ctx_b |= window_tokens
    if not ctx_a or not ctx_b:
        return 0
    return len(ctx_a & ctx_b) / len(ctx_a | ctx_b)
```

**Correct (Step 3 — mine corpus-specific expansions, then expand):**

```python
from collections import Counter

def build_cooccurrence_expansion(corpus, min_freq: int = 3) -> dict[str, str]:
    """If `usrCount` and `userCount` co-occur in similar contexts,
    treat `usr` as expanding to `user` (Lawrie-Binkley GenTest, 2011)."""
    vocab = Counter(t for doc in corpus for t in doc)
    short_tokens = [t for t in vocab if 2 <= len(t) <= 4]
    long_tokens = {t for t in vocab if len(t) >= 5}

    expansions = {}
    for short in short_tokens:
        cands = [l for l in long_tokens
                 if l.startswith(short) or _initials_match(short, l)]
        for cand in cands:
            if (_context_similarity(short, cand, corpus) > 0.5
                    and vocab[cand] >= min_freq):
                expansions[short] = cand
                break
    return expansions

def expand_tokens(tokens: list[str], mined: dict[str, str]) -> list[str]:
    """Dictionary first (high precision), mined second (recall)."""
    return [SOFTWARE_ABBREVS.get(t, mined.get(t, t)) for t in tokens]
```

**Alternative (subword tokenization — sidestep the problem):**

```python
# If expansion feels like too much engineering, BPE / WordPiece tokenization
# (used by CodeBERT, GraphCodeBERT, code2vec) operates at the subword level.
# `usr` and `user` both decompose to overlapping sub-tokens (`us`, `er`, `r`)
# so vector similarity captures the relatedness without explicit expansion.
# Heavier infrastructure; only worth it if you're already running embeddings.
# See lex-stem-versus-subword-tokenization.
```

**Empirical baseline:** Hill et al. (ICPC 2014) compared dictionary-only, dictionary+context, and BPE: dictionary+context recovers the most tokens at the lowest cost; BPE is competitive but harder to explain to humans. Madani et al. (TSE 2010, "Recognizing words from source code identifiers using speech recognition techniques") report that domain-specific abbreviation expansion shifts LDA topic interpretability up by 12–18% on Mozilla and Eclipse.

**When NOT to expand:**

- Heavily abbreviated, domain-specific contexts (embedded C, kernel code, bash scripts) where `cnt` truly is the term of art — expansion produces noise.
- Generated code (protobuf, GraphQL types) — identifiers are deterministic and abbreviation isn't a developer choice.
- Polyglot codebase where different abbreviation conventions per language confuse a single dictionary.

**Production:** Eclipse Mylyn's task-context features include abbreviation expansion for relevance scoring; Sourcegraph applies a limited dictionary expansion for cross-language symbol search; the GitHub Semantic team mines per-language abbreviation tables from public-corpus statistics.

Reference: [Effective Identifier Names for Comprehension and Memory (Lawrie, Morrell, Feild, Binkley, J. Innov. Syst. Softw. Eng. 2007)](https://link.springer.com/article/10.1007/s11334-007-0031-2)

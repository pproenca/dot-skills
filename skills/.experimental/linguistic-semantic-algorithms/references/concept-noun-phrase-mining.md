---
title: Extract Noun Phrases from Identifiers to Find Candidate Domain Entities
impact: CRITICAL
impactDescription: surfaces 80%+ of domain entities from naming alone
tags: concept, pos-tagging, noun-phrases, ddd, entity-discovery
---

## Extract Noun Phrases from Identifiers to Find Candidate Domain Entities

Domain entities almost always show up in code as noun phrases inside identifier names: `customerSubscription`, `pet_sit_application`, `HouseListingReview`. Tokenize identifiers, tag each token with a part-of-speech tag, then run a noun-phrase chunker — the result is a frequency-ranked list of multi-word entity candidates with very little noise. This is how engineers manually "see" the domain in a codebase, automated. Done well, the top 50 noun phrases capture ~80% of the actual domain ubiquitous language; you'd recover the same list by interviewing the team for half a day.

**Incorrect (counting bare tokens — misses multi-word entities, swamped by verbs):**

```python
# Counts every lowercase word in identifiers and ranks by frequency.
# Result is dominated by verbs ("get", "set", "is") and framework
# words ("request", "response"). Multi-word entities like
# "house listing review" never surface as a unit.
import re, pathlib, collections

SPLIT = re.compile(r"[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)")
counter = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    counter.update(w.lower() for w in SPLIT.findall(p.read_text()))

# Top 20: get, set, is, request, return, self, value, data, response, ...
print(counter.most_common(20))
```

**Correct (POS-tag identifier tokens, chunk into noun phrases, rank):**

```python
import re, pathlib, collections
import spacy
nlp = spacy.load("en_core_web_sm")

SPLIT = re.compile(r"[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)")
DOMAIN_STOPS = {"get", "set", "is", "do", "make", "self", "value", "data"}

def identifiers(path: pathlib.Path) -> list[str]:
    return re.findall(r"\b[A-Za-z_][A-Za-z0-9_]{2,}\b", path.read_text(errors="ignore"))

phrase_counts = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    for ident in identifiers(p):
        tokens = [t.lower() for t in SPLIT.findall(ident) if t.lower() not in DOMAIN_STOPS]
        if len(tokens) < 2:
            continue
        # POS-tag the reconstructed phrase and keep noun-headed chunks
        doc = nlp(" ".join(tokens))
        for chunk in doc.noun_chunks:
            phrase_counts[chunk.text] += 1

for phrase, n in phrase_counts.most_common(50):
    print(f"{n:>5}  {phrase}")
# 3122  user account
# 2410  house listing
# 1880  pet sit application
# 1655  customer subscription
# 1402  payment method
```

**Filter the top-N against a generic-code corpus** (see `concept-tfidf-rare-terms`) so framework noun phrases like "http response" don't dominate. The combination of POS + IDF leaves a high-purity domain entity list.

**Combine with `ling-abbreviation-expansion`** before chunking — without expansion, `pet_sit_appl` reads as three short noun tokens and the chunker drops it.

**When NOT to apply:**
- Languages where identifiers are short cryptic codes (legacy Fortran, COBOL) — POS tagging on `EMPMAST` is useless
- Codebases written in a language other than English — load a non-English spaCy model or skip

Reference: [Allamanis et al., Mining Source Code Repositories at Massive Scale](https://miltos.allamanis.com/publications/2013msr/), [spaCy noun chunks](https://spacy.io/usage/linguistic-features#noun-chunks)

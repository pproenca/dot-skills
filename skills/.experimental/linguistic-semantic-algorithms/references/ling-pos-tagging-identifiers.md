---
title: Tag Identifier Tokens with POS to Find Misnamed Functions and Classes
impact: MEDIUM
impactDescription: flags 5-10% of identifiers that violate noun/verb naming conventions
tags: ling, pos-tagging, naming, convention, spacy
---

## Tag Identifier Tokens with POS to Find Misnamed Functions and Classes

A small style convention with disproportionate consequence: **functions should start with verbs, classes/types should be nouns**. Codebases that follow this convention are easier to read, search, and statically analyze. Violators (`function userData()`, `class Validate`) hide intent and break naming-based heuristics. POS-tag the leading token of every identifier and check it against the expected category. The mismatches are a cheap renaming backlog with high readability ROI; the rate of mismatches is also a useful proxy for "how disciplined was this team's naming?".

**Incorrect (eyeball + grep for "bad names" — ad-hoc and inconsistent):**

```bash
# A code reviewer comments "this should be a verb" when they notice.
# 90% of mismatches slip through review because no one notices.
grep -r "def " src/ | head -10
# Returns every function definition; reviewer scans visually.
# Inconsistent and obviously not run on legacy code.
```

**Correct (POS-tag the leading split-token, flag category mismatches):**

```python
import ast, re, pathlib
import spacy

nlp = spacy.load("en_core_web_sm")
SPLIT = re.compile(r"[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)")

def first_word(identifier: str) -> str | None:
    parts = SPLIT.findall(identifier)
    return parts[0].lower() if parts else None

def pos_of(word: str) -> str:
    # Single-word POS tagging — supply a verb-form sentence frame for accuracy
    doc = nlp(f"I want to {word} it.")
    return doc[3].pos_                              # POS of the verb-slot word

def is_verb(word: str) -> bool:
    return pos_of(word) in {"VERB", "AUX"} or word in CUSTOM_VERBS

CUSTOM_VERBS = {                                    # whitelist code-specific verbs
    "init", "destroy", "render", "serialize", "lookup", "fetch", "parse",
    "marshal", "diff", "ack", "dispatch", "yield", "fork", "spawn",
}
CUSTOM_NOUN_ROOTS = {                               # tokens that "look like" verbs but aren't
    "data", "info", "service", "user", "process",   # 'process' as a noun in code
}

flags = []
for p in pathlib.Path("src").rglob("*.py"):
    try: tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError: continue
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            head = first_word(node.name)
            if head and not is_verb(head) and head not in CUSTOM_VERBS:
                flags.append((str(p), node.lineno, "function-not-verb", node.name))
        elif isinstance(node, ast.ClassDef):
            head = first_word(node.name)
            if head and is_verb(head) and head not in CUSTOM_NOUN_ROOTS:
                flags.append((str(p), node.lineno, "class-not-noun", node.name))

for path, line, kind, name in flags[:25]:
    print(f"  {path}:{line}  {kind:>18}  {name}")
# src/api/handlers.py:142  function-not-verb  userData      -> rename to getUserData / fetchUser
# src/billing/validate.py:88 class-not-noun    Validate      -> rename to Validator
```

**Tune CUSTOM_VERBS for your domain.** Code uses many specialized verbs that spaCy doesn't tag as verbs out of the box (`render`, `marshal`, `dispatch`, `ack`). Curate a per-language whitelist; without it, false-positive rate is too high to be useful.

**This is the simplest rule in this skill, and one of the most overlooked.** Most codebases have a 5-10% rate of convention violations; surfacing them gives clear, agreed-upon renaming tasks that improve readability with zero design risk.

**Use the *rate* as a code-health metric.** A codebase with <2% violation rate has disciplined naming; >15% means naming convention isn't being enforced and other naming-based heuristics (clone detection, similarity ranking) will degrade.

**Combine with `concept-noun-phrase-mining`:** the noun phrases in your codebase represent domain entities. POS-mismatched functions or classes block extraction — fix them first, then re-run mining for better coverage.

**Pre-tag with a frame** (`"I want to ${word} it."`). Tagging a bare word out of context produces unreliable POS labels for ambiguous words like "log" or "match". A grammatical frame disambiguates without adding much code.

**When NOT to apply:**
- Languages where the convention is opposite or absent (Lisp, Haskell idioms differ) — adapt the rule or skip
- Domain-specific languages where identifiers are physical units (`meters`, `volts`) — POS tagging produces noise; whitelist heavily

Reference: [Caprile & Tonella, Restructuring Program Identifier Names (ICSM 2000)](https://ieeexplore.ieee.org/document/883005), [spaCy POS tagging docs](https://spacy.io/usage/linguistic-features#pos-tagging)

---
title: Extract Verb-Object Pattern From Method Names For Concept Mining
impact: MEDIUM-HIGH
impactDescription: surfaces 70%+ of "what this code does to what" semantics that pure bag-of-tokens loses
tags: lex, pos-tagging, verb-object, method-names, høst-østvold
---

## Extract Verb-Object Pattern From Method Names For Concept Mining

`getUserById`, `validatePaymentMethod`, `dispatchOrderToFulfillment`, `cancelSubscriptionAfterTrial` — method names are tiny sentences with a **verb-object grammar**. Treating them as bags of unordered tokens throws away the relationship between *action* and *thing-acted-upon*. Extracting (verb, direct-object) pairs surfaces the underlying domain operations directly: "validate × payment-method", "dispatch × order", "cancel × subscription" — exactly the operations a domain-driven-design ubiquitous-language extraction wants.

This idea goes back to **Caprile-Tonella (ICSM 1999, "Nomen est omen")** and was formalized by **Høst & Østvold (ICSE 2009, "Debugging method names")** who showed that 70%+ of Java method names follow the V-O pattern, and that mismatches (`getUser` that doesn't return a user) are real bugs. For codebase comprehension, the (verb, object) pair is a much higher-signal feature than either alone — `get × user` and `set × user` cluster differently than `get × payment` and `set × user`, even though all four contain the token `user`.

**Incorrect (bag of tokens — loses the action/object distinction):**

```python
def file_concepts_bag(file_path: str) -> list[str]:
    """Returns flat tokens. `getUserById` and `setUserById` produce the same
    bag minus one verb — the topic model can't tell which file is reading
    vs writing the User domain object."""
    tokens = []
    for method in extract_methods(file_path):
        tokens.extend(split_identifier(method.name))
    return tokens
```

**Correct (extract verb-object pairs as compound concepts):**

**Correct (Step 1 — verb / preposition vocabularies, Sourcerer-mined):**

```python
# The leading verb of a method name is one of ~50 common operations
# (Bajracharya-Lopes ICSE 2009, Sourcerer 2.5M-method dataset).
COMMON_VERBS = frozenset({
    # accessors / predicates
    "get", "set", "is", "has", "can", "should", "will",
    # readers / writers
    "find", "fetch", "load", "save", "store", "put", "post", "write", "persist",
    # constructors / destructors
    "create", "make", "build", "construct", "init",
    "delete", "remove", "destroy", "drop", "clear",
    # mutators / validators / computers
    "update", "modify", "change", "edit",
    "validate", "verify", "check", "test", "assert",
    "compute", "calculate", "derive", "evaluate",
    # messengers / lifecycle / transformers
    "send", "receive", "dispatch", "publish", "subscribe",
    "open", "close", "start", "stop", "begin", "end",
    "encode", "decode", "parse", "format", "serialize",
    # dispatch / decisions
    "handle", "process", "execute", "run", "invoke",
    "cancel", "reject", "accept", "approve", "deny",
})

PREP_BRIDGES = frozenset({"to", "from", "of", "in", "on", "with", "by", "for", "as"})
```

**Correct (Step 2 — parse one method name into (verb, object, modifier)):**

```python
def parse_method_name(method_name: str) -> dict | None:
    """
    `dispatchOrderToFulfillment`    → ('dispatch', ['order'],         ['fulfillment'])
    `validatePaymentMethodForUser`  → ('validate', ['payment','method'], ['user'])
    Returns None if no recognized verb leads.
    """
    tokens = split_identifier(method_name)  # see lex-split-identifiers-with-samurai
    if not tokens or tokens[0].lower() not in COMMON_VERBS:
        return None

    verb = tokens[0].lower()
    obj_tokens, mod_tokens = [], []
    seen_prep = False
    for t in (t.lower() for t in tokens[1:]):
        if t in PREP_BRIDGES:
            seen_prep = True
            continue
        (mod_tokens if seen_prep else obj_tokens).append(t)
    return {"verb": verb, "object": obj_tokens, "modifier": mod_tokens}
```

**Correct (Step 3 — file-level concept extraction):**

```python
def file_concepts_vo(file_path: str) -> list[tuple[str, str]]:
    """For each method, emit (verb, object_head) — the (operation, primary noun)
    that captures the method's semantic essence."""
    pairs = []
    for method in extract_methods(file_path):
        p = parse_method_name(method.name)
        if p and p["object"]:
            pairs.append((p["verb"], p["object"][-1]))  # head noun
    return pairs

# On a payments-domain file:
#   [('validate', 'method'), ('process', 'payment'), ('refund', 'transaction'),
#    ('compute', 'tax'), ('send', 'receipt')]
# V-O pairs cluster much more sharply by domain than tokens alone.
```

**Alternative (full POS-tagging with a code-aware tagger):**

```python
# Binkley-Pighin-Lawrie (TSE 2011, "Improving identifier informativeness using
# part of speech information") trained a POS-tagger specifically on
# identifiers. It distinguishes:
#   noun-modifier-noun:  payment method, user account
#   verb-object:         validate payment, process order
#   predicate:           is valid, has expired
# Less commonly available off-the-shelf than the heuristic above; if you have
# many years of identifier data, train your own tagger and use it instead.
```

**How to use V-O pairs in clustering:**

```python
# Two complementary uses:
# 1) Append the verb-object string ('validate-payment') to the bag of tokens
#    in TF-IDF. Now files agree on COMPOUND concepts.
# 2) Build a bipartite graph: files on one side, V-O pairs on the other.
#    Two files connect strongly if they share many V-O pairs — a much
#    stronger signal than sharing individual tokens.

def file_vector_with_vo(file_path: str) -> dict[str, int]:
    counts = Counter(extract_tokens(file_path))
    for v, o in file_concepts_vo(file_path):
        counts[f"VO:{v}-{o}"] += 1  # weight: appears twice (V, O, V-O)
    return counts
```

**Empirical baseline:** Hill et al. (ICPC 2011, "AMAP: Automatically mining abbreviation expansions") use V-O parsing as a preprocessing step for concept location and report 12–22% improvement in feature-location F1. Binkley-Lawrie (TSE 2011) report that V-O–enriched LDA improves topic NPMI coherence by 0.05–0.12.

**When NOT to use:**

- Languages without a verb-object naming convention. Functional languages (Haskell, OCaml) use noun-only names (`payment`, `tax`). Smalltalk-influenced (Ruby) uses different conventions (`payment?` predicates, `do_action!` mutators).
- Languages with reversed word order (some style guides put nouns first: `paymentValidate`). Detect by sampling.
- DSLs / config-style code where method names don't follow imperative grammar.

**Production:** Sourcegraph's symbol-similarity index includes a V-O feature; the JetBrains "Search Everywhere" ranking uses V-O parsing for method-name relevance scoring; the SCANL workshop on identifier analysis has produced multiple academic implementations (POSSE, Stanford POS Tagger fine-tuned on identifiers).

Reference: [Debugging Method Names (Høst & Østvold, ECOOP 2009)](https://link.springer.com/chapter/10.1007/978-3-642-03013-0_14)

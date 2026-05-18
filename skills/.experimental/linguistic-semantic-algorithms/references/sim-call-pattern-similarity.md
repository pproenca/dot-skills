---
title: Compare Functions by Call-Sequence N-grams to Find Behavioral Twins
impact: MEDIUM-HIGH
impactDescription: reduces behavioral-clone search to set operations on call-trace n-grams
tags: sim, n-grams, call-sequence, behavioral, idiom-mining
---

## Compare Functions by Call-Sequence N-grams to Find Behavioral Twins

Two functions can have identical control flow but completely different bodies — for example, a Stripe checkout flow and a PayPal checkout flow that both follow the pattern `validate → authorize → capture → record → notify`. AST/text comparison misses this because the local variables and exact method names differ. But if you extract just the *sequence of method calls* (the function's "trace") and compare n-gram sets, behavioral twins surface immediately. This finds functions that *do the same thing*, even when none of the implementation looks alike.

**Incorrect (compare full source text — local detail drowns the call-sequence signal):**

```python
# Two functions that follow the same pattern: validate, charge, record, notify.
def checkout_stripe(cart):
    if not validate_cart(cart): raise InvalidCart()
    payment_id = stripe_client.charge(cart.total, cart.method)
    order_repo.record(cart, payment_id, "stripe")
    notify_user(cart.user, payment_id)
    return payment_id

def checkout_paypal(cart):
    validate_cart_state(cart)
    txn = paypal_gateway.execute(cart.total_cents, cart.method)
    order_repo.record(cart, txn.id, "paypal")
    notify_user(cart.user, txn.id)
    return txn.id

# AST diff: large (different node types, identifier names, control flow)
# Text Jaccard: 0.18 — misses the behavioral isomorphism.
```

**Correct (extract call sequences, compare bigram/trigram sets via Jaccard):**

```python
import ast, pathlib
from collections import defaultdict

def call_trace(fn: ast.FunctionDef) -> list[str]:
    trace = []
    for node in ast.walk(fn):
        if isinstance(node, ast.Call):
            f = node.func
            if isinstance(f, ast.Attribute):
                trace.append(f.attr)                  # ignore receiver name
            elif isinstance(f, ast.Name):
                trace.append(f.id)
    return trace

def ngrams(seq: list[str], n: int = 2) -> set[tuple]:
    return {tuple(seq[i:i + n]) for i in range(len(seq) - n + 1)}

def jaccard(a: set, b: set) -> float:
    return len(a & b) / max(1, len(a | b))

# Index every function's call-trace n-grams
records: list[tuple[str, set]] = []
for p in pathlib.Path("src").rglob("*.py"):
    try:
        tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError:
        continue
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            grams = ngrams(call_trace(node), n=2) | ngrams(call_trace(node), n=3)
            if grams:
                records.append((f"{p}:{node.name}", grams))

# Query: find behavioral twins of a target function
target_grams = records[next(i for i, (n, _) in enumerate(records) if n.endswith(":checkout_stripe"))][1]
ranked = sorted(records, key=lambda r: jaccard(target_grams, r[1]), reverse=True)[:5]
for name, grams in ranked:
    print(f"  {jaccard(target_grams, grams):.3f}  {name}")
# 1.000  src/payments/checkout.py:checkout_stripe        (self)
# 0.730  src/payments/checkout.py:checkout_paypal         <- behavioral twin
# 0.611  src/payments/refunds.py:reverse_payment
# 0.520  src/admin/manual_charge.py:apply_charge
```

**Normalize call names before n-gram extraction** for cross-provider patterns. Map `charge`, `execute`, `capture` to a canonical `pay` step. The cost is a small ontology file (~50 entries for common verbs); the benefit is much higher recall.

**Combine with `concept-entity-name-resolution`** for the *objects* the calls operate on. Function trace plus object trace gives a much richer behavioral fingerprint.

**This is also how `mine-bug-fix-patterns` detects recurring bug-fix structures** — fixes that share a call-sequence pattern often address the same root cause class.

**When NOT to apply:**
- Heavily method-chained code (jQuery-style) — the trace becomes one long chain and n-grams degenerate
- Functions under ~5 calls — trace too short for n-grams to discriminate

Reference: [Allamanis & Sutton, Mining idioms from source code (FSE 2014)](https://miltos.allamanis.com/publications/2014idioms/), [Robillard et al., How API documentation fails (IEEE Software 2014)](https://www.cs.mcgill.ca/~martin/papers/software2014.pdf)

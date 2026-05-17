---
title: Use Code Naturalness (N-gram Entropy) As A Codebase-Health Signal
impact: MEDIUM
impactDescription: code is 30-50% more predictable than English; buggy regions show 10-30% entropy spike (Hindle ICSE 2012)
tags: info, naturalness, hindle, devanbu, n-gram, entropy
---

## Use Code Naturalness (N-gram Entropy) As A Codebase-Health Signal

For codebase comprehension, **code naturalness** is a quantitative *typicality* signal per file and per token — it answers "is this file doing something conventional or something unique?", which is exactly the question that separates "boilerplate" from "domain logic" when mapping a codebase into business domains. **Hindle, Barr, Su, Gabel, Devanbu** ("On the Naturalness of Software," ICSE 2012) made the counterintuitive founding finding: source code is **more repetitive and more predictable than natural language**. A simple n-gram language model trained on a project's own code achieves **cross-entropy of ~3–5 bits per token** on held-out files, versus ~7–8 bits per token on English text. This *naturalness* property has three uses directly relevant to domain mapping:

1. **Surprising tokens are often bugs.** Ray-Hellendoorn-Devanbu et al. (FSE 2016, "On the Naturalness of Buggy Code") showed that bug-fix commits change code at tokens with **measurably higher entropy** under a clean-code language model. Naturalness flags buggy regions even without specifying what the bug is.
2. **Idioms emerge as low-entropy patterns.** Allamanis & Sutton ("Mining Idioms from Source Code," MSR 2014) used naturalness to mine common code idioms — useful for *describing what a codebase does*.
3. **Codebase fluency varies.** Tu, Su, Devanbu (FSE 2014, "On the Localness of Software") showed that naturalness is *local*: a token's entropy is much lower under a model trained on the surrounding directory than the whole project. This is a quantitative signal of architectural cohesion.

For codebase comprehension, naturalness gives the agent a **per-token confidence score**: high naturalness regions are conventional; low naturalness regions are unique or surprising. The latter is where features live (and where bugs hide).

**Incorrect (skip language modelling — treat all code as equally informative):**

```python
# An agent surveying the codebase weights every token equally. It can't
# distinguish "standard boilerplate" (which says nothing about the domain)
# from "domain-specific code" (which says everything). It misses the
# concentration of feature-content in a small fraction of tokens.
```

**Correct (Step 1 — train an n-gram language model on the codebase):**

```python
from collections import defaultdict, Counter
import math

def train_ngram(documents: list[list[str]], n: int = 4):
    """
    Train an n-gram model with Witten-Bell smoothing.
    Hindle 2012 uses 3-gram and 4-gram; 4-gram is the sweet spot for code.
    """
    counts = defaultdict(Counter)  # context tuple → next token counts
    total_context = Counter()
    for doc in documents:
        padded = ["<s>"] * (n - 1) + doc + ["</s>"]
        for i in range(len(padded) - n + 1):
            context = tuple(padded[i:i + n - 1])
            target = padded[i + n - 1]
            counts[context][target] += 1
            total_context[context] += 1
    return counts, total_context

def p_witten_bell(target, context, counts, total_context, vocab_size):
    """Witten-Bell smoothed probability (Chen-Goodman 1999): better than
    Laplace for code; competitive with Kneser-Ney for typical n-gram orders."""
    c = counts.get(context, Counter())
    n_w = c.get(target, 0)
    n_c = total_context.get(context, 0)
    n_unique = len(c)
    if n_c == 0:
        return 1 / vocab_size
    return (n_w + n_unique / vocab_size) / (n_c + n_unique)
```

**Correct (Step 2 — compute per-token cross-entropy on a file):**

```python
def cross_entropy(tokens: list[str], counts, total_context, vocab_size, n: int = 4) -> float:
    """Mean bits per token under the trained n-gram model. Lower = more
    predictable (more 'natural'). Hindle's papers report ~3-5 bits for code,
    ~7-8 for English."""
    padded = ["<s>"] * (n - 1) + tokens + ["</s>"]
    log_probs = []
    for i in range(len(padded) - n + 1):
        context = tuple(padded[i:i + n - 1])
        target = padded[i + n - 1]
        p = p_witten_bell(target, context, counts, total_context, vocab_size)
        log_probs.append(-math.log2(max(p, 1e-12)))
    return sum(log_probs) / len(log_probs)
```

**Correct (Step 3 — flag unusually high-entropy tokens within a file):**

```python
def per_token_surprise(tokens: list[str], counts, total_context, vocab_size, n: int = 4):
    """Return per-token surprise (bits). Tokens with surprise above the
    file's mean + 2σ are 'naturalness outliers' — often where bugs hide
    or where the file does something genuinely unusual."""
    padded = ["<s>"] * (n - 1) + tokens
    surprises = []
    for i in range(n - 1, len(padded)):
        context = tuple(padded[i - n + 1:i])
        target = padded[i]
        p = p_witten_bell(target, context, counts, total_context, vocab_size)
        surprises.append((target, -math.log2(max(p, 1e-12))))

    bits = [s for _, s in surprises]
    mean, std = sum(bits) / len(bits), (sum((b - sum(bits)/len(bits))**2 for b in bits) / len(bits)) ** 0.5
    threshold = mean + 2 * std
    outliers = [(i, tok, s) for i, (tok, s) in enumerate(surprises) if s > threshold]
    return surprises, outliers

# Apply: pick top-N surprising files per cluster — those are the "atypical"
# files within each cluster, worth investigating.
```

**Three uses of naturalness for codebase comprehension:**

1. **Cluster typicality**: compute average cross-entropy per cluster. Low-entropy clusters are repetitive (CRUD endpoints, generated code, glue); high-entropy clusters do unique things (core algorithms, business rules).
2. **File centrality (alternative to PageRank)**: a file whose code is well-predicted by the rest of the project is *typical*; a file with unique vocabulary patterns is *novel* and tends to be architecturally important.
3. **Bug-prediction prior**: regions of high surprise correlate with bug hotspots (Ray et al. FSE 2016); flag them for extra agent attention during code review.

**Quantitative baselines (from the literature):**

| Code corpus | Cross-entropy (bits/token) | Source |
|-------------|---------------------------:|--------|
| English text (Brown corpus) | 7.5–8.5 | classical NLP |
| Java (10 OSS projects, Hindle 2012) | **3.0–4.5** | ICSE 2012 |
| Python (numpy + scipy) | 4.0–5.5 | Allamanis-Sutton MSR 2014 |
| English bug fixes | 7.0–8.5 | Ray et al. FSE 2016 |
| Code bug fixes (pre-fix vs post-fix) | **+0.5–1.0 bits before fix** | Ray et al. FSE 2016 |

Code is roughly **twice as predictable** as English. Buggy code is roughly **30% less predictable** than correct code by the same project's standard.

**Modern variant — neural language models:**

```python
# n-grams plateau around 3-4 bits for code. Neural LMs (LSTM, Transformer) push
# down to 2-3 bits. Pre-trained CodeBERT, GraphCodeBERT, Codex/Claude offer
# even lower entropy. For modern agent pipelines, replace the n-gram with
# token-level log-prob from a code LLM. Same downstream uses; lower noise.
```

**When NOT to use naturalness:**

- Tiny codebases (< ~50 files) — not enough training data for the n-gram model.
- Polyglot codebases — train one model per language; mixing produces meaningless cross-entropy.
- Generated code mixed with hand-written — generated code is artificially low-entropy and dominates the model. Filter out or model separately.

**Production:** Allamanis et al.'s `naturalize` toolkit applies naturalness for code style normalization. `tssb-3m` is a large dataset of natural-vs-buggy code pairs used for bug-prediction research. Ray-Hellendoorn-Devanbu's `Bugram` is the canonical naturalness-bug-prediction tool. The technique remains underused in industry analysis tools.

Reference: [On the Naturalness of Software (Hindle, Barr, Su, Gabel, Devanbu, ICSE 2012)](https://ieeexplore.ieee.org/document/6227135)

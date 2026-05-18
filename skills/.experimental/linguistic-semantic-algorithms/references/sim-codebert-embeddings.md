---
title: Use CodeBERT Embeddings plus Cosine Similarity for Semantic Code Search
impact: CRITICAL
impactDescription: enables semantic code search across renames, synonyms, and rewrites
tags: sim, codebert, embeddings, semantic-search, transformers
---

## Use CodeBERT Embeddings plus Cosine Similarity for Semantic Code Search

CodeBERT (Microsoft, 2020) is a BERT-family model pre-trained on six programming languages plus matching natural-language docstrings. Encoding every function in a codebase into a 768-dim vector and indexing it with cosine similarity lets an agent answer "find functions semantically similar to *this one*" — even when the matches use different identifier names, different control flow, and different languages. This is the only technique on this list that crosses naming boundaries reliably; everything based on tokens or AST shape misses rewrites. The cost is a few hours of GPU encoding per million LoC; the payoff is feature-mapping queries grep will never solve.

**Incorrect (token overlap as a similarity proxy — misses rewrites and renames):**

```python
# Jaccard on token sets: catches type-1/2 clones but misses
# semantically equivalent functions with no shared identifiers.
import re

WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")

def jaccard(a: str, b: str) -> float:
    ta, tb = set(WORD.findall(a)), set(WORD.findall(b))
    return len(ta & tb) / max(1, len(ta | tb))

# Two functions that compute the same total but share almost no identifiers
sum_loop_src = """
def total(items):
    totals = 0
    for x in items:
        totals += x
    return totals
""".strip()

sum_reduce_src = """
def aggregate(xs):
    from functools import reduce
    from operator import add
    return reduce(add, xs, 0)
""".strip()

print(jaccard(sum_loop_src, sum_reduce_src))
# 0.13 — Jaccard says these are unrelated despite identical behavior.
```

**Correct (CodeBERT embeddings + cosine — captures semantic equivalence):**

```python
import ast, pathlib
import torch, numpy as np
from transformers import AutoTokenizer, AutoModel

tok = AutoTokenizer.from_pretrained("microsoft/codebert-base")
model = AutoModel.from_pretrained("microsoft/codebert-base").eval()

@torch.no_grad()
def embed(snippet: str) -> np.ndarray:
    inputs = tok(snippet, truncation=True, max_length=256, return_tensors="pt")
    out = model(**inputs)
    # Mean-pool over tokens, then L2-normalize
    mask = inputs["attention_mask"].unsqueeze(-1).float()
    pooled = (out.last_hidden_state * mask).sum(1) / mask.sum(1).clamp(min=1)
    v = pooled[0].numpy()
    return v / (np.linalg.norm(v) + 1e-9)

# Index every function in the repo
records: list[tuple[str, np.ndarray]] = []
for p in pathlib.Path("src").rglob("*.py"):
    src = p.read_text(errors="ignore")
    try:
        tree = ast.parse(src)
    except SyntaxError:
        continue
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            snippet = ast.unparse(node)
            records.append((f"{p}:{node.name}", embed(snippet)))

# Query: find functions similar to a target snippet
target = embed("def total(items):\n    return sum(items)")
matrix = np.stack([v for _, v in records])
scores = matrix @ target                    # cosine — vectors are normalized
top = sorted(zip(scores, (n for n, _ in records)), reverse=True)[:5]
for s, name in top:
    print(f"  {s:.3f}  {name}")
# 0.918  src/aggregate.py:sum_amounts
# 0.901  src/billing.py:total_charges      <- different name, same shape
# 0.884  src/cart.py:calculate_subtotal    <- behavioral match
```

**Use approximate nearest-neighbor (FAISS / HNSW) above ~50k functions** — exact cosine search becomes the bottleneck. `faiss.IndexFlatIP` for ≤50k, `faiss.IndexHNSWFlat` above.

**For multi-language repos, use a multilingual code model** (e.g. `microsoft/unixcoder-base` or `Salesforce/codet5p-110m-embedding`). CodeBERT covers six languages, UniXcoder covers nine and produces better cross-language matches.

**When NOT to apply:**
- Tiny repos (<200 functions) — linear-scan AST diff is faster and gives finer-grained matches
- Generated code (protobuf, codegen output) — embeddings of repetitive boilerplate cluster together meaninglessly

Reference: [CodeBERT (Feng et al., 2020)](https://arxiv.org/abs/2002.08155), [UniXcoder (Guo et al., 2022)](https://arxiv.org/abs/2203.03850), [FAISS — efficient similarity search](https://github.com/facebookresearch/faiss)

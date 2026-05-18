---
title: Embed Documentation and Code in the Same Space to Detect Drift
impact: MEDIUM-HIGH
impactDescription: automatic flagging of stale docs via joint code-doc embedding
tags: sim, embeddings, docs, drift-detection, retrieval
---

## Embed Documentation and Code in the Same Space to Detect Drift

Docs go stale because code changes faster than the people who wrote the docs. Worse, *no one notices* until a user files a bug. Encode every docstring/markdown section and every function body into the same embedding space (CodeBERT does this — it was trained on paired NL+code). Then for every doc paragraph, find its nearest-neighbor function. If the cosine similarity is below threshold or the function it points to has changed substantially since the doc was last edited, the doc is drifting. The output is a ranked list of "docs most likely to be wrong" — a maintenance backlog from a single batch job.

**Incorrect (manual periodic doc audits — they don't happen, or happen too late):**

```bash
# Quarterly: an engineer manually walks the docs/ directory and
# checks each section against the code. Takes 2 days, gets done
# twice a year, finds at most 30% of stale sections.
find docs -name "*.md" | xargs -I{} echo "Review: {}"
```

**Correct (joint embedding + git-blame age — automatic drift ranking):**

```python
import ast, pathlib, subprocess
import numpy as np
from sentence_transformers import SentenceTransformer

encoder = SentenceTransformer("microsoft/codebert-base")

# 1. Encode all functions (with their last-modified commit date)
def file_last_modified(path: str) -> str:
    return subprocess.check_output(["git", "log", "-1", "--format=%cI", "--", path]).decode().strip()

functions: list[dict] = []
for p in pathlib.Path("src").rglob("*.py"):
    src = p.read_text(errors="ignore")
    try:
        tree = ast.parse(src)
    except SyntaxError:
        continue
    last_mod = file_last_modified(str(p))
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            functions.append({
                "id": f"{p}:{node.name}",
                "text": ast.unparse(node),
                "last_mod": last_mod,
            })

func_emb = encoder.encode([f["text"] for f in functions], normalize_embeddings=True)

# 2. Encode every doc paragraph (with the doc's last-modified date)
docs: list[dict] = []
for p in pathlib.Path("docs").rglob("*.md"):
    last_mod = file_last_modified(str(p))
    for i, para in enumerate(p.read_text().split("\n\n")):
        if len(para.strip()) > 80:                         # ignore TOCs, headings
            docs.append({"id": f"{p}#para{i}", "text": para, "last_mod": last_mod})

doc_emb = encoder.encode([d["text"] for d in docs], normalize_embeddings=True)

# 3. For each doc paragraph: find its closest function, flag if stale or unmoored
sims = doc_emb @ func_emb.T
best_idx = sims.argmax(axis=1)
for i, d in enumerate(docs):
    j = best_idx[i]
    cos = sims[i, j]
    f = functions[j]
    if cos < 0.40:
        print(f"UNMOORED  cos={cos:.2f}  {d['id']}  (no clear code referent)")
    elif f["last_mod"] > d["last_mod"]:
        days_drift = (np.datetime64(f["last_mod"][:10]) - np.datetime64(d["last_mod"][:10])).astype(int)
        if days_drift > 30:
            print(f"DRIFT     cos={cos:.2f}  {d['id']}  refers to {f['id']}")
            print(f"          (code moved {days_drift} days after doc was last edited)")
```

**Use BOTH signals.** Low cosine alone often means the doc covers a high-level concept with no single matching function (that's fine). Recent code change alone often means a refactor without behavioral change (also fine). Together they identify docs that are most likely to lie.

**Surface in PR review.** A pre-merge check that runs this against changed functions and flags affected doc sections forces drift to surface at write time, not at user-bug time.

**Combine with `local-embedding-bug-text`:** when a user reports a bug, the doc paragraphs flagged by drift in the affected area are first candidates for the bug being a *documented contract that the code no longer honours*.

**When NOT to apply:**
- Docs that are reference-only API docs auto-generated from docstrings — they can't drift independently
- Conceptual / architectural docs without code referents — these will all show low cosine; tune threshold or skip the directory

Reference: [Hindle et al., Naturalness of software (ICSE 2012)](https://web.cs.ucdavis.edu/~devanbu/teaching/289/Schedule_files/Naturalness.pdf), [Wen et al., Why and how developers respond to API deprecation](https://arxiv.org/abs/2102.11526)

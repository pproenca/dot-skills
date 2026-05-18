---
title: Map New Feature Requests to Prior Pull Requests via Diff Embedding Similarity
impact: HIGH
impactDescription: reduces a 1000-PR backlog to top-3 implementation precedents per feature
tags: sim, pr-mining, embeddings, history, feature-mapping
---

## Map New Feature Requests to Prior Pull Requests via Diff Embedding Similarity

When a product manager asks "add a way to schedule a sit", an engineer's first move is to ask "have we done something like this before?". The answer almost always exists — buried in a PR from 2 years ago that touched the same files, used the same API patterns, and made the same trade-offs. Encode every prior merged PR's diff into an embedding, store with title/description, and at feature-design time encode the new request and retrieve the K-nearest neighbours. The agent now has working precedent: which files to touch, which integration tests to copy, which review nits to expect.

**Incorrect (keyword search over PR titles — misses anything with different terminology):**

```bash
# A PM asks for "scheduled house sits". The engineer searches
# closed PRs for "schedule" — misses the relevant prior work
# titled "Calendar-based booking" because the words don't match.
gh pr list --state merged --search "schedule" --json title,url --limit 50
# Returns 12 PRs about CI schedules, none about sits.
```

**Correct (embed PR diffs once, retrieve by cosine similarity at feature-design time):**

```python
import json, subprocess, pathlib
import numpy as np
from sentence_transformers import SentenceTransformer

encoder = SentenceTransformer("BAAI/bge-base-en-v1.5")    # strong on technical text

# 1. Build the index: one row per merged PR
def fetch_prs() -> list[dict]:
    out = subprocess.check_output([
        "gh", "pr", "list", "--state", "merged", "--limit", "1000",
        "--json", "number,title,body,files,additions,deletions",
    ])
    return json.loads(out)

def pr_signature(pr: dict) -> str:
    files = " ".join(f["path"] for f in pr.get("files", [])[:20])
    return f"{pr['title']}\n{(pr.get('body') or '')[:500]}\nTouched: {files}"

prs = fetch_prs()
signatures = [pr_signature(p) for p in prs]
embeddings = encoder.encode(signatures, normalize_embeddings=True, show_progress_bar=True)
np.save("pr_index.npy", embeddings)
pathlib.Path("pr_meta.json").write_text(json.dumps([
    {"number": p["number"], "title": p["title"]} for p in prs
]))

# 2. At feature-design time: encode the request, retrieve top-K
def find_precedent(request: str, k: int = 5):
    q = encoder.encode(request, normalize_embeddings=True)
    scores = embeddings @ q
    top = np.argsort(-scores)[:k]
    return [(scores[i], prs[i]) for i in top]

request = "Allow owners to schedule a sit window for a future date range"
for score, pr in find_precedent(request):
    print(f"  {score:.3f}  #{pr['number']:>5}  {pr['title']}")
# 0.812  #4218  Calendar-based booking for confirmed sits
# 0.788  #5601  Owner-side availability windows on listings
# 0.764  #3092  Pre-arrival check-in date selection
```

**Augment retrieval with file-path overlap.** Two PRs with cosine 0.78 but no overlapping files are weaker precedent than two PRs with cosine 0.72 and 6 overlapping files. Re-rank top-20 by a combined score: `0.7 × cosine + 0.3 × file_jaccard`.

**Re-index on a schedule.** Add to your CI: nightly job that pulls new merged PRs and appends to the index. The lookup stays fresh without per-query encoding cost.

**Combine with `mine-change-coupling`:** the prior PRs' co-changed file set is a starting plan for the new feature — files that have historically moved together should move together again.

**When NOT to apply:**
- Repos with fewer than ~100 merged PRs — the index is too sparse to find meaningful neighbours
- PR descriptions are template-only ("fix bug") — body text carries no signal; rely on file-path overlap alone

Reference: [BAAI/bge-base-en — text embeddings](https://huggingface.co/BAAI/bge-base-en-v1.5), [Bird et al., The promises and perils of mining git (2009)](https://www.researchgate.net/publication/220955334)

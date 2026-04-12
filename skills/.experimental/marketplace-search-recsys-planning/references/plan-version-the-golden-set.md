---
title: Freeze and Version the Golden Set per Evaluation Cycle
impact: HIGH
impactDescription: enables comparable evaluations across releases
tags: plan, golden-set, versioning
---

## Freeze and Version the Golden Set per Evaluation Cycle

A golden query set that changes mid-evaluation cycle produces uncomparable numbers: version A was evaluated on 500 queries, version B on 540, and the NDCG delta is partly an artefact of the new queries. Freezing the golden set per cycle — committing it to the repo with a version tag — makes every version in the cycle comparable. The set still grows across cycles as the domain expands, but within a cycle it is immutable. This is the same principle that applies to benchmark sets in academic ML: fixed inputs, varying models.

**Incorrect (queries added to the golden set ad-hoc during an eval):**

```python
def add_golden_query(query: str, expected_listings: list[str]) -> None:
    golden_set.append(query, expected_listings)
    save_golden_set()
```

**Correct (golden set versioned and frozen per evaluation cycle):**

```python
def add_golden_query(query: str, expected_listings: list[str]) -> None:
    if current_cycle.is_frozen():
        raise CycleFrozenError(
            f"Cycle {current_cycle.version} is frozen. "
            f"Add to next cycle via golden_set.open_next_cycle()"
        )
    current_cycle.append(query, expected_listings)

def freeze_current_cycle() -> str:
    version = current_cycle.freeze_and_tag()
    git.commit(f"golden_set/{version}.jsonl", message=f"Freeze golden set {version}")
    return version
```

Reference: [Pinecone — Evaluation Measures in Information Retrieval](https://www.pinecone.io/learn/offline-evaluation/)

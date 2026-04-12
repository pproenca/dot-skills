---
title: Choose the Embedding Model Deliberately Before Hybrid Search
impact: MEDIUM-HIGH
impactDescription: avoids full re-embedding on model change
tags: retrieve, embeddings, model-selection
---

## Choose the Embedding Model Deliberately Before Hybrid Search

Hybrid BM25 plus KNN retrieval depends on a vector embedding for every indexed document, and changing the embedding model means re-running inference on the entire corpus and reindexing — a multi-day operation for a marketplace with millions of listings. The choice of embedding model is therefore a lifetime commitment almost as expensive as the mapping itself. Pick by domain fit (general-purpose versus domain-adapted), dimensionality (bigger is not always better — 384d is often as good as 768d at half the RAM), open versus managed (operational cost versus lock-in), and future re-embedding cost. Record the choice and its rationale in the decisions log.

**Incorrect (embedding model picked ad-hoc, no re-embedding plan):**

```python
def embed_listing(listing: Listing) -> list[float]:
    response = openai.embeddings.create(
        model="text-embedding-3-large",
        input=listing.description,
    )
    return response.data[0].embedding
```

**Correct (explicit model registry with versioning and re-embedding strategy):**

```python
EMBEDDING_MODEL = EmbeddingModelSpec(
    name="bge-small-en-v1.5",
    version="1.5.0",
    dimensions=384,
    provider="huggingface",
    chosen_because=(
        "Open weights, domain-neutral English performance close to larger models, "
        "384 dimensions keeps index RAM within budget, HF inference endpoint matches "
        "production SLO."
    ),
    reembedding_cost_estimate_hours=36,
    decisions_log="decisions/2026-04-11-embedding-model-choice.md",
)

def embed_listing(listing: Listing, model: EmbeddingModelSpec = EMBEDDING_MODEL) -> Embedding:
    vector = embedding_client.encode(listing.description, model=model.name)
    return Embedding(
        listing_id=listing.id,
        vector=vector,
        model_name=model.name,
        model_version=model.version,
    )
```

Reference: [Sentence Transformers — Domain Adaptation](https://sbert.net/examples/sentence_transformer/domain_adaptation/README.html)

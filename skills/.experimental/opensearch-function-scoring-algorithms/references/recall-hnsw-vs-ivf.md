---
title: Choose HNSW for Latency, IVF for Memory at Scale
impact: HIGH
impactDescription: 3-10x memory savings with IVF beyond 100M vectors
tags: recall, hnsw, ivf, faiss, ann, index-selection
---

## Choose HNSW for Latency, IVF for Memory at Scale

HNSW (Hierarchical Navigable Small Worlds) gives sub-10ms p99 latency and the highest recall at small-to-medium scale (<100M vectors) but uses ~1.5-2× the vector data in graph links — RAM cost is brutal at billion scale. IVF (Inverted File) clusters vectors and probes only the nearest centroids; memory footprint is roughly the raw vector size but recall and latency depend heavily on `nprobe`. Airbnb (Abdool et al. 2025) evaluated both and chose IVF for their listing index based on speed/quality tradeoff at their scale.

**Incorrect (HNSW at 500M-vector scale with default parameters — OOM):**

```json
PUT /listings_500m
{
  "settings": { "index.knn": true },
  "mappings": {
    "properties": {
      "embedding": {
        "type": "knn_vector",
        "dimension": 128,
        "method": {
          "name": "hnsw",
          "engine": "lucene",
          "parameters": { "ef_construction": 512, "m": 48 }
        }
      }
    }
  }
}
```

At 500M vectors × 128 dims × 4 bytes = 256GB raw; HNSW with `m=48` adds ~50% in graph links = 384GB working set per shard replica.

**Correct (IVF for billion-scale with controlled probe budget):**

```json
PUT /listings_500m
{
  "settings": { "index.knn": true, "number_of_shards": 16 },
  "mappings": {
    "properties": {
      "embedding": {
        "type": "knn_vector",
        "dimension": 128,
        "method": {
          "name": "ivf",
          "engine": "faiss",
          "parameters": { "nlist": 4096, "nprobes": 32 }
        }
      }
    }
  }
}
```

**Sizing guidance:**

| Scale | Recommended | Why |
|-------|-------------|-----|
| <10M vectors | HNSW | Best recall/latency, RAM is fine |
| 10M-100M | HNSW or IVF | HNSW if latency-critical; IVF if RAM-budgeted |
| >100M | IVF (Faiss) | HNSW graph overhead unsustainable |

**Tune `nprobes` empirically:** Higher = better recall, more latency. Start at `sqrt(nlist)` and adjust based on offline recall@k evaluation against a gold set.

Reference: [OpenSearch k-NN engines](https://opensearch.org/docs/latest/search-plugins/knn/knn-index/) · [Embedding-Based Retrieval for Airbnb Search](https://arxiv.org/pdf/2601.06873)

---
title: Prefer Listwise (LambdaMART) over Pairwise (RankNet) LTR Loss
impact: HIGH
impactDescription: 3-8% NDCG@10 gain on graded relevance sets
tags: rel, ltr, lambdamart, listwise, ranknet, ranklib
---

## Prefer Listwise (LambdaMART) over Pairwise (RankNet) LTR Loss

Pairwise losses (RankNet, RankBoost) optimize for getting each pair of documents in the correct order — they minimize the number of inversions. This treats a top-of-page swap and a page-30 swap as equally important, which is wrong: ranking metrics like NDCG and MAP weight top positions heavily. Listwise losses (LambdaMART, ListNet, ListMLE) directly optimize the metric you care about. Burges' LambdaMART (MSR-TR-2010-82) demonstrated the gap and remains the production default in OpenSearch LTR via RankLib.

**Incorrect (training a pairwise model on top-window data — flat over positions):**

```bash
# RankLib pairwise (RankNet) — treats all inversions equally
java -jar RankLib.jar \
  -ranker 1 \
  -train training.txt \
  -metric2t NDCG@10 \
  -save model_ranknet.txt
```

**Correct (LambdaMART listwise — weights gradients by NDCG delta):**

```bash
# RankLib listwise (LambdaMART) — gradient per pair is scaled by
# the NDCG change that swap would produce
java -jar RankLib.jar \
  -ranker 6 \
  -train training.txt \
  -metric2t NDCG@10 \
  -tree 300 \
  -leaf 16 \
  -shrinkage 0.05 \
  -save model_lambdamart.txt
```

**Why LambdaMART beats pure listwise (ListNet/ListMLE) in practice:** LambdaMART approximates the listwise gradient *through* a pairwise formulation, but each pair's contribution is multiplied by `|ΔNDCG|` — the metric improvement that swapping them would yield. This gives the metric-awareness of listwise with the optimization stability of pairwise. It's the workhorse for a reason.

**Upload to OpenSearch LTR:**

```bash
curl -X POST "localhost:9200/_ltr/_featureset/marketplace_features/_createmodel" \
  -H 'Content-Type: application/json' -d @model_lambdamart.json
```

```json
{
  "model": {
    "name": "marketplace_ltr_v3",
    "model": {
      "type": "model/ranklib",
      "definition": "<ranklib-serialized-model-string>"
    }
  }
}
```

**Common training pitfall:** Train with `NDCG@10` as the *training* metric (matches what you serve), not with `MAP` or `ERR@k` because they're available — they optimize the wrong thing.

Reference: [Burges — From RankNet to LambdaRank to LambdaMART (MSR-TR-2010-82)](https://www.microsoft.com/en-us/research/publication/from-ranknet-to-lambdarank-to-lambdamart-an-overview/) · [OpenSearch LTR plugin](https://opensearch.org/docs/latest/search-plugins/ltr/index/) · [RankLib](https://sourceforge.net/p/lemur/wiki/RankLib/)

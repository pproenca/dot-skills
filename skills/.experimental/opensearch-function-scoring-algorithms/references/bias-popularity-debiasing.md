---
title: Subsample Popular Items in Embedding Training Negatives
impact: MEDIUM-HIGH
impactDescription: prevents head-item embedding collapse
tags: bias, popularity, negative-sampling, embeddings, debiasing
---

## Subsample Popular Items in Embedding Training Negatives

Embedding models trained with naive uniform negative sampling treat every item as equally likely to be the "negative" — but popular items get sampled as negatives often, pushing them away from queries even when they're relevant. The result: head items collapse to mediocre embeddings; long-tail items get pulled around by noise. Word2Vec's authors (Mikolov 2013) noted this and proposed **subsampling frequent words**; the equivalent fix for marketplace item embeddings is sampling negatives proportional to `f^(3/4)` (or similar sub-linear scaling) and explicitly excluding the in-batch positives.

**Incorrect (uniform negative sampling — head items collapse):**

```python
def get_negatives(positive_item_id, k=5):
    """Uniform — every item equally likely to be a negative"""
    return random.sample(all_item_ids - {positive_item_id}, k)
```

A popular item gets sampled as a negative ~10× more often than it should, because it co-occurs with 10× more queries. Its embedding drifts away from many queries even when it's actually relevant to them.

**Correct (frequency-adjusted negative sampling, à la Word2Vec):**

```python
import numpy as np

# Pre-compute sampling probabilities ∝ frequency^(3/4)
item_freq = compute_item_frequencies(training_data)  # {item_id: count}
freq_arr = np.array([item_freq[i] for i in item_ids])
sample_prob = freq_arr ** 0.75
sample_prob /= sample_prob.sum()

def get_negatives_adjusted(positive_item_id, k=5):
    """Sample ∝ freq^0.75 — heavy items down-weighted from raw frequency"""
    return np.random.choice(item_ids, size=k, replace=False, p=sample_prob).tolist()
```

The 0.75 exponent comes from Mikolov et al.'s Word2Vec — empirically the best trade-off between sampling rare items often enough and not over-sampling head items.

**Equivalent: importance-weighted contrastive loss:**

If you can't change the sampler, weight the contrastive loss by `1 / freq^0.75` for each negative:

```python
def contrastive_loss(query_vec, pos_vec, neg_vecs, neg_freqs):
    pos_score = query_vec @ pos_vec
    neg_scores = query_vec @ neg_vecs.T  # shape (k,)

    # Down-weight popular-item negatives
    weights = 1.0 / (neg_freqs ** 0.75)
    weights /= weights.sum()  # normalize

    loss = -torch.log_softmax(
        torch.cat([pos_score.unsqueeze(0), weights * neg_scores]),
        dim=0
    )[0]
    return loss
```

**Validation:** After training, plot per-item average cosine similarity to a random query batch. Without debiasing, head items show systematically lower similarity (over-pushed-away). With debiasing, the distribution flattens.

**The deeper bias:** Popularity bias affects more than negative sampling. It shows up in:
1. **Click logs** — head items get clicked more from exposure, not relevance (see `bias-position-ips`).
2. **Conversion rates** — head items convert more from familiarity, not match quality.
3. **User similarity** — users who click head items look "similar" to each other because head items are everywhere.

Apply IPS for click bias (`bias-position-ips`); apply frequency-adjusted sampling for embedding bias (this rule). They're complementary, not redundant.

**For marketplaces with long-tail strategy:** Down-weighting popularity in embeddings is a *prerequisite* for surfacing long-tail inventory. Without it, your retrieval system can't physically generate long-tail candidates because their embeddings are too far from query embeddings.

Reference: [Mikolov et al. — Distributed Representations of Words and Phrases (NIPS 2013)](https://papers.nips.cc/paper/5021-distributed-representations-of-words-and-phrases-and-their-compositionality) · [Recsys Popularity Bias survey (RecSys 2021)](https://arxiv.org/abs/2105.06419)

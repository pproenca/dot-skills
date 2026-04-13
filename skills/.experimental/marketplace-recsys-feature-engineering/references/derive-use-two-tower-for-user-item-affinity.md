---
title: Use a Two-Tower Model for User-to-Item Affinity
impact: MEDIUM-HIGH
impactDescription: learned u2i affinity beats hand-crafted scoring 2-5x on NDCG
tags: derive, u2i, two-tower, dual-encoder, retrieval
---

## Use a Two-Tower Model for User-to-Item Affinity

Hand-crafted u2i scoring ("sitter pet-experience match × region overlap × availability") produces interpretable rules but hits a ceiling quickly — the weights are guesses and the interactions are missed. A two-tower model trains a user encoder and an item encoder jointly so that the dot product of their outputs approximates the acceptance probability, and the architecture naturally scales to retrieval via ANN over precomputed item vectors. Ship a two-tower as the u2i baseline once you have ~1M interaction events; hand-crafted scoring is only appropriate below that data scale or as an interpretable fallback.

**Incorrect (hand-crafted scoring with fixed weights):**

```python
def score_listing_for_sitter(sitter: Sitter, listing: Listing) -> float:
    return (
        0.4 * pet_experience_match(sitter, listing)
        + 0.3 * region_overlap(sitter, listing)
        + 0.2 * availability_overlap(sitter, listing)
        + 0.1 * rating_match(sitter, listing)
    )
    # weights were guessed once and never updated; new features can only be added by hand
```

**Correct (two-tower with trained embeddings):**

```python
class UserTower(nn.Module):
    def forward(self, user_features: dict) -> torch.Tensor:
        x = torch.cat([self.embed[f](user_features[f]) for f in self.FIELDS], dim=-1)
        return F.normalize(self.mlp(x), dim=-1)  # 128-dim user embedding

class ItemTower(nn.Module):
    def forward(self, item_features: dict) -> torch.Tensor:
        x = torch.cat([self.embed[f](item_features[f]) for f in self.FIELDS], dim=-1)
        return F.normalize(self.mlp(x), dim=-1)  # 128-dim item embedding

def train_step(batch, user_tower, item_tower, opt):
    u = user_tower(batch["user"])
    i_pos = item_tower(batch["item_pos"])
    i_neg = item_tower(batch["item_neg"])
    pos_score = (u * i_pos).sum(-1)
    neg_score = (u * i_neg).sum(-1)
    loss = -F.logsigmoid(pos_score - neg_score).mean()
    opt.zero_grad(); loss.backward(); opt.step()

# Serving: precompute item vectors offline, compute user vector per session, ANN lookup.
def score(sitter_id: str, listing_id: str) -> float:
    u = feature_store.get(sitter_id, "u2i_user_vector")
    i = feature_store.get(listing_id, "u2i_item_vector")
    return float(u @ i)
```

Reference: [Shaped — The Two-Tower Model for Recommendation Systems: A Deep Dive](https://www.shaped.ai/blog/the-two-tower-model-for-recommendation-systems-a-deep-dive)

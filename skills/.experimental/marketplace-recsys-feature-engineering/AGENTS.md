# Two-Sided Recsys Feature Engineering

**Version 0.1.0**  
Marketplace Engineering  
April 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

First-principles guide for deriving usable recommender features from the raw assets of a two-sided trust marketplace — listing photos, owner-entered listing metadata, and sitter wizard responses — for item-to-item, user-to-item, and user-to-user solutions. Contains 44 rules across 8 categories ordered by cascade impact on the feature-engineering lifecycle, from asset auditing and first-principles decomposition through vision, text, and wizard extraction, multi-modal composition into i2i/u2i/u2u scores, feature-store governance and training-serving parity, and incremental online value proof. Includes one playbook that composes the rules into an end-to-end feature discovery workflow. Functions as the upstream precursor to the companion marketplace-personalisation, marketplace-search-recsys-planning, and marketplace-pre-member-personalisation skills.

---

## Table of Contents

1. [Asset Audit and Inventory](references/_sections.md#1-asset-audit-and-inventory) — **CRITICAL**
   - 1.1 [Measure Coverage Before Declaring a Field a Feature](references/audit-measure-coverage-before-modelling.md) — CRITICAL (prevents modelling features that only exist for 10% of items)
   - 1.2 [Quantify Freshness Per Asset Type](references/audit-quantify-freshness-per-asset.md) — CRITICAL (prevents stale assets from poisoning similarity and affinity scores)
   - 1.3 [Sample Every Asset Type End-to-End Before Planning Features](references/audit-sample-every-asset-type-end-to-end.md) — CRITICAL (prevents silent garbage inputs to extraction pipelines)
   - 1.4 [Separate Raw Assets from Derived Features](references/audit-separate-raw-assets-from-derived-features.md) — CRITICAL (prevents 1-way data loss that blocks re-extraction with better models)
   - 1.5 [Verify Rights and Privacy Before Running Extraction](references/audit-verify-rights-and-privacy-before-extraction.md) — CRITICAL (prevents irreversible privacy and ToS violations)
2. [First-Principles Feature Decomposition](references/_sections.md#2-first-principles-feature-decomposition) — **CRITICAL**
   - 2.1 [Ask What Signal a Human Uses to Make the Same Decision](references/firstp-ask-what-signal-a-human-uses.md) — CRITICAL (prevents guessing — surfaces 5-15 evidence-backed candidates per interview round)
   - 2.2 [Kill Features a Popularity Baseline Already Captures](references/firstp-kill-features-a-popularity-baseline-already-captures.md) — CRITICAL (prevents redundant features inflating the portfolio)
   - 2.3 [Prefer Directly Observed Features over Learned Features at Launch](references/firstp-prefer-directly-observed-over-learned.md) — CRITICAL (delivers 80% of the lift at 10% of the system complexity)
   - 2.4 [Reject Features You Cannot Compute at Inference Time](references/firstp-reject-features-you-cannot-serve-at-inference.md) — CRITICAL (prevents the #1 cause of training-serving skew)
   - 2.5 [Start from the Decision, Not the Algorithm](references/firstp-start-from-the-decision-not-the-algorithm.md) — CRITICAL (eliminates 60-80% of features that add cost without moving the outcome)
   - 2.6 [Tie Every Feature to a Specific Solution and Metric](references/firstp-tie-every-feature-to-a-specific-solution.md) — CRITICAL (prevents orphan features that cost maintenance without lift)
3. [Image Feature Extraction](references/_sections.md#3-image-feature-extraction) — **HIGH**
   - 3.1 [Apply Domain Fine-Tuning Only When Zero-Shot CLIP Plateaus](references/vision-fine-tune-on-your-domain-when-clip-underperforms.md) — HIGH (closes 10-30% of the i2i relevance gap on domain taxonomies)
   - 3.2 [Detect Room Type Before Detecting Amenities](references/vision-detect-room-types-before-detecting-amenities.md) — HIGH (makes amenity counts per-room, cutting false positives by 50%)
   - 3.3 [Extract Per-Object Counts, Not Just Presence](references/vision-extract-per-object-counts-not-just-presence.md) — HIGH (prevents conflating a studio with a 6-bedroom villa)
   - 3.4 [Pool Embeddings Across a Listing's Photo Set](references/vision-pool-embeddings-across-a-listings-photo-set.md) — HIGH (reduces i2i variance by 2-4x versus single-photo features)
   - 3.5 [Quantify Image Quality Separately from Content](references/vision-quantify-image-quality-separately-from-content.md) — HIGH (prevents low-quality photos from flattening content embeddings)
   - 3.6 [Use CLIP for Zero-Shot Listing Embeddings Before Fine-Tuning](references/vision-use-clip-for-zero-shot-listing-embeddings.md) — HIGH (ships the vision pipeline 10-15x faster than training from scratch)
4. [Listing Text and Metadata Extraction](references/_sections.md#4-listing-text-and-metadata-extraction) — **HIGH**
   - 4.1 [Declare Categorical Fields for Bounded Vocabularies](references/listing-declare-categorical-fields-for-bounded-vocabularies.md) — HIGH (enables per-value learned features instead of text-bag processing)
   - 4.2 [Embed Description Text with a Pretrained Sentence Encoder](references/listing-embed-description-with-pretrained-sentence-encoder.md) — HIGH (prevents TF-IDF sparsity and synonym drift with 0 training cost)
   - 4.3 [Encode Amenity Lists as Multi-Hot Vectors, Not Free-Text Strings](references/listing-multi-hot-encode-amenity-lists.md) — HIGH (prevents string-tokenization drift across training and serving)
   - 4.4 [Encode Pet Requirements as Structured Triples](references/listing-encode-pet-requirements-as-structured-triples.md) — HIGH (enables per-axis matching that free text cannot)
   - 4.5 [Extract Stay Duration Shape, Not Just Length](references/listing-extract-stay-duration-shape-not-just-length.md) — HIGH (unlocks 3-5 sitter preference segments over a single integer)
   - 4.6 [Hash Geo to Hierarchies, Not Raw Lat/Lon](references/listing-hash-geo-to-hierarchies-not-raw-lat-lon.md) — HIGH (prevents the model from treating geo as an arbitrary 2D plane)
5. [Sitter Wizard and Profile Extraction](references/_sections.md#5-sitter-wizard-and-profile-extraction) — **HIGH**
   - 5.1 [Capture Experience as Counts and Dates, Not Adjectives](references/wizard-capture-experience-as-counts-and-dates.md) — HIGH (prevents aspirational self-rating that flattens the feature)
   - 5.2 [Make Optional Questions Genuinely Skippable and Log the Skip](references/wizard-make-skips-genuine-and-log-them.md) — HIGH (preserves the "did not answer" signal instead of destroying it)
   - 5.3 [Order Wizard Questions by Information Gain](references/wizard-order-questions-by-information-gain.md) — HIGH (2-3x feature usefulness per completed wizard question)
   - 5.4 [Prefer Multiple-Choice over Free Text in the Wizard](references/wizard-prefer-multiple-choice-over-free-text.md) — HIGH (prevents downstream NLP cost and training-serving drift)
   - 5.5 [Separate Hard Constraints from Soft Preferences in the Wizard](references/wizard-separate-hard-constraints-from-soft-preferences.md) — HIGH (prevents 30-50% of requests ending in owner rejection)
6. [Derived Similarity and Affinity](references/_sections.md#6-derived-similarity-and-affinity) — **MEDIUM-HIGH**
   - 6.1 [Cache the User Embedding with a Short TTL, Not Per-Request](references/derive-cache-user-embedding-with-short-ttl.md) — MEDIUM-HIGH (drops u2i latency from 80ms to 5ms per request)
   - 6.2 [Decompose Affinity into Interpretable Subscores](references/derive-decompose-affinity-into-interpretable-subscores.md) — MEDIUM-HIGH (cuts rank-debug investigation time by 3-5x)
   - 6.3 [Fuse Modalities Before Computing Item Similarity](references/derive-fuse-modalities-before-item-similarity.md) — MEDIUM-HIGH (multi-modal i2i beats any single modality alone)
   - 6.4 [Precompute Item-to-Item Nearest Neighbours Offline](references/derive-precompute-i2i-nearest-neighbours-offline.md) — MEDIUM-HIGH (turns i2i from 500ms per request to 5ms)
   - 6.5 [Score User-to-User Compatibility as Symmetric Mutual Fit](references/derive-score-u2u-as-symmetric-mutual-fit.md) — MEDIUM-HIGH (prevents the 30-50% of requests that end in owner rejection)
   - 6.6 [Use a Two-Tower Model for User-to-Item Affinity](references/derive-use-two-tower-for-user-item-affinity.md) — MEDIUM-HIGH (learned u2i affinity beats hand-crafted scoring 2-5x on NDCG)
7. [Feature Quality and Governance](references/_sections.md#7-feature-quality-and-governance) — **MEDIUM-HIGH**
   - 7.1 [Freeze Feature Schemas per Model Version](references/quality-freeze-feature-schemas-per-model-version.md) — MEDIUM-HIGH (prevents mid-flight schema drift from silently retraining the wrong model)
   - 7.2 [Gate Every Feature on Coverage and Drift Alarms](references/quality-gate-features-on-coverage-and-drift.md) — MEDIUM-HIGH (catches coverage collapse 10-20x earlier than metric drift)
   - 7.3 [Scrub PII Before Features Leave the Secure Zone](references/quality-scrub-pii-before-features-leave-secure-zone.md) — MEDIUM-HIGH (prevents GDPR exposure through embedding leaks)
   - 7.4 [Serve Training and Inference Features from One Store](references/quality-serve-training-and-inference-from-one-store.md) — MEDIUM-HIGH (eliminates the #1 cause of silent model regression)
   - 7.5 [Version Feature Definitions in a Single Registry](references/quality-version-feature-definitions-in-one-registry.md) — MEDIUM-HIGH (prevents two models silently computing the same feature differently)
8. [Incremental Rollout and Value Proof](references/_sections.md#8-incremental-rollout-and-value-proof) — **MEDIUM**
   - 8.1 [Dedicate a Random Exploration Slice to New Features](references/prove-dedicate-random-exploration-slice-to-new-features.md) — MEDIUM (prevents offline-metric overfitting from blocking good features)
   - 8.2 [Kill Features That Do Not Earn Their Maintenance Cost](references/prove-kill-features-that-dont-earn-maintenance.md) — MEDIUM (removes 20-40% of features over the first year of portfolio maturity)
   - 8.3 [Measure Lift Against a Feature-Ablated Variant, Not the Old Model](references/prove-measure-lift-against-feature-ablated-variant.md) — MEDIUM (prevents attribution confounds from hyperparameter or data changes)
   - 8.4 [Retain a Feature-Free Baseline Permanently](references/prove-retain-feature-free-baseline-permanently.md) — MEDIUM (prevents silent ML-vs-baseline gap collapse)
   - 8.5 [Ship One Feature at a Time in the First Year](references/prove-ship-one-feature-at-a-time.md) — MEDIUM (prevents bundled-release attribution confounds)

---

## References

1. [https://developers.google.com/machine-learning/guides/rules-of-ml](https://developers.google.com/machine-learning/guides/rules-of-ml)
2. [https://eugeneyan.com/writing/system-design-for-discovery/](https://eugeneyan.com/writing/system-design-for-discovery/)
3. [https://eugeneyan.com/writing/patterns-for-personalization/](https://eugeneyan.com/writing/patterns-for-personalization/)
4. [https://eugeneyan.com/writing/real-time-recommendations/](https://eugeneyan.com/writing/real-time-recommendations/)
5. [https://medium.com/airbnb-engineering/amenity-detection-and-beyond-new-frontiers-of-computer-vision-at-airbnb-144a4441b72e](https://medium.com/airbnb-engineering/amenity-detection-and-beyond-new-frontiers-of-computer-vision-at-airbnb-144a4441b72e)
6. [https://medium.com/airbnb-engineering/when-a-picture-is-worth-more-than-words-17718860dcc2](https://medium.com/airbnb-engineering/when-a-picture-is-worth-more-than-words-17718860dcc2)
7. [https://medium.com/airbnb-engineering/airbnbs-ai-powered-photo-tour-using-vision-transformer-e470535f76d4](https://medium.com/airbnb-engineering/airbnbs-ai-powered-photo-tour-using-vision-transformer-e470535f76d4)
8. [https://medium.com/airbnb-engineering/widetext-a-multimodal-deep-learning-framework-31ce2565880c](https://medium.com/airbnb-engineering/widetext-a-multimodal-deep-learning-framework-31ce2565880c)
9. [https://medium.com/airbnb-engineering/listing-embeddings-for-similar-listing-recommendations-and-real-time-personalization-in-search-601172f7603e](https://medium.com/airbnb-engineering/listing-embeddings-for-similar-listing-recommendations-and-real-time-personalization-in-search-601172f7603e)
10. [https://medium.com/airbnb-engineering/embedding-based-retrieval-for-airbnb-search-aabebfc85839](https://medium.com/airbnb-engineering/embedding-based-retrieval-for-airbnb-search-aabebfc85839)
11. [https://arxiv.org/pdf/1810.09591](https://arxiv.org/pdf/1810.09591)
12. [https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
13. [https://medium.com/pinterest-engineering/pinsage-a-new-graph-convolutional-neural-network-for-web-scale-recommender-systems-88795a107f48](https://medium.com/pinterest-engineering/pinsage-a-new-graph-convolutional-neural-network-for-web-scale-recommender-systems-88795a107f48)
14. [https://medium.com/pinterest-engineering/pinnersage-multi-modal-user-embedding-framework-for-recommendations-at-pinterest-bfd116b49475](https://medium.com/pinterest-engineering/pinnersage-multi-modal-user-embedding-framework-for-recommendations-at-pinterest-bfd116b49475)
15. [https://cs.stanford.edu/people/jure/pubs/itemsage-kdd22.pdf](https://cs.stanford.edu/people/jure/pubs/itemsage-kdd22.pdf)
16. [https://arxiv.org/abs/2306.08121](https://arxiv.org/abs/2306.08121)
17. [https://huggingface.co/docs/transformers/model_doc/clip](https://huggingface.co/docs/transformers/model_doc/clip)
18. [https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2)
19. [https://www.width.ai/post/product-similarity-search-with-fashion-clip](https://www.width.ai/post/product-similarity-search-with-fashion-clip)
20. [https://aws.amazon.com/blogs/machine-learning/implement-unified-text-and-image-search-with-a-clip-model-using-amazon-sagemaker-and-amazon-opensearch-service/](https://aws.amazon.com/blogs/machine-learning/implement-unified-text-and-image-search-with-a-clip-model-using-amazon-sagemaker-and-amazon-opensearch-service/)
21. [https://www.shaped.ai/blog/the-two-tower-model-for-recommendation-systems-a-deep-dive](https://www.shaped.ai/blog/the-two-tower-model-for-recommendation-systems-a-deep-dive)
22. [https://www.hopsworks.ai/dictionary/two-tower-embedding-model](https://www.hopsworks.ai/dictionary/two-tower-embedding-model)
23. [https://h3geo.org/](https://h3geo.org/)
24. [https://docs.feast.dev](https://docs.feast.dev)
25. [https://feast.dev/blog/what-is-a-feature-store/](https://feast.dev/blog/what-is-a-feature-store/)
26. [https://medium.com/@scoopnisker/solving-the-training-serving-skew-problem-with-feast-feature-store-3719b47e23a2](https://medium.com/@scoopnisker/solving-the-training-serving-skew-problem-with-feast-feature-store-3719b47e23a2)
27. [https://careersatdoordash.com/blog/building-a-gigascale-ml-feature-store-with-redis/](https://careersatdoordash.com/blog/building-a-gigascale-ml-feature-store-with-redis/)
28. [https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/](https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/)
29. [https://www.uber.com/blog/michelangelo-machine-learning-platform/](https://www.uber.com/blog/michelangelo-machine-learning-platform/)
30. [https://www.uber.com/us/en/blog/michelangelo-machine-learning-model-representation/](https://www.uber.com/us/en/blog/michelangelo-machine-learning-model-representation/)
31. [https://greatexpectations.io/blog/ml-ops-data-quality/](https://greatexpectations.io/blog/ml-ops-data-quality/)
32. [https://www.hopsworks.ai/post/data-validation-for-enterprise-ai-using-great-expectations-with-hopsworks](https://www.hopsworks.ai/post/data-validation-for-enterprise-ai-using-great-expectations-with-hopsworks)
33. [https://www.nngroup.com/articles/progressive-disclosure/](https://www.nngroup.com/articles/progressive-disclosure/)
34. [https://www.nngroup.com/articles/required-fields/](https://www.nngroup.com/articles/required-fields/)
35. [https://docs.aws.amazon.com/personalize/latest/dg/item-dataset-requirements.html](https://docs.aws.amazon.com/personalize/latest/dg/item-dataset-requirements.html)
36. [https://research.netflix.com/research-area/recommendations](https://research.netflix.com/research-area/recommendations)
37. [https://experimentguide.com/](https://experimentguide.com/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
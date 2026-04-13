# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by cascade impact on the feature-engineering lifecycle for a
two-sided marketplace recommender. A mistake at an earlier stage silently corrupts
every stage that depends on it. Auditing mistakes produce features built on
imaginary data. First-principles mistakes produce features borrowed from other
products that do not match this marketplace's decisions. Extraction mistakes
produce garbage signals that no downstream composition can rescue. Composition
mistakes produce similarity and affinity scores that look reasonable offline and
collapse online. Quality mistakes let drift eat the model silently. Rollout
mistakes let a feature portfolio accumulate maintenance cost without lift.

---

## 1. Asset Audit and Inventory (audit)

**Impact:** CRITICAL  
**Description:** Every downstream stage is built on assumptions about raw data, so an honest audit of what actually exists — coverage, freshness, quality, privacy status — is the only thing that separates a feature plan from wishful thinking.

## 2. First-Principles Feature Decomposition (firstp)

**Impact:** CRITICAL  
**Description:** Features must be derived from the specific decision a buyer or seller is making in this marketplace, not copied from other products, so every candidate feature is reasoned backwards from the outcome it is supposed to move and the solution (i2i, u2i, u2u) it is supposed to feed.

## 3. Image Feature Extraction (vision)

**Impact:** HIGH  
**Description:** Listing photos carry aesthetic, layout, amenity, and quality signal that text cannot capture, so vision features — CLIP or domain-tuned embeddings, room-type classification, object detection, quality scoring — are the highest-leverage extraction in a visual marketplace when done with discipline around pooling, freshness, and privacy.

## 4. Listing Text and Metadata Extraction (listing)

**Impact:** HIGH  
**Description:** Owner-supplied metadata (amenities, location, duration, pet requirements, descriptions) is the cheapest, most controllable feature source, so the quality of categorical encoding, geo-hashing, text embedding, and structured triple design determines how much downstream i2i and u2i ranking can learn without new ML infrastructure.

## 5. Sitter Wizard and Profile Extraction (wizard)

**Impact:** HIGH  
**Description:** Sitter self-declarations from the onboarding wizard are features by construction, so question ordering by information gain, multiple-choice over free text, honest skippability, and the hard-constraint-versus-soft-preference split decide whether the wizard produces usable u2i features or noise.

## 6. Derived Similarity and Affinity (derive)

**Impact:** MEDIUM-HIGH  
**Description:** Item-to-item similarity, user-to-item affinity, and user-to-user mutual fit are compositions over base features — fused modalities, trained two-tower embeddings, interpretable subscores, precomputed nearest-neighbour shelves — so the composition strategy governs whether i2i, u2i, and u2u surfaces are debuggable, servable, and actually two-sided.

## 7. Feature Quality and Governance (quality)

**Impact:** MEDIUM-HIGH  
**Description:** Features silently rot through drift, privacy leaks, training-serving skew, and definitional ambiguity, so a single feature registry, a feature store that serves both training and inference, coverage and drift alarms, and PII scrubbing at the extraction boundary keep the portfolio trustworthy over time.

## 8. Incremental Rollout and Value Proof (prove)

**Impact:** MEDIUM  
**Description:** Features must earn their place in production through online A/B tests against a feature-ablated variant, not against the previous model, so shipping one feature at a time, dedicating an exploration slice, killing non-lifting features, and retaining a feature-free baseline protect the portfolio from accumulating maintenance cost without measurable value.

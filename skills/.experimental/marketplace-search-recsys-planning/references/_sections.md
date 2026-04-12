# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by cascade impact on the retrieval lifecycle of a two-sided
marketplace. Intent misunderstanding poisons architecture; wrong architecture poisons
index shape; wrong index shape poisons retrieval forever until a reindex; and every
downstream layer inherits the upstream error. Planning and monitoring are meta-layers
that observe the cascade and drive the iteration cycle — they are deliberately
positioned to feed back into the upstream layers as the system evolves.

---

## 1. Problem Framing and User Intent (intent)

**Impact:** CRITICAL  
**Description:** Misunderstanding what users are actually doing — searching for a specific result, browsing for inspiration, or asking the system to suggest — poisons every downstream decision and produces a system that is technically correct and operationally wrong.

## 2. Surface Taxonomy and Architecture (arch)

**Impact:** CRITICAL  
**Description:** Mapping product surfaces to the right retrieval primitive (search, recommender, hybrid) determines the shape of the entire system, and choosing the wrong primitive per surface forces expensive architectural rework months later.

## 3. Index Design and Mapping (index)

**Impact:** HIGH  
**Description:** OpenSearch mappings are effectively immutable without a full reindex, so field types, analyzers and multi-field layouts are lifetime commitments that constrain every query and ranking choice that follows.

## 4. Planning and Improvement Methodology (plan)

**Impact:** HIGH  
**Description:** Retrieval work without a structured plan, a golden query set, a decisions log and a bottleneck analysis drifts into algorithm tuning when the real problem is instrumentation or coverage — applying theory of constraints prevents months of wasted effort.

## 5. Query Understanding (query)

**Impact:** MEDIUM-HIGH  
**Description:** Query parsing, normalization, analyzer choice, synonym management, typo tolerance and intent classification turn raw user input into a structured retrieval request, and each layer directly affects recall, precision and reformulation rate.

## 6. Retrieval Strategy (retrieve)

**Impact:** MEDIUM-HIGH  
**Description:** OpenSearch query DSL structure — filter versus must clauses, bool composition, hybrid BM25 plus KNN, rescoring — governs how candidates are generated from the index, and each stage trades off latency, relevance and cache efficiency.

## 7. Relevance and Ranking (rank)

**Impact:** MEDIUM-HIGH  
**Description:** Scoring candidates by BM25 parameters, function_score business signals, rescoring pipelines, and Learning to Rank models determines the ordering users actually see, but only if the upstream retrieval and index layers are correct.

## 8. Search and Recommender Blending (blend)

**Impact:** MEDIUM  
**Description:** Deciding when to use search alone, recommendations alone, or a blended response — with explicit normalization and zero-result fallbacks — protects the marketplace from dead-end sessions and keeps cold-start cohorts productive.

## 9. Measurement and Experimentation (measure)

**Impact:** MEDIUM  
**Description:** Defining the right metrics — NDCG, MRR, zero-result rate, session success, reformulation rate — and the right experimentation primitives — golden sets, offline judgments, interleaving, online A/B tests — turns "does it feel better" into "did it actually improve".

## 10. Instrumentation, Dashboards and Decision Triggers (monitor)

**Impact:** MEDIUM  
**Description:** Raw query logs, decision-triggering dashboards, threshold alerts, ranking churn tracking and a weekly quality review ritual are the instrumentation that converts measurement into ongoing decision-making, and without them the team operates on intuition instead of evidence.

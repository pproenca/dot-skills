---
name: linguistic-semantic-algorithms
description: Use this skill whenever mapping out an unfamiliar codebase, hunting bugs across many files, scoping a new feature, identifying domain entities, or analyzing commit history — covers 40 algorithms across topic modelling, semantic embeddings, code graphs, repository mining, clone detection, IR-based bug localization, identifier linguistics, and complexity metrics. Trigger even if the user doesn't explicitly mention algorithms — apply when they ask "where does X live in this codebase?", "what is this codebase about?", "find duplicated logic", "what changed recently?", "who owns this code?", or "is this function risky?".
---

# pproenca Linguistic and Semantic Algorithms Best Practices

Reference of 40 algorithms an agent should reach for when extracting structure, meaning, history, or risk signals from source code and commit data. Categories are ordered by **insight-per-effort** — how much non-obvious truth the technique exposes relative to how easy it is to apply. The first two categories target the highest-leverage questions: *what business entities live in this code?* and *where else does this concept already exist?* — questions that grep and intuition cannot answer.

## When to Apply

Reach for these algorithms when:

- **Orienting in an unfamiliar codebase**: PageRank the import graph to find the core, run LDA over identifier tokens to discover business themes, mine change coupling to surface hidden architectural couplings.
- **Hunting a bug from a description**: BM25 + history prior + embedding re-rank produces a ranked file shortlist far better than grep.
- **Scoping a feature**: find prior PRs that did similar work via embedding similarity; map the feature's vocabulary against the codebase's domain via TF-IDF and noun-phrase mining.
- **Reviewing a refactor**: AST-level GumTree diff reveals semantic impact text diff hides; PDG isomorphism finds the "same logic, different code" twin you should also update.
- **Auditing risk**: hotspots (churn × complexity), bus factor, defect-magnet density, dead-code candidates — together they direct attention to the parts of the codebase that pay back attention.
- **Identifying domain entities and bounded contexts**: noun-phrase mining + TF-IDF rare-term extraction + Louvain communities + Jensen-Shannon divergence on per-cluster vocabulary.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Question answered |
|---|---|---|---|---|
| 1 | Concept & Domain Extraction | CRITICAL | `concept-` | What business entities live in this code? |
| 2 | Semantic Similarity & Feature Mapping | CRITICAL | `sim-` | Where else does this concept already exist? |
| 3 | Architectural Topology | HIGH | `graph-` | What is the shape of this codebase? |
| 4 | Co-Change & Temporal Mining | HIGH | `mine-` | What hidden couplings does history reveal? |
| 5 | Clone & Duplication Detection | MEDIUM-HIGH | `clone-` | Where are we repeating ourselves? |
| 6 | Bug & Feature Localization | MEDIUM-HIGH | `local-` | Given a description, where in code? |
| 7 | Identifier Linguistics | MEDIUM | `ling-` | How to prepare tokens so the other algorithms work? |
| 8 | Complexity & Risk Metrics | MEDIUM | `risk-` | Where is the danger concentrated? |

## Quick Reference

### 1. Concept & Domain Extraction (CRITICAL)

- [`concept-lda-topic-modeling`](references/concept-lda-topic-modeling.md) — LDA over identifier tokens surfaces latent business themes
- [`concept-noun-phrase-mining`](references/concept-noun-phrase-mining.md) — POS-tag + chunk identifiers to extract entity candidates
- [`concept-tfidf-rare-terms`](references/concept-tfidf-rare-terms.md) — IDF against a generic corpus isolates domain vocabulary from framework noise
- [`concept-identifier-cooccurrence-network`](references/concept-identifier-cooccurrence-network.md) — PMI-weighted co-occurrence graph reveals conceptual neighborhoods
- [`concept-entity-name-resolution`](references/concept-entity-name-resolution.md) — Cluster name variants (`user/usr/u/userAccount`) via embedding + edit distance
- [`concept-bounded-context-detection`](references/concept-bounded-context-detection.md) — Louvain + Jensen-Shannon divergence detects DDD bounded contexts

### 2. Semantic Similarity & Feature Mapping (CRITICAL)

- [`sim-codebert-embeddings`](references/sim-codebert-embeddings.md) — CodeBERT + cosine for semantic code search across renames
- [`sim-pdg-semantic-clones`](references/sim-pdg-semantic-clones.md) — Program Dependence Graph isomorphism finds Type-4 clones
- [`sim-cross-pr-feature-mapping`](references/sim-cross-pr-feature-mapping.md) — Embed merged PRs once, retrieve precedent at feature-design time
- [`sim-cosine-vsm-files`](references/sim-cosine-vsm-files.md) — TF-IDF VSM file similarity when no GPU is available
- [`sim-call-pattern-similarity`](references/sim-call-pattern-similarity.md) — N-grams on call-sequence find behavioral twins
- [`sim-doc-code-alignment`](references/sim-doc-code-alignment.md) — Joint code-doc embedding flags drift between docs and code

### 3. Architectural Topology (HIGH)

- [`graph-pagerank-core`](references/graph-pagerank-core.md) — PageRank the import graph to find the codebase core
- [`graph-betweenness-bottlenecks`](references/graph-betweenness-bottlenecks.md) — Betweenness centrality surfaces bottleneck modules
- [`graph-louvain-modules`](references/graph-louvain-modules.md) — Louvain community detection reveals natural module boundaries
- [`graph-scc-cycle-tangles`](references/graph-scc-cycle-tangles.md) — Tarjan's SCC algorithm exposes circular-dependency tangles
- [`graph-feedback-arcs`](references/graph-feedback-arcs.md) — Eades-Lin-Smyth FAS chooses the smallest cycle-breaking cut

### 4. Co-Change & Temporal Mining (HIGH)

- [`mine-change-coupling`](references/mine-change-coupling.md) — Conditional probability over commit history exposes hidden coupling
- [`mine-hotspots-churn-complexity`](references/mine-hotspots-churn-complexity.md) — Churn × complexity = canonical hotspot score (Tornhill)
- [`mine-bus-factor`](references/mine-bus-factor.md) — Per-file authorship Gini coefficient surfaces knowledge concentration
- [`mine-commit-topic-modeling`](references/mine-commit-topic-modeling.md) — LDA on commit messages reveals quarterly themes
- [`mine-bug-fix-density`](references/mine-bug-fix-density.md) — Classify commits, rank files by fix-density to find defect magnets
- [`mine-codebase-aging`](references/mine-codebase-aging.md) — Last-modified age + reachability splits stable code from dead code

### 5. Clone & Duplication Detection (MEDIUM-HIGH)

- [`clone-minhash-lsh`](references/clone-minhash-lsh.md) — MinHash + LSH for sub-linear near-duplicate retrieval
- [`clone-simhash`](references/clone-simhash.md) — SimHash 64-bit fingerprints for O(1) Hamming-distance lookups
- [`clone-suffix-array-cpd`](references/clone-suffix-array-cpd.md) — Token-level suffix array (PMD CPD) for precise clone boundaries
- [`clone-ast-gumtree`](references/clone-ast-gumtree.md) — GumTree algorithm for fine-grained AST differencing
- [`clone-zhang-shasha-ted`](references/clone-zhang-shasha-ted.md) — Zhang-Shasha tree edit distance for exact subtree similarity

### 6. Bug & Feature Localization (MEDIUM-HIGH)

- [`local-tfidf-bug-reports`](references/local-tfidf-bug-reports.md) — TF-IDF rank source files against bug report tokens
- [`local-bm25-saturation`](references/local-bm25-saturation.md) — BM25 handles length normalization and TF saturation
- [`local-history-prior-localization`](references/local-history-prior-localization.md) — Bayesian fusion of IR score with bug-history prior
- [`local-embedding-bug-text`](references/local-embedding-bug-text.md) — Two-stage BM25 + embedding re-rank for semantic localization

### 7. Identifier Linguistics (MEDIUM)

- [`ling-camel-snake-split`](references/ling-camel-snake-split.md) — Split camelCase, snake_case, digit-boundaries before any analysis
- [`ling-abbreviation-expansion`](references/ling-abbreviation-expansion.md) — Expand `idx→index`, `mgr→manager` via dictionary + mining
- [`ling-porter-stemming`](references/ling-porter-stemming.md) — Apply Porter stemmer to unify singular/plural forms
- [`ling-pos-tagging-identifiers`](references/ling-pos-tagging-identifiers.md) — POS-tag identifier heads to flag misnamed functions/classes

### 8. Complexity & Risk Metrics (MEDIUM)

- [`risk-cyclomatic-mccabe`](references/risk-cyclomatic-mccabe.md) — McCabe cyclomatic complexity for branch-test surface
- [`risk-cognitive-complexity`](references/risk-cognitive-complexity.md) — SonarSource Cognitive Complexity for readability gates
- [`risk-halstead-volume`](references/risk-halstead-volume.md) — Halstead volume for language-agnostic size and effort
- [`risk-shannon-entropy-naming`](references/risk-shannon-entropy-naming.md) — Per-token entropy flags overloaded names

## How to Use

Pick the category that matches the user's question, then read one or two specific rules from that category. Most rules cite combinable partners ("Combine with `mine-change-coupling`...") that compound the signal — read the partner rule when you need higher precision.

For unfamiliar repos, the highest-ROI starting sequence is:
1. `graph-pagerank-core` → read the top-20 most central files
2. `concept-lda-topic-modeling` + `concept-tfidf-rare-terms` → identify the business themes
3. `mine-hotspots-churn-complexity` → find where the bugs concentrate
4. `mine-change-coupling` → uncover hidden architectural couplings

For a single-task bug or feature, the pipeline is:
1. `local-bm25-saturation` (broad candidates) → `local-embedding-bug-text` (semantic re-rank) → `local-history-prior-localization` (fix-history boost)
2. `sim-cross-pr-feature-mapping` for prior precedent on new features
3. `mine-change-coupling` to surface partner files that historically move together

Always preprocess identifier tokens via `ling-camel-snake-split` → `ling-abbreviation-expansion` → `ling-porter-stemming` before any vocabulary-based algorithm. Skipping this step silently degrades every downstream signal.

**Cross-language parsing.** Most rule code examples use Python's built-in `ast` module for brevity. For real cross-language work (Go, Rust, Java, TS, C++ in the same repo), use [tree-sitter](https://tree-sitter.github.io/tree-sitter/) — it provides robust parsers for 40+ languages with a uniform API. Every AST-based rule in this skill (PDG clones, GumTree, Zhang-Shasha, POS-tag heads, identifier co-occurrence) maps cleanly onto tree-sitter ASTs.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new algorithm rules |
| [metadata.json](metadata.json) | Version and reference information |

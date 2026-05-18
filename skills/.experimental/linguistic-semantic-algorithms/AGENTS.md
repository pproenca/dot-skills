# Codebase Analysis Algorithms

**Version 0.1.0**  
pproenca  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs applying Codebase Analysis Algorithms  
> when mapping, debugging, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Reference of 40 linguistic, semantic, statistical, and graph algorithms an AI agent should reach for when mapping an unfamiliar codebase, hunting bugs, scoping features, or analyzing commit history. Organized into 8 categories ordered by insight-per-effort — from concept and domain extraction (LDA, noun-phrase mining, TF-IDF rare-term extraction, entity resolution, bounded-context detection) and semantic similarity (CodeBERT embeddings, PDG isomorphism for Type-4 clones, call-pattern n-grams, doc-code alignment) through architectural topology (PageRank, betweenness, Louvain, SCC, feedback-arc-set), co-change mining (change coupling, hotspots, bus factor, commit-topic modeling), clone detection (MinHash, SimHash, suffix-array CPD, GumTree, Zhang-Shasha), bug-localization IR (TF-IDF, BM25, history priors, embedding re-rank), identifier-linguistic preprocessing (camel/snake split, abbreviation expansion, Porter stemming, POS tagging) to complexity metrics (cyclomatic, cognitive, Halstead, Shannon entropy on naming). Each rule contrasts the naive grep-or-eyeball approach with the algorithmic alternative, with production-realistic code in Python and references to canonical papers.

---

## Table of Contents

1. [Concept & Domain Extraction](references/_sections.md#1-concept-&-domain-extraction) — **CRITICAL**
   - 1.1 [Build an Identifier Co-occurrence Graph to Reveal Conceptual Neighborhoods](references/concept-identifier-cooccurrence-network.md) — HIGH (reduces noise from utility tokens via PMI-weighted edges)
   - 1.2 [Cluster Identifier Variants into Canonical Entities via Embedding plus Edit Distance](references/concept-entity-name-resolution.md) — HIGH (deduplicates 30-50% of identifier vocabulary into canonical entity names)
   - 1.3 [Detect DDD Bounded Contexts via Louvain Communities Plus Vocabulary Divergence](references/concept-bounded-context-detection.md) — HIGH (automatic detection of bounded-context candidates without manual partitioning)
   - 1.4 [Extract Noun Phrases from Identifiers to Find Candidate Domain Entities](references/concept-noun-phrase-mining.md) — CRITICAL (surfaces 80%+ of domain entities from naming alone)
   - 1.5 [Use LDA over Identifier Tokens to Surface Latent Domain Topics](references/concept-lda-topic-modeling.md) — CRITICAL (reduces a 100k-file codebase to 10-20 named topics in one pass)
   - 1.6 [Use TF-IDF Against a Generic Corpus to Separate Domain Vocabulary from Framework Noise](references/concept-tfidf-rare-terms.md) — CRITICAL (eliminates 90%+ of framework terms from domain-vocabulary ranking)
2. [Semantic Similarity & Feature Mapping](references/_sections.md#2-semantic-similarity-&-feature-mapping) — **CRITICAL**
   - 2.1 [Compare Functions by Call-Sequence N-grams to Find Behavioral Twins](references/sim-call-pattern-similarity.md) — MEDIUM-HIGH (reduces behavioral-clone search to set operations on call-trace n-grams)
   - 2.2 [Embed Documentation and Code in the Same Space to Detect Drift](references/sim-doc-code-alignment.md) — MEDIUM-HIGH (automatic flagging of stale docs via joint code-doc embedding)
   - 2.3 [Find Type-4 Clones via Program Dependence Graph Isomorphism](references/sim-pdg-semantic-clones.md) — HIGH (eliminates false negatives on Type-4 clones text and AST diff both miss)
   - 2.4 [Map New Feature Requests to Prior Pull Requests via Diff Embedding Similarity](references/sim-cross-pr-feature-mapping.md) — HIGH (reduces a 1000-PR backlog to top-3 implementation precedents per feature)
   - 2.5 [Use CodeBERT Embeddings plus Cosine Similarity for Semantic Code Search](references/sim-codebert-embeddings.md) — CRITICAL (enables semantic code search across renames, synonyms, and rewrites)
   - 2.6 [Use TF-IDF Vector Space Model for File Similarity When No GPU Is Available](references/sim-cosine-vsm-files.md) — MEDIUM-HIGH (enables semantic-ish file search at 100x lower cost than neural embeddings)
3. [Architectural Topology](references/_sections.md#3-architectural-topology) — **HIGH**
   - 3.1 [Apply Louvain Community Detection to Reveal Natural Module Boundaries](references/graph-louvain-modules.md) — HIGH (reduces O(N^2) modularity search to O(N log N) for module discovery)
   - 3.2 [Approximate Minimum Feedback Arc Set to Choose the Smallest Cycle-Breaking Cut](references/graph-feedback-arcs.md) — MEDIUM-HIGH (minimizes edits required to make the import graph acyclic)
   - 3.3 [Run PageRank on the Import Graph to Find the Codebase Core](references/graph-pagerank-core.md) — HIGH (ranks the 1% of files that everything depends on)
   - 3.4 [Use Betweenness Centrality to Find Bottleneck Modules](references/graph-betweenness-bottlenecks.md) — HIGH (prevents brittle refactors by surfacing bottleneck modules)
   - 3.5 [Use Strongly Connected Components to Find Dependency Cycle Tangles](references/graph-scc-cycle-tangles.md) — HIGH (reveals every cyclic import group in O(V+E) — Tarjan's algorithm)
4. [Co-Change & Temporal Mining](references/_sections.md#4-co-change-&-temporal-mining) — **HIGH**
   - 4.1 [Compute Change Coupling from Git History to Find Hidden Architectural Couplings](references/mine-change-coupling.md) — HIGH (directly affects refactor scope by exposing cross-layer coupling static analysis misses)
   - 4.2 [Compute Per-File Bus Factor from Authorship Concentration](references/mine-bus-factor.md) — MEDIUM-HIGH (prevents key-person dependencies from surprising the team mid-incident)
   - 4.3 [Multiply Churn by Complexity to Find the Real Bug Hotspots](references/mine-hotspots-churn-complexity.md) — HIGH (ranks files where bugs concentrate — 80% of defects in 20% of files)
   - 4.4 [Plot Per-File Age Distribution to Separate Stable Code from Forgotten Code](references/mine-codebase-aging.md) — MEDIUM (eliminates dead-code candidates that static analysis alone cannot confirm)
   - 4.5 [Rank Files by Bug-Fix Density to Find Defect Magnets](references/mine-bug-fix-density.md) — MEDIUM-HIGH (identifies files where 50%+ of commits are bug fixes)
   - 4.6 [Run LDA on Commit Messages to Discover the Real Themes of Recent Work](references/mine-commit-topic-modeling.md) — MEDIUM-HIGH (reduces 5000 quarterly commits to 5-10 named themes for retrospectives)
5. [Clone & Duplication Detection](references/_sections.md#5-clone-&-duplication-detection) — **MEDIUM-HIGH**
   - 5.1 [Compute Zhang-Shasha Tree Edit Distance for Subtree Similarity Scoring](references/clone-zhang-shasha-ted.md) — MEDIUM (O(n^2 · m^2) tree distance — the exact baseline behind every approximate clone tool)
   - 5.2 [Use MinHash plus LSH to Find Near-Duplicate Code at Repository Scale](references/clone-minhash-lsh.md) — MEDIUM-HIGH (reduces O(n^2) pairwise Jaccard to sub-linear retrieval at 10k+ files)
   - 5.3 [Use SimHash 64-bit Fingerprints for Constant-Time Similarity Lookups](references/clone-simhash.md) — MEDIUM-HIGH (reduces a file to a 64-bit fingerprint with O(1) Hamming distance)
   - 5.4 [Use the GumTree Algorithm for Fine-Grained AST Differencing](references/clone-ast-gumtree.md) — MEDIUM-HIGH (reduces a 240-line text diff to 4 semantic AST actions on typical refactors)
   - 5.5 [Use Token-Level Suffix Arrays for Precise Clone Boundary Detection](references/clone-suffix-array-cpd.md) — MEDIUM-HIGH (finds clone boundaries in O(n log n) with exact location and length)
6. [Bug & Feature Localization](references/_sections.md#6-bug-&-feature-localization) — **MEDIUM-HIGH**
   - 6.1 [Boost IR Scores with a Bug-History Prior for Better Localization Precision](references/local-history-prior-localization.md) — MEDIUM (improves top-10 bug-localization precision by 15-30% over IR-only ranking)
   - 6.2 [Embed Bug Reports and Source Code in the Same Space for Semantic Localization](references/local-embedding-bug-text.md) — MEDIUM (enables semantic localization when bug and code share no vocabulary)
   - 6.3 [Rank Source Files by TF-IDF Against Bug Report Text for Localization](references/local-tfidf-bug-reports.md) — MEDIUM-HIGH (reduces a 10k-file repo to a 10-file candidate list from a bug report)
   - 6.4 [Use BM25 over TF-IDF when Source Files Vary Greatly in Length](references/local-bm25-saturation.md) — MEDIUM (prevents long-file bias in IR ranking via TF saturation and length normalization)
7. [Identifier Linguistics](references/_sections.md#7-identifier-linguistics) — **MEDIUM**
   - 7.1 [Apply Porter Stemming to Unify Singular and Plural Token Forms](references/ling-porter-stemming.md) — MEDIUM (collapses 10-20% of vocabulary into shared roots without semantic loss)
   - 7.2 [Expand Identifier Abbreviations Against a Domain Dictionary](references/ling-abbreviation-expansion.md) — MEDIUM (reduces synonym fragmentation by 30-40% in identifier-vocabulary tasks)
   - 7.3 [Split camelCase and snake_case Identifiers Before Any Text Analysis](references/ling-camel-snake-split.md) — MEDIUM (prevents 50%+ vocabulary fragmentation that breaks every downstream algorithm)
   - 7.4 [Tag Identifier Tokens with POS to Find Misnamed Functions and Classes](references/ling-pos-tagging-identifiers.md) — MEDIUM (flags 5-10% of identifiers that violate noun/verb naming conventions)
8. [Complexity & Risk Metrics](references/_sections.md#8-complexity-&-risk-metrics) — **MEDIUM**
   - 8.1 [Compute Shannon Entropy of Identifier Tokens to Flag Overloaded Names](references/risk-shannon-entropy-naming.md) — LOW-MEDIUM (eliminates overloaded-name confusion via per-token directory entropy)
   - 8.2 [Measure McCabe Cyclomatic Complexity to Quantify Per-Function Branch Risk](references/risk-cyclomatic-mccabe.md) — MEDIUM (predicts independent test paths in O(edges - nodes + 2))
   - 8.3 [Use Cognitive Complexity When Readability Risk Matters More Than Test Surface](references/risk-cognitive-complexity.md) — MEDIUM (prevents the false-positive complexity flags that cyclomatic complexity produces)
   - 8.4 [Use Halstead Volume for a Language-Agnostic Size and Effort Metric](references/risk-halstead-volume.md) — LOW-MEDIUM (enables cross-language complexity comparison without LoC bias)

---

## References

1. [https://www.jmlr.org/papers/v3/blei03a.html](https://www.jmlr.org/papers/v3/blei03a.html)
2. [https://pragprog.com/titles/atcrime2/your-code-as-a-crime-scene-second-edition/](https://pragprog.com/titles/atcrime2/your-code-as-a-crime-scene-second-edition/)
3. [https://arxiv.org/abs/2002.08155](https://arxiv.org/abs/2002.08155)
4. [https://arxiv.org/abs/2203.03850](https://arxiv.org/abs/2203.03850)
5. [https://hal.science/hal-01054552/document](https://hal.science/hal-01054552/document)
6. [https://epubs.siam.org/doi/10.1137/0218082](https://epubs.siam.org/doi/10.1137/0218082)
7. [http://www.cs.princeton.edu/courses/archive/spring13/cos598C/broder97resemblance.pdf](http://www.cs.princeton.edu/courses/archive/spring13/cos598C/broder97resemblance.pdf)
8. [https://www.cs.princeton.edu/courses/archive/spr04/cos598B/bib/CharikarEstim.pdf](https://www.cs.princeton.edu/courses/archive/spr04/cos598B/bib/CharikarEstim.pdf)
9. [https://arxiv.org/abs/0803.0476](https://arxiv.org/abs/0803.0476)
10. [https://epubs.siam.org/doi/10.1137/0201010](https://epubs.siam.org/doi/10.1137/0201010)
11. [https://ieeexplore.ieee.org/document/1702388](https://ieeexplore.ieee.org/document/1702388)
12. [https://www.sonarsource.com/resources/cognitive-complexity/](https://www.sonarsource.com/resources/cognitive-complexity/)
13. [https://nlp.stanford.edu/IR-book/pdf/06vect.pdf](https://nlp.stanford.edu/IR-book/pdf/06vect.pdf)
14. [https://miltos.allamanis.com/publications/2014idioms/](https://miltos.allamanis.com/publications/2014idioms/)
15. [https://aclanthology.org/J90-1003/](https://aclanthology.org/J90-1003/)
16. [https://github.com/adamtornhill/code-maat](https://github.com/adamtornhill/code-maat)
17. [https://pmd.github.io/pmd/pmd_userdocs_cpd.html](https://pmd.github.io/pmd/pmd_userdocs_cpd.html)
18. [https://www.cs.toronto.edu/~frank/csc2501/Readings/R2_Porter/Porter-1980.pdf](https://www.cs.toronto.edu/~frank/csc2501/Readings/R2_Porter/Porter-1980.pdf)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
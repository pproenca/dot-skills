# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by **insight-per-effort** — how much non-obvious truth the technique extracts from a codebase or its history relative to how easy it is to apply. The first two answer the highest-leverage questions: *what business entities live in this code?* and *where else does this concept already exist?*

Note: a category's impact level is the impact of its *best* rules. Individual rules within a CRITICAL category may carry HIGH or MEDIUM-HIGH impact themselves — they're still in the highest-leverage category because the top rules in that category are CRITICAL. Inspect each rule's frontmatter for its specific impact level.

---

## 1. Concept & Domain Extraction (concept)

**Impact:** CRITICAL  
**Description:** Discovers the latent business vocabulary and entities a codebase encodes implicitly — LDA topics, noun-phrase mining, identifier co-occurrence networks, TF-IDF rare-term extraction, name-variant resolution, and bounded-context detection turn an undocumented codebase into a domain model before a single file is opened by hand.

## 2. Semantic Similarity & Feature Mapping (sim)

**Impact:** CRITICAL  
**Description:** Finds equivalent or near-equivalent behaviour across renames, synonyms, and rewrites — embedding-based code search, PDG isomorphism for type-4 clones, call-pattern n-grams, and doc-code alignment — so an agent can answer "where else is this feature implemented?" instead of grep-and-pray.

## 3. Architectural Topology (graph)

**Impact:** HIGH  
**Description:** Treats imports, calls, and references as a graph so PageRank, betweenness centrality, Louvain communities, strongly-connected components, and minimum-feedback-arc-set surface the *shape* of the codebase — core modules, bottlenecks, natural module boundaries, and cycle tangles invisible at the file level.

## 4. Co-Change & Temporal Mining (mine)

**Impact:** HIGH  
**Description:** Uses commit history as a signal source — files that change together, churn × complexity hotspots, authorship concentration (bus factor), commit-message topic modelling, and bug-fix density — to reveal couplings and risks the current snapshot of the code cannot show.

## 5. Clone & Duplication Detection (clone)

**Impact:** MEDIUM-HIGH  
**Description:** Scales duplication detection beyond grep with MinHash + LSH, SimHash, token suffix arrays (CPD), GumTree AST diff, and Zhang-Shasha tree edit distance — catching type-1 copy-paste, type-2 rename-only, and type-3 near-miss clones across a whole repository in minutes.

## 6. Bug & Feature Localization (local)

**Impact:** MEDIUM-HIGH  
**Description:** Given a bug report or feature description in natural language, ranks source files by relevance using TF-IDF, BM25, history priors, and embedding-based retrieval — turning "where do I even start?" into a ranked short-list of files most likely to contain the change.

## 7. Identifier Linguistics (ling)

**Impact:** MEDIUM  
**Description:** The preprocessing layer every other algorithm depends on — camelCase / snake_case splitting, abbreviation expansion, Porter stemming, and POS tagging on identifiers — without which `userId`, `user_id`, and `usrIdent` look like three different things and every downstream signal degrades.

## 8. Complexity & Risk Metrics (risk)

**Impact:** MEDIUM  
**Description:** Quantifies risk per file — McCabe cyclomatic complexity, SonarSource cognitive complexity, Halstead volume, and Shannon entropy on identifier vocabularies — to direct attention toward the most error-prone parts of the codebase when combined with the temporal signals from `mine-`.

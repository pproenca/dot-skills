# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Encoding & Bit Interleaving (enc)

**Impact:** CRITICAL  
**Description:** The encoder is the foundation every other operation depends on — a wrong bit-interleaving order, a non-standard base32 alphabet, or float drift in the binary chop silently corrupts every hash, query, and neighbor downstream. Get this exactly right or nothing else works.

## 2. Precision & Cell Geometry (prec)

**Impact:** CRITICAL  
**Description:** Precision (geohash length) determines cell size, error bounds, and query correctness for the whole system. Treating cells as square, ignoring that they shrink toward the poles, or confusing cell size with error radius produces results that look plausible but are wrong by a factor of two or more everywhere.

## 3. Neighbors & Adjacency (nbr)

**Impact:** HIGH  
**Description:** Adjacency is the most bug-prone primitive in geohashing — the canonical lookup-table algorithm, antimeridian wraparound, and pole handling all have edge cases that naive bit-math gets wrong. Every proximity query is built on top of correct neighbors, so errors here cascade into silent missing results.

## 4. Proximity & Range Queries (qry)

**Impact:** HIGH  
**Description:** The defining geohash trap: two points metres apart can share zero common prefix when they straddle a cell border. A query that only prefix-matches the centre cell returns false negatives at every boundary. Correct queries cover the cell plus its eight neighbours and refine with true distance.

## 5. Codebase-as-Map Spatial Layout (map)

**Impact:** HIGH  
**Description:** The signature application — projecting a codebase into a 2D plane so geohash prefixes become navigable domain regions. Getting the projection deterministic, stable across runs, and monotonic with code coupling is what makes the map usable; getting it wrong produces a pretty picture that reshuffles every commit and clusters unrelated code together.

## 6. Decoding & Bounding Boxes (dec)

**Impact:** MEDIUM-HIGH  
**Description:** Decoding recovers geography from a hash. The common mistakes — returning a bare centre point instead of the cell it represents, dropping the error margin, or re-encoding and accumulating round-trip drift — corrupt rendering, hit-testing, and any logic that compares decoded coordinates.

## 7. Spatial Indexing & Storage (idx)

**Impact:** MEDIUM-HIGH  
**Description:** Geohashes earn their keep as sortable keys: stored as sorted strings or interleaved integers they turn proximity into range scans that any B-tree or sorted set serves efficiently. Choosing the wrong key representation or query decomposition forces full scans and erases the index's advantage at scale.

## 8. Navigation & Rendering (nav)

**Impact:** MEDIUM  
**Description:** The Google-Maps-style UX layer over a geohashed dataset: mapping precision to zoom levels, aggregating by prefix for level-of-detail, lazy-loading tiles, and clustering markers. Lower cascade impact than the data layer, but it is what turns a correct spatial index into something a human can actually fly through.

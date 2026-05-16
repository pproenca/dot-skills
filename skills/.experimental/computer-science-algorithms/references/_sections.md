# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Asymptotic Complexity & Algorithm Selection (comp)

**Impact:** CRITICAL  
**Description:** The single most consequential decision: choosing an algorithm class whose asymptotic cost matches the input size. A wrong choice here (e.g. O(n²) where O(n log n) exists) makes every other optimization irrelevant once inputs grow.

## 2. Data Structure Selection (ds)

**Impact:** CRITICAL  
**Description:** The container determines which operations are cheap. The wrong data structure forces wrong-complexity algorithms — every read, write, lookup, or iteration pays the structural cost forever.

## 3. Sorting & Searching (srch)

**Impact:** HIGH  
**Description:** Sorting and searching are the bedrock of higher-level algorithms (greedy, two-pointer, sweep line, binary search on the answer). Reaching for the right library primitive prevents O(n²) hand-rolls and unlocks O(log n) lookups.

## 4. Dynamic Programming (dp)

**Impact:** HIGH  
**Description:** DP turns exponential recursions into polynomial computations by remembering subproblem answers. Correct state design and transition order separate problems solvable in milliseconds from problems that hang for hours.

## 5. Graph Algorithms (graph)

**Impact:** HIGH  
**Description:** Networks, dependencies, routing, scheduling, and reachability all reduce to graph problems. Picking the right traversal (BFS vs DFS) or shortest-path algorithm (Dijkstra vs Bellman-Ford vs BFS) changes complexity by orders of magnitude.

## 6. Divide & Conquer and Recursion (divide)

**Impact:** MEDIUM-HIGH  
**Description:** Recursive decomposition unlocks logarithmic-factor speedups (merge sort, FFT, binary search) but introduces stack-depth and recurrence-relation traps. The Master Theorem and tail-call patterns matter here.

## 7. Greedy Algorithms (greedy)

**Impact:** MEDIUM  
**Description:** Greedy algorithms are fast and simple when they work — but they only work when the problem has the greedy-choice and optimal-substructure properties. Misapplying greedy where DP is required produces silently wrong answers.

## 8. String & Sequence Algorithms (str)

**Impact:** MEDIUM  
**Description:** Strings have specialized algorithms (KMP, Z-function, suffix arrays, rolling hash) that beat naive O(nm) pattern matching. Choosing the right one prevents quadratic blowup on adversarial inputs.

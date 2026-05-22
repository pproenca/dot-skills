# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Sections are ordered by the execution lifecycle of a fog-of-war system:
schedule → compute FOV → merge → persist → diff → render → composite. Mistakes
earlier in this chain cascade across every viewer and every frame.

---

## 1. FOV / Visibility Algorithm (fov)

**Impact:** CRITICAL  
**Description:** The visibility algorithm fixes the complexity and correctness of every recompute; recursive shadowcasting visits each cell once (O(cells in radius)) while a naive ray-per-perimeter-cell sweep re-walks shared cells (O(cells × radius)) and produces asymmetric artifacts.

## 2. Update Scheduling & Incremental Recompute (update)

**Impact:** CRITICAL  
**Description:** Recomputing field of view when nothing changed multiplies cost across frames and across units; gating recompute on movement and applying refcounted deltas instead of full rebuilds is the single largest real-world win.

## 3. State Representation & Data Structures (state)

**Impact:** HIGH  
**Description:** Fog state is touched on every tile access and every recompute, so the container choice dominates cache behavior; flat typed arrays and bitsets are an order of magnitude faster than `boolean[][]` or `Map` keyed by `"x,y"` strings.

## 4. Rendering the Fog Layer (render)

**Impact:** HIGH  
**Description:** The fog is painted on frames where it is visible, so per-frame paint cost is paid continuously; an offscreen layer with dirty-region blits and GPU-upscaled soft fog avoids redrawing thousands of tiles every frame.

## 5. Memory & Allocation (mem)

**Impact:** MEDIUM-HIGH  
**Description:** Allocating fog buffers per frame creates GC pressure that surfaces as visible stutter; reusing buffers, clearing with `fill`/generation stamps, and bit-packing the explored layer keep the heap flat.

## 6. Multi-Viewer & Map Scaling (scale)

**Impact:** MEDIUM  
**Description:** RTS-scale unit counts and large maps break naive per-unit, per-frame approaches; chunking, shared team visibility, spatial-partitioned edits, and capped recompute budgets keep the cost bounded as the world grows.

## 7. Geometry & Hot-Loop Math (geo)

**Impact:** MEDIUM  
**Description:** Per-cell math is multiplied across every scanned cell, so small constant-factor wins compound; squared-distance radius checks, integer slope arithmetic, and integer Bresenham avoid sqrt, float drift, and per-cell trig.

## 8. Correctness & Visual Artifacts (correct)

**Impact:** LOW-MEDIUM  
**Description:** A clean result without flicker or extra passes depends on a consistent visibility model; symmetry, deliberate corner-peeking rules, and a monotonic explored layer prevent the rework that ad-hoc fixes cause.

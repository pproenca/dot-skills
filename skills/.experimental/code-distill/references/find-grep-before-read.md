---
title: Grep narrowly before reading whole files
tags: find, grep, read
---

## Grep narrowly before reading whole files

By default the agent opens the README or a likely-named file and reads it linearly looking for the pattern. This burns the context window — most repos have 50-line README sections, 200-line `index.ts` files, and 500-line implementation files that are 80% boilerplate. The move is to **grep narrowly first** to pinpoint the exact lines that hold the pattern, then read a small window around each hit. Open whole files only after grep has narrowed the candidate set to ≤ 3 files.

```text
The grep-narrow sequence:

  1. Form a SHARP grep target — a token that the pattern's
     implementation will use but that boilerplate will not.

     Good targets (specific, low-noise):
       "createContext"        - state pattern; appears once per store
       "Slot.Root"            - Radix-style composition entry
       "export const cva"     - class-variance-authority idiom
       "Effect.gen"           - effect-ts canonical usage form

     Bad targets (vague, high-noise):
       "state"                - matches half the repo
       "component"            - 4-digit hit count
       "design"               - hits comments more than code

  2. Add structural filters to the grep.

       --type=ts            - skip CSS, markdown, lockfiles
       --glob='!**/test/**' - exclude tests during the FIND phase
                              (tests come back in `find-tests-show-intent`)
       --glob='!**/dist/**' - skip build output
       --glob='!**/node_modules/**'

  3. Read ONLY the file the grep hit, and ONLY a window around the hit.

       output_mode: "content" with -B 5 -A 20 (or -B 10 -A 30)
       NOT: open the whole file

  4. If the window is insufficient, EXPAND it (-B 30 -A 60) rather
     than read the whole file. Most patterns are visible in <80 lines
     of context.

  5. Read the whole file ONLY after grep has narrowed to ≤ 3 files
     AND the windowed reads were inconclusive.

The token-cost guardrail:
  - Whole-file read: 200-1000 lines × N candidates
  - Grep + windowed read: 20-80 lines × N candidates
  Difference is typically 10×. Reading whole files first is the
  single most expensive habit in code-pattern extraction sessions.
```

The mechanical trigger: before any `Read` call on a file > 100 lines, ask "did I grep for the specific token I'm looking for first?" If no, grep first. The grep-narrow pass is a few seconds of work; the whole-file read is a few seconds of work plus 800 lines of context burn.

Reference: [ripgrep — the canonical fast-grep tool whose `-B` / `-A` flags exist precisely for this windowed-read pattern](https://github.com/BurntSushi/ripgrep)

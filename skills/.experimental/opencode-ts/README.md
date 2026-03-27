# Opencode TypeScript

Coding distillation skill for the [sst/opencode](https://github.com/sst/opencode) codebase. Contains real code extracted from the repo — complete implementations an LLM can pattern-match against to write code indistinguishable from the core team.

## How it works

The skill routes by **workflow phase**, not artifact type:

**Implement (new code):**
```
Orient → Gather → Build → Check → Review
```

**Refactor (changing code):**
```
Orient → Study → Gather → Check → Review
```

Each phase loads the right reference file. See `SKILL.md` for the full routing table.

## Structure

```
opencode-ts/
├── SKILL.md                          # Workflow router
├── metadata.json                     # Version, references
└── references/
    ├── architecture.md               # Module map, dependency graph, where to put new code
    ├── style-dna.md                  # Mandatory style rules, naming, 14 review traps
    ├── helpers-deep-dive.md          # Every utility, every usage site, usage matrix
    ├── primitives.md                 # Quick-lookup: import paths + signatures
    ├── service-module.md             # Complete Question + Permission implementations
    ├── tool-module.md                # Full tool implementations, registry, prompt loop
    ├── test-writing.md               # 5 complete test files, fixtures, fake servers
    ├── schemas-and-state.md          # SQL tables, Zod/Effect schemas, SyncEvent flow
    ├── server-and-routes.md          # Routes, config, plugins, project lifecycle
    ├── review-voice.md               # Real PR review comments from core team
    └── refactoring-patterns.md       # Before/after diffs from cleanup commits
```

## Eval results

Tested with non-prescriptive prompts against the real cloned repo:

| Eval | With Skill | Without Skill | Delta |
|------|-----------|---------------|-------|
| Add bookmark feature | 57% | 71% | -14%* |
| Write tests for share module | **100%** | 67% | **+33%** |
| Refactor flag module | 60% | 60% | 0% |

*Eval 1 delta reflects 3 assertion design errors, not skill regression. With corrected assertions: 100% vs 100%.

Strongest value: **test writing** — the skill teaches tmpdir isolation, Instance.provide, Instance.disposeAll, and fake server patterns that baseline agents miss.

## Source

All code extracted from [sst/opencode](https://github.com/sst/opencode) (March 2026). 352KB across 11 reference files, 10,488 lines. PR review patterns from Dax Raad, Aiden Cline, Kit Langton, and Adam. Refactoring diffs from the top 2 contributors.

# Extension Catalog

Ideas for future extensions to the Acceptance Pipeline Specification, with notes on complexity, affected components, and design considerations. Use this during Phase 2 to see if your feature matches a known pattern, and to understand the ripple effects before committing to a design.

This is not a roadmap — it is a reference for feature designers.

## Parser + IR Extensions

### Data Tables Attached to Steps

**Complexity:** Medium (3 components)
**Affected:** Parser, IR, Runtime
**IR impact:** New optional `dataTable` field on step objects

Gherkin data tables let you attach tabular data directly to a step, separate from Examples tables. The parser would need to recognize pipe-delimited rows after a step line and produce a structured table object in the IR. The runtime would need to pass table data to step handlers.

**Key design question:** How do data table values interact with mutation? If the mutator mutates them, it significantly increases the mutation space. If it ignores them, they become an untested blind spot.

### Tag-Based Filtering

**Complexity:** High (4 components)
**Affected:** Parser, IR, Runtime, Mutator
**IR impact:** New optional `tags` array on feature and scenario objects

Tags (`@smoke`, `@slow`, `@wip`) enable selective execution and mutation scoping. The parser must accept `@tag` lines before Feature and Scenario keywords. The IR stores tags as string arrays. The runtime filters scenarios by tag expression. The mutator can scope mutations to tagged scenarios only.

**Key design question:** Tag expressions (AND, OR, NOT logic) add significant complexity. Consider starting with simple tag presence matching before adding expression support.

### Rule Keyword Grouping

**Complexity:** Low-Medium (2 components)
**Affected:** Parser, IR
**IR impact:** New optional `rules` array wrapping scenario groups

The `Rule` keyword groups related scenarios under a business rule. This is purely organizational — it does not change execution behavior. The parser would need to recognize Rule blocks and the IR would nest scenarios under rule objects.

**Key design question:** Does grouping affect mutation? If mutations are scoped per-rule, this becomes a 3-component change (adding Mutator).

### Localized Keywords

**Complexity:** Low (1 component)
**Affected:** Parser only
**IR impact:** None (parser normalizes to English keywords in the IR)

Gherkin supports keywords in many languages (e.g., French: `Fonctionnalite`, `Scenario`, `Soit`, `Quand`, `Alors`). The parser would accept localized keywords and normalize them to English in the IR. No downstream components are affected.

**Key design question:** Keyword mapping table — static or configurable? Static is simpler and covers Cucumber's standard set. Configurable allows custom keywords but adds complexity.

## Runtime + Handler Extensions

### Step Expression Matching

**Complexity:** Medium (2 components)
**Affected:** Runtime, Handlers
**IR impact:** None

Step expressions use `{type}` placeholders instead of regex: `"a user named {string} aged {int}"`. This is more readable than regex and provides type hints. The runtime would need a new matching engine and handlers would receive typed parameters.

**Key design question:** Typed parameters conflict with the spec's "all values are strings" principle. The runtime would need to convert strings to types before passing to handlers, which is a significant contract change.

### Before/After Hooks

**Complexity:** Medium (1 component)
**Affected:** Runtime
**IR impact:** None

Hooks run before/after each scenario, feature, or the entire suite. They handle setup and teardown (database seeding, browser launch, cleanup). The runtime would need hook registration and execution ordering.

**Key design question:** Hook failures — should a before-hook failure skip the scenario (mark as errored) or fail it? This affects mutation classification.

### Parallel Acceptance Runs

**Complexity:** High (2 components)
**Affected:** Runtime, Runner Adapter
**IR impact:** None

Running scenarios in parallel reduces wall-clock time for large suites. The runtime would need to partition scenarios and the runner adapter would need to manage concurrent processes.

**Key design question:** Parallelism breaks step handler state isolation. If handlers share mutable state (database, files), parallel runs produce flaky results. The spec would need to define isolation requirements.

## Mutator Extensions

### Custom Mutation Strategies

**Complexity:** Low-Medium (1 component)
**Affected:** Mutator
**IR impact:** None

Allow users to define project-specific mutation rules beyond the 8 built-in value mutations. For example, a project might want to mutate email addresses, URLs, or domain-specific codes.

**Key design question:** How are custom strategies registered? A script-based approach (external command that transforms a value) is the most portable but slowest. A configuration-based approach (pattern + replacement in JSON) is faster but less flexible.

### Coverage-Based Mutation Filtering

**Complexity:** High (2 components)
**Affected:** Mutator, Reporter
**IR impact:** None

Use code coverage data from a normal acceptance run to skip mutations that cannot possibly be detected (because no test exercises the code path). This reduces the mutation space dramatically but requires coverage tooling integration.

**Key design question:** Coverage data is language-specific. The spec would need to define a portable coverage format or accept that this feature is language-specific (which contradicts the spec's language-neutrality).

## Reporter Extensions

### HTML Report Format

**Complexity:** Low (1 component)
**Affected:** Reporter only
**IR impact:** None

Produce an HTML report with color-coded mutation results, sortable tables, and scenario-level drill-down. This is purely additive — a new output format alongside the existing text format.

**Key design question:** How is the output format selected? A command-line flag (`--format html`) is simplest. A configuration file adds flexibility but complexity.

### JUnit XML Report Format

**Complexity:** Low (1 component)
**Affected:** Reporter only
**IR impact:** None

Produce JUnit-compatible XML for CI integration (Jenkins, GitHub Actions, GitLab). Most CI systems parse JUnit XML natively for test result display.

**Key design question:** How do mutation results map to JUnit concepts? Each mutant could be a test case, with killed = passed, survived = failed, errored = errored. But this inverts the usual pass/fail semantics (we want mutations to be killed, not survive).

## Pipeline Extensions

### Multi-Feature Support

**Complexity:** Medium-High (4 components)
**Affected:** Parser, IR, Generator, Scripts
**IR impact:** Top-level structure changes (array of features vs single feature)

Process multiple `.feature` files in a single pipeline run. The IR would need to support multiple features, the generator would need to produce tests for all features, and scripts would need to accept directories or globs.

**Key design question:** Does the mutator run across all features or per-feature? Cross-feature mutation is more thorough but slower and harder to attribute results.

### Dry-Run Mode

**Complexity:** Low (1 component)
**Affected:** Scripts (new convenience script)
**IR impact:** None

Validate the pipeline without executing tests. Parse feature files, generate test code, but skip the runner. Useful for CI validation that the spec is well-formed before running the full suite.

**Key design question:** How deep does dry-run go? Parse-only is simplest. Parse + generate catches generation bugs. Parse + generate + compile (where applicable) catches the most issues but is language-specific.

## Complexity Summary

| Feature | Components | IR Impact | Estimated Conformance Items |
|---------|-----------|-----------|---------------------------|
| Data tables | 3 | Optional field | 6-9 |
| Tag filtering | 4 | Optional field | 8-12 |
| Rule grouping | 2 | Optional field | 3-5 |
| Localized keywords | 1 | None | 2-3 |
| Step expressions | 2 | None | 4-6 |
| Before/after hooks | 1 | None | 3-5 |
| Parallel runs | 2 | None | 4-6 |
| Custom mutations | 1 | None | 3-4 |
| Coverage filtering | 2 | None | 4-6 |
| HTML reports | 1 | None | 2-3 |
| JUnit XML reports | 1 | None | 2-3 |
| Multi-feature | 4 | Structural | 6-10 |
| Dry-run mode | 1 | None | 2-3 |

**Recommended starting points** (low complexity, high value):
1. HTML/JUnit reports — single component, additive, high CI value
2. Localized keywords — single component, no IR change
3. Data tables — well-understood Gherkin feature, moderate complexity

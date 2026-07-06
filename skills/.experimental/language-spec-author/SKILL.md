---
name: language-spec-author
description: "Turn a rough idea for a language into a complete, implementable specification — a DSL, query, config/data, template, or protocol language — by interviewing the author dimension by dimension until another developer could build a conforming implementation from the document alone. It grills for the decisions authors skip: lexical rules (whitespace, case, comments, literals), grammar with precedence and ambiguity resolution, a semantic/type model, validation rules with counter-examples, execution algorithms and the error model, the output/serialization format, and RFC 2119 conformance. The completeness bar and formal notation (lexical vs syntactic grammar, function-style algorithms) are distilled from the GraphQL specification. Trigger on \"spec out my language\", \"design a DSL / query language\", \"write a language or grammar spec\", \"formalize this syntax\", or when someone has a language idea that needs to become an implementable spec — even if they only say \"spec\" or \"grammar\"."
---
# Author an Implementable Language Specification

Take an author from a rough language idea to a specification precise enough that a
developer with **zero access to the author** can build a conforming implementation from
the document alone. The output is a spec in the mold of the
[GraphQL specification](https://spec.graphql.org/draft/) — grammar, semantics, validation,
execution, and conformance — that other devs can implement and interoperate against.

The hard part of a language spec is not prose; it is eliminating the ambiguities the
author does not know they are leaving. Two implementers reading a vague sentence produce
two incompatible languages. So this skill's method is **grilling**: ask one sharp
question at a time, recommend a default, and refuse to write down any answer that fails
the stranger / edge-case / two-implementers tests. It bundles a scaffold script, a
completeness linter, and reference docs for the anatomy, the formal notation, and the
interview itself.

## When to Apply

- The user wants to **design or formalize a language**: a DSL, query language, config or
  data format, template language, expression language, or wire protocol.
- The user has a **working idea or prototype** and needs a written spec others can
  implement against — "spec out my query language", "formalize this syntax".
- The user asks for a **grammar, a language spec, or an implementable definition** and
  needs the lexical/syntactic/semantic structure worked out, not just examples.
- The user has a spec draft that **implementers keep asking questions about** — the holes
  need to be found and closed.

Do **not** use this for: authoring a Python language proposal (use `python-pep-author`),
an internal company RFC or design doc (use `dev-rfc` / `feature-spec`), or documenting an
API surface that already has a fixed definition.

## Prerequisites

- **Bash + coreutils** (`awk`, `sed`, `grep`, `date`) for the two scripts — present by
  default on macOS/Linux. No language runtime is required to draft or lint.
- The author available to answer questions. This skill is an interview; it cannot invent
  the language's decisions, only extract, pressure-test, and record them.

## Workflow Overview

The interview walks the pipeline every implementable spec must describe — source text →
tokens → tree → validated tree → result — grilling at each stage. Phase 0 decides which
parts apply; not every language needs all of them.

```
0. Frame ──► 1. Purpose &   ──► 2. Lexical   ──► 3. Syntactic
   the         principles        grammar          grammar
   language    (tie-breakers)    (chars→tokens)   (tokens→AST)
                                                       │
                                                       ▼
8. Conformance ◄─ 7. Output & ◄─ 6. Execution ◄─ 5. Validation ◄─ 4. Semantic model
   (MUST/SHOULD/    error format   (algorithms +    (static rules +   / type system
    MAY, normative) (result+errors) error model)    counter-examples) (optional)
        │
        ▼
   Scaffold (new-spec.sh) filled section by section ──► Lint (check-spec.sh) ──► Cold-read test
```

Scaffold once, early, so answers land in a structured document as they are settled:

```bash
scripts/new-spec.sh --title "AcmeQL" --goal-symbol "Document" --editors "R. User <r@x.io>"
```

### 0. Frame the language

Before any grammar, establish what kind of language this is — query, config, imperative,
declarative, protocol, template — because that decides which anatomy parts apply. A pure
config format may have no execution section; a query language needs all eight. Ask the
Phase-0 questions in [references/interview-playbook.md](references/interview-playbook.md)
and read [references/spec-anatomy.md](references/spec-anatomy.md) to see the eight parts
and mark which are in scope. Absent parts must be a **stated choice**, never a silent gap.

### 1. Purpose & design principles

Pin the purpose, the non-goals, and 3–5 design principles. Principles are the tie-breakers
that resolve every ambiguity the spec did not foresee, so grill each one: "what future
decision does this principle pre-resolve?"

### 2–3. Lexical then syntactic grammar

Define tokens (`::`, characters → tokens) before structure (`:`, tokens → AST). Read
[references/formal-notation.md](references/formal-notation.md) first — the two-colon
discipline and the shorthands (`?`, `+`, `but not`, lookahead) are what keep the grammar
unambiguous. This is where authors under-specify most: whitespace significance, case
sensitivity, comment syntax, exact literal patterns, and — the classic hole — **operator
precedence and associativity**. Actively hunt ambiguity; an ambiguous grammar is not
implementable.

### 4. Semantic model / type system (if applicable)

If the language talks about typed entities, schemas, or resources, define that model
separately from the grammar, with its constraints and (optionally) introspection.

### 5. Validation (static semantics)

Enumerate every way a document can parse yet still be invalid. Write each as a **named
rule** with a formal specification, explanatory text, and a **counter-example** (the
smallest invalid document). The counter-example doubles as a test case and proves the
rule is decidable.

### 6. Execution (dynamic semantics)

Specify evaluation as **named, function-style algorithms** (formal-notation.md), not
prose. Force the three decisions authors skip: **evaluation order** (only where
observable), **coercion** rules, and above all the **error model** — does an error abort,
propagate to a boundary, or yield a partial result? Every algorithm path must return or
raise a defined error.

### 7. Output & error format

The observable result shape, the error object shape (message, location, path,
extensions), and at least one concrete serialization. Under-specifying the error format
is a top interop failure — clients written against one implementation break on another.

### 8. Conformance

Adopt RFC 2119 keywords, declare the normative/non-normative split, and include the
observably-equivalent clause so implementations can optimize. The template's conformance
section is pre-filled to the GraphQL convention.

### Finish: lint, then cold-read

Run the linter to catch structural holes, fix every FAIL, then apply the real test:

```bash
scripts/check-spec.sh acmeql-spec.md
```

`check-spec.sh` finds mechanical gaps (missing sections, unresolved `TODO`s, missing
grammar notation, absent conformance keywords). It **cannot** judge whether the semantics
are correct — that is the **cold-read test**: hand the draft to a developer with no
context. Every question they must ask you is a defect; fold the answer back in.

## Reference Files

| File | Read it when |
|------|--------------|
| [references/spec-anatomy.md](references/spec-anatomy.md) | Framing scope (Phase 0) and checking completeness — the eight parts of an implementable spec, what each answers, and the done-bar for each |
| [references/formal-notation.md](references/formal-notation.md) | Writing the grammar (Phases 2–3) and semantics (Phases 5–6) — lexical vs syntactic notation, algorithm notation, data collections, RFC 2119 keywords |
| [references/interview-playbook.md](references/interview-playbook.md) | Running the interview — the grilling stance, the three rejection tests, underspecification detectors, and the per-phase question bank |

## Scripts

| Script | What it does |
|--------|--------------|
| `scripts/new-spec.sh` | Scaffolds a spec draft from the template, filling title/date/version/goal-symbol. Run with `-h` for usage. |
| `scripts/check-spec.sh` | Lints a draft for structural holes (missing sections, unresolved placeholders, grammar notation, conformance keywords, counter-examples) → PASS/WARN/FAIL, non-zero exit on any FAIL. |

The template the scaffold fills lives at
[assets/templates/spec-template.md](assets/templates/spec-template.md) — copy it directly
if you would rather fill the sections by hand.

## Gotchas

See [gotchas.md](gotchas.md). The recurring ones: authors describe the happy path and
skip the **error model**; lexical (`::`) and syntactic (`:`) grammar get conflated;
evaluation order is specified everywhere or nowhere (specify it only where observable);
and a spec that *reads* complete still fails the cold-read test.

## Related Skills

- `radical-simplification` — its `clarify-interview-one-at-a-time` move is the interview
  discipline this skill applies to language design.
- `python-pep-author` — proposing a feature to upstream Python (a governance process, not
  a from-scratch language spec).
- `dev-rfc` / `feature-spec` — internal RFCs, design docs, and feature specs (not formal
  language definitions).

# {{TITLE}} Specification

- **Status**: {{STATUS}}
- **Version**: {{VERSION}}
- **Created**: {{CREATED}}
- **Editors**: {{EDITORS}}

<!--
  This skeleton mirrors the anatomy of an implementable language spec (see the
  language-spec-author skill, references/spec-anatomy.md). Fill each section to the
  "a stranger could implement it" bar. DELETE sections that genuinely do not apply to
  this language, but replace them with one line saying so — an absent part must be a
  stated choice, not a silent omission. Every `TODO` marker below is a hole; run
  scripts/check-spec.sh to find the ones you missed.

  Notation: `::` = lexical grammar (chars→tokens), `:` = syntactic grammar (tokens→AST),
  Algorithm(args): with ordered steps = semantics. Legend is in the appendix.
-->

## 1. Overview

<!-- Purpose, shape (query/config/imperative/…), non-goals, and the design principles
     that act as tie-breakers for every unforeseen ambiguity. -->

TODO: What is this language for, in one paragraph?

**Non-goals**: TODO

**Design principles**:

- TODO — principle, and what future decision it pre-resolves.

## 2. Lexical Grammar

<!-- Source characters → tokens. Nothing ignored appears between the terminals of one
     token. Use `::`. -->

**Source text & encoding**: TODO (e.g. any sequence of Unicode scalar values).

**Ignored tokens**: TODO (whitespace? line terminators? comments? are they significant?)

**Tokens**:

```
Name :: TODO
IntValue :: TODO
FloatValue :: TODO
StringValue :: TODO
Punctuator :: TODO
```

TODO: case sensitivity of names/keywords; reserved words.

## 3. Syntactic Grammar

<!-- Tokens → AST, starting from the goal symbol. Use `:`. Ignored tokens may appear
     between terminals. Pin down precedence/associativity and resolve every ambiguity. -->

Goal symbol: {{GOAL_SYMBOL}}.

```
Document : TODO
```

**Operator precedence and associativity** (if the language has expressions): TODO —
give the full table; a grammar ambiguous about `a - b - c` is not implementable.

## 4. Semantic Model

<!-- The entities/types the language talks about, if any. Delete if the language has no
     type system / schema, replacing with: "This language defines no separate semantic
     model; parsing produces the final structure." -->

TODO: the entities/types, their fields, relationships, and constraints. Introspection?

## 5. Validation

<!-- Well-formed-but-invalid rules. One named rule per subsection, each with: a formal
     specification, explanatory text, and a counter-example. Group by construct. -->

### TODO Rule Name

**Formal Specification**:

- TODO: the exact predicate/algorithm an implementation checks.

**Explanatory Text**: TODO — why the rule exists.

```counter-example
TODO: the smallest document that violates this rule.
```

## 6. Execution

<!-- Dynamic semantics as named, function-style algorithms. Every path returns or raises
     a defined error. Specify evaluation order only where observable. Delete if the
     language does not execute (parsing is the whole semantics), replacing with a note. -->

Evaluate{{GOAL_SYMBOL}}(input):

- TODO: ordered steps. Reference sub-algorithms by name; define each below.
- Return TODO.

**Error model**: TODO — does an error abort, propagate to a boundary, or yield a partial
result? Be specific per error kind.

**Evaluation order**: TODO — where observable (state which), and where explicitly free.

## 7. Response

<!-- The observable output, including on failure, plus at least one serialization. -->

**Result shape**: TODO (e.g. a map with `data`, `errors`).

**Error object shape**: TODO (message, location, path, extensions?).

**Serialization**: TODO (e.g. JSON, with any map-ordering guarantees).

## 8. Conformance

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT,
RECOMMENDED, MAY, and OPTIONAL in this document are to be interpreted as described in
[RFC 2119](https://tools.ietf.org/html/rfc2119), even when written in lowercase.

All content is normative except examples and notes, which are non-normative.

A conforming implementation MAY provide additional functionality not described here,
except where explicitly forbidden or where it would cause non-conformance. Algorithms in
this document describe required *observable* behavior; an implementation MAY use any
strategy that produces an observably equivalent result.

TODO: any language-specific extension points or explicit prohibitions.

## Appendix: Notation Conventions

Grammar: a `::` production is **lexical** (source characters → tokens, no ignored
characters between terminals); a `:` production is **syntactic** (tokens → AST, ignored
tokens permitted between terminals). `Symbol?` = optional, `Symbol+` = one or more,
`A but not B` = `A` excluding `B`, `[lookahead != X]` = not followed by `X`. Terminals
are in `monospace`.

Algorithms: `Name(args):` followed by ordered steps (`Let`, `If … :`, `Return`).
Data collections: List (ordered, dups), Set / ordered set, Map / ordered map — ordered
variants used only where order is observable.

## Appendix: Grammar Summary

<!-- Optional but recommended: all lexical and syntactic productions collected in one
     place for implementers. -->

TODO

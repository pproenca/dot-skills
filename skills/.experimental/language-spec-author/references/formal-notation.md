# Formal Notation for Language Specs

Read this when writing the grammar (Phases 2–3) and the semantics (Phases 5–6). It is
the notation that lets a spec state grammar and algorithms **precisely enough that two
implementers produce the same behavior**. It is the GraphQL notation
([Appendix B](https://spec.graphql.org/draft/#sec-Appendix-Notation-Conventions)),
which is a lightly-sugared context-free-grammar + pseudocode convention — battle-tested
and readable. You may adopt another established notation (ISO EBNF, ABNF/RFC 5234, W3C
railroad) instead, but pick **one**, define it in the spec's notation appendix, and use
it consistently. Do not invent ad-hoc notation per section.

## Two grammars, two colons

The defining discipline: **the lexical grammar and the syntactic grammar are separate**,
and the colon count marks which is which.

| | Lexical grammar | Syntactic grammar |
|---|---|---|
| Notation | double colon `::` | single colon `:` |
| Input | source characters | tokens |
| Output | tokens | AST / document |
| Ignored chars between terminals | **not allowed** | allowed (whitespace, comments) |
| Example | `Word :: Letter+` | `Sentence : Word+ \`.\`` |

Why it matters: a lexical production defines the *shape of a token* character by
character with nothing between them; a syntactic production defines *structure* and
tolerates ignored tokens between its parts. Collapsing the two is the most common
notation error (see gotchas). Terminals are written in `monospace` — either literal
characters (`` `=` ``, `` `query` ``) or a named code point ("Space (U+0020)").
Non-terminals are written {InBraces} when referenced in prose.

## Production forms

A non-terminal with a single definition, inline:

```
NonTerminalWithSingleDefinition : NonTerminal `terminal`
```

A non-terminal with alternatives, as a list:

```
NonTerminalWithManyDefinitions :
  - OtherNonTerminal `terminal`
  - `terminal`
```

Recursion expresses repetition:

```
ListOfLetterA :
  - ListOfLetterA `a`
  - `a`
```

## Grammar shorthands

These sugar common patterns; each expands to plain context-free productions.

- **Optional** `Symbol?` — one form with the symbol, one without.
  `Sentence : Noun Verb Adverb?` ≡ `Noun Verb Adverb` | `Noun Verb`.
- **List** `Symbol+` — one or more, via a recursive helper production. (`*` for zero or
  more if your notation defines it; GraphQL uses only `?` and `+`.)
- **Constraints** `A but not B` — anything matching `A` except sequences that match `B`.
  Multiple exclusions: `Name but not \`true\` or \`false\``. Use to carve keywords out
  of identifiers.
- **Lookahead** `Symbol [lookahead != X]` — the production may not be followed by `X`.
  Removes ambiguity and forces greedy matching, e.g. `Word :: Letter+ [lookahead != Letter]`.
- **Parameterized productions** `Symbol[Param]` — one definition generates variants
  gated on a parameter; conditional alternatives are prefixed `[+Param]` / `[~Param]`,
  and `[?Param]` threads the parameter into a sub-symbol. Use sparingly, only when it
  genuinely collapses duplication (GraphQL uses it for `const` vs variable values).

**When writing the grammar, actively hunt ambiguity**: left recursion that a parser
cannot resolve, missing operator precedence/associativity, and productions that match
the same input two ways. An ambiguous grammar is not implementable — resolve it with
precedence tables, `but not`, or lookahead before the spec ships.

## Grammar semantics (a production's value)

A production can carry a semantic value, given as algorithmic steps directly under the
lexical/syntactic rule. This is how you say "and here is what this token *means*":

```
StringValue :: `"` StringCharacter+ `"`
  - Return the Unicode character sequence of all {StringCharacter} values.
```

## Algorithm notation (static & dynamic semantics)

Validation rules and execution are written as **named, function-like algorithms** with
ordered steps — not prose. This is what makes semantics testable and unambiguous.

```
Fibonacci(number):
  - If {number} is {0}:
    - Return {1}.
  - If {number} is {1}:
    - Return {2}.
  - Let {previousNumber} be {number} - {1}.
  - Let {previousPreviousNumber} be {number} - {2}.
  - Return {Fibonacci(previousNumber)} + {Fibonacci(previousPreviousNumber)}.
```

Conventions that keep algorithms unambiguous:

- **Name + typed-ish arguments**: `AlgorithmName(arg1, arg2):`.
- **Ordered steps** executed top to bottom; nested steps under a condition are indented.
- **`Let x be …`** introduces a value; **`If … :`** branches; **`Return …`** yields the
  result. Every path must `Return` (or explicitly raise a defined error) — an algorithm
  with an input that falls off the end is a spec hole.
- **Reference other algorithms** by call: "Let `r` be the result of `CompleteValue(…)`".
  Every called algorithm must be defined somewhere in the spec.
- **Error behavior is explicit**: state when an algorithm raises a *request error* vs a
  *field/execution error* vs propagates. Do not leave failure implicit.

## Abstract data collections

When algorithms need containers, use abstract types with defined ordering/uniqueness
semantics rather than a concrete data structure, so implementers stay free to optimize:

- **List** — ordered, duplicates allowed; new values appended after existing ones.
- **Set** — no duplicates. **Ordered set** — a set with defined insertion order.
- **Map** — key→value, unique keys, direct key access. **Ordered map** — insertion-ordered.

Specify *ordered* variants **only when the order is observable**. If order does not
affect the observable result, use the unordered type and let implementations choose.

## Conformance keywords (RFC 2119)

State normativity precisely with **MUST / MUST NOT / REQUIRED / SHALL / SHOULD /
SHOULD NOT / RECOMMENDED / MAY / OPTIONAL**, interpreted per
[RFC 2119](https://tools.ietf.org/html/rfc2119). Declare in the conformance section how
these keywords are interpreted — there are two conventions, pick one and state it:

- **GraphQL's**: the keywords are normative even when written in lowercase.
- **The modern [RFC 8174](https://tools.ietf.org/html/rfc8174) refinement**: only the
  **uppercase** keywords are normative, so casual prose ("the parser must be fast") does
  not accidentally bind an implementation. Most specs written since 2017 cite both 2119
  and 8174 and restrict normativity to uppercase.

Then:

- **Everything is normative except** clearly marked examples and notes.
- **Examples** (`example` / `counter-example` blocks, or "for example …") illustrate; they
  never impose requirements.
- **Notes** ("Note: …") clarify intent and edge cases; also non-normative.
- **The observably-equivalent clause**: implementations MAY use any strategy provided the
  observable result matches the spec's algorithms. Include this so the literal algorithm
  text does not forbid optimization.

Keeping requirements (normative, keyworded) visually and structurally distinct from
illustration (examples, notes) is what lets a reader tell, for any sentence, whether it
binds an implementation.

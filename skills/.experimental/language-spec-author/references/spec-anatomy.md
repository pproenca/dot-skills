# The Anatomy of an Implementable Language Spec

This is the completeness checklist the interview drives toward. It is distilled from
the [GraphQL specification](https://spec.graphql.org/draft/) — a spec that dozens of
independent teams have implemented interoperably from the document alone — and
generalized to any formal language: a DSL, a query language, a config/data format, a
template language, or a wire protocol.

**The test for every part below:** could a developer with zero access to you build a
conforming implementation from this section? If they would have to guess or ask, the
part is incomplete.

## The pipeline the spec must describe

Every implementable language spec describes a pipeline from source text to observable
result. Each stage is a place two implementations can diverge, so each stage needs its
own normative section:

```
source text ──lexical──► tokens ──syntactic──► AST ──validation──► valid AST ──execution──► result
             grammar              grammar             (static rules)          (dynamic semantics)   + errors
```

GraphQL maps this to Sections 1–7 + Appendices A/B. The generalized parts:

| # | Part | Answers | GraphQL analog | Applies to |
|---|------|---------|----------------|------------|
| 1 | Purpose & Design Principles | What is this for? What is it *not*? | §1 Overview | all |
| 2 | Lexical Grammar | How do source characters become tokens? | §2.1 Source Text, Tokens | all |
| 3 | Syntactic Grammar | How do tokens become a tree/document? | §2.2+ Document | all |
| 4 | Semantic Model | What entities exist and how do they relate? | §3 Type System | schema/query/typed langs |
| 5 | Static Semantics (Validation) | What is well-formed but still invalid? | §5 Validation | most |
| 6 | Dynamic Semantics (Execution) | How is a valid input evaluated? | §6 Execution | executable langs |
| 7 | Output & Error Format | What comes back, including on failure? | §7 Response | executable langs |
| 8 | Conformance | What must an implementation guarantee? | Appendix A | all |

Not every language needs every part. A pure config format may have no execution
(parsing *is* the semantics) and no type-system introspection; a query language needs
all eight. The interview decides which parts apply in Phase 0 and does not pad the
document with empty sections — an absent part is a deliberate, stated choice, not an
omission.

---

## 1. Purpose & Design Principles

State what the language is for, its shape (query? config? imperative? declarative?),
and — critically — its **non-goals** and **design principles**. Principles are not
marketing: they are tie-breakers that resolve every future ambiguity the spec did not
foresee. GraphQL's "the response shape mirrors the request shape" and "the client
specifies exactly what it receives" decide dozens of downstream design questions.

Done when: a reader can predict, from the principles alone, how an unlisted edge case
*should* be resolved.

## 2. Lexical Grammar (characters → tokens)

Define the token stream. This is where the pedantic-but-essential decisions live:

- **Character set / encoding** (Unicode? ASCII? which normalization?)
- **Ignored tokens**: whitespace, line terminators, comments, separators. Is whitespace
  significant (like Python/YAML) or ignored (like C/JSON)?
- **Token kinds**: identifiers/names, punctuators, and literals (int, float, string,
  boolean, null). For each literal give the *exact* pattern and any escape rules.
- **Case sensitivity** of names and keywords.
- **Reserved words** vs contextual keywords.

Use lexical grammar notation (`::`) — see [formal-notation.md](formal-notation.md).
The rule: no ignored characters may appear between the terminals of a single token.

Done when: a lexer can be written that turns any byte sequence into a token stream or a
lexical error, with no remaining "well, it depends" cases.

## 3. Syntactic Grammar (tokens → AST)

Define the tree. Give the productions that assemble tokens into the language's
constructs, starting from a single **goal/start symbol** (e.g. `Document`, `Program`,
`Config`). Cover:

- The top-level structure and every nested construct.
- **Operator precedence and associativity** if the language has expressions — the
  single most under-specified area in hand-written specs. A bare grammar that is
  ambiguous about `a - b - c` or `a && b || c` is not implementable.
- Optional and repeated elements (`?`, `+`, `*` — see formal-notation).
- Disambiguation: "but not" constraints and lookahead restrictions where a naive
  grammar would be ambiguous.

Use syntactic grammar notation (`:`). Done when: two people writing parsers from this
section independently produce the same AST for the same input, including for tricky
precedence and edge cases.

## 4. Semantic Model / Type System

If the language talks *about* things (types, schemas, entities, resources, capabilities),
define that model separately from the grammar. GraphQL's Type System (§3) defines
objects, interfaces, unions, enums, input objects, scalars, and directives — the
vocabulary a valid document is checked against. For a config language this might be the
schema of allowed keys and value types; for a protocol, the message types and their
fields.

Include, where relevant, an **introspection/reflection** sub-part: can a program query
the model itself? GraphQL makes the schema queryable via `__schema`/`__type`, which is
what powers its tooling ecosystem. This is optional but high-leverage for query/schema
languages.

Done when: the set of legal "shapes" a document can take is fully enumerable from this
section, and every constraint a validator will enforce has a home here.

## 5. Static Semantics (Validation)

Rules a document must satisfy that the grammar *cannot* express — the difference between
"parses" and "is meaningful". GraphQL groups ~25 rules by construct (Operations, Fields,
Arguments, Fragments, Values, Directives, Variables), and each rule follows a fixed shape:

1. **A named rule** ("Argument Uniqueness", "Leaf Field Selections").
2. **A formal specification** — a predicate or short algorithm stating precisely what
   must hold.
3. **Explanatory text** — the *why*, in prose.
4. **Example and counter-example** — a valid case and an invalid one.

Writing each rule to this shape is what makes validation implementable and testable:
the formal spec tells the implementer what to check, the counter-example is a ready-made
test case. Common rule families to interrogate: name resolution (every referenced name
is defined), uniqueness (no duplicate keys/args/variables), type correctness (values
match expected types), reachability (no unused or undefined fragments/variables), and
cardinality (required things present, `oneOf` things exclusive).

Done when: the boundary between valid and invalid is a decidable check, and every rule
carries a counter-example.

## 6. Dynamic Semantics (Execution)

How a valid document is evaluated to produce a result. Specify this as **function-style
algorithms** (see formal-notation.md), not loose prose. GraphQL nests them:
`ExecuteRequest → ExecuteQuery/Mutation/Subscription → ExecuteSelectionSet →
ExecuteField → CoerceArgumentValues → ResolveFieldValue → CompleteValue`, plus explicit
error handling at each level. The decisions that *must* be pinned down:

- **Evaluation order** — but only where it is observable (side effects, error
  precedence, output order). Say explicitly where order is unobservable and therefore
  free. Over-specifying order forbids valid optimizations; under-specifying makes
  programs non-portable.
- **Coercion / conversion** rules between values and expected types.
- **Error semantics**: does an error abort, propagate, or produce a partial result?
  GraphQL's null-propagation-on-error is a defining, non-obvious decision — the kind
  every executable language must make explicitly.
- **Concurrency**: what may run in parallel vs must run serially (GraphQL: query fields
  may be parallel, top-level mutation fields must be serial).

Done when: the algorithms are deterministic (or their non-determinism is explicitly
bounded), every referenced sub-algorithm is defined, and every algorithm has a defined
return for every input including error cases.

## 7. Output & Error Format

The observable result. Define the result structure (GraphQL: a map of `data`, `errors`,
`extensions`), the **error object shape** (message, source location, path, custom
extensions), and at least one concrete **serialization** (GraphQL specifies JSON and
its map-ordering rules). Under-specifying the error format is a classic interop failure:
clients written against one implementation break on another.

Done when: a client author knows the exact shape of every response, success or failure,
and how it is serialized on the wire.

## 8. Conformance

Define what "a conforming implementation" means so the spec is a contract, not a
suggestion. This part is small but load-bearing:

- **Normative keywords**: adopt RFC 2119 — MUST / MUST NOT / SHOULD / SHOULD NOT / MAY
  — and say you are doing so. These make each requirement's strength unambiguous.
- **Normative vs non-normative**: declare that everything is normative *except* clearly
  marked examples and notes. This lets you write clarifying prose without accidentally
  imposing requirements.
- **The "observably equivalent" escape hatch**: state that implementations may use any
  strategy as long as the observable result matches the spec's algorithms. Without it,
  the literal algorithm text forbids every optimization.

Done when: for any behavior, a reader can classify it as required, recommended, optional,
or forbidden — and knows which text is binding.

---

## How the parts reference each other

The parts are not independent — validation references the semantic model, execution
references validation ("a request must first be validated"), the output format
references execution's error semantics. A complete spec is a closed graph: every term,
token, type, and algorithm a section uses is defined by some other section. A dangling
reference (an algorithm that calls an undefined algorithm, a rule that checks an
undefined type) is the structural signature of an incomplete spec — `check-spec.sh`
flags the common cases.

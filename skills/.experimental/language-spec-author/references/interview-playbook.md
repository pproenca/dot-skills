# The Grilling Playbook

This is the method: how to interrogate an author until their idea becomes a spec another
developer can implement. The value of this skill is not the template — it is the
**pressure applied to vague answers**. A passive template collects whatever the author
already thought of; grilling surfaces the decisions they did not know they were skipping.

## The interview stance

- **One question at a time.** Ask a single, concrete question, wait for the answer, then
  ask the next. Batching ten questions gets ten shallow answers; one sharp question gets
  one real decision. (Same discipline as `radical-simplification`'s
  `clarify-interview-one-at-a-time`.)
- **Recommend a default.** Never ask an open question bare. Offer the answer most
  languages choose and *why*, so the author can accept in one word or push back
  deliberately: "Names — case-sensitive, like almost every language since C? (recommended,
  case-insensitivity surprises users and complicates tooling) or case-insensitive like SQL?"
- **Prefer the source over the author.** If the answer is already implied by an earlier
  decision or a stated design principle, derive it and confirm, rather than re-asking.
  The principles from Phase 1 are your tie-breaker.
- **Grill, don't transcribe.** When an answer is vague, incomplete, or hand-wavy, do not
  write it down — push. The rejection tests below are your instruments.

## The three rejection tests

Apply these to every answer before accepting it into the spec:

1. **The stranger test.** "Could a developer who has never spoken to you implement this
   from what you just said?" If the answer needs a follow-up clarification, it is not
   done — the clarification is the real spec.
2. **The edge-case test.** For every rule, ask for the boundary: empty input, duplicate,
   missing, maximum, malformed, conflicting. "You said arguments are named — what happens
   when the same name appears twice? When a required one is absent? When an unknown one is
   passed?" Happy-path answers are half-answers.
3. **The two-implementers test.** "If two teams implemented this sentence independently,
   would they produce identical observable behavior?" If they could diverge, the sentence
   is under-specified — pin it down or explicitly declare it implementation-defined.

When an answer fails a test, name the gap and re-ask with a sharper, narrower question.
Escalate concreteness until the answer survives all three.

## Underspecification detectors — the words that hide decisions

These words in an author's answer almost always mark an unmade decision. Treat each as a
trigger to grill:

| The author says… | The hidden question to force |
|---|---|
| "it just parses the…" | What are the exact token/grammar rules? Show me the production. |
| "the usual way" / "like normal" | Like *which* language, exactly? Name it, then confirm each difference. |
| "handles errors gracefully" | Which errors? Abort, propagate, or partial result? What is returned? |
| "you can nest them" | To what depth? Any restrictions? What does a cycle do? |
| "whitespace doesn't matter" | Truly nowhere significant? Inside strings? As a token separator? |
| "it evaluates the expression" | In what order? Left-to-right? Are side effects observable? |
| "types should match" | Match how — exactly, or with coercion? Which coercions, in which direction? |
| "it's optional" | What is the behavior when omitted — a default value, or absent? What default? |
| "case doesn't matter" | For identifiers, keywords, string values, all three? |
| "returns the result" | In what shape? Serialized how? What does failure look like in that shape? |

## Per-phase question bank

Use these as the spine of each phase. They are prompts to grill *from*, not a script to
read — follow the author's answers into the edge cases they expose.

### Phase 0 — Frame the language
- What kind of language is this: query, config/data, imperative, declarative, protocol,
  template? (This decides which anatomy parts apply.)
- Does a program in it *execute* to produce a result, or is parsing the whole point?
- Does it describe a type system / schema that documents are checked against?
- Who writes it, who reads it, and what existing language is it closest to?

### Phase 1 — Purpose & principles
- In one sentence, what is this language for?
- What is it deliberately *not* for? Name three non-goals.
- Give 3–5 design principles. For each: what future decision does it pre-resolve?

### Phase 2 — Lexical grammar
- Character set and encoding? Unicode (recommended) — with what normalization?
- Is whitespace significant or ignored? Line terminators?
- Comment syntax? Do comments nest?
- Identifier/name rules: allowed characters, first-character rule, case sensitivity.
- Every literal kind: integer, float, string (escapes! quoting?), boolean, null — exact pattern.
- Reserved words vs contextual keywords.

### Phase 3 — Syntactic grammar
- What is the top-level / goal symbol?
- Walk every construct; for each, the exact production.
- Expressions: full precedence and associativity table. `a - b - c`? `-a * b`? `a || b && c`?
- Where is the grammar ambiguous, and how is each ambiguity resolved (precedence, `but not`, lookahead)?
- What are the syntactic limits (nesting depth, list length) if any?

### Phase 4 — Semantic model / type system (if applicable)
- What entities/types exist? Their fields, relationships, constraints?
- How are they declared? Can one reference another? Cycles allowed?
- Is the model introspectable from within the language?

### Phase 5 — Validation (static semantics)
- List every way a document can parse yet still be invalid.
- Group rules by construct. For each rule: its name, the exact predicate, and a
  counter-example (the smallest invalid document that violates it).
- Name resolution: is every referenced name required to be defined? Uniqueness rules?
  Required-vs-optional? Unused-declaration rules? Type-correctness of values?

### Phase 6 — Execution (dynamic semantics)
- Write the top-level evaluation algorithm, then each sub-algorithm it calls.
- Evaluation order: where is it observable, and where is it explicitly free?
- Coercion rules between values and expected types.
- The error model: does an error abort the whole thing, propagate up some boundary, or
  yield a partial result plus an error entry? Be specific per error kind.
- Concurrency: what may run in parallel, what must be serial, and why?

### Phase 7 — Output & error format
- Exact shape of a successful result.
- Exact shape of an error object: message, location, path, extensions?
- Can a result be partially-successful (data + errors together)?
- At least one concrete serialization (e.g. JSON) with any ordering guarantees.

### Phase 8 — Conformance
- Confirm RFC 2119 keywords and the normative/non-normative split.
- What extensions may an implementation add? What is explicitly forbidden?
- Confirm the observably-equivalent clause so implementations can optimize.

## Knowing when to stop

Stop grilling a phase when its answers survive the three rejection tests and
`check-spec.sh` reports no structural holes for that section. Stop the whole interview
when the done-bar in SKILL.md is met: a cold reader could implement the language. Do not
keep asking questions the design principles already answer — derive, confirm, move on.

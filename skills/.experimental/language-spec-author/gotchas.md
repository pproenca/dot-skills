# Gotchas

Failure points discovered while using this skill. Append entries with a date as they surface.

### Authors describe the happy path and skip the error model
The single most common source of an unimplementable spec: the interview yields a
clean grammar and a clean execution algorithm, but never answers "what happens on
malformed input, a missing name, a type mismatch, division by zero?" Two
implementers will then invent different error behavior and the language forks.
Fix: in every phase, force the failure question before moving on — "for this
construct, what is invalid, and what does the implementation produce when it is?"
Added: 2026-07-06

### Lexical vs syntactic notation gets mixed up
Authors (and the model) conflate the token grammar with the rule grammar, writing a
single grammar that tries to define whitespace handling and structure at once. The
GraphQL convention exists to prevent exactly this: `::` = lexical (source characters
→ tokens, no ignored characters between terminals), `:` = syntactic (tokens → AST,
whitespace/comments allowed between terminals). Keep the two grammars separate;
`check-spec.sh` warns if only one colon style appears.
Added: 2026-07-06

### "Evaluation order" is specified everywhere or nowhere
Under-specifying makes programs non-portable; over-specifying forbids valid optimizations.
The GraphQL rule of thumb: specify order **only when it is observable** (side effects,
error precedence, output serialization). Where order is not observable, say so
explicitly ("the order of X is non-normative") so implementers know they are free.
Added: 2026-07-06

### The spec reads as complete but nobody tried to implement from it
The done-bar is behavioral, not structural: hand the draft to a developer with zero
prior context and no access to you. If they must ask you a question to write the
parser, the type checker, or the evaluator, that answer belonged in the spec. Treat
every such question as a defect and fold the answer back in. `check-spec.sh` catches
structural holes; only a cold read catches semantic ones.
Added: 2026-07-06

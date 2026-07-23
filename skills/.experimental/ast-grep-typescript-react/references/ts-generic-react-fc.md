---
title: Target the type annotation to strip React.FC
tags: ts, generics, react-fc, type-annotation
---

## Target the type annotation to strip React.FC

Removing `React.FC` typings (a common modernization, since `React.FC` implies `children` and complicates generics) means editing the **type annotation** on the declaration, not the component value. `const Card: React.FC<CardProps> = (props) => …` parses as a `variable_declarator` whose `type` field is a `type_annotation` wrapping a `generic_type`; the `React.FC` name itself is a `nested_type_identifier` (`module: React`, `name: FC`). A rewrite must drop the annotation and keep the value — matching the whole declaration and re-emitting it without the `: React.FC<…>` part.

```yaml
# const Card: React.FC<CardProps> = (props) => {...}
#   →  const Card = (props: CardProps) => {...}
language: tsx
rule:
  pattern: "const $NAME: React.FC<$PROPS> = ($ARGS) => $BODY"
fix: "const $NAME = ($ARGS: $PROPS) => $BODY"
```

Note the quotes around `pattern` and `fix`: a TS type annotation puts a `:` inside the pattern, and an **unquoted** YAML scalar containing `: ` is read as a nested mapping — ast-grep then reports *"mapping values are not allowed in this context."* Any TS pattern with a type annotation, object type, or ternary must be quoted. For components typed as bare `React.FC` with no props generic, write a second pattern without `<$PROPS>` (an `any` combining both), since the optional generic is a structurally different node, not an optional token.

Reference: [ast-grep rewrite guide](https://ast-grep.github.io/guide/rewrite-code.html)

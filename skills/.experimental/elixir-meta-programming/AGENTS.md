# Elixir metaprogramming (macros & DSLs)

**Version 0.1.0**  
dot-skills  
July 2026

---

## Abstract

How to build Elixir macros and declarative DSLs correctly once one is warranted: corrects the wrong defaults a model makes with quote/unquote hygiene and evaluation, the accumulate-attribute + @before_compile DSL pattern, and compile-time validation. Complements the anti-macro gate in staff-level-elixir and adversarial-elixir.

---

## Table of Contents

1. [Macro Design](references/_sections.md#1-macro-design)
   - 1.1 [Keep the macro thin; expand to a call into a runtime function](references/macro-thin-delegate-runtime.md)
   - 1.2 [Use defguard for constructs that must work inside a guard](references/macro-defguard-for-guards.md)
2. [Quote & Hygiene](references/_sections.md#2-quote-&-hygiene)
   - 2.1 [Escape a computed term with Macro.escape before splicing it into quote](references/quote-escape-runtime-data.md)
   - 2.2 [Rely on macro hygiene; break it with var! only deliberately](references/quote-rely-on-hygiene.md)
   - 2.3 [Use bind_quoted so an unquoted expression evaluates once](references/quote-bind-quoted-single-eval.md)
3. [DSL Construction](references/_sections.md#3-dsl-construction)
   - 3.1 [Collect declarations in an accumulating attribute, drain it in @before_compile](references/dsl-accumulate-attributes.md)
   - 3.2 [Generate an introspection function so callers read data, not re-run macros](references/dsl-introspection-function.md)
   - 3.3 [Generate one clause per declaration with unquote fragments](references/dsl-unquote-fragments.md)
   - 3.4 [Keep __using__ to setup only — its AST is copied into every caller](references/dsl-using-minimal.md)
4. [Compile-Time Validation](references/_sections.md#4-compile-time-validation)
   - 4.1 [Point compile errors at the caller's DSL line](references/valid-locate-errors-at-caller.md)
   - 4.2 [Validate the DSL in the macro body, not in the returned quote](references/valid-fail-at-compile-time.md)

---

## References

1. [https://elixir.hexdocs.pm/domain-specific-languages.html](https://elixir.hexdocs.pm/domain-specific-languages.html)
2. [https://elixir.hexdocs.pm/quote-and-unquote.html](https://elixir.hexdocs.pm/quote-and-unquote.html)
3. [https://elixir.hexdocs.pm/macros.html](https://elixir.hexdocs.pm/macros.html)
4. [https://elixir.hexdocs.pm/Kernel.SpecialForms.html#quote/2](https://elixir.hexdocs.pm/Kernel.SpecialForms.html#quote/2)
5. [https://elixir.hexdocs.pm/Macro.html#escape/1](https://elixir.hexdocs.pm/Macro.html#escape/1)
6. [https://elixir.hexdocs.pm/Macro.Env.html](https://elixir.hexdocs.pm/Macro.Env.html)
7. [https://elixir.hexdocs.pm/Module.html#module-compile-callbacks](https://elixir.hexdocs.pm/Module.html#module-compile-callbacks)
8. [https://elixir.hexdocs.pm/Kernel.html#defguard/1](https://elixir.hexdocs.pm/Kernel.html#defguard/1)
9. [https://hexdocs.pm/elixir/macro-anti-patterns.html](https://hexdocs.pm/elixir/macro-anti-patterns.html)
10. [https://hexdocs.pm/ecto/Ecto.Schema.html#module-reflection](https://hexdocs.pm/ecto/Ecto.Schema.html#module-reflection)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
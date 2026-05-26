---
title: Fill four When-to-Apply slots — import trigger, problem domain, frequency, not-to-do boundary
tags: shape, when-to-apply, triggers
---

## Fill four When-to-Apply slots — import trigger, problem domain, frequency, not-to-do boundary

By default the agent writes "When to Apply" as a vague paragraph: "Use this skill when you are working with library X." This does not trigger reliably — the dispatcher cannot tell from the paragraph whether a specific user prompt should invoke the skill or a sibling. Across shipped library-ref skills, the "When to Apply" section has the same **4-slot structure**. Fill all four slots explicitly.

```text
Slot 1 — Import-statement trigger
  The exact code patterns that, when present in user-shown code,
  should invoke this skill.

  Bad:   "When working with form state."
  Good:  "When code imports useForm, Controller, FormProvider, or
         useFormContext from react-hook-form."

Slot 2 — Problem-domain language
  The words the user uses (not the library uses) that signal this
  problem space.

  Bad:   "Form validation."
  Good:  "When the user says 'controlled vs uncontrolled', 'too
         many re-renders', 'isSubmitting stuck', 'validation runs
         twice', or 'I need to read form state without subscribing
         to it'."

Slot 3 — Frequency signal
  How often the triggering pattern fires — used to disambiguate
  from skills with overlapping surface area.

  Bad:   (none — most skills omit this).
  Good:  "When the user is debugging re-renders that fire on every
         keystroke" (RHF), or "When animating high-frequency user
         actions like cursor moves" (emilkowal-animations).

Slot 4 — NOT-to-do boundary (with sibling routing)
  The cases where this skill is wrong and which sibling owns them.

  Bad:   (none — most skills omit this).
  Good:  "NOT for React 19 Server Actions form-handling (→ use
         react-19-component-scaffolder). NOT for OpenAPI schema
         generation from zod (→ use orval). NOT for general
         TypeScript narrowing (→ use typescript)."

Full template before drafting:

  ## When to Apply

  Use this skill when:
  - [Slot 1: import X from "lib"; pattern Y in code]
  - [Slot 2: user says "..." or "..." or "..."]
  - [Slot 3: at frequency/scale "..."]

  This skill is NOT for:
  - [Slot 4a: case + sibling skill it routes to]
  - [Slot 4b: case + sibling skill it routes to]
```

The test: hand your "When to Apply" to someone unfamiliar with the library and ask "could you tell from this alone whether to invoke this skill or `react-19-component-scaffolder` for a given prompt?" If they can't, a slot is missing or vague. The 4 slots together are the dispatcher's input — treat them as a contract, not as marketing copy.

Reference: [nuqs SKILL.md "When to Apply" naming useQueryState, parser kinds, and explicit boundaries with react-19 and orval](../../../../skills/.curated/nuqs/SKILL.md)

# Choosing the PEP Type

Every PEP is exactly one of three types, set in the `Type:` header. The type drives
which headers are required and the bar the proposal is held to. Getting this wrong is
a common early mistake — a process change dressed up as a feature, or vice versa.

## The three types

### Standards Track

> Describes a new feature or implementation for Python, **or** an interoperability
> standard supported outside the standard library for current Python versions before
> a later PEP adds stdlib support.

Use it for: new syntax, new builtins, new stdlib modules/APIs, changes to the language
or interpreter, and cross-implementation standards.

Implications:
- Typically carries a **`Python-Version`** header (the release the feature targets).
- The **`Resolution`** header is **required** once resolved (accepted/rejected/withdrawn).
- Needs a **reference implementation** (complete before `Final`).
- Held to the full acceptance bar: clear & complete, net improvement, solid implementation, pythonic.

### Informational

> Describes a Python design issue, or provides general guidelines or information to the
> community, but does **not** propose a new feature.

Use it for: design guidance, conventions, or community information where adoption is
optional. Informational PEPs **do not necessarily represent consensus or a
recommendation** — users and implementers are free to ignore them.

Implications:
- No `Python-Version`, no reference implementation, no net-improvement-of-the-language bar.
- May be marked **Active** if it is an ongoing document never meant to be "completed".

### Process

> Describes a process surrounding Python, or proposes a change to (or an event in) a
> process. Like Standards Track PEPs, but applied to areas **other than the language
> itself**.

Use it for: changes to the development workflow, decision-making, release cadence,
governance, or the PEP process itself. Process PEPs **require community consensus** and,
unlike Informational PEPs, users are typically **not** free to ignore them. Examples:
PEP 1 (this process) and PEP 13 (governance) — both `Active`.

## Quick decision guide

| If the proposal… | Type |
|------------------|------|
| Adds/changes language syntax, a builtin, or a stdlib API | **Standards Track** |
| Defines an interoperability standard across implementations | **Standards Track** |
| Offers optional guidance or information, proposes no feature | **Informational** |
| Changes how the project/community operates (workflow, governance, releases) | **Process** |

Ask: *"Does this change Python the language/library, or change how the Python project
operates, or is it just information?"* Language/library → Standards Track. How the
project operates → Process. Pure information with no mandate → Informational.

## Topic (a separate axis)

The optional `Topic:` header is **not** the type. It tags a PEP into a sub-index and
takes one of: `Governance`, `Packaging`, `Release`, `Typing`. A Standards Track typing
PEP, for example, has `Type: Standards Track` and `Topic: Typing`.

# Body Sections, RST Conventions, and the Acceptance Bar

The body follows the preamble. `assets/templates/pep-template.rst` has the full skeleton;
this file explains **what each section is for and the bar it must clear**. Only the
**Copyright** section is strictly mandatory, but a serious Standards Track PEP needs
Abstract, Motivation, Rationale, Specification, and Backwards Compatibility to stand a
chance. Source: [PEP 12](https://peps.python.org/pep-0012/).

## The acceptance bar (write to this)

From PEP 1, a PEP is accepted only if it is:
1. a **clear and complete** description of the enhancement,
2. a **net improvement**,
3. backed by a **solid implementation that doesn't unduly complicate the interpreter** (if applicable), and
4. **"pythonic"**.

Every section below exists to demonstrate one of these. If a section doesn't move a
reviewer toward "yes" on one of them, tighten it.

## Sections

| Section | Required? | Its job |
|---------|-----------|---------|
| **Abstract** | Strongly recommended | ~200-word technical summary. A reader decides from this alone whether the PEP concerns them. |
| **Motivation** | Effectively required for Standards Track | Why the current spec/situation is inadequate. Reviewers who don't grasp the motivation won't engage — this is the section that earns attention. |
| **Specification** | Required for Standards Track | Syntax and semantics precise enough to implement. Be language-lawyerly: edge cases, errors, interactions with existing features, grammar changes. |
| **Rationale** | Recommended | Why these design decisions; what alternatives were considered and why rejected; prior art in other languages. Shows consensus and records dissent. |
| **Backwards Compatibility** | **Required if there are incompatibilities** | Impact and severity on existing code, and migration. State explicitly when there are none. |
| **Security Implications** | When applicable | New attack surface a malicious actor could exploit. State explicitly when there is none. |
| **How to Teach This** | For feature additions | How to introduce the feature to new and experienced users; docs and mental models. |
| **Reference Implementation** | Before `Final` | Link + state of the implementation. Must be complete before `Final`, not before acceptance. |
| **Rejected Ideas** | Recommended | Alternatives raised in discussion and why they were dropped — prevents re-litigation. |
| **Open Issues** | While unresolved | Points still being decided. **Resolve and remove before final review.** |
| **Acknowledgements** | Optional | Thank the people who contributed to the discussion and design. |
| **Footnotes** | As needed | Citations using RST footnote syntax. |
| **Change History** | Optional | Major revisions, newest first, each a dated bullet matching a `Post-History` entry. |
| **Copyright** | **Mandatory** | The dual public-domain / CC0 notice (verbatim below). |

> **Section order matters.** Note that `Specification` comes **before** `Rationale` in
> the canonical PEP 12 template — describe *what* you propose, then justify *why*.

## Mandatory copyright notice (verbatim)

```
Copyright
=========

This document is placed in the public domain or under the
CC0-1.0-Universal license, whichever is more permissive.
```

`scripts/check-pep.sh` fails the draft if the `CC0-1.0-Universal` notice is missing.

## reStructuredText conventions

PEPs are UTF-8 reStructuredText. The conventions that matter:

- **Section headers** use an underline of punctuation **at least as long as the title**:
  - First level: `=` underline
  - Second level: `-` underline
  - Third level: `'` underline
  - Capitalise each word; acronyms stay all-caps. Leave **two blank lines** before the next section heading.

- **Code / literal blocks:** end the lead-in line with `::` then indent the block 4
  spaces, or use `.. code-block:: python`.

- **Links:** inline as `` `link text <https://example.com>`__ ``. Reference other PEPs
  and RFCs with the roles `:pep:\`8\`` and `:rfc:\`2822\`` rather than raw URLs.

- **Footnotes:** cite with ``[#label]_`` in the text and define with ``.. [#label]
  content`` in the Footnotes section.

- **Lists:** bullets with `-`/`*`/`+`; numbered with `1.`/`a.`; definition lists are a
  term line followed by an indented definition.

## Auxiliary files

Diagrams: `pep-XXXX-Y.ext` (serial `Y` from 1) or anything inside a `pep-XXXX/`
subdirectory. Prefer SVG/PNG, legible in light **and** dark mode.

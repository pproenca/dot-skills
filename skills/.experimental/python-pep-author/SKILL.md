---
name: python-pep-author
description: |
  Use this skill whenever the user wants to write, draft, or structure a Python Enhancement Proposal (PEP) — proposing a Python language feature, a standard library change, an interoperability standard, or an informational/process document for the Python community. Trigger on "write a PEP", "draft a PEP", "propose a Python feature", "create a Python Enhancement Proposal", "PEP template", or when someone is preparing a proposal for the Python Discourse or python-dev. Covers all three PEP types (Standards Track, Informational, Process): choosing the right type, scaffolding a valid reStructuredText pep-NNNN file, filling each required section to the acceptance bar, linting the headers, and navigating the sponsor / submission / Steering Council review process. Use it even if the user only says "PEP" or doesn't mention reStructuredText — the headers, sections, and process are exactly what trips PEP authors up.
metadata:
  internal: true
---
# Write a Python Enhancement Proposal (PEP)

A PEP is the design document the Python community uses to propose a new language
feature, a stdlib change, an interoperability standard, or a process/informational
guideline. This skill takes an author from a rough idea to a correctly-formatted,
process-compliant draft ready for submission to the [python/peps](https://github.com/python/peps)
repository.

The hard parts of a PEP are not the prose — they are getting the **type** right,
the **header preamble** valid, the **sections** complete to the acceptance bar,
and following the **process** (vetting, sponsorship, review). This skill bundles
two scripts for the deterministic parts and reference docs for the judgement calls.

## When to Apply

- The user asks to **write / draft / structure a PEP** or a "Python Enhancement Proposal".
- The user wants to **propose a Python language or standard-library feature** and needs it written up formally.
- The user has an idea they've been discussing on the Python Discourse and wants to **turn it into a PEP draft**.
- The user needs the **PEP template, header fields, or section structure** explained or generated.
- The user is **revising an existing PEP** (changing status, adding a Resolution, addressing review feedback).

Do **not** use this skill for internal company RFCs / design docs (use `dev-rfc`) — a
PEP is specifically a proposal to the upstream CPython / Python community governed by
[PEP 1](https://peps.python.org/pep-0001/).

## Prerequisites

- **Bash + coreutils** (`awk`, `sed`, `grep`, `date`) for the two scripts — present by default on macOS/Linux.
- A clone of, or a fork of, [github.com/python/peps](https://github.com/python/peps) only when you're ready to *submit* (Step 6). Drafting needs no repo.
- No Python runtime is required to draft or lint; the reference implementation (if any) is the author's separate codebase.

## Workflow Overview

```
1. Vet the idea ────► 2. Choose the type ────► 3. Scaffold the file
   (is it PEP-able?)     (Standards/Info/Process)   (scripts/new-pep.sh)
                                                          │
   6. Submit ◄──── 5. Self-check ◄──── 4. Draft each section
   (sponsor, PR)      (scripts/check-pep.sh)   (to the acceptance bar)
        │
        ▼
   7. Review & resolution ──► update Status + Resolution header
```

### 1. Vet the idea (before writing anything)

A PEP that duplicates prior work or isn't community-wide in scope will be rejected on
sight. Post the idea to the **Ideas** category of the [Python Discourse](https://discuss.python.org/c/ideas/6)
first (or the Typing / Packaging category if specialised). Confirm it's original,
applicable to the whole community, and not already settled by a past discussion.
See [references/workflow.md](references/workflow.md) for venues and what to check.

### 2. Choose the PEP type

There are exactly three: **Standards Track**, **Informational**, **Process**. The type
determines required headers (e.g. `Python-Version`, `Resolution`) and the bar for
acceptance. Pick with [references/pep-types.md](references/pep-types.md).

### 3. Scaffold the file

Generate a valid, correctly-headed reStructuredText file rather than hand-typing the
preamble (the field set and ordering are exact):

```bash
scripts/new-pep.sh \
  --title "A short descriptive title" \
  --author "Random J. User <random@example.com>" \
  --type "Standards Track" \
  --python-version 3.15            # Standards Track only; omit otherwise
```

This writes `pep-9999.rst` (`9999` = placeholder; PEP editors assign the real number),
sets `Status: Draft` and today's `Created` date, and enforces the 44-character title
limit. Run `scripts/new-pep.sh` with no args for full usage.

### 4. Draft each section

Fill the body sections in the canonical PEP 12 order: **Abstract → Motivation →
Specification → Rationale → Backwards Compatibility → Security Implications → How to
Teach This → Reference Implementation → Rejected Ideas → Open Issues →
Acknowledgements → Footnotes → Change History → Copyright**.
Each section has a specific job and a quality bar — read
[references/sections.md](references/sections.md) before drafting, and consult
[references/header-fields.md](references/header-fields.md) for any header you need to
fill in (Sponsor, Discussions-To, Requires, etc.).

The acceptance bar (from PEP 1): the proposal must be a **clear and complete**
description, represent a **net improvement**, have a **solid** implementation that
doesn't unduly complicate the interpreter, and be **"pythonic"**. Write to that bar.

### 5. Self-check the draft

Lint the headers and required structure before showing it to anyone:

```bash
scripts/check-pep.sh pep-9999.rst
```

It verifies the required headers are present, the title length, valid `Status`/`Type`
values, the `Created` date format, the mandatory CC0 copyright notice, and an
`Abstract` section — reporting PASS / WARN / FAIL and exiting non-zero on any FAIL.
Fix every FAIL.

### 6. Submit

If **no co-author is a CPython core developer**, you must first find a **sponsor**
(a core developer who shepherds the PEP). Then fork python/peps, add `pep-NNNN.rst`,
list authors/sponsors in `.github/CODEOWNERS`, and open a pull request. PEP editors
review for format and soundness and assign the number. Full steps and the role
definitions are in [references/workflow.md](references/workflow.md).

### 7. Review & resolution

When the authors (and sponsor) judge it ready, content review and the
accept/reject decision rest with the **Steering Council** (or an appointed
**PEP-Delegate**). On a decision, update the `Status` and add a `Resolution`
header linking to the pronouncement. The full status lifecycle and valid
transitions are in [references/status-lifecycle.md](references/status-lifecycle.md).

## Reference Files

| File | Read it when |
|------|--------------|
| [references/workflow.md](references/workflow.md) | Vetting, finding a sponsor, submitting, the review process, the roles, transferring ownership |
| [references/pep-types.md](references/pep-types.md) | Choosing between Standards Track / Informational / Process |
| [references/header-fields.md](references/header-fields.md) | Filling any preamble field — formats, required vs optional, examples |
| [references/status-lifecycle.md](references/status-lifecycle.md) | Setting or changing `Status`, understanding valid transitions, the `Resolution` header |
| [references/sections.md](references/sections.md) | Drafting the body — what each section must contain, RST conventions, the acceptance bar |

## Scripts

| Script | What it does |
|--------|--------------|
| `scripts/new-pep.sh` | Scaffolds a valid `pep-NNNN.rst` from the template, substituting the header fields and enforcing the title-length limit |
| `scripts/check-pep.sh` | Lints a PEP draft against PEP 1 / PEP 12 rules (headers, status/type, date format, copyright, abstract) |

The template the scripts use lives at `assets/templates/pep-template.rst` — copy it
directly if you'd rather fill the headers by hand.

## Gotchas

See [gotchas.md](gotchas.md). The most common early mistakes: skipping the Discourse
vetting step, choosing `Standards Track` for what is really a `Process` PEP, omitting
the mandatory CC0 copyright notice, and a title over 44 characters.

## Related Skills

- `dev-rfc` — internal/company RFCs, design docs, and architecture docs (not upstream Python proposals).

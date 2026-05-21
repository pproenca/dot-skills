# The Header Preamble (RFC 2822 Fields)

Every PEP starts with an [RFC 2822](https://datatracker.ietf.org/doc/html/rfc2822)
style header block, ending at the first blank line. Fields appear in the order below.
This is the most error-prone part of a PEP — `scripts/check-pep.sh` validates it.

## Field reference

| Field | Required? | Value / format |
|-------|-----------|----------------|
| `PEP` | **Required** | The PEP number (unpadded, e.g. `8`). Use `9999` as a placeholder until editors assign one. |
| `Title` | **Required** | Short, descriptive title — **maximum 44 characters**. |
| `Author` | **Required** | `Name <email>` or just `Name`. One author per line (RFC 2822 continuation) for multiple. |
| `Sponsor` | Optional | The sponsoring core developer. **Omit** if a co-author is a core developer. |
| `PEP-Delegate` | Optional | The individual the Steering Council appointed to decide this PEP. |
| `Discussions-To` | Optional* | URL of the canonical discussion thread. *Expected once the PEP is past `Draft`. For mailing lists, link to the thread in the archives — not a bare `mailto:`. |
| `Status` | **Required** | One of the lifecycle statuses — see [status-lifecycle.md](status-lifecycle.md). New PEPs start at `Draft`. |
| `Type` | **Required** | `Standards Track`, `Informational`, or `Process` — see [pep-types.md](pep-types.md). |
| `Topic` | Optional | One of `Governance`, `Packaging`, `Release`, `Typing`. Sub-index tag, not the type. |
| `Requires` | Optional | PEP number(s) this PEP depends on. |
| `Created` | **Required** | Date the PEP was assigned a number, format `dd-mmm-yyyy` (e.g. `21-May-2026`). |
| `Python-Version` | Optional | Target release `M.N` (e.g. `3.15`). **Standards Track only.** |
| `Post-History` | Optional | Dates + URLs of `Discussions-To` posts, e.g. `` `21-May-2026 <URL>`__ ``. |
| `Replaces` | Optional | PEP number this one renders obsolete (pairs with `Superseded-By` on the older PEP). |
| `Superseded-By` | Optional | PEP number that renders **this** PEP obsolete. |
| `Resolution` | Optional* | A `dd-mmm-yyyy` date linked (RST) to the post making the accept/reject pronouncement, e.g. `` `21-May-2026 <URL>`__ ``. **Required for Standards Track** once resolved. |

## Format rules that catch people out

- **`Author` format is exact:** `Random J. User <random@example.com>` *with* an email, or
  `Random J. User` *without*. Multiple authors each go on their own continuation line:

  ```
  Author: Random J. User <random@example.com>,
          Another Person <another@example.com>
  ```

- **`Title` ≤ 44 characters.** This is a hard limit (it has to fit the PEP index). The
  scaffold and lint scripts both enforce it.

- **`Created` is `dd-mmm-yyyy`** with a three-letter English month: `01-Feb-2026`, not
  `2026-02-01` and not `1-Feb-2026` without the leading zero.

- **`Sponsor` vs core-dev authorship:** if any author is a core developer, leave
  `Sponsor` out entirely. Don't list a sponsor "for safety" — it signals no author has
  commit rights.

- **`Discussions-To` must point at a specific thread**, not a list's landing page, so
  reviewers land on the actual conversation.

- **`Replaces` / `Superseded-By` are reciprocal:** when PEP B supersedes PEP A, A gets
  `Superseded-By: B` and B gets `Replaces: A`. Setting only one side is inconsistent.

- **`Resolution` is mandatory for resolved Standards Track PEPs.** Add it together with
  the `Status` change to `Accepted` / `Rejected` / `Withdrawn`.

## Minimal valid Draft header (Standards Track)

```
PEP: 9999
Title: Add frobnication to the standard library
Author: Random J. User <random@example.com>
Status: Draft
Type: Standards Track
Created: 21-May-2026
Python-Version: 3.15
```

`scripts/new-pep.sh` generates exactly this (with the full optional-field skeleton).

# Status Lifecycle

The `Status` header tracks where a PEP is in its life. Setting it to a value the
process doesn't allow (or skipping the `Resolution` header on a decision) is a common
slip. Source: [PEP 1](https://peps.python.org/pep-0001/).

## The statuses

| Status | Meaning |
|--------|---------|
| **Draft** | Initial state of every new PEP; under discussion and revision. |
| **Deferred** | No progress is being made (or no PEP-Delegate is available). A PEP editor can move it back to Draft. |
| **Accepted** | Approved for implementation; the reference implementation is not yet complete. |
| **Provisional** | "Provisionally Accepted": accepted for inclusion in the reference implementation, but more user feedback is needed before `Final`. **May still be Rejected or Withdrawn even after shipping in a release.** |
| **Final** | The reference implementation is complete and merged into the main source repository. |
| **Active** | For Informational/Process PEPs that are ongoing and never meant to be "completed" (e.g. PEP 1, PEP 13). |
| **Rejected** | Reviewed and decided against — not a good idea. |
| **Withdrawn** | The *author* decided it's a bad idea, or accepted a competing proposal as better. |
| **Superseded** | Rendered obsolete by a later PEP. Carries a `Superseded-By` header; the newer PEP carries `Replaces`. |

## Valid transitions

```
Draft ──► Deferred ──► Draft            (stalled, then revived)
Draft ──► Rejected | Withdrawn
Draft ──► Accepted ──► Final
Accepted ──► Provisional ──► Final
Accepted | Provisional ──► Rejected | Withdrawn
Rejected | Withdrawn | Final | Superseded ──► Active   (meta-PEPs only)
```

Notes that trip people up:

- **`Accepted` → `Rejected` / `Withdrawn` is allowed only before the change ships in a
  Python release.** Once released, an accepted PEP can't be un-accepted (only
  `Provisional` PEPs can be reversed post-release).
- **A PEP-Delegate stepping down (or being asked to) overrules any prior
  acceptance/rejection and reverts the PEP to `Draft`.**
- **`Active`** is reachable only for Informational/Process meta-PEPs that are living
  documents.

## The `Resolution` header on a decision

When a PEP becomes **Accepted, Rejected, or Withdrawn**, update the PEP accordingly:
at minimum change `Status` **and** add a `Resolution` header with a direct link to the
post making the decision (posted to the PEPs category of the Python Discourse). For
**Standards Track** PEPs the `Resolution` header is **mandatory**; `check-pep.sh`
flags its absence.

## Reaching `Final`

`Final` requires the **reference implementation to be complete and merged**. A PEP can
be `Accepted` without it, but not `Final`. Don't set `Final` while the implementation
is still in review.

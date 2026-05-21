# The PEP Process: From Idea to Resolution

The PEP process is as much about **building consensus** as about writing a document.
The author's job is to champion the idea, document dissent fairly, and shepherd it
through review. Source of truth: [PEP 1](https://peps.python.org/pep-0001/).

## The roles

| Role | Who | What they do |
|------|-----|--------------|
| **Author / Champion** | Anyone | Writes the PEP, drives discussion, builds consensus, documents dissent. |
| **Sponsor** | A core developer (or a community member approved by the Steering Council) | Required only if **no co-author is a core developer**. Guides the author through the logistics; recorded in the `Sponsor` header. |
| **PEP Editors** | A small team, reached via `@python/pep-editors` on GitHub | Manage the administrative/editorial side: assign PEP numbers, check format and soundness, change statuses. They are **not** responsible for correctness. |
| **PEP-Delegate** (formerly BDFL-Delegate) | A core developer the Steering Council approves to decide a specific PEP | Has authority to approve or reject that PEP; recorded in `PEP-Delegate`. |
| **Steering Council** | The elected council ([PEP 13](https://peps.python.org/pep-0013/)) | Final authority on acceptance/rejection. May delegate to a PEP-Delegate. |
| **Typing Council** | [PEP 729](https://peps.python.org/pep-0729/) | For type-system PEPs, gives the Steering Council a recommendation. |

## Step 1 — Vet the idea (pre-PEP discussion)

Public vetting **saves the author time**: it weeds out ideas already rejected in prior
discussions, confirms the idea is original, and confirms it's applicable to the whole
community rather than just the author. Do this *before* drafting.

Post to the appropriate venue:

- **Ideas** category of the [Python Discourse](https://discuss.python.org/c/ideas/6) — general proposals.
- **Typing** category — static typing ideas.
- **Packaging** category — packaging ideas.

Once vetted, a draft PEP is presented to the same venue to be made well-formatted,
high quality, and to address initial concerns.

## Step 2 — Determine your path (core dev or not?)

- If **one or more co-authors are core developers**, they follow the submission steps below directly.
- Otherwise, the author(s) must **find a sponsor** first. A sponsor is a core developer (or SC-approved community member) who agrees to shepherd the PEP. Record them in the `Sponsor` header. PEP-editors team members and Typing Council members are pre-approved to act as sponsors.

## Step 3 — Submit the PEP

1. **Fork** the [python/peps](https://github.com/python/peps) repository.
2. Create `pep-NNNN.rst`, where `NNNN` is the next available PEP number not used by a published or in-PR PEP.
3. In the header: put the number in `PEP:`, set `Type:` to one of the three types, set `Status: Draft`.
4. Update `.github/CODEOWNERS` so any co-authors/sponsors with write access are listed for your file.
5. Push to your fork and **open a pull request**.

PEP editors then review for: a sound and complete idea that makes technical sense; an
accurate title; correct language and code style; and valid reStructuredText (checked
automatically). **Approval is not a guarantee of correctness** — that stays with
authors and reviewers. Once approved, editors **assign the PEP number**.

Reasons editors may deny PEP status: duplication of effort, being technically unsound,
not providing proper motivation or addressing backwards compatibility, or not being in
keeping with the Python philosophy.

> Core developers with write access may claim a number and commit a new PEP directly,
> taking on the tasks editors would normally handle.

## Step 4 — Discussion and revision

Draft PEPs are freely open for discussion and modification at the authors' discretion
until submitted for review. Substantive content changes should generally be proposed
first on the PEP's `Discussions-To` thread; copyedits and corrections can go straight
to a GitHub issue or PR. Record discussion threads in `Post-History`.

## Step 5 — Review and resolution

When the authors (and sponsor, if any) judge the PEP **ready for final review**, content
review and acceptance become the **Steering Council's** responsibility, formally
initiated by opening a Steering Council issue.

- Any suitably experienced core developer may offer to be the **PEP-Delegate** by notifying the SC (and the authors/sponsor). The SC generally approves such self-nominations by default, but may decline (e.g. conflict of interest).
- If no volunteer steps forward and no suitable candidate can be found, the PEP is marked **Deferred** until one is available.
- For type-system PEPs, request a recommendation from the **Typing Council** via its issue tracker.

**Acceptance criteria** (a PEP must meet all): a clear and complete description of the
enhancement; the enhancement is a **net improvement**; the implementation (if any) is
**solid and does not unduly complicate the interpreter**; and the proposal is
**"pythonic"**.

The reference implementation must be complete before a PEP becomes **Final**, but not
before it is accepted. Pronouncements of resolution are posted to the **PEPs** category
of the Python Discourse; link to that post from the `Resolution` header.

## After resolution — modifying a PEP

Once a PEP reaches **Accepted, Final, Rejected, or Superseded**, it is a historical
document, not a living spec, and is no longer substantially modified. Exceptions:

- **Provisional** (or, with SC approval, **Accepted**) Standards Track PEPs may be updated from implementation experience — note the changes in the PEP.
- **Active** (Informational/Process) PEPs may be updated over time to reflect changing practice.

## Transferring PEP ownership

Sometimes a PEP needs a new champion (the original author lost time/interest or went
quiet). A *bad* reason is disagreement with the PEP's direction. To take over: fork,
make the ownership change, open a PR, and mention both the original author and
`@python/pep-editors`. It's preferable to keep the original author as a co-author. If
the original author is unresponsive, the PEP editors make a unilateral decision.

## Auxiliary files

Diagrams and other support files are named `pep-XXXX-Y.ext` (`XXXX` = PEP number,
`Y` = serial number from 1, `ext` = extension), **or** placed in a `pep-XXXX/`
subdirectory (no naming constraints inside it). Prefer browser-friendly formats
(SVG, PNG) that are legible in both light and dark mode.

## Copyright

Each new PEP must be dual-licensed: **public domain and CC0-1.0-Universal**. The
mandatory closing notice is in [sections.md](sections.md).

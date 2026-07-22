# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance ×
frequency** — the decisions that come up on every setup, and cost most when
wrong, go first.

SonarQube ships a release every two months, so these rules are pinned to a
**date, not a version**: verified against docs.sonarsource.com in **July 2026**,
against **SonarQube Server 2026.3** (current LTA **2026.1**). Re-verify anything
version-shaped before trusting it.

Categories are ordered by **cost of being wrong**, not by execution order. A
mistake in category 1 invalidates the whole plan — there is nothing to build if
the licence cannot analyze a pull request. A mistake in category 6 shows up as a
container that will not boot, which at least announces itself.

The order you actually execute in is **1 → 6 → 5 → 4 → 2 → 3**: confirm the
licence, stand up the server, configure the scanner, define what "new" means,
apply the AI-specific machinery, and read category 3 last — before declaring the
gate finished.

---

## 1. Edition & Version Reality (plat)

**Description:** What the licence you have can actually do, and what the product
is currently called. First because it is the only category that can delete the
work: the free tier cannot analyze a pull request at all, so a "continuous gate
on AI-generated changes" has no place to run on it. Also covers the calendar
versioning scheme that replaced 10.x and the upgrade path that will not let you
skip an LTA.

## 2. AI Code Assurance (aica)

**Description:** The AI-specific machinery Sonar shipped in 10.7 and has been
reshaping since — labelling a project as containing AI code, qualifying a
quality gate to grant assurance status, and the built-in profile tuned for
agentic failure modes. The model does not know this feature set exists, so
without these rules it builds a generic code-quality setup and calls it an AI
gate.

## 3. What the Gate Doesn't Measure (blind)

**Description:** The highest-value category, and the reason a green gate can be
worthless on AI-generated code. Duplication and coverage conditions are skipped
below a change-size threshold that is on by default; duplication is not measured
on test code at all; the complexity metric everyone reaches for has no new-code
variant. Each of these is silent — nothing in the UI or the scanner output says
a condition was not evaluated.

## 4. New Code & Blame (newcode)

**Description:** "Continuously" is implemented entirely through the new code
period, and the new code period is computed from SCM blame. Get the checkout
wrong and the mechanism degrades to timestamps without telling you. Covers the
full-clone requirement and choosing a definition that matches your branching
model.

## 5. Scanner Configuration (scan)

**Description:** The properties whose defaults are wrong for a self-hosted,
gate-enforcing setup. Several fail open rather than loudly: an unset host URL
targets Sonar's SaaS, an unset gate-wait leaves CI green on a red gate, and an
unset test scope means no file is treated as test code.

## 6. Running the Server (ops)

**Description:** The self-hosted deployment decisions that bite once rather than
continuously — kernel limits that must be set before first boot, and the
database and volume choices that decide whether the instance survives its first
upgrade. Last because these fail loudly.

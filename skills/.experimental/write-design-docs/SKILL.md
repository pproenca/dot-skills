---
name: write-design-docs
description: Write, revise, or review software design documents using Malte Ubl's "Design Docs at Google" guidance. Use when Codex needs to draft a design doc, technical design, RFC, engineering review doc, architecture proposal, mini design doc, or design-doc review focused on context, goals, non-goals, trade-offs, alternatives, cross-cutting concerns, review lifecycle, and deciding whether a design doc is warranted.
---

# Write Design Docs

## Core Workflow

Use the design doc as a problem-solving and consensus-building tool, not as an implementation manual.

1. Decide whether a design doc is warranted.
   - Write one when the software design is ambiguous, complex, contentious, cross-functional, likely to benefit from senior review, or valuable as organizational memory.
   - Prefer a short note, issue, or direct implementation when the solution is obvious and there are no meaningful trade-offs.
   - Prefer a mini design doc for small but non-obvious changes.

2. Gather the minimum context needed to make the design concrete.
   - Identify the problem, existing landscape, constraints, stakeholders, and decision deadline.
   - Ask focused questions only when missing information would materially change goals, non-goals, or trade-offs.
   - State assumptions explicitly when proceeding with incomplete information.

3. Draft around decisions and trade-offs.
   - Start with objective context and scope.
   - Define goals and non-goals as explicit boundaries.
   - Present the selected design from overview to detail.
   - Explain why the selected design best satisfies the goals under the known constraints.
   - Compare realistic alternatives, including why they were not selected.
   - Cover cross-cutting concerns such as security, privacy, reliability, observability, migrations, and operations when relevant.

4. Keep the document readable.
   - Optimize for busy reviewers who need to understand the decision, not every implementation detail.
   - Link to detailed requirements, prototypes, schemas, code, or prior docs instead of copying them wholesale.
   - Include diagrams or compact API/data sketches only when they clarify the design trade-offs.
   - Avoid large code blocks unless explaining a novel algorithm.

5. Shape the lifecycle.
   - Mark the document status: draft, in review, accepted, implementing, superseded, or archived.
   - Suggest the smallest useful review group first, then wider review when the design is stable.
   - Update the doc while the system has not shipped if implementation reveals wrong assumptions or changed requirements.
   - Link amendments or follow-up docs when the original doc diverges from reality.

## Reference

Read [references/design-doc-guidance.md](references/design-doc-guidance.md) before drafting or reviewing a substantive design doc. Use it for the article-derived template, decision checklist, section guidance, and review rubric.

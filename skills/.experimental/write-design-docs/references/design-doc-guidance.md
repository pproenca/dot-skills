# Design Doc Guidance

Source: Malte Ubl, "Design Docs at Google", https://www.industrialempathy.com/posts/design-docs-at-google/

Use this as a practical guide, not a rigid template. Adapt the shape to the problem.

## Write Or Do Not Write

Write a design doc when at least some of these are true:

- The right software design is unclear and upfront reasoning would reduce risk.
- Senior engineers or specialists should influence the design before code review.
- Consensus matters because the design is ambiguous, contentious, or cross-team.
- The team often misses cross-cutting concerns such as security, privacy, logging, observability, or operability.
- Future maintainers need a high-level explanation of why the system exists and why it is shaped this way.

Do not write a full design doc when:

- The solution is obvious and there are no real trade-offs to evaluate.
- The proposed doc would only describe the implementation steps.
- Rapid prototyping is the better way to discover whether an approach works.

When the work is small but still non-obvious, write a mini design doc. Keep the same reasoning structure but compress the sections.

## Recommended Structure

Use these sections unless the problem calls for a different order.

### Title And Metadata

Include:

- Title
- Authors
- Reviewers or approvers
- Status
- Last updated date
- Links to requirements, issues, prototypes, prior docs, or amendments

### Context And Scope

Explain the landscape where the system or change fits.

Include:

- The problem being solved
- Existing systems, constraints, and dependencies
- What is in scope
- What is out of scope
- Links to detailed background

Keep this factual. Avoid turning it into a requirements document.

### Goals And Non-Goals

Use short bullets.

Good goals:

- State desired outcomes or properties.
- Are specific enough to guide trade-offs.
- Avoid implementation detail unless it is itself a constraint.

Good non-goals:

- Name plausible goals the project is intentionally not pursuing.
- Prevent reviewers from relitigating excluded outcomes.
- Are not merely negated goals.

### Design

Start with an overview, then add only the detail needed for the decision.

Useful elements:

- System context diagram showing how the new work fits into the larger technical landscape.
- Key components and responsibilities.
- Request, data, event, or control flow.
- API sketch focused on design-relevant surfaces.
- Data model sketch focused on durable concepts, ownership, and constraints.
- State, consistency, failure, or migration behavior when relevant.
- Links to prototypes when implementability matters.

Avoid:

- Copying full API definitions or schemas that will become stale.
- Long implementation walkthroughs.
- Code or pseudocode unless it explains a novel algorithm.

### Alternatives Considered

List realistic alternatives that could have achieved similar goals.

For each alternative, explain:

- Why someone would reasonably consider it.
- What trade-offs it makes.
- Why those trade-offs are worse than the selected design for this problem.

This section is central. It helps reviewers see that obvious other paths were considered and records the decision logic for future readers.

### Cross-Cutting Concerns

Add short focused subsections for concerns relevant to the organization and system.

Common concerns:

- Security
- Privacy
- Reliability and availability
- Observability, logging, metrics, and alerting
- Data retention and compliance
- Performance and scalability
- Operational ownership and support
- Rollout, migration, and rollback

If a dedicated security, privacy, or launch-review document exists, summarize the design impact and link to the dedicated doc.

### Open Questions

Use this section when the design is not fully settled.

For each open question, include:

- The decision needed
- The options under consideration
- Who owns the answer
- When it must be resolved

## Length Guidance

Aim for the shortest document that allows informed review.

- Mini design doc: 1 to 3 pages for incremental or narrow changes.
- Larger design doc: roughly 10 to 20 pages for substantial projects.
- If the doc grows far beyond that, split the problem into smaller design docs.

## Review Lifecycle

### Creation And Rapid Iteration

Draft with co-authors or close collaborators who understand the problem. Use early comments to clarify the problem, tighten goals, and expose missing alternatives before wider review.

### Review

Choose the lightest review process that still gets the needed expertise.

Use lightweight review when:

- The scope is local to a team.
- The trade-offs are meaningful but not organization-wide.
- Asynchronous comments can resolve most issues.

Use heavier review when:

- The design is high-risk, cross-cutting, or sets precedent.
- Senior engineering judgment is necessary.
- Privacy, security, reliability, or other specialist review is required.

Seek crucial feedback directly instead of blocking progress on a large formal meeting when a smaller expert review would answer the important questions.

### Implementation And Iteration

Update the doc before launch when implementation reveals wrong assumptions, new requirements, or design changes. If changes are captured in follow-up docs, link them from the original.

### Maintenance And Learning

Treat design docs as organizational memory. Future maintainers should be able to learn what the system was intended to do, what alternatives were rejected, and what assumptions shaped the design. Revisit older docs to compare expected and actual outcomes.

## Review Rubric

Use these questions when reviewing or revising:

- Is the problem and scope clear enough for a reviewer outside the immediate work?
- Are goals and non-goals explicit and useful for making trade-offs?
- Does the selected design follow from the stated context and goals?
- Are the important trade-offs visible, not implied?
- Are realistic alternatives evaluated fairly?
- Are cross-cutting concerns addressed early enough to affect the design?
- Is the document concise enough to read?
- Does it avoid stale detail such as copied schemas, full interface definitions, or implementation manuals?
- Are assumptions, open questions, and follow-up owners clear?
- Will a future maintainer understand why this design was chosen?

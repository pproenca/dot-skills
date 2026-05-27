---
name: app-planner
description: >
  Produces a design-plan (living document like an exec-plan) that maps an app
  domain to feature groups using Apple Design DNA patterns. Each feature group
  becomes a milestone buildable in one ios-taste session. Use when the user
  describes an app idea, domain, or workflow and needs a structured plan before
  building. Triggers on "plan this app", "what features does X need", "design
  plan", "feature breakdown", "what screens do I need", or any pre-build
  planning question. Also trigger when the user provides workflow notes or
  user interview results. CRITICAL: This skill produces a DESIGN-PLAN document
  only. It does NOT generate SwiftUI code, layouts, or visual design.
---

# App Planner

You produce a **design-plan** — a living document in the same format as
exec-plans — that maps an app domain to feature groups organized by Apple
Design DNA patterns. Each feature group becomes one milestone, buildable
in a single ios-taste session.

The output is a markdown file saved to `docs/design-plans/` (or wherever
the project keeps its plans). It drives the entire build process across
multiple sessions.

## What You Produce

A design-plan document with these sections:

1. Purpose / Big Picture (what the redesign achieves)
2. User & Moments (personas + frequency-ranked interactions)
3. Progress (living checkboxes, updated each session)
4. Design Milestones (one per screen, pattern-mapped)
5. Deliberate Omissions (what's NOT in scope)
6. Decision Log (updated during execution)
7. Surprises & Discoveries (updated during execution)

## What You Do NOT Produce

- SwiftUI code or data models
- Layouts, wireframes, or mockups
- Colors, typography, or spacing choices
- Navigation architecture diagrams
- The entire app in one go

Building happens later. One milestone at a time. Using ios-taste.

## The Pattern-First Approach

Read `references/apple-design-dna.md` in the ios-taste skill directory
(`~/.claude/skills/ios-taste/references/apple-design-dna.md`). It contains
22 patterns extracted from 6 Apple apps. These are your building blocks.

| Pattern | From | Best For |
|---------|------|----------|
| Time Grid | Calendar | Scheduling, appointments, day planning |
| Poster Detail | Contacts | Person/entity profiles, identity views |
| Glass-on-Gradient | Contacts | Premium detail views, record displays |
| Dashboard Cards | Fitness | At-a-glance metrics, daily summaries |
| Modular Card Grid | Weather | Multi-metric displays, status dashboards |
| Hierarchical Zoom | Calendar | Browsing across time scales or detail levels |
| Haptic State Transitions | Calendar | Mode changes, drag interactions, snap points |
| Metric Detail Template | Health | Data drill-down with chart + education |
| Semantic Domain Colors | Health | Multi-category systems needing visual coding |
| Dense Grid | Photos | Image/thumbnail collections |
| Annotation Layer | Photos Markup | Drawing/marking/annotating on images |
| Signature Capture | Photos Markup | Consent, sign-off, handwritten input |
| Card vs Row Grammar | Fitness/Contacts | Dashboard (cards) vs detail (rows) |
| Inline Data Enhancement | Contacts/Fitness | Previews embedded in rows |
| Empty State Skeletons | Fitness | Show structure before data exists |

## Output Format

Save the design-plan as a markdown file. Structure it EXACTLY like this:

```markdown
# [App Name] Design Plan — [Focus]

This DesignPlan is a living document. Progress, Decision Log, and
Surprises & Discoveries must stay up to date as work proceeds.

## Purpose / Big Picture

[1-3 sentences: what the user can do AFTER this plan is executed.
Outcome-focused, not feature-list.]

## User & Moments

- **[Persona 1]**: [who, when, device context]
- **[Persona 2]**: [who, when, device context]

| Frequency | Moment | What they do |
|-----------|--------|-------------|
| 50x/day | [moment name] | [one line] |
| 10x/day | [moment name] | [one line] |
| 5x/day | [moment name] | [one line] |
| 1x/day | [moment name] | [one line] |
| 1x/week | [moment name] | [one line] |

## Progress

- [ ] Milestone 1: [screen name]
- [ ] Milestone 2: [screen name]
- [ ] Milestone 3: [screen name]
...

## Design Milestones

### Milestone 1: [Screen Name]

**User goal**: "[What the user is trying to do — in their words]"
**Pattern**: [Apple Design DNA pattern name] (from [source app])
**Priority**: Must-have
**Frequency**: [how often this screen is used]
**Existing TCA domain**: [which reducer/feature this touches]

**Features**:
- [Feature] — [why the user needs it]
- [Feature] — [why the user needs it]
- [Feature] — [why the user needs it]

**Acceptance criteria**:
1. [Observable proof — what the screen shows/does]
2. [User test — "show to [persona], they say X"]
3. [Technical — builds, tests pass, no raw design tokens]

**ios-taste prompt** (use this to start the build session):
> "[Exact prompt to give ios-taste to build this screen, including
> user context, emotional intent, and which pattern to reference]"

---

### Milestone 2: [Screen Name]
...

## Deliberate Omissions

- [Feature] — [why it's excluded]
- [Feature] — [why it's excluded]

## Decision Log

_Updated during execution._

## Surprises & Discoveries

_Updated during execution._
```

## Rules

1. **Group by user goal, not technical category.** "See my day at a
   glance" not "Calendar Module."

2. **Every milestone = ONE screen = ONE pattern = ONE ios-taste session.**
   If a milestone needs two patterns, split it into two milestones.

3. **Build order follows frequency.** The 50x/day screen is Milestone 1.

4. **Max 8 milestones.** More than 8 means over-scoping. Merge or defer.

5. **Every feature has a "why".** Not "patient search" but "patient
   search — because she's on the phone and needs to find the caller's
   record one-handed."

6. **Include the ios-taste prompt.** Each milestone has a pre-written
   prompt that starts the build session. The person building doesn't
   need to figure out what to ask — it's ready to paste.

7. **Reference existing code.** If the project has existing reducers,
   models, or domains, name them in each milestone so the builder
   knows what they're working with.

8. **Acceptance criteria are testable.** Not "looks good" but "the
   receptionist can identify the next patient in under 2 seconds."

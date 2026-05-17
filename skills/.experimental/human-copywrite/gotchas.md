# Gotchas

## Source scope notes

### The "Writing inclusively" chapter was intentionally excluded
The source PDF includes a chapter on gender-neutral pronouns, person-first/identity-first disability terminology, and replacements for terms like *blacklist/whitelist* and *master/slave*. These entries were skipped at ingest time per skill-owner preference. Apple product features that relate to accessibility (VoiceOver, AssistiveTouch, Guided Access, Live Listen, etc.) are retained in `references/apple-features-software.md` as product references, not identity guidance.
Added: 2026-05-17

## Usage gotchas

No usage gotchas yet. Append entries as they're discovered.

## Validator misfit (known, expected)

`validate-skill.js` flags this skill with ~60 errors when run against the distillation discipline. Almost all of them are "missing frontmatter field: title/impact/tags" and "Missing **Incorrect / **Correct code example section" on each topic file.

**Why this is expected:** The validator's distillation schema assumes each `references/*.md` file is one code-style rule with one Incorrect/Correct code-block pair (see `37signals-rails/references/arch-vanilla-rails.md` for the canonical shape). This skill is a different shape — each topic file is a catalog of 20-200 short editorial entries copied verbatim from Apple's guide. There is no meaningful per-file "impact" rating, no code blocks, and no single rule per file.

**What to do:** Treat validator errors on this skill as non-blocking. Substance review (`skill-reviewer` agent against the distillation RUBRIC.md) is the meaningful quality check for editorial content. If a future dev-skill discipline is added for "reference-catalog" or "editorial" shapes, migrate at that point.

Added: 2026-05-17

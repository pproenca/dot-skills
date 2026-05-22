# Decision Tree: Wrong Type / Type-Mixing

**Symptom:** a page feels bloated, rambling, or hard to use, or a mode has visibly drifted — a tutorial that stalls into explanation, a how-to guide that lectures, reference that editorialises, an explanation stuffed with steps. Almost every documentation problem is this one: **content serving more than one need at once.**

The fix is never to "balance" the modes inside one page — it's to *separate* them.

```
A document feels off / mixed
│
├── Step 1. Establish the document's PRIMARY job.
│   Run the compass on the document as a whole → compass-tree.md.
│   That one mode stays; everything that serves a different need is a candidate to move out.
│
├── Step 2. Scan for the four tell-tale intrusions and relocate each:
│   │
│   ├── Passages that EXPLAIN — "the reason is…", history, trade-offs, rationale
│   │   └── If primary mode ≠ explanation → MOVE to an explanation page; link to it.
│   │       See explanation.md.
│   │
│   ├── Passages that INSTRUCT step-by-step — "first do x, then y"
│   │   └── If primary mode ≠ how-to/tutorial → MOVE to a how-to guide; link to it.
│   │       See how-to-guides.md.
│   │
│   ├── Passages that exhaustively DESCRIBE — option tables, every flag/param/field
│   │   └── If primary mode ≠ reference → MOVE to reference; link to it. See reference.md.
│   │
│   └── A guided first-run LESSON embedded inside something else
│       └── MOVE to a tutorial; link to it. See tutorials.md.
│
├── Step 3. Resolve the two classic confusions deliberately:
│   │
│   ├── TUTORIAL vs HOW-TO (both inform action). Ask: is the reader a BEGINNER I'm
│   │   teaching (→ tutorial) or a COMPETENT user pursuing their own goal (→ how-to)?
│   │   Split the content along that line.
│   │
│   └── REFERENCE vs EXPLANATION (both inform cognition). Ask: is this NEUTRAL fact to
│       look up (→ reference) or DISCUSSION to build understanding (→ explanation)?
│       Split along that line.
│
└── Step 4. Verify and record.
    Each resulting page should now serve EXACTLY ONE need and LINK to its siblings
    instead of inlining them. Re-run the compass on each to confirm it's single-mode.
    Terminal: SPLIT complete — record it in ../assets/templates/report.md.
```

## If nothing needs moving

If Step 1 shows the document is already single-mode and just *reads* badly (clumsy prose, poor ordering within the mode), this is **not** a Diátaxis problem.

- **Terminal: DISMISS** — hand it to prose/structure editing within its mode (e.g. a copy-editing skill), or fix flow using that mode's own principles. Don't split a page that has only one need.

## Decision criteria

| You see… | It's an intrusion of… | Move it to… |
|----------|-----------------------|-------------|
| "The reason / historically / the trade-off is…" | explanation | explanation.md |
| Numbered "do this, then that" procedure | how-to (or tutorial, if for a beginner) | how-to-guides.md / tutorials.md |
| Tables of every option, signature, error | reference | reference.md |
| Hand-held, guaranteed-to-work walkthrough | tutorial | tutorials.md |

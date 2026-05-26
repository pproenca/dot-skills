---
title: Classify the question before searching — changelog, reference, idiom, or known-bug
tags: src, source-selection, classification
---

## Classify the question before searching — changelog, reference, idiom, or known-bug

By default the agent treats "I need to look this up" as "open the docs and search." This produces a Google-style scan that lands on the API reference even when the answer is in the changelog, a guide, or a GitHub issue. The move is to **classify the question first** — five categories, each pointing to a different doc section. The classification takes seconds and saves the wrong-page-read tax.

```text
Question type            First place to look
─────────────────────────────────────────────────────────────────────
Reference                API reference page for the resource/hook/component
  "What does X return?"  e.g. /docs/api/<resource>, /docs/<hook-name>
  "What are X's params?"

Changelog                Changelog or release notes
  "Did X change?"        e.g. /changelog, /releases, github releases tab
  "Why broken since N→M?"

Idiom                    Examples dir / samples repo / cookbook
  "How should I do X?"   e.g. github.com/<author>/<lib>/tree/main/examples
  "What's the right way?"  e.g. <lib>-samples repo, /docs/recipes

Known-bug                GitHub issues, status page, Discord/forum
  "Docs say X but Y"     e.g. github.com/<author>/<lib>/issues
  "This isn't working"     status.<lib>.com, community.<lib>.com

Migration                Upgrade guide / breaking changes doc
  "Move from N to M"     e.g. /docs/upgrades, /docs/migrating-to-vN

If unclassifiable:        ASK THE USER what they actually want before
                          scanning the docs. The classification IS the spec.
```

Apply before opening any doc page: name the question type out loud (even silently), then open the matching section. If you find yourself on the reference page for a "did X change?" question, stop — you are reading the wrong section. The cheapest way to misuse documentation is to land on a page that *could* contain the answer but doesn't.

Reference: [Diátaxis documentation framework — reference / how-to / explanation / tutorial as the canonical doc-section taxonomy](https://diataxis.fr/)

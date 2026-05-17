# Sections

This skill is a **topic-organized editorial reference** distilled from the Apple Style Guide (June 2025). Unlike a code-style distillation skill (where each file is one rule with Incorrect/Correct code examples), each file here is a **topic catalog** containing 20-200 short usage entries.

The "section ID" column below identifies the topic catalog. Files are named with topic-descriptive slugs rather than rule-prefix-name.md.

---

## 1. Voice & Tone (voice)

**Impact:** CRITICAL
**Description:** Active voice, present tense, second person. Verb-usage entries (*activate*/*turn on*, *appear* not *display*, *click* vs *tap*, contractions, future tense). The most-consulted topic for any user-facing prose.

## 2. Punctuation (punct)

**Impact:** HIGH
**Description:** Periods, commas (serial), em dashes, en dashes, ellipses, parentheses, brackets, apostrophes, quotation marks, slashes, ampersands, colons, semicolons. Apple deviates from Chicago in a few specific places — those exceptions are called out inline.

## 3. Capitalization (caps)

**Impact:** HIGH
**Description:** Sentence-style for headings (not title case), proper-noun handling, exceptions for product names, chapter, command names.

## 4. Hyphenation & Compounds (hyph)

**Impact:** HIGH
**Description:** Compound modifiers preceding a noun get hyphens (*user-friendly app*); following the verb they don't (*the app is user friendly*). Prefix rules (*e-*, *re-*, *non-*, *pre-*, *anti-*). The `(adj.)` / `(pred. adj.)` notation throughout the source maps to this topic.

## 5. Numbers & Dates (nums)

**Impact:** HIGH
**Description:** When to spell out numbers, ranges, ordinals, fractions, percentages, time of day, dates, days of week, decades, *2D/3D*, *2K/4K/8K*, *24/7*. The *generation* entry.

## 6. Units of Measure (units)

**Impact:** MEDIUM
**Description:** Spell-out rules, hyphenation in compound modifiers (*17-inch display*), SI prefix table, full unit/symbol reference (GB, MHz, mm, etc.).

## 7. Word Choice & Confusables (word)

**Impact:** HIGH
**Description:** Pairs and triples like *affect/effect*, *assure/ensure/insure*, *backup/back up*, *login/log in*, *setup/set up*, *email* (not *e-mail*), *online* (not *on-line*), *OK* (not *okay*). The largest catalog of one-off term decisions.

## 8. Abbreviations & Acronyms (abbr)

**Impact:** MEDIUM
**Description:** When to spell out, when to use articles (*a* vs *an*), file types, plurals, pronunciation. Includes industry acronyms (URL, ISP, JPEG, WYSIWYG, USB, etc.) but not Apple product abbreviations.

## 9. UI Elements (ui)

**Impact:** HIGH
**Description:** Button, action sheet, popover, share sheet, sidebar, status bar, menu bar, More button, disclosure arrow, side button, top button, slider, stepper, switch, checkbox, radio button, text field, dialog, etc. — how to refer to onscreen controls.

## 10. Apple Products (apple-hw)

**Impact:** MEDIUM
**Description:** Hardware names: iPhone, iPad, Mac, MacBook (Air/Pro), iMac, Mac Studio, Mac Pro, Mac mini, Apple Watch, Apple TV, AirPods (and variants), HomePod, AirTag, Apple Pencil, Magic Keyboard/Mouse/Trackpad, Studio Display, Pro Display XDR, Vision Pro, M-series and A-series chips, etc.

## 11. Apple Features & Software (apple-sw)

**Impact:** MEDIUM
**Description:** macOS, iOS, iPadOS, watchOS, tvOS, visionOS, iCloud, Apple Music, Apple TV+, Apple Pay, App Store, iMessage, FaceTime, Siri, AirPlay, AirDrop, Apple Intelligence, Genmoji, Active Noise Cancellation, Focus, Spotlight, Stage Manager, Live Text, Find My, Family Sharing, Face ID, Touch ID, and all OS features / built-in apps.

## 12. Technical Notation (tech)

**Impact:** MEDIUM
**Description:** Developer-doc-only conventions: code font usage, syntax descriptions with `[brackets]` for optional, italicized placeholder names (`sourceFile`), don't-use-function-names-as-verbs.

## 13. International Style (intl)

**Impact:** MEDIUM
**Description:** ISO 3166 country codes, ISO 4217 currency codes, ISO 8601 dates, ISO 639 language codes, ITU-T E.123 telephone numbers, SI units. Apply when content will be localized.

---

## A-Z Lookup

For single-term lookups, see [a-z-lookup.md](a-z-lookup.md) — alphabetical index of all 870+ entries pointing to the relevant topic catalog.

## Note on validator misfit

This skill's content shape (editorial micro-entries in topic catalogs) doesn't match the dev-skill validator's expected distillation schema (one rule per file with code-block examples). The validator will flag missing frontmatter and missing code blocks on each topic file — those flags are accurate for code-style skills and inappropriate here. See [../gotchas.md](../gotchas.md) for the full note.

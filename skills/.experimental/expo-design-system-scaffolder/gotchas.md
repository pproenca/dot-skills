# Gotchas

Append failure points as they are discovered, with dates.

## 2026-05-22 — Web parity: `_web` cursor only on interactive templates

The pressable primitive, form field, and list row emit a Unistyles `_web` block (`cursor`,
`_hover`, `_focus`). Do **not** add a pointer cursor to the card or text primitive — a hand cursor
on a non-clickable surface misleads web users (`platform-web-pseudo-states` "When NOT to use").
Caveat: a `Pressable`'s `cursor` stays `pointer` even when `disabled` on React Native Web; if that
matters for a given component, override `cursor: 'default'` in the disabled path.

# Gotchas

Real failure points discovered while building and reviewing this skill. Newest first.

Format:

```markdown
### <Short title of the failure point>
What went wrong, why, and how to avoid it.
Added: YYYY-MM-DD
```

### `Specification` comes before `Rationale` in PEP 12
It is tempting to justify the design (Rationale) before specifying it. The canonical
PEP 12 order is Abstract → Motivation → **Specification → Rationale** → Backwards
Compatibility. Describe *what* you propose, then *why*. The template and `sections.md`
follow this order.
Added: 2026-05-21

### Empty header lines can fool a naive linter
The template ships every optional field as an empty `Field:` line (e.g. `Resolution:`).
A linter that checks only for the field *name* will report it present, giving false
assurance. `check-pep.sh` uses a value-aware `has_value()` so empty scaffold lines do
not satisfy the conditional checks (Resolution, Discussions-To, Python-Version).
Added: 2026-05-21

### `date +%b` is locale-sensitive
PEP 1 requires the English three-letter month in `Created` (e.g. `21-May-2026`). Under
a non-English locale (`LC_TIME=fr_FR`), `date +%b` yields `mai`, which is wrong and even
fails `check-pep.sh`'s own `dd-mmm-yyyy` regex. `new-pep.sh` forces `LC_ALL=C` on the
date call.
Added: 2026-05-21

### Multiple authors need RFC 2822 continuation lines
A single `Author: A, B` line is invalid — each author goes on its own continuation line
indented 8 spaces. Pass `--author "A <a@x>, B <b@y>"` (comma-separated); `new-pep.sh`
splits them onto continuation lines automatically.
Added: 2026-05-21

### `Python-Version` is Standards Track only
Setting `Python-Version` on a Process or Informational PEP is wrong. `new-pep.sh` errors
if `--python-version` is combined with a non-Standards-Track `--type`, and `check-pep.sh`
warns if the header has a value on a non-Standards-Track PEP.
Added: 2026-05-21

### `Created` is the date a number is assigned, not the draft date
PEP 1 defines `Created` as the date the PEP was assigned a number (at editor approval),
which may be later than when you scaffold the file. `new-pep.sh` stamps today and prints
a reminder to update it if the number is assigned on a different date.
Added: 2026-05-21

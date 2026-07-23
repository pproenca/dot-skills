# Gotchas

### Detectors gated on `useForm()` go blind on the recommended architecture
Rules 13, 15 and 16 used to live inside a loop over `useForm()` call sites, and the file
loop did `if (useFormCalls.length === 0) continue;`. Because the companion distillation
skill tells authors to move field arrays and context consumers into child components that
take `control` as a prop, those files contain no `useForm()` — so an identical `key={index}`
violation was caught in the parent form and missed in the child. Verified with two fixtures
differing only in whether the component called `useForm()`. Rules 13/15/16 now run at file
level. Check the scope of any new detector against a child-component fixture, not just a
whole-form one.
Added: 2026-07-23

### Rule 04 fired CRITICAL on correct code and failed CI
`rhf-audit-04-useeffect-depends-useform` claimed the `useForm()` return is a new reference
each render. It is not: `useForm` returns `_formControl.current` (a `useRef`) and mutates
`formState` onto it, so `useEffect(..., [form])` never loops. The detector was CRITICAL, so
`audit.sh` exited 1 on code that was fine. Removed in 0.2.0; rule ID 04 is retired and must
not be reused. Verify a detector's premise against the shipped library before assigning it a
CI-failing severity.
Added: 2026-07-23

Append further findings below as the skill is used in real projects.

Format:

```
### {Short title}
{What goes wrong and how to avoid it. Be specific — exact command, exact error.}
Added: YYYY-MM-DD
```

# Gotchas

Living log of diagnostic lessons accumulated from pre-member conversion incidents.
Every entry is dated, describes a concrete surprise or failure mode, and records the
resolution. Append new entries at the top. Never delete entries — older lessons still
carry context even when the specific code they refer to has changed.

## Format

```markdown
### Short descriptive title of the surprise
Date: YYYY-MM-DD
Context: what the team was working on
Symptom: what the observable failure mode was
Root cause: what was actually wrong
Resolution: how the team fixed it
Lesson: the generalisable takeaway
```

---

### Example seed: geo-IP fallback trapped Spanish visitors in an English experience
Date: 2026-04-12
Context: Worked example illustrating the gotchas convention — replace when a real one is captured.
Symptom: Conversion rate from Spanish-speaking anonymous traffic dropped 30% over a weekend.
Root cause: A geo-IP library upgrade lowered the confidence threshold for country detection. Spanish visitors routed via Amazon CDN edge in Dublin were being classified as Irish with high confidence, served English-only content, and bouncing.
Resolution: Reverted the confidence-threshold change, added an explicit "is this your country?" chooser when the language of the `Accept-Language` header contradicts the geo-IP result.
Lesson: Geo-IP confidence alone is not enough — cross-check with `Accept-Language`, and surface a correction UI when signals disagree. Related rule: `signal-infer-geography-with-confidence`.

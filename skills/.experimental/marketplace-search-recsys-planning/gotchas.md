# Gotchas

Living log of diagnostic lessons accumulated from marketplace search and recsys work.
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

### Example seed: analyzer mismatch caused silent zero-result spike
Date: 2026-04-11
Context: Worked example illustrating the gotchas convention — replace when a real one is captured.
Symptom: Zero-result rate jumped from 4% to 14% over a weekend on queries containing common plurals ("sitters", "walks", "stays").
Root cause: A well-intentioned mapping change dropped the `english` analyzer from the title field, reverting to the standard analyzer which does not stem. Plurals stopped matching singular-form listing titles.
Resolution: Reverted the mapping change, scheduled a reindex, and added a post-release RBO churn check that would have caught the silent drift within an hour of deploy (see `monitor-track-ranking-stability-churn`).
Lesson: Analyzer changes on text fields are effectively ranking changes and belong in the decisions log with a golden-set offline evaluation before deploy.

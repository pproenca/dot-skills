---
title: Make Optional Questions Genuinely Skippable and Log the Skip
impact: HIGH
impactDescription: preserves the "did not answer" signal instead of destroying it
tags: wizard, skippable, missing, optional, negative-signal
---

## Make Optional Questions Genuinely Skippable and Log the Skip

A wizard that forces a default answer ("Any" for pet size, "No preference" for dates) silently fills the feature store with a value the sitter did not mean — the model cannot distinguish a genuine "I'm flexible" from "I didn't bother". Make optional questions truly skippable, record the skip as its own categorical value (`ANSWERED / SKIPPED / NOT_SHOWN`), and treat the distinction as feature signal: sitters who actively chose "any" are different from sitters who skipped. A forced default destroys the difference.

**Incorrect (pre-selected default that becomes a silent default):**

```python
def wizard_question_willing_pet_sizes() -> dict:
    return {
        "id": "willing_pet_sizes",
        "type": "multi_select",
        "options": ["small", "medium", "large"],
        "default": ["small", "medium", "large"],  # pre-checked
        "required": False,
    }
# everyone has all three ticked; feature is constant across 80% of sitters
```

**Correct (no default, explicit skip state logged):**

```python
def wizard_question_willing_pet_sizes() -> dict:
    return {
        "id": "willing_pet_sizes",
        "type": "multi_select",
        "options": ["small", "medium", "large"],
        "default": None,         # nothing pre-checked
        "required": False,
        "allow_skip": True,      # skip button present, not just "submit without choosing"
    }

def extract_answer(event: WizardEvent) -> dict:
    if event.action == "skip":
        return {"willing_pet_sizes": None, "willing_pet_sizes_state": "SKIPPED"}
    if event.action == "not_shown":
        return {"willing_pet_sizes": None, "willing_pet_sizes_state": "NOT_SHOWN"}
    return {"willing_pet_sizes": event.selected, "willing_pet_sizes_state": "ANSWERED"}

# downstream u2i model uses both the value AND the state; skip is informative.
```

Reference: [Nielsen Norman Group — Required Fields in Web Forms](https://www.nngroup.com/articles/required-fields/)

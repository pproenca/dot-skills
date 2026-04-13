---
title: Capture Experience as Counts and Dates, Not Adjectives
impact: HIGH
impactDescription: prevents aspirational self-rating that flattens the feature
tags: wizard, experience, counts, dates
---

## Capture Experience as Counts and Dates, Not Adjectives

"Experienced with dogs" is a string that tells the ranker almost nothing. "3 completed stays with dogs in the last 12 months, last stay 6 weeks ago" is five numeric features a model can learn on directly. When asking about experience in the wizard, ask for counts (how many times) and dates (when most recent), not adjectives. Pull what you already know from the platform's own history where possible — a sitter who already has 20 completed stays should not have to self-declare "experienced" because the platform can compute that feature.

**Incorrect (self-declared adjective):**

```python
def wizard_question_experience() -> dict:
    return {
        "id": "experience_level",
        "type": "single_select",
        "prompt": "How experienced are you with pets?",
        "options": ["beginner", "some experience", "experienced", "very experienced"],
    }
    # everyone picks "experienced" — the option is aspirational, not factual
```

**Correct (counts + dates, cross-checked with platform history):**

```python
def wizard_questions_experience() -> list[dict]:
    return [
        {
            "id": "previous_stays_count_self_declared",
            "type": "number",
            "prompt": "How many pet sits have you done (anywhere)?",
            "range": [0, 500],
            "required": False,
        },
        {
            "id": "pet_years_experience",
            "type": "number",
            "prompt": "How many years have you lived with pets?",
            "range": [0, 80],
            "required": False,
        },
    ]

def derive_experience_features(sitter: Sitter) -> dict:
    # platform-derived features take precedence; self-declared fills the gap for new sitters
    return {
        "ths_completed_stays_all_time": sitter.stats.completed_stays,
        "ths_completed_stays_last_12m": sitter.stats.completed_stays_12m,
        "ths_last_stay_days_ago": sitter.stats.last_stay_days_ago,
        "self_declared_stays": sitter.wizard.previous_stays_count_self_declared,
        "self_declared_pet_years": sitter.wizard.pet_years_experience,
    }
```

Reference: [Google — Rules of Machine Learning, Rule #19: Use very specific features when you can](https://developers.google.com/machine-learning/guides/rules-of-ml)

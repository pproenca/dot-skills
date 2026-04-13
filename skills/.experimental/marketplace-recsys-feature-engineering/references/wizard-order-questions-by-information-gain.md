---
title: Order Wizard Questions by Information Gain
impact: HIGH
impactDescription: 2-3x feature usefulness per completed wizard question
tags: wizard, information-gain, ordering, onboarding
---

## Order Wizard Questions by Information Gain

A sitter onboarding wizard is a finite sequence — after 5-7 questions, drop-off accelerates and every subsequent question collects signal from a smaller and smaller cohort. Order questions by the information gain each one provides over the features you are trying to build: the question that splits the sitter population most evenly on the primary u2i outcome (would they accept this listing?) goes first, the next most discriminative goes second, and so on. Asking for favourite colour before pet experience is not a mistake of taste — it is a feature-engineering failure that costs you the majority of your data on the most valuable question.

**Incorrect (arbitrary order, most important question is question 8):**

```python
WIZARD_QUESTIONS = [
    "name",
    "age_bracket",
    "languages_spoken",
    "hometown",
    "reason_for_joining",          # narrative, low signal
    "favourite_travel_destination", # narrative, low signal
    "allergies",
    "pet_experience_species",       # the most discriminative feature, asked 8th
    "pet_experience_years",
]
```

**Correct (ranked by information gain over u2i acceptance):**

```python
# Offline: compute mutual information between each candidate question and the outcome
# outcome = "sitter requested a listing with this pet species AND the owner accepted"
INFORMATION_GAIN = {
    "pet_experience_species": 0.42,
    "available_dates_next_90d": 0.31,
    "willing_countries": 0.24,
    "experience_count": 0.19,
    "home_situation": 0.11,
    "languages_spoken": 0.05,
    "age_bracket": 0.03,
    "name": 0.00,  # identity, not predictive
}

WIZARD_QUESTIONS = [
    "pet_experience_species",     # question 1: highest gain
    "available_dates_next_90d",
    "willing_countries",
    "experience_count",
    "home_situation",
    # stop here — the remaining questions can live in a later "enrich your profile" screen
]
```

Reference: [Nielsen Norman Group — Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)

---
title: Prefer Multiple-Choice over Free Text in the Wizard
impact: HIGH
impactDescription: prevents downstream NLP cost and training-serving drift
tags: wizard, multiple-choice, free-text, categorical
---

## Prefer Multiple-Choice over Free Text in the Wizard

Every free-text answer in the onboarding wizard is a downstream NLP problem — you either run an encoder on it (drift, cost, latency) or you ignore it (waste). Multiple-choice answers with a fixed vocabulary become categorical features by construction, are always serveable, and produce deterministic training-serving parity. Convert free-text questions to multiple-choice wherever the answer space is bounded, and reserve free text only for genuinely open-ended prompts like introduction paragraphs where the text itself is displayed to the other side of the marketplace.

**Incorrect (free text for a bounded-vocabulary question):**

```python
def wizard_question_pet_experience() -> dict:
    return {
        "id": "pet_experience",
        "type": "free_text",
        "prompt": "Tell us about your experience with pets",
    }
    # answers: "lots", "grew up with dogs", "5 years volunteering at a shelter", "since 2019"
    # the downstream model has to normalise this string at training and inference
```

**Correct (multiple-choice with a versioned vocabulary):**

```python
def wizard_question_pet_experience_species() -> dict:
    return {
        "id": "pet_experience_species_v2",  # versioned for vocabulary changes
        "type": "multi_select",
        "prompt": "Which pet species have you cared for before?",
        "options": [
            {"value": "dog_small", "label": "Small dogs (under 10kg)"},
            {"value": "dog_medium", "label": "Medium dogs (10-25kg)"},
            {"value": "dog_large", "label": "Large dogs (over 25kg)"},
            {"value": "cat", "label": "Cats"},
            {"value": "rabbit", "label": "Rabbits"},
            {"value": "reptile", "label": "Reptiles"},
            {"value": "bird", "label": "Birds"},
            {"value": "farm_animal", "label": "Farm animals"},
        ],
        "min_select": 0,  # skippable, but the options are the full vocabulary
    }
```

Reference: [Nielsen Norman Group — Required Fields in Web Forms](https://www.nngroup.com/articles/required-fields/)

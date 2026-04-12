---
title: Meet the AWS Personalize Minimum Dataset Sizes Before Training
impact: HIGH
impactDescription: prevents training on below-threshold data
tags: schema, prerequisites, minimums
---

## Meet the AWS Personalize Minimum Dataset Sizes Before Training

AWS Personalize has hard minimums for solution training: 50 users, 50 items, and 1000 active interactions at the time the solution version is created. Below this, training may succeed but produces essentially random recommendations that obscure whether the architecture is correct. For a new surface, the first milestone is collecting enough data to clear the minimums — not tuning the first model. Gating training on a dataset-size check turns a silent "why is the model terrible" debugging session into an explicit "not enough data yet" message.

**Incorrect (training kicked off regardless of dataset size):**

```python
def train_homefeed_solution() -> None:
    personalize.create_solution_version(
        solutionArn=SOLUTION_ARN,
        trainingMode="FULL",
    )
```

**Correct (gate training on dataset minimums with explicit reporting):**

```python
def train_homefeed_solution() -> None:
    stats = dataset_stats.fetch(DATASET_GROUP_ARN)
    required = {"users": 50, "items": 50, "active_interactions": 1_000}
    missing = {
        key: required[key] - getattr(stats, key)
        for key in required
        if getattr(stats, key) < required[key]
    }
    if missing:
        logger.info(f"Dataset below training minimums; waiting on: {missing}")
        return
    personalize.create_solution_version(
        solutionArn=SOLUTION_ARN,
        trainingMode="FULL",
    )
```

Reference: [Amazon Personalize Cheat Sheet — Insufficient Data Pitfall](https://github.com/aws-samples/amazon-personalize-samples/blob/master/PersonalizeCheatSheet2.0.md)

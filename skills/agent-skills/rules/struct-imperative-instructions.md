---
title: Write Instructions in Imperative Mood
impact: HIGH
impactDescription: reduces instruction ambiguity by 50%
tags: struct, grammar, clarity, instructions
---

## Write Instructions in Imperative Mood

Use direct commands like "Extract text" rather than passive constructions like "Text should be extracted". Imperative mood creates unambiguous instructions that Claude executes consistently.

**Incorrect (passive and conditional language):**

```markdown
# PDF Processor

## Instructions
Text could be extracted from the PDF if needed. Users may request
tables to be parsed. It would be good to validate the output format.
Forms may need to be filled based on user requirements.
```

```text
# "could be", "may want", "would be good", "may need"
# All introduce ambiguity about when to act
# Claude may or may not perform these actions
```

**Correct (direct imperative commands):**

```markdown
# PDF Processor

## Instructions
1. Extract all text from the PDF document
2. Parse tables and preserve their structure
3. Validate output format before returning
4. Fill form fields when the user provides values
```

```text
# "Extract", "Parse", "Validate", "Fill"
# Clear commands with no ambiguity
# Claude executes each instruction
```

**Transform passive to imperative:**
| Passive/Conditional | Imperative |
|---------------------|------------|
| Text should be extracted | Extract text |
| It would be helpful to validate | Validate |
| "The user may request" | When user requests, |
| Consider checking | Check |

Reference: [Prompt Engineering Guide](https://www.promptingguide.ai/)

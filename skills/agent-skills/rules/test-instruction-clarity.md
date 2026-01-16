---
title: Test Instructions with Fresh Context
impact: MEDIUM
impactDescription: prevents 30-50% of instruction misinterpretations
tags: test, clarity, instructions, fresh-context
---

## Test Instructions with Fresh Context

Test your skill at the start of a new conversation, without any prior context. Instructions that seem clear after extensive development may be ambiguous to Claude seeing them for the first time.

**Incorrect (tested only in development context):**

```markdown
# Code Formatter - SKILL.md

## Instructions
Format the code using the settings we discussed.
Apply the rules from the configuration.
Use the standard approach for this project.
```

```text
# During development, these made sense
# New conversation: "what settings?"
# New conversation: "what configuration?"
# New conversation: "what standard approach?"
# Claude has no context for these references
```

**Correct (self-contained instructions):**

```markdown
# Code Formatter - SKILL.md

## Instructions
Format code using Prettier with these settings:
- printWidth: 100
- tabWidth: 2
- singleQuote: true
- trailingComma: 'es5'

## Process
1. Read the target file
2. Apply Prettier formatting
3. Write formatted output back
4. Report changes made

## Default Behavior
If no specific style requested, use the Prettier defaults above.
```

```text
# All context self-contained
# No references to "previous discussion"
# No "as mentioned before"
# Works in any conversation
```

**Testing checklist:**
- [ ] Start new Claude Code session
- [ ] Trigger skill with simple request
- [ ] Verify Claude follows instructions without asking clarifying questions
- [ ] Check output matches expected format
- [ ] Repeat with 3 different simple requests

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

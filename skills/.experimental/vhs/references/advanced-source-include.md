---
title: Use Source for Reusable Tape Components
impact: LOW
impactDescription: enables DRY patterns across multiple tapes
tags: advanced, source, include, reuse, modularity
---

## Use Source for Reusable Tape Components

Use the `Source` command to include commands from another tape file. This enables reusable setup sequences, consistent styling, and modular tape organization.

**Incorrect (duplicating setup across tapes):**

```tape
# demo1.tape
Output demo1.gif
Set Shell "bash"
Set FontSize 32
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Require mycli
Type "mycli feature1"
Enter
```

```tape
# demo2.tape (duplicated settings)
Output demo2.gif
Set Shell "bash"
Set FontSize 32
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Require mycli
Type "mycli feature2"
Enter
```

**Correct (shared configuration):**

```tape
# _common.tape (shared settings, no Output)
Set Shell "bash"
Set FontSize 32
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 50ms
Require mycli
```

```tape
# demo1.tape
Output demo1.gif
Source _common.tape
Type "mycli feature1"
Enter
Sleep 3s
```

```tape
# demo2.tape
Output demo2.gif
Source _common.tape
Type "mycli feature2"
Enter
Sleep 3s
```

**Use cases:**
- Shared visual styling across all project demos
- Common setup sequences (cd, source .env, etc.)
- Reusable demonstration patterns

Reference: [VHS README - Source](https://github.com/charmbracelet/vhs#source)

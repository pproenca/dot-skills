---
title: Record Live Sessions Then Edit
impact: LOW
impactDescription: 2-5× faster tape creation for complex workflows
tags: advanced, record, live, editing, workflow
---

## Record Live Sessions Then Edit

Use `vhs record` to capture a live terminal session, then edit the generated tape file to perfect timing and remove mistakes. This is faster than writing tape files from scratch for complex workflows.

**Incorrect (writing from scratch):**

```tape
# Manually writing every command and timing
Output demo.gif
Set Shell "bash"

Type "cd myproject"
Enter
Sleep 500ms
Type "ls -la"
Enter
Sleep 1s
# Tedious for complex multi-step workflows
# Hard to get natural timing right
```

**Correct (record then polish):**

```bash
# Step 1: Record live session
vhs record > draft.tape

# Step 2: Edit the generated tape
vim draft.tape
```

```tape
# draft.tape after editing
Output demo.gif
Set Shell "bash"
Set FontSize 32

Type "cd myproject"
Enter
Sleep 500ms

Type "ls -la"
Enter
Sleep 1s

Type "npm start"
Enter
Sleep 3s
```

**Benefits:**
- Natural command flow from real interaction
- Captures realistic timing baseline
- Edit out mistakes and dead time
- Add proper settings and output declarations

Reference: [VHS README - Recording](https://github.com/charmbracelet/vhs#recording)

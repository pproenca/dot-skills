---
title: Generate Multiple Output Formats
impact: MEDIUM
impactDescription: single render produces all needed formats
tags: output, formats, efficiency, workflow
---

## Generate Multiple Output Formats

Specify multiple `Output` commands to generate several formats in a single render pass. This is more efficient than running VHS multiple times and ensures all outputs are identical.

**Incorrect (separate renders for each format):**

```bash
# Running VHS multiple times
vhs demo-gif.tape   # Contains: Output demo.gif
vhs demo-mp4.tape   # Contains: Output demo.mp4
vhs demo-webm.tape  # Contains: Output demo.webm
# Inefficient, may produce inconsistent results
```

**Correct (single tape, multiple outputs):**

```tape
# Generate all formats in one pass
Output demo.gif
Output demo.mp4
Output demo.webm
Output frames/  # PNG sequence for custom processing

Set Shell "bash"
Set FontSize 32
Set Width 1200
Set Height 600

Type "mycli demo"
Enter
Sleep 5s
```

**Organize outputs by directory:**

```tape
Output assets/gifs/demo.gif
Output assets/videos/demo.mp4
Output assets/videos/demo.webm
```

Reference: [VHS README - Output](https://github.com/charmbracelet/vhs#output)

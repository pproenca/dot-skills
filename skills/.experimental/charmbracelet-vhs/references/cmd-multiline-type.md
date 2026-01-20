---
title: Handle Multiline Commands Properly
impact: MEDIUM
impactDescription: prevents broken command entry in recordings
tags: cmd, type, multiline, continuation
---

## Handle Multiline Commands Properly

For multiline commands, use the shell's line continuation character (`\`) followed by `Enter`, then continue typing. Don't try to include newlines directly in the `Type` string.

**Incorrect (newline in Type string):**

```tape
Type "docker run -d \
  -p 8080:80 \
  nginx"
Enter
# Parsing error or unexpected behavior
```

**Correct (explicit line continuation):**

```tape
Type "docker run -d \"
Enter
Type "  -p 8080:80 \"
Enter
Type "  -v ./html:/usr/share/nginx/html \"
Enter
Type "  nginx:latest"
Enter
```

**Alternative (single long line):**

```tape
Type "docker run -d -p 8080:80 -v ./html:/usr/share/nginx/html nginx:latest"
Enter
# Works but may be hard to read if terminal is narrow
```

**For heredocs:**

```tape
Type "cat << 'EOF'"
Enter
Type "line 1"
Enter
Type "line 2"
Enter
Type "EOF"
Enter
```

Reference: [VHS README - Type](https://github.com/charmbracelet/vhs#type)

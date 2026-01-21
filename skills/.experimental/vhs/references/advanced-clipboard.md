---
title: Use Copy and Paste for Complex Input
impact: LOW
impactDescription: simplifies long or complex text entry
tags: advanced, copy, paste, clipboard, input
---

## Use Copy and Paste for Complex Input

Use `Copy` and `Paste` commands to handle long URLs, complex commands, or text that would be tedious to type character by character.

**Incorrect (typing long URLs):**

```tape
Type "git clone https://github.com/charmbracelet/very-long-repository-name.git"
Enter
# Slow typing for a URL viewers don't need to read character-by-character
```

**Correct (copy/paste for long text):**

```tape
Copy "https://github.com/charmbracelet/very-long-repository-name.git"
Type "git clone "
Paste
Enter
```

**Demonstrating clipboard workflows:**

```tape
# Show copying from command output
Type "mycli generate-token"
Enter
Sleep 1s
# Simulating copy from output
Copy "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

Type "curl -H 'Authorization: Bearer "
Paste
Type "' https://api.example.com"
Enter
```

**When to use:**
- Long URLs (> 50 characters)
- API keys or tokens
- Complex JSON or configuration strings
- Demonstrating paste workflows

Reference: [VHS README - Clipboard](https://github.com/charmbracelet/vhs#copy--paste)

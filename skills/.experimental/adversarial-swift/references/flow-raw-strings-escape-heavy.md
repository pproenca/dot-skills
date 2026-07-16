---
title: Write escape-heavy literals as raw strings
tags: flow, strings, raw-strings, literals
---

## Write escape-heavy literals as raw strings

The wrong default for JSON fixtures, regex patterns, and Windows-style paths is a literal full of `\"` and `\\` escapes. Escape soup is where literal-content bugs hide — a miscounted backslash silently changes the string (worst inside regex patterns), and a reviewer cannot visually diff the intended content against its escaped form. A `#"..."#` raw string carries the content verbatim, and the `\#()` form keeps interpolation available when needed.

**Evidence of violation:** a string literal containing two or more escaped double quotes (`\"`) or escaped backslashes (`\\`) with no interpolation present, or where the `\#()` extended delimiter form would serve the interpolation. PASS: literals with a single incidental escape, or literals that only need plain `\n`/`\t` escapes. N/A: the target introduces no string literals with quote or backslash escapes.

**Incorrect (escaped — the literal's real content must be mentally un-escaped):**

```swift
let jsonString = """
{\"name\": \"John\", \"age\": 30, \"city\": \"New York\"}
"""
```

**Correct (raw string — the content reads exactly as it is):**

```swift
let rawJsonString = #"{"name": "John", "age": 30, "city": "New York"}"#
```

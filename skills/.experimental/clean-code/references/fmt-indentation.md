---
title: Respect Indentation Rules
impact: MEDIUM
impactDescription: preserves visual hierarchy for quick scanning
tags: fmt, indentation, hierarchy, structure
---

## Respect Indentation Rules

Indentation makes the scope hierarchy visible. Each level of indentation represents a nested scope. Never collapse short statements onto one line to save space.

**Incorrect (collapsed structure):**

```java
public class CommentWidget extends TextWidget {
public CommentWidget(ParentWidget parent, String text) { super(parent, text); }
public String render() throws Exception { return ""; }
}

public void process() { for (int i = 0; i < 10; i++) { if (valid(i)) { execute(i); } } }

if (condition) return false; else return true;
```

**Correct (proper indentation):**

```java
public class CommentWidget extends TextWidget {

    public CommentWidget(ParentWidget parent, String text) {
        super(parent, text);
    }

    public String render() throws Exception {
        return "";
    }
}

public void process() {
    for (int i = 0; i < 10; i++) {
        if (valid(i)) {
            execute(i);
        }
    }
}

if (condition) {
    return false;
} else {
    return true;
}
```

**Why maintain indentation?**
- Visual scanning relies on indentation
- Structure is immediately apparent
- Debugging is easier when scope is visible
- Merges are cleaner with consistent formatting

Reference: [Clean Code, Chapter 5: Formatting](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

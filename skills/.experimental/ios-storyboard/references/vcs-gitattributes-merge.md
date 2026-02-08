---
title: Configure .gitattributes to Use Union Merge for Storyboards
impact: LOW-MEDIUM
impactDescription: reduces merge conflict frequency
tags: vcs, gitattributes, merge-strategy, storyboard
---

## Configure .gitattributes to Use Union Merge for Storyboards

By default, git uses a text-based three-way merge for storyboard files, which produces conflict markers inside XML that Xcode cannot parse. Configuring a merge strategy in `.gitattributes` either prevents automatic merging entirely (binary strategy) or attempts a union merge that accepts both sides. Either approach is safer than the default, which silently corrupts storyboard XML when conflict markers are left in place.

**Incorrect (default merge strategy produces unparseable XML):**

```bash
# .gitattributes — no storyboard-specific configuration
# Git treats .storyboard as text and inserts <<<<<<< markers

# Result after a conflicted merge:
<<<<<<< HEAD
<constraint firstItem="title" firstAttribute="top"
           secondItem="safe-area" secondAttribute="top" constant="16"/>
=======
<constraint firstItem="title" firstAttribute="top"
           secondItem="safe-area" secondAttribute="top" constant="24"/>
>>>>>>> feature/redesign
# Xcode fails to open the storyboard — XML parse error
```

**Correct (binary merge strategy forces manual resolution):**

```bash
# .gitattributes
*.storyboard binary -merge
*.xib binary -merge
```

This tells git to never attempt automatic merging. Any conflict requires the developer to choose one version and re-apply their changes manually, which is safer than corrupted XML.

**Alternative (union merge accepts both sides):**

```bash
# .gitattributes
*.storyboard merge=union
*.xib merge=union
```

Union merge includes lines from both sides without conflict markers. This works when edits are in different scenes but can produce duplicate elements when both sides modify the same scene. Use with caution and always validate the storyboard opens in Xcode after merging.

**Benefits:**

- Binary strategy: guarantees no silent XML corruption from conflict markers
- Union strategy: resolves non-overlapping scene edits automatically
- Both strategies prevent Xcode from encountering unparseable storyboard files

Reference: [gitattributes - Defining a custom merge driver](https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver)

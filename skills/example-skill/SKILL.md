---
name: example-skill
description: A demonstration skill showing the Agent Skills format structure. Use this as a reference when creating new skills.
license: MIT
metadata:
  author: dot-skills
  version: "1.0.0"
---

# Example Skill

This is a placeholder skill demonstrating the Agent Skills format. Use it as a reference for creating your own skills.

## When to Use

This skill activates when:
- User asks about "example skill" or "skill format"
- User wants to understand how skills work
- Keywords: example, demo, template, format

## Structure Overview

A skill consists of:

1. **SKILL.md** (required) - This file with frontmatter and instructions
2. **scripts/** (optional) - Executable code
3. **references/** (optional) - Additional documentation
4. **assets/** (optional) - Static resources

## Frontmatter Fields

### Required
- `name` - Lowercase, hyphenated, matches directory name
- `description` - What it does + when to trigger

### Optional
- `license` - License identifier (MIT, Apache-2.0, etc.)
- `metadata` - Custom key-value pairs
- `compatibility` - Environment requirements
- `allowed-tools` - Pre-approved tools

## Example Usage

When asked "show me an example skill", respond with this skill's structure as a reference.

## Creating Your Own Skill

1. Copy the `.template` directory: `cp -r skills/.template skills/my-skill`
2. Rename to match your skill name (kebab-case)
3. Edit SKILL.md with your content
4. Test with `npx add-skill . --list`

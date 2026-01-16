---
title: Maintain a Changelog for Skill Updates
impact: LOW-MEDIUM
impactDescription: enables users to understand updates before installing
tags: maint, changelog, documentation, updates
---

## Maintain a Changelog for Skill Updates

Keep a CHANGELOG.md file documenting all changes between versions. Users need to understand what changed before updating, especially for breaking changes.

**Incorrect (no changelog):**

```text
skill-directory/
├── SKILL.md
└── metadata.json  # version: "3.0.0"
```

```text
# User on v2.0.0 sees v3.0.0 available
# No information about what changed
# No warning about breaking changes
# Updates blindly, skill breaks their workflow
```

**Correct (changelog with all versions):**

```text
skill-directory/
├── SKILL.md
├── metadata.json
└── CHANGELOG.md
```

```markdown
# Changelog

All notable changes to this skill are documented here.

## [3.0.0] - 2024-02-01

### Breaking Changes
- Output format changed from JSON to YAML
- Minimum Node.js version is now 18

### Added
- Support for TypeScript type generation

### Fixed
- Handle circular references in schemas

## [2.1.0] - 2024-01-15

### Added
- New `--dry-run` flag for preview mode

### Changed
- Improved error messages for invalid inputs

## [2.0.0] - 2024-01-01

### Breaking Changes
- Renamed `generate` command to `create`

### Added
- Batch processing support
```

**Changelog sections:**
| Section | Content |
|---------|---------|
| Breaking Changes | Incompatible changes requiring user action |
| Added | New features |
| Changed | Changes to existing functionality |
| Deprecated | Features to be removed in future |
| Removed | Features removed in this version |
| Fixed | Bug fixes |
| Security | Security-related fixes |

Reference: [Keep a Changelog](https://keepachangelog.com/)

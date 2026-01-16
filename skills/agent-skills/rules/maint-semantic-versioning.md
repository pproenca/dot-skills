---
title: Use Semantic Versioning for Skill Releases
impact: LOW-MEDIUM
impactDescription: enables safe updates and rollbacks
tags: maint, versioning, semver, releases
---

## Use Semantic Versioning for Skill Releases

Track skill versions using semantic versioning (MAJOR.MINOR.PATCH). This allows users to understand update impact and pin to known-working versions when needed.

**Incorrect (no versioning or arbitrary versions):**

```json
{
  "name": "api-generator",
  "version": "latest"
}
```

```text
# No way to know what changed
# Can't pin to specific version
# Breaking changes surprise users
# No rollback path
```

**Correct (semantic versioning):**

```json
{
  "name": "api-generator",
  "version": "2.1.0"
}
```

```markdown
# CHANGELOG.md

## [2.1.0] - 2024-01-15
### Added
- Support for GraphQL endpoints

## [2.0.0] - 2024-01-01
### Changed
- BREAKING: Changed output format from JSON to YAML
- BREAKING: Renamed 'endpoint' parameter to 'path'

## [1.2.3] - 2023-12-15
### Fixed
- Handle paths with special characters
```

**Version increment rules:**
| Change Type | Version | Example |
|-------------|---------|---------|
| Breaking (incompatible) | MAJOR | 1.x.x → 2.0.0 |
| New feature (compatible) | MINOR | 1.1.x → 1.2.0 |
| Bug fix | PATCH | 1.1.1 → 1.1.2 |

**Breaking changes include:**
- Changing output format
- Renaming required parameters
- Removing capabilities
- Changing default behavior

Reference: [Semantic Versioning](https://semver.org/)

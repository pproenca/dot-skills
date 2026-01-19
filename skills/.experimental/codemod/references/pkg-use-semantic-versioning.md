---
title: Use Semantic Versioning for Packages
impact: LOW
impactDescription: enables safe dependency management and updates
tags: pkg, versioning, semver, releases
---

## Use Semantic Versioning for Packages

Follow semantic versioning (semver) for codemod packages. Version numbers communicate compatibility and change scope to consumers.

**Incorrect (arbitrary versioning):**

```yaml
# codemod.yaml - meaningless version
schema_version: "1.0"
name: react-migration
version: "42"  # What does this mean?
# Or:
version: "2024.01.15"  # Date-based, no compatibility info
```

**Correct (semantic versioning):**

```yaml
# codemod.yaml - semver
schema_version: "1.0"
name: react-migration
version: "1.2.3"
# 1 = Major (breaking changes to transform behavior)
# 2 = Minor (new features, backward compatible)
# 3 = Patch (bug fixes, no behavior change)
```

**Version bump guidelines:**

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Fix bug in existing pattern | Patch: 1.2.3 → 1.2.4 | Fix edge case handling |
| Add new transformation rule | Minor: 1.2.3 → 1.3.0 | Support new API pattern |
| Change output format | Major: 1.2.3 → 2.0.0 | Different code style |
| Remove pattern support | Major: 1.2.3 → 2.0.0 | Drop legacy format |

**Pre-release versions:**

```yaml
version: "2.0.0-beta.1"  # Pre-release testing
version: "2.0.0-rc.1"    # Release candidate
```

**Publishing workflow:**

```bash
# Validate before version bump
npx codemod jssg test ./transform.ts

# Update version in codemod.yaml
# Commit and tag
git tag v1.2.4
git push --tags

# Publish
npx codemod publish
```

Reference: [Codemod Package Structure](https://docs.codemod.com/package-structure)

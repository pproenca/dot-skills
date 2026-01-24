---
title: Use Snapshot Testing for Fix Verification
impact: LOW-MEDIUM
impactDescription: prevents 95% of rewrite regressions
tags: test, snapshot, fix, verification
---

## Use Snapshot Testing for Fix Verification

Snapshot testing captures expected rewrite output. Use `--update-all` to regenerate snapshots when intentionally changing fixes.

**Incorrect (no fix verification):**

```yaml
id: migrate-import
rule:
  pattern: require($PATH)
fix: import $PATH  # Fix applied but never tested!
```

**Correct (snapshot test for fix):**

```yaml
# tests/migrate-import-test.yml
id: migrate-import
valid:
  - import 'lodash'
invalid:
  - require('lodash')

# Run test to generate snapshot
# ast-grep test -c sgconfig.yml
```

**Generated snapshot file:**

```yaml
# __snapshots__/migrate-import-test.yml.snap
id: migrate-import
snapshots:
  require('lodash'):
    fixed: import 'lodash'
    labels: []
```

**Snapshot workflow:**

```bash
# 1. Write rule with fix
# 2. Write test cases

# 3. Generate initial snapshots
ast-grep test -c sgconfig.yml -U

# 4. Review snapshots in __snapshots__/

# 5. Commit both test and snapshot files

# 6. CI runs tests against snapshots
ast-grep test -c sgconfig.yml
```

**Updating after intentional changes:**

```bash
# After modifying fix template
ast-grep test -c sgconfig.yml --update-all
# Review changes, then commit
```

Reference: [Testing Rules](https://ast-grep.github.io/guide/project/test-rule.html)

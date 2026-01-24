---
title: Test Rewrites on Representative Code
impact: MEDIUM-HIGH
impactDescription: prevents 90% of rewrite bugs
tags: rewrite, testing, validation, safety
---

## Test Rewrites on Representative Code

Always test rewrites with `--interactive` mode on representative samples before running on entire codebase. Edge cases in real code often break assumptions.

**Incorrect (deploys untested rewrite):**

```bash
# Dangerous: applies to entire codebase without verification
ast-grep scan --rule migrate.yml --update-all
```

**Correct (interactive testing first):**

```bash
# Step 1: Test on sample file
ast-grep run -p 'console.log($MSG)' -r 'logger.info($MSG)' sample.js

# Step 2: Interactive review on subset
ast-grep scan --rule migrate.yml --interactive src/module/

# Step 3: Full deployment after confidence
ast-grep scan --rule migrate.yml --update-all
```

**Testing workflow:**

```yaml
# 1. Create test file for rule
# tests/migrate-console-test.yml
id: migrate-console
valid:
  - 'logger.info(msg)'
  - 'console.debug(msg)'  # Should not match
invalid:
  - 'console.log(msg)'
  - 'console.log("test", data)'
```

```bash
# 2. Run rule tests
ast-grep test -c sgconfig.yml

# 3. Dry run on codebase
ast-grep scan --rule migrate.yml  # View matches only

# 4. Interactive apply
ast-grep scan --rule migrate.yml --interactive
```

Reference: [CLI Reference](https://ast-grep.github.io/reference/cli.html)

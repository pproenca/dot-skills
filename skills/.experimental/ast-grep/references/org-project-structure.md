---
title: Use Standard Project Directory Structure
impact: MEDIUM
impactDescription: enables team collaboration and tool discovery
tags: org, project, structure, sgconfig
---

## Use Standard Project Directory Structure

Organize ast-grep projects with standard directories for rules, utilities, and tests. The `sgconfig.yml` file defines project root and directories.

**Incorrect (flat structure, no config):**

```text
project/
├── rule1.yml
├── rule2.yml
├── test1.yml
└── some-code.js
```

**Correct (organized with sgconfig.yml):**

```text
project/
├── sgconfig.yml
├── rules/
│   ├── security/
│   │   └── no-eval.yml
│   └── style/
│       └── prefer-const.yml
├── utils/
│   └── inside-function.yml
└── tests/
    ├── no-eval-test.yml
    └── prefer-const-test.yml
```

**sgconfig.yml example:**

```yaml
ruleDirs:
  - rules
utilsDirs:
  - utils
testConfigs:
  - testDir: tests
```

**Directory purposes:**
- `rules/` - Lint rules that produce diagnostics
- `utils/` - Reusable rule fragments (utility rules)
- `tests/` - Test cases for rule validation

**Initialize with:**

```bash
ast-grep new project  # Creates sgconfig.yml
ast-grep new rule     # Scaffolds rule file
ast-grep new test     # Creates test file
```

Reference: [Tooling Overview](https://ast-grep.github.io/guide/tooling-overview.html)

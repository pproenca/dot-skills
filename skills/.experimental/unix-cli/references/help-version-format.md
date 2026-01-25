---
title: Format Version Output Correctly
impact: MEDIUM
impactDescription: enables automated version detection
tags: help, version, gnu, automation
---

## Format Version Output Correctly

The `--version` output should include the program name, version number, copyright, and license. Follow the GNU format for consistency.

**Incorrect (incomplete version info):**

```c
void print_version(void) {
    printf("v1.2.3\n");  // Missing program name, license
}
```

```bash
$ mytool --version
v1.2.3
# Can't tell which program this is from output alone
```

**Correct (full version information):**

```c
void print_version(void) {
    printf("mytool 1.2.3\n");
    printf("Copyright (C) 2024 Example Corporation\n");
    printf("License MIT: <https://opensource.org/licenses/MIT>\n");
    printf("This is free software: you are free to change and redistribute it.\n");
    printf("There is NO WARRANTY, to the extent permitted by law.\n\n");
    printf("Written by Jane Developer.\n");
}
```

```bash
$ mytool --version
mytool 1.2.3
Copyright (C) 2024 Example Corporation
License MIT: <https://opensource.org/licenses/MIT>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Jane Developer.
```

**Version string format:**
- First line: `PROGRAM VERSION`
- No "v" prefix on version (just `1.2.3`, not `v1.2.3`)
- Semantic versioning recommended
- Exit with status 0 after printing

**For automated parsing:**
```bash
$ mytool --version | head -1 | awk '{print $2}'
1.2.3
```

Reference: [GNU Coding Standards - --version](https://www.gnu.org/prep/standards/html_node/_002d_002dversion.html)

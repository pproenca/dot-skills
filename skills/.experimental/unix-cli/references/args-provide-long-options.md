---
title: Provide Long Options for All Short Options
impact: CRITICAL
impactDescription: improves discoverability and script readability
tags: args, long-options, gnu, usability
---

## Provide Long Options for All Short Options

Every single-letter option should have an equivalent long-form option. Long options are self-documenting in scripts and easier to remember.

**Incorrect (short options only, cryptic in scripts):**

```bash
#!/bin/bash
# What does -q -f -r mean? Reader must check docs
mytool -q -f -r /data
```

```c
while ((opt = getopt(argc, argv, "qfr")) != -1) {
    switch (opt) {
        case 'q': quiet = 1; break;
        case 'f': force = 1; break;
        case 'r': recursive = 1; break;
    }
}
```

**Correct (long options are self-documenting):**

```bash
#!/bin/bash
# Intent is immediately clear
mytool --quiet --force --recursive /data
```

```c
static struct option long_options[] = {
    {"quiet",     no_argument, NULL, 'q'},
    {"force",     no_argument, NULL, 'f'},
    {"recursive", no_argument, NULL, 'r'},
    {NULL, 0, NULL, 0}
};

while ((opt = getopt_long(argc, argv, "qfr", long_options, NULL)) != -1) {
    switch (opt) {
        case 'q': quiet = 1; break;
        case 'f': force = 1; break;
        case 'r': recursive = 1; break;
    }
}
```

**Benefits:**
- Scripts become self-documenting
- Users can guess options (`--verbose`, `--help`, `--version`)
- Reduces trips to man pages

Reference: [GNU Coding Standards](https://www.gnu.org/prep/standards/standards.html)

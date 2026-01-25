---
title: Support Option Bundling
impact: HIGH
impactDescription: matches user expectations from standard UNIX tools
tags: args, bundling, posix, usability
---

## Support Option Bundling

Allow multiple single-letter options to be combined behind one hyphen. This is standard POSIX behavior and users expect it to work.

**Incorrect (requires separate hyphens):**

```c
// Manual parsing that doesn't support bundling
for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "-l") == 0) long_format = 1;
    else if (strcmp(argv[i], "-a") == 0) show_all = 1;
    else if (strcmp(argv[i], "-h") == 0) human_readable = 1;
}
```

```bash
# User expects this to work but it fails
$ mytool -lah
mytool: invalid option -- 'lah'

# User forced to type each separately
$ mytool -l -a -h
```

**Correct (getopt handles bundling automatically):**

```c
int opt;
while ((opt = getopt(argc, argv, "lahvo:")) != -1) {
    switch (opt) {
        case 'l': long_format = 1; break;
        case 'a': show_all = 1; break;
        case 'h': human_readable = 1; break;
        case 'v': verbose = 1; break;
        case 'o': output_file = optarg; break;
    }
}
```

```bash
# All of these work identically
$ mytool -lah
$ mytool -l -a -h
$ mytool -la -h
$ mytool -h -al

# With argument at end
$ mytool -lavo output.txt
```

**Note:** Options with required arguments can appear at the end of a bundle: `-lvo file` means `-l -v -o file`.

Reference: [POSIX Utility Conventions - Guideline 5](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html)

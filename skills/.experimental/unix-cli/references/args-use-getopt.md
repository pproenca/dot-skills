---
title: Use Standard Argument Parsing Libraries
impact: CRITICAL
impactDescription: prevents 90% of argument handling bugs
tags: args, parsing, getopt, posix, library
---

## Use Standard Argument Parsing Libraries

Use `getopt`, `getopt_long`, or equivalent libraries instead of manual argument parsing. These libraries handle edge cases, provide consistent behavior, and generate proper error messages.

**Incorrect (manual parsing, breaks on edge cases):**

```c
int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-v") == 0) {
            verbose = 1;
        } else if (strcmp(argv[i], "-o") == 0) {
            output_file = argv[++i];  // Crashes if -o is last arg
        }
    }
    // Doesn't handle: -vo file, --verbose, -v -o, unknown options
}
```

**Correct (getopt handles all edge cases):**

```c
int main(int argc, char *argv[]) {
    int opt;
    while ((opt = getopt(argc, argv, "vo:")) != -1) {
        switch (opt) {
            case 'v': verbose = 1; break;
            case 'o': output_file = optarg; break;
            default:
                fprintf(stderr, "Usage: %s [-v] [-o file]\n", argv[0]);
                return EXIT_FAILURE;
        }
    }
    // Handles: -vo file, -v -o file, missing arg errors
}
```

**Alternative (getopt_long for GNU-style long options):**

```c
static struct option long_options[] = {
    {"verbose", no_argument, NULL, 'v'},
    {"output", required_argument, NULL, 'o'},
    {NULL, 0, NULL, 0}
};

while ((opt = getopt_long(argc, argv, "vo:", long_options, NULL)) != -1) {
    // Same switch as above, now handles --verbose and --output=file
}
```

Reference: [GNU Coding Standards - Command-Line Interfaces](https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html)

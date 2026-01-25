---
title: Implement --help and --version Options
impact: CRITICAL
impactDescription: required by GNU standards, expected by all users
tags: args, help, version, gnu, required
---

## Implement --help and --version Options

Every CLI must support `--help` and `--version`. These are universally expected and required by GNU Coding Standards. Exit with status 0 after displaying either.

**Incorrect (no help or version support):**

```c
int main(int argc, char *argv[]) {
    // No --help or --version handling
    if (argc < 2) {
        fprintf(stderr, "Error: missing argument\n");
        return 1;  // User has no way to learn usage
    }
    process(argv[1]);
}
```

**Correct (both options implemented properly):**

```c
static void print_help(const char *progname) {
    printf("Usage: %s [OPTIONS] FILE...\n", progname);
    printf("Process files according to specified options.\n\n");
    printf("Options:\n");
    printf("  -v, --verbose    increase verbosity\n");
    printf("  -o, --output=F   write output to F\n");
    printf("  -h, --help       display this help and exit\n");
    printf("      --version    output version information and exit\n");
    printf("\nReport bugs to: bugs@example.com\n");
}

static void print_version(void) {
    printf("mytool 1.0.0\n");
    printf("Copyright (C) 2024 Example Inc.\n");
    printf("License GPLv3+: GNU GPL version 3 or later\n");
}

int main(int argc, char *argv[]) {
    static struct option long_options[] = {
        {"help",    no_argument, NULL, 'h'},
        {"version", no_argument, NULL, 'V'},
        {NULL, 0, NULL, 0}
    };

    int opt;
    while ((opt = getopt_long(argc, argv, "hV", long_options, NULL)) != -1) {
        switch (opt) {
            case 'h': print_help(argv[0]); return EXIT_SUCCESS;
            case 'V': print_version(); return EXIT_SUCCESS;
        }
    }
}
```

**Note:** The `--version` output should include program name, version, copyright, and license. Bug reports go in `--help`.

Reference: [GNU Coding Standards - --version](https://www.gnu.org/prep/standards/html_node/_002d_002dversion.html)

---
title: Structure Help Output Consistently
impact: MEDIUM-HIGH
impactDescription: reduces learning curve for new users
tags: help, documentation, structure, usability
---

## Structure Help Output Consistently

Follow the standard help output structure: synopsis, description, options (with defaults), examples, and where to report bugs.

**Incorrect (unstructured help):**

```c
void print_help(void) {
    printf("mytool - does stuff with files\n");
    printf("-v makes it verbose\n");
    printf("-o is for output\n");
    printf("You can also use -f\n");
}
```

**Correct (well-structured help):**

```c
void print_help(const char *progname) {
    printf("Usage: %s [OPTIONS] FILE...\n", progname);
    printf("Process files and output results.\n\n");

    printf("Options:\n");
    printf("  -f, --format=FMT   output format: text, json, csv (default: text)\n");
    printf("  -o, --output=FILE  write output to FILE (default: stdout)\n");
    printf("  -r, --recursive    process directories recursively\n");
    printf("  -v, --verbose      increase verbosity (can be repeated)\n");
    printf("  -q, --quiet        suppress non-error output\n");
    printf("  -n, --dry-run      show what would be done without doing it\n");
    printf("  -h, --help         display this help and exit\n");
    printf("      --version      output version information and exit\n\n");

    printf("Examples:\n");
    printf("  %s file.txt                Process single file\n", progname);
    printf("  %s -r -o out.json dir/     Process directory recursively\n", progname);
    printf("  %s -v --format=csv *.log   Process logs with verbose CSV output\n\n", progname);

    printf("Report bugs to: https://github.com/example/mytool/issues\n");
}
```

```bash
$ mytool --help
Usage: mytool [OPTIONS] FILE...
Process files and output results.

Options:
  -f, --format=FMT   output format: text, json, csv (default: text)
  -o, --output=FILE  write output to FILE (default: stdout)
  -r, --recursive    process directories recursively
  -v, --verbose      increase verbosity (can be repeated)
  -q, --quiet        suppress non-error output
  -n, --dry-run      show what would be done without doing it
  -h, --help         display this help and exit
      --version      output version information and exit

Examples:
  mytool file.txt                Process single file
  mytool -r -o out.json dir/     Process directory recursively
  mytool -v --format=csv *.log   Process logs with verbose CSV output

Report bugs to: https://github.com/example/mytool/issues
```

Reference: [GNU Coding Standards - --help](https://www.gnu.org/prep/standards/html_node/_002d_002dhelp.html)

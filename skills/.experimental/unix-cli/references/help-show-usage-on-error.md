---
title: Show Brief Usage on Argument Errors
impact: MEDIUM-HIGH
impactDescription: reduces round-trips to documentation
tags: help, usage, errors, usability
---

## Show Brief Usage on Argument Errors

When arguments are missing or invalid, show a brief usage hint along with the error. Don't force users to run `--help` separately.

**Incorrect (error without guidance):**

```c
int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Error: missing file argument\n");
        return 1;
    }
}
```

```bash
$ mytool
Error: missing file argument
# User must now run mytool --help to learn syntax
```

**Correct (error includes usage hint):**

```c
void print_usage_hint(FILE *stream, const char *progname) {
    fprintf(stream, "Usage: %s [OPTIONS] FILE...\n", progname);
    fprintf(stream, "Try '%s --help' for more information.\n", progname);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "%s: missing file operand\n", argv[0]);
        print_usage_hint(stderr, argv[0]);
        return EX_USAGE;
    }

    // Unknown option
    if (unknown_opt) {
        fprintf(stderr, "%s: unrecognized option '%s'\n", argv[0], opt);
        print_usage_hint(stderr, argv[0]);
        return EX_USAGE;
    }
}
```

```bash
$ mytool
mytool: missing file operand
Usage: mytool [OPTIONS] FILE...
Try 'mytool --help' for more information.

$ mytool --badopt
mytool: unrecognized option '--badopt'
Usage: mytool [OPTIONS] FILE...
Try 'mytool --help' for more information.
```

**Note:** Brief usage goes to stderr (since it's an error condition). Full `--help` output goes to stdout.

Reference: [GNU Coding Standards - User Interfaces](https://www.gnu.org/prep/standards/html_node/User-Interfaces.html)

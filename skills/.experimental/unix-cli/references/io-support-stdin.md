---
title: Support Reading from stdin
impact: HIGH
impactDescription: enables use in pipelines as a filter
tags: io, stdin, pipes, filter, unix-philosophy
---

## Support Reading from stdin

When no input file is specified, read from stdin. This enables your tool to work as a filter in pipelines, a core UNIX pattern.

**Incorrect (requires file argument):**

```c
int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s FILE\n", argv[0]);
        return 1;  // Can't use in pipeline
    }
    FILE *f = fopen(argv[1], "r");
    process(f);
}
```

```bash
# Cannot use in pipeline
$ cat data.txt | mytool
Usage: mytool FILE

# Must create temp file
$ cat data.txt > /tmp/data.txt && mytool /tmp/data.txt
```

**Correct (reads stdin when no file given):**

```c
int main(int argc, char *argv[]) {
    FILE *input;

    if (argc < 2 || strcmp(argv[1], "-") == 0) {
        input = stdin;  // Read from stdin
    } else {
        input = fopen(argv[1], "r");
        if (!input) {
            fprintf(stderr, "%s: %s: %s\n",
                    argv[0], argv[1], strerror(errno));
            return 1;
        }
    }

    process(input);

    if (input != stdin) {
        fclose(input);
    }
    return 0;
}
```

```bash
# Works as a filter
$ cat data.txt | mytool
$ curl -s https://example.com/data | mytool

# Explicit stdin with -
$ mytool - < data.txt

# Still works with file argument
$ mytool data.txt
```

**Pattern:** Treat `-` as explicit stdin, useful when other arguments are also files.

Reference: [POSIX Utility Conventions - Guideline 13](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html)

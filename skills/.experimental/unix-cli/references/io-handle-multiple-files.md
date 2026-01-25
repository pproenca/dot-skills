---
title: Handle Multiple Input Files Consistently
impact: MEDIUM
impactDescription: matches behavior of standard UNIX tools
tags: io, files, globbing, batch, unix-philosophy
---

## Handle Multiple Input Files Consistently

Accept multiple input files and process them as a stream, like `cat`, `grep`, and other standard tools. Support shell globbing patterns naturally.

**Incorrect (processes only one file):**

```c
int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s FILE\n", argv[0]);
        return 1;
    }
    FILE *f = fopen(argv[1], "r");
    process(f);
}
```

```bash
# Can't process multiple files
$ mytool *.txt
Usage: mytool FILE

# User must loop manually
$ for f in *.txt; do mytool "$f"; done
```

**Correct (handles multiple files as stream):**

```c
int main(int argc, char *argv[]) {
    int exit_status = 0;

    if (argc < 2 || (argc == 2 && strcmp(argv[1], "-") == 0)) {
        // No args or "-": read from stdin
        process_stream(stdin, "(stdin)");
    } else {
        // Process each file in order
        for (int i = 1; i < argc; i++) {
            FILE *f;
            const char *filename = argv[i];

            if (strcmp(filename, "-") == 0) {
                f = stdin;
                filename = "(stdin)";
            } else {
                f = fopen(filename, "r");
                if (!f) {
                    fprintf(stderr, "%s: %s: %s\n",
                            argv[0], filename, strerror(errno));
                    exit_status = 1;
                    continue;  // Continue with other files
                }
            }

            process_stream(f, filename);

            if (f != stdin) fclose(f);
        }
    }

    return exit_status;
}
```

```bash
# Works with multiple files
$ mytool file1.txt file2.txt file3.txt

# Works with glob patterns
$ mytool *.txt

# Mix files and stdin
$ echo "extra data" | mytool file1.txt - file2.txt

# Returns error if any file failed
$ mytool good.txt missing.txt other.txt
mytool: missing.txt: No such file or directory
$ echo $?
1
```

Reference: [cat(1) - concatenate files](https://man7.org/linux/man-pages/man1/cat.1.html)

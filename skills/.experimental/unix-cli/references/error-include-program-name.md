---
title: Include Program Name in Error Messages
impact: HIGH
impactDescription: enables error identification in pipelines
tags: error, format, program-name, debugging, pipelines
---

## Include Program Name in Error Messages

Prefix error messages with the program name. When multiple tools run in a pipeline or script, this identifies which tool produced the error.

**Incorrect (no program name, ambiguous source):**

```c
int main(int argc, char *argv[]) {
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "Cannot open file\n");  // Which program?
        return 1;
    }
}
```

```bash
# In a pipeline, unclear which tool failed
$ producer | transformer | consumer
Cannot open file
# Which of the three tools failed?
```

**Correct (program name identifies error source):**

```c
const char *program_name;

int main(int argc, char *argv[]) {
    program_name = argv[0];
    // Or use basename for cleaner output:
    // program_name = basename(argv[0]);

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "%s: %s: %s\n",
                program_name, argv[1], strerror(errno));
        return 1;
    }
}
```

```bash
# Error source is immediately clear
$ producer | transformer | consumer
transformer: input.dat: No such file or directory

# Standard format: progname: context: message
$ mytool config.yaml
mytool: config.yaml: Permission denied
```

**GNU standard error format:**

```text
progname: filename:line: message
progname: filename: message
progname: message
```

Reference: [GNU Coding Standards - Errors](https://www.gnu.org/prep/standards/html_node/Errors.html)

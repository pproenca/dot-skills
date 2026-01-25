---
title: Prefer Flags Over Positional Arguments
impact: CRITICAL
impactDescription: improves readability and future extensibility
tags: args, flags, positional, design, extensibility
---

## Prefer Flags Over Positional Arguments

Use named flags instead of positional arguments when the meaning isn't obvious. Flags are self-documenting, order-independent, and allow adding new options without breaking existing scripts.

**Incorrect (positional args with unclear meaning):**

```bash
# What does "5" mean? What does "json" mean?
mytool input.txt output.txt 5 json
```

```c
int main(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Usage: %s input output retries format\n", argv[0]);
        return 1;
    }
    char *input = argv[1];
    char *output = argv[2];
    int retries = atoi(argv[3]);  // User must remember position
    char *format = argv[4];
}
```

**Correct (flags are self-documenting):**

```bash
# Intent is clear, order doesn't matter
mytool --input input.txt --output output.txt --retries 5 --format json
mytool -i input.txt -o output.txt -r 5 -f json
```

```c
int main(int argc, char *argv[]) {
    char *input = NULL, *output = NULL, *format = "text";
    int retries = 3;

    static struct option opts[] = {
        {"input",   required_argument, NULL, 'i'},
        {"output",  required_argument, NULL, 'o'},
        {"retries", required_argument, NULL, 'r'},
        {"format",  required_argument, NULL, 'f'},
        {NULL, 0, NULL, 0}
    };

    int opt;
    while ((opt = getopt_long(argc, argv, "i:o:r:f:", opts, NULL)) != -1) {
        switch (opt) {
            case 'i': input = optarg; break;
            case 'o': output = optarg; break;
            case 'r': retries = atoi(optarg); break;
            case 'f': format = optarg; break;
        }
    }
}
```

**When positional arguments are acceptable:**
- File operands after all options: `cat file1.txt file2.txt`
- Well-known patterns: `cp source dest`, `mv old new`

Reference: [Command Line Interface Guidelines](https://clig.dev/)

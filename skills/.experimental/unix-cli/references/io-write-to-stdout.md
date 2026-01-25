---
title: Write Output to stdout by Default
impact: HIGH
impactDescription: enables output redirection and piping
tags: io, stdout, redirection, pipes, unix-philosophy
---

## Write Output to stdout by Default

Write output to stdout unless an output file is explicitly specified with `-o`/`--output`. Let users redirect output with standard shell operators.

**Incorrect (writes directly to file):**

```c
int main(int argc, char *argv[]) {
    // Always writes to output.txt
    FILE *out = fopen("output.txt", "w");
    process(stdin, out);
    fclose(out);
}
```

```bash
# Can't pipe or redirect output
$ mytool < input.txt | wc -l
# Output went to output.txt, not the pipe

# Must specify output location
$ mytool < input.txt
$ cat output.txt | wc -l
```

**Correct (writes to stdout, file optional):**

```c
int main(int argc, char *argv[]) {
    FILE *output = stdout;  // Default to stdout
    char *output_file = NULL;
    int opt;

    while ((opt = getopt(argc, argv, "o:")) != -1) {
        switch (opt) {
            case 'o': output_file = optarg; break;
        }
    }

    if (output_file) {
        output = fopen(output_file, "w");
        if (!output) {
            fprintf(stderr, "%s: %s: %s\n",
                    argv[0], output_file, strerror(errno));
            return 1;
        }
    }

    process(stdin, output);

    if (output != stdout) {
        fclose(output);
    }
    return 0;
}
```

```bash
# Pipe output
$ mytool < input.txt | sort | head

# Redirect output
$ mytool < input.txt > output.txt

# Explicit output file
$ mytool -o output.txt < input.txt

# View and save simultaneously
$ mytool < input.txt | tee output.txt | less
```

**Note:** Use `-o` for output file to follow GNU conventions. Positional output arguments are confusing.

Reference: [GNU Coding Standards - Output](https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html)

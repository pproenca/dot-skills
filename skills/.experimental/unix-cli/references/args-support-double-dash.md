---
title: Support Double-Dash to Terminate Options
impact: CRITICAL
impactDescription: enables handling of filenames starting with dash
tags: args, double-dash, posix, filenames
---

## Support Double-Dash to Terminate Options

The `--` argument terminates option processing, allowing operands that start with `-` to be treated as filenames rather than options. This is required by POSIX and essential for safe file handling.

**Incorrect (cannot process files starting with dash):**

```c
int main(int argc, char *argv[]) {
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            process_option(argv[i]);  // -myfile.txt treated as option
        } else {
            process_file(argv[i]);
        }
    }
}
```

```bash
# User cannot delete a file named -rf
$ rm -rf            # Interpreted as options, not filename
rm: missing operand
```

**Correct (getopt handles -- automatically):**

```c
int main(int argc, char *argv[]) {
    int opt;
    while ((opt = getopt(argc, argv, "v")) != -1) {
        switch (opt) {
            case 'v': verbose = 1; break;
        }
    }
    // After getopt, optind points past -- if present
    for (int i = optind; i < argc; i++) {
        process_file(argv[i]);  // -myfile.txt processed as filename
    }
}
```

```bash
# Double-dash allows processing files starting with dash
$ rm -- -rf         # Deletes file named "-rf"
$ grep pattern -- -myfile.txt
```

**When NOT to use this pattern:**
- Interactive shells where `--` has other meanings

Reference: [POSIX Utility Conventions](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html)

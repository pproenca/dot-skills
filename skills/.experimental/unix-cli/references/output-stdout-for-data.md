---
title: Write Data to stdout Only
impact: CRITICAL
impactDescription: enables piping and redirection to work correctly
tags: output, stdout, pipes, unix-philosophy, composition
---

## Write Data to stdout Only

Standard output is for program data that can be piped to other programs. Progress messages, warnings, and any human-oriented text must go to stderr. Mixing them breaks pipes.

**Incorrect (messages mixed with data on stdout):**

```c
int main(int argc, char *argv[]) {
    printf("Processing %s...\n", argv[1]);  // Message on stdout
    process_and_output(argv[1]);             // Data on stdout
    printf("Done!\n");                       // Message on stdout
}
```

```bash
# User tries to capture output, gets garbage
$ mytool data.csv > output.csv
$ head output.csv
Processing data.csv...   # Garbage in output file!
id,name,value
1,foo,100
Done!                     # More garbage!
```

**Correct (only data goes to stdout):**

```c
int main(int argc, char *argv[]) {
    fprintf(stderr, "Processing %s...\n", argv[1]);  // Message to stderr
    process_and_output(argv[1]);                      // Data to stdout
    fprintf(stderr, "Done!\n");                       // Message to stderr
}
```

```bash
# Output is clean, messages visible in terminal
$ mytool data.csv > output.csv
Processing data.csv...
Done!
$ head output.csv
id,name,value
1,foo,100
```

**Rule of thumb:** If the output is meant for another program, use stdout. If it's meant for a human watching the terminal, use stderr.

Reference: [Command Line Interface Guidelines](https://clig.dev/)

---
title: Handle Binary Data Safely
impact: MEDIUM
impactDescription: prevents data corruption with non-text files
tags: io, binary, encoding, data-integrity
---

## Handle Binary Data Safely

When processing binary data, use binary mode for file operations and avoid functions that assume text encoding. Text-mode I/O can corrupt binary data.

**Incorrect (text mode corrupts binary):**

```c
int main(int argc, char *argv[]) {
    // Text mode on Windows translates \r\n
    FILE *in = fopen(argv[1], "r");   // Text mode!
    FILE *out = fopen(argv[2], "w");  // Text mode!

    int c;
    while ((c = fgetc(in)) != EOF) {
        fputc(c, out);  // Binary corrupted on Windows
    }
}
```

```bash
# On Windows, binary file gets corrupted
$ mytool image.png copy.png
$ md5sum image.png copy.png
a1b2c3d4  image.png
e5f6g7h8  copy.png   # Different! Corrupted.
```

**Correct (explicit binary mode):**

```c
int main(int argc, char *argv[]) {
    // Binary mode preserves data exactly
    FILE *in = fopen(argv[1], "rb");   // Binary read
    FILE *out = fopen(argv[2], "wb");  // Binary write

    if (!in || !out) {
        perror(argv[0]);
        return 1;
    }

    char buffer[8192];
    size_t n;
    while ((n = fread(buffer, 1, sizeof(buffer), in)) > 0) {
        if (fwrite(buffer, 1, n, out) != n) {
            perror("write");
            return 1;
        }
    }
}
```

```bash
# Binary files preserved correctly
$ mytool image.png copy.png
$ md5sum image.png copy.png
a1b2c3d4  image.png
a1b2c3d4  copy.png   # Identical
```

**Binary I/O checklist:**
- Use `"rb"` and `"wb"` modes for file operations
- Use `fread`/`fwrite` instead of `fgets`/`fputs`
- Set `_setmode(_fileno(stdin), _O_BINARY)` on Windows for stdin/stdout
- Avoid string functions on binary data

Reference: [fopen(3) - Linux manual page](https://man7.org/linux/man-pages/man3/fopen.3.html)

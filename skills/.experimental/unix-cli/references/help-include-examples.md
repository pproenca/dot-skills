---
title: Include Practical Examples in Help
impact: MEDIUM
impactDescription: accelerates learning by 3-5×
tags: help, examples, documentation, usability
---

## Include Practical Examples in Help

Include 2-4 real-world examples in your `--help` output. Examples teach faster than abstract descriptions.

**Incorrect (no examples):**

```c
void print_help(void) {
    printf("Usage: imgconv [OPTIONS] INPUT OUTPUT\n");
    printf("Convert images between formats.\n\n");
    printf("Options:\n");
    printf("  -q, --quality=N    output quality (1-100)\n");
    printf("  -s, --scale=SCALE  resize factor or dimensions\n");
    printf("  -f, --format=FMT   output format\n");
}
```

**Correct (practical examples included):**

```c
void print_help(void) {
    printf("Usage: imgconv [OPTIONS] INPUT OUTPUT\n");
    printf("Convert images between formats.\n\n");

    printf("Options:\n");
    printf("  -q, --quality=N    output quality 1-100 (default: 85)\n");
    printf("  -s, --scale=SCALE  resize: 50%%, 0.5, or 800x600\n");
    printf("  -f, --format=FMT   output format: jpg, png, webp (default: auto)\n\n");

    printf("Examples:\n");
    printf("  imgconv photo.png photo.jpg\n");
    printf("      Convert PNG to JPEG with default quality\n\n");

    printf("  imgconv -q 95 raw.tiff final.jpg\n");
    printf("      Convert TIFF to high-quality JPEG\n\n");

    printf("  imgconv -s 50%% large.png thumbnail.png\n");
    printf("      Create half-size thumbnail\n\n");

    printf("  imgconv -s 1920x1080 photo.jpg wallpaper.jpg\n");
    printf("      Resize to specific dimensions\n");
}
```

```bash
$ imgconv --help
Usage: imgconv [OPTIONS] INPUT OUTPUT
Convert images between formats.

Options:
  -q, --quality=N    output quality 1-100 (default: 85)
  -s, --scale=SCALE  resize: 50%, 0.5, or 800x600
  -f, --format=FMT   output format: jpg, png, webp (default: auto)

Examples:
  imgconv photo.png photo.jpg
      Convert PNG to JPEG with default quality

  imgconv -q 95 raw.tiff final.jpg
      Convert TIFF to high-quality JPEG

  imgconv -s 50% large.png thumbnail.png
      Create half-size thumbnail
```

**Example selection criteria:**
- Most common use case first
- Show different option combinations
- Progress from simple to complex

Reference: [Command Line Interface Guidelines](https://clig.dev/)

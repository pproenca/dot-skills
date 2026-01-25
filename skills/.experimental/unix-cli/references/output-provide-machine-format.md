---
title: Provide Machine-Readable Output Format
impact: HIGH
impactDescription: enables reliable parsing by scripts and other tools
tags: output, json, machine-readable, parsing, automation
---

## Provide Machine-Readable Output Format

Offer a `--json`, `--porcelain`, or similar flag for structured, machine-parseable output. Human-readable output changes; machine output is a stable API.

**Incorrect (only human-readable output):**

```c
void list_files(void) {
    printf("Found 3 files:\n");
    printf("  - document.pdf (2.5 MB, modified yesterday)\n");
    printf("  - image.png (156 KB, modified 2 hours ago)\n");
    printf("  - notes.txt (1.2 KB, modified just now)\n");
}
```

```bash
# Scripts must parse fragile human-readable format
$ mytool list | grep -oP '\d+\.\d+ [KMG]B'
2.5 MB
156 KB
1.2 KB
# Breaks when format changes
```

**Correct (provides structured output option):**

```c
void list_files(int json_output) {
    if (json_output) {
        printf("[\n");
        printf("  {\"name\": \"document.pdf\", \"size\": 2621440, \"mtime\": 1706140800},\n");
        printf("  {\"name\": \"image.png\", \"size\": 159744, \"mtime\": 1706220000},\n");
        printf("  {\"name\": \"notes.txt\", \"size\": 1229, \"mtime\": 1706227200}\n");
        printf("]\n");
    } else {
        printf("Found 3 files:\n");
        printf("  - document.pdf (2.5 MB, modified yesterday)\n");
        // ... human-readable format
    }
}
```

```bash
# Scripts use reliable JSON
$ mytool list --json | jq '.[].name'
"document.pdf"
"image.png"
"notes.txt"

# Format is stable, won't break scripts
$ mytool list --json | jq 'map(select(.size > 1000000))'
```

**Machine format conventions:**
- `--json` for JSON output
- `--porcelain` for stable line-based format (git convention)
- `--format=` for user-specified templates

Reference: [Command Line Interface Guidelines](https://clig.dev/)

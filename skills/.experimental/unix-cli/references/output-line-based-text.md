---
title: Use Line-Based Output for Text Streams
impact: HIGH
impactDescription: enables standard UNIX tools to process output
tags: output, text, lines, pipes, unix-philosophy
---

## Use Line-Based Output for Text Streams

Default output should be one record per line, terminated by newlines. This enables processing with standard tools like `grep`, `awk`, `sort`, and `head`.

**Incorrect (multi-line records, unclear boundaries):**

```c
void print_record(Record *r) {
    printf("Name: %s\n", r->name);
    printf("Email: %s\n", r->email);
    printf("Phone: %s\n", r->phone);
    printf("\n");  // Blank line separator
}
```

```bash
# Hard to process with standard tools
$ mytool list | grep "John"
Name: John Doe     # Only gets partial record
$ mytool list | head -1
Name: Alice Smith  # Not a complete record
```

**Correct (one record per line):**

```c
void print_record(Record *r) {
    printf("%s\t%s\t%s\n", r->name, r->email, r->phone);
}

void print_record_verbose(Record *r) {
    // Verbose mode can use multi-line
    printf("Name: %s\n", r->name);
    printf("Email: %s\n", r->email);
    printf("Phone: %s\n", r->phone);
    printf("\n");
}
```

```bash
# Easy to process with standard tools
$ mytool list | grep "John"
John Doe	john@example.com	555-1234

$ mytool list | head -3
Alice Smith	alice@example.com	555-0001
Bob Jones	bob@example.com	555-0002
Carol White	carol@example.com	555-0003

$ mytool list | cut -f2 | sort -u  # Extract unique emails
$ mytool list | wc -l              # Count records
```

**Conventions:**
- Use tab (`\t`) or colon (`:`) as field delimiter
- Handle fields containing delimiter by quoting or escaping
- For complex data, provide `--json` option

Reference: [The Art of Unix Programming - Textuality](http://www.catb.org/esr/writings/taoup/html/ch05s01.html)

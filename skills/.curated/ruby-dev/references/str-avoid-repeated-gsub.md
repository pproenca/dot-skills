---
title: Chain gsub Calls into a Single Replacement
impact: MEDIUM
impactDescription: reduces N string allocations and regex scans to 1
tags: str, gsub, regex, replacement
---

## Chain gsub Calls into a Single Replacement

Each `.gsub` call scans the entire string and allocates a new copy with the substitutions applied. Chaining N calls means N full scans and N intermediate strings. A single `.gsub` with a Regexp union and a replacement hash performs one scan and one allocation, doing the same work in a fraction of the time.

**Incorrect (each gsub scans and allocates a new string):**

```ruby
def sanitize_user_input(raw_input)
  result = raw_input
    .gsub("&", "&amp;")        # scan 1, allocation 1
    .gsub("<", "&lt;")          # scan 2, allocation 2
    .gsub(">", "&gt;")          # scan 3, allocation 3
    .gsub('"', "&quot;")        # scan 4, allocation 4
    .gsub("'", "&#39;")         # scan 5, allocation 5 — 5 full passes over the string
  result
end

def normalize_product_slug(name)
  name
    .gsub(/\s+/, "-")           # first pass: whitespace to hyphens
    .gsub(/[^\w-]/, "")         # second pass: strip non-word chars
    .gsub(/--+/, "-")           # third pass: collapse double hyphens
    .downcase
end
```

**Correct (single scan with hash replacement or combined regex):**

```ruby
HTML_ESCAPE = { "&" => "&amp;", "<" => "&lt;", ">" => "&gt;",
                '"' => "&quot;", "'" => "&#39;" }.freeze
HTML_ESCAPE_PATTERN = Regexp.union(HTML_ESCAPE.keys).freeze

def sanitize_user_input(raw_input)
  raw_input.gsub(HTML_ESCAPE_PATTERN, HTML_ESCAPE)   # one scan, one allocation
end

def normalize_product_slug(name)
  name.downcase.gsub(/[^\w-]+/, "-")  # one pass: lowercase then replace all non-word sequences
      .delete_prefix("-").delete_suffix("-")
end
```

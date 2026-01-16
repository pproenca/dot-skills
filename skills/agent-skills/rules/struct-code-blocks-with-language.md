---
title: Specify Language in Code Blocks
impact: HIGH
impactDescription: 2-3× improvement in code execution accuracy
tags: struct, code-blocks, syntax, formatting
---

## Specify Language in Code Blocks

Always include language identifiers in fenced code blocks. Claude uses these to determine execution context and syntax rules. Missing identifiers cause parsing ambiguity and execution errors.

**Incorrect (no language specified):**

```text
## Example Usage

` ` `
const result = await extractText(pdf)
console.log(result)
` ` `

Run the script:

` ` `
python scripts/process.py --input file.pdf
` ` `
```

```text
# First block: Is it JavaScript? TypeScript? Node?
# Second block: Is it bash? Should Claude execute it?
# Ambiguous execution context
```

**Correct (language specified for each block):**

```text
## Example Usage

` ` `typescript
const result = await extractText(pdf)
console.log(result)
` ` `

Run the script:

` ` `bash
python scripts/process.py --input file.pdf
` ` `
```

```text
# TypeScript: Claude knows syntax rules and types
# Bash: Claude knows this is a shell command
# Clear execution context for each block
```

**Common language identifiers:**
- `typescript`, `javascript`, `python`, `bash`, `go`, `rust`
- `yaml`, `json`, `toml` for configuration
- `markdown` for documentation examples
- `diff` for showing changes

Reference: [CommonMark Specification](https://spec.commonmark.org/)

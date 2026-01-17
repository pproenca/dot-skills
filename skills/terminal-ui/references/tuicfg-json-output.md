---
title: Support Machine-Readable Output Format
impact: MEDIUM
impactDescription: enables scripting and tool integration
tags: tuicfg, json, output, machine, automation
---

## Support Machine-Readable Output Format

Provide a `--json` flag for machine-readable output. This enables scripting, piping to other tools, and CI integration.

**Incorrect (human-only output):**

```typescript
async function listProjects() {
  const projects = await getProjects()

  console.log('Projects:')
  projects.forEach(p => {
    console.log(`  • ${p.name} (${p.status})`)
  })
  console.log(`\nTotal: ${projects.length}`)
}
// Can't be parsed by other tools
```

**Correct (dual output modes):**

```typescript
interface OutputOptions {
  json?: boolean
  quiet?: boolean
}

async function listProjects(options: OutputOptions) {
  const projects = await getProjects()

  if (options.json) {
    // Machine-readable output
    console.log(JSON.stringify({
      projects,
      total: projects.length
    }, null, 2))
    return
  }

  if (options.quiet) {
    // Just names, one per line (for piping)
    projects.forEach(p => console.log(p.name))
    return
  }

  // Human-readable output
  console.log(color.bold('Projects:'))
  projects.forEach(p => {
    const status = p.status === 'active'
      ? color.green('●')
      : color.dim('○')
    console.log(`  ${status} ${p.name}`)
  })
  console.log(color.dim(`\nTotal: ${projects.length}`))
}
```

**Consistent JSON structure:**

```typescript
interface JsonOutput<T> {
  success: boolean
  data?: T
  error?: {
    code: string
    message: string
    details?: unknown
  }
  meta?: {
    timestamp: string
    version: string
  }
}

function outputJson<T>(data: T): void {
  const output: JsonOutput<T> = {
    success: true,
    data,
    meta: {
      timestamp: new Date().toISOString(),
      version: packageJson.version
    }
  }
  console.log(JSON.stringify(output, null, 2))
}

function outputJsonError(code: string, message: string): void {
  const output: JsonOutput<never> = {
    success: false,
    error: { code, message }
  }
  console.log(JSON.stringify(output, null, 2))
  process.exit(1)
}
```

**Usage examples:**

```bash
# Parse with jq
mycli list --json | jq '.projects[].name'

# Use in scripts
PROJECT_COUNT=$(mycli list --json | jq '.total')

# Quiet mode for simple piping
mycli list --quiet | xargs -I {} mycli deploy {}
```

Reference: [clig.dev - Output](https://clig.dev/#output)

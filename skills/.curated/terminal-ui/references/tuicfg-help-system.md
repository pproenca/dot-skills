---
title: Implement Comprehensive Help System
impact: MEDIUM
impactDescription: enables self-service and reduces support burden
tags: tuicfg, help, documentation, cli, usage
---

## Implement Comprehensive Help System

Provide thorough help accessible via `-h`, `--help`, and running without arguments. Include examples, not just option lists.

**Incorrect (minimal help):**

```typescript
if (args.help) {
  console.log('Usage: mycli [options]')
  console.log('  --name    Name')
  console.log('  --output  Output')
  process.exit(0)
}
// Unhelpful, no examples, no context
```

**Correct (comprehensive help):**

```typescript
function showHelp() {
  const help = `
${color.bold('mycli')} - Build and deploy applications

${color.yellow('USAGE')}
  mycli <command> [options]

${color.yellow('COMMANDS')}
  init          Create a new project
  build         Build the project
  deploy        Deploy to production
  dev           Start development server

${color.yellow('GLOBAL OPTIONS')}
  -h, --help     Show this help message
  -v, --version  Show version number
  -q, --quiet    Suppress non-error output
  --no-color     Disable colored output

${color.yellow('EXAMPLES')}
  ${color.dim('# Create a new TypeScript project')}
  mycli init my-app --template typescript

  ${color.dim('# Build for production')}
  mycli build --minify --target es2020

  ${color.dim('# Deploy to staging')}
  mycli deploy --env staging

${color.yellow('LEARN MORE')}
  Documentation: ${color.cyan('https://mycli.dev/docs')}
  GitHub:        ${color.cyan('https://github.com/org/mycli')}
`
  console.log(help)
}
```

**Subcommand help:**

```typescript
function showCommandHelp(command: string) {
  const helpMap: Record<string, string> = {
    init: `
${color.bold('mycli init')} - Create a new project

${color.yellow('USAGE')}
  mycli init <name> [options]

${color.yellow('ARGUMENTS')}
  name    Project name (required)

${color.yellow('OPTIONS')}
  -t, --template <name>   Project template (default: default)
  --no-git                Skip git initialization
  --no-install            Skip dependency installation

${color.yellow('TEMPLATES')}
  default     Basic project structure
  typescript  TypeScript with strict config
  react       React application
  api         API server with Express

${color.yellow('EXAMPLES')}
  mycli init my-app
  mycli init my-api --template api
`,
    // ... other commands
  }

  console.log(helpMap[command] || showHelp())
}
```

**Key elements:**
- Examples with comments
- All options with descriptions
- Default values shown
- Links to documentation

Reference: [clig.dev - Help](https://clig.dev/#help)

---
title: Use Meaningful Exit Codes
impact: LOW-MEDIUM
impactDescription: enables proper error handling in scripts
tags: robust, exit, codes, scripting, automation
---

## Use Meaningful Exit Codes

Return appropriate exit codes for different outcomes. Scripts and CI systems rely on exit codes to determine success or failure.

**Incorrect (always exit 1 on error):**

```typescript
try {
  await runCommand()
} catch (error) {
  console.error(error.message)
  process.exit(1)  // Same code for all errors
}
```

**Correct (meaningful exit codes):**

```typescript
// Standard exit codes
const EXIT = {
  SUCCESS: 0,
  GENERAL_ERROR: 1,
  MISUSE: 2,           // Invalid arguments, bad usage
  CANNOT_EXECUTE: 126,  // Permission denied
  NOT_FOUND: 127,       // Command not found
  SIGINT: 130,          // 128 + 2 (Ctrl+C)
  SIGTERM: 143          // 128 + 15
} as const

async function main() {
  try {
    const args = parseArgs()

    if (args.help) {
      showHelp()
      process.exit(EXIT.SUCCESS)
    }

    if (!args.command) {
      console.error('Error: No command specified')
      console.error('Run with --help for usage')
      process.exit(EXIT.MISUSE)
    }

    await runCommand(args)
    process.exit(EXIT.SUCCESS)

  } catch (error) {
    if (error instanceof ValidationError) {
      console.error(`Invalid input: ${error.message}`)
      process.exit(EXIT.MISUSE)
    }

    if (error instanceof PermissionError) {
      console.error(`Permission denied: ${error.message}`)
      process.exit(EXIT.CANNOT_EXECUTE)
    }

    if (error instanceof NotFoundError) {
      console.error(`Not found: ${error.message}`)
      process.exit(EXIT.NOT_FOUND)
    }

    console.error(`Error: ${error.message}`)
    process.exit(EXIT.GENERAL_ERROR)
  }
}
```

**Exit code categories:**

```typescript
// 0: Success
// 1: General error
// 2: Misuse (bad arguments, invalid config)
// 3-63: Reserved for application-specific errors
// 64-78: Sysexits.h codes (EX_USAGE, EX_DATAERR, etc.)
// 126: Cannot execute
// 127: Command not found
// 128+N: Killed by signal N

// Application-specific
const APP_EXIT = {
  CONFIG_ERROR: 10,
  NETWORK_ERROR: 11,
  AUTH_ERROR: 12,
  BUILD_FAILED: 20,
  TEST_FAILED: 21,
  DEPLOY_FAILED: 22
}
```

**Check exit code in scripts:**

```bash
mycli build || exit $?

if mycli test; then
  mycli deploy
else
  echo "Tests failed with exit code $?"
fi
```

Reference: [clig.dev - Exit codes](https://clig.dev/#exit-codes)

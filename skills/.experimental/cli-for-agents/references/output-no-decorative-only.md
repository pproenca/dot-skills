---
title: Avoid Relying on Decorative Output to Convey State
impact: MEDIUM
impactDescription: prevents state from being lost when agents read raw bytes
tags: output, decorative, spinners, accessibility
---

## Avoid Relying on Decorative Output to Convey State

Spinners, checkmark glyphs, progress bars, and box-drawing characters look great to humans but communicate nothing extra to agents — and can even be lost entirely when output is captured line-by-line (spinners overwrite the same terminal line). Every state the decoration conveys must ALSO appear as plain text: "done" in words, not just "✓"; "building (3/10)" in words, not just a progress bar. Treat decoration as a sugar layer on top of parseable text, never as the primary channel.

**Incorrect (spinner is the only success indicator):**

```javascript
import ora from 'ora';

async function deploy() {
  const spinner = ora('Deploying...').start();
  try {
    await api.deploy();
    spinner.succeed();          // ✓ glyph only, no text
    // Agent reading stdout via non-TTY capture sees: empty string
  } catch (err) {
    spinner.fail();              // ✗ glyph only
    process.exit(1);
  }
}

deploy();
```

**Correct (spinner is sugar; plain text is the primary channel):**

```javascript
import ora from 'ora';

async function deploy() {
  // NO_COLOR governs color, not motion — use isTTY + CI detection instead
  const useSpinner = process.stdout.isTTY && !process.env.CI;
  const spinner = useSpinner ? ora('Deploying...').start() : null;

  try {
    const result = await api.deploy();
    spinner?.stop();
    // Plain text is always emitted, TTY or not
    console.log(`deployed ${result.id} in ${result.duration}ms`);
  } catch (err) {
    spinner?.stop();
    console.error(`Error: deploy failed: ${err.message}`);
    console.error('  mycli deploy --tag v1.2.3 --debug   # for details');
    process.exit(1);
  }
}

deploy();
```

**Benefits:**
- Agent capture (`mycli deploy 2>&1 | tee run.log`) always contains the state
- Humans still get the spinner when running interactively
- Line-based logs from CI/test runners correctly record success vs failure

Reference: [clig.dev — Don't animate in non-TTY](https://clig.dev/#output)

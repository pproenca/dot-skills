# VHS

**Version 0.1.0**  
Charmbracelet  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for VHS terminal recordings, designed for AI agents and LLMs. Contains 47 rules across 8 categories, prioritized by impact from critical (configuration structure, dependency management) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific guidance to create professional, portable, and optimized terminal GIFs and videos.

---

## Table of Contents

1. [Configuration Structure](references/_sections.md#1-configuration-structure) — **CRITICAL**
   - 1.1 [Declare Output at File Start](references/config-output-first.md) — CRITICAL (prevents missing output files)
   - 1.2 [Explicitly Set Shell Type](references/config-shell-explicit.md) — CRITICAL (ensures consistent cross-platform behavior)
   - 1.3 [Place All Settings Before Commands](references/config-settings-order.md) — CRITICAL (prevents silent setting failures)
   - 1.4 [Set Explicit Terminal Dimensions](references/config-dimensions-explicit.md) — HIGH (prevents content clipping and inconsistent layouts)
   - 1.5 [Set Global TypingSpeed Early](references/config-typing-speed-global.md) — HIGH (establishes consistent pacing throughout recording)
   - 1.6 [Use Comments to Document Tape Structure](references/config-comments-document.md) — MEDIUM (improves maintainability and team collaboration)
2. [Dependency Management](references/_sections.md#2-dependency-management) — **CRITICAL**
   - 2.1 [Place Require Before Settings](references/deps-require-order.md) — CRITICAL (ensures early failure before any processing)
   - 2.2 [Require All External Commands](references/deps-require-all.md) — HIGH (documents and validates all dependencies)
   - 2.3 [Use Require for Dependency Validation](references/deps-require-early.md) — CRITICAL (prevents silent failures from missing programs)
   - 2.4 [Verify System Dependencies](references/deps-system-requirements.md) — HIGH (prevents cryptic ffmpeg and ttyd errors)
3. [Command Syntax](references/_sections.md#3-command-syntax) — **HIGH**
   - 3.1 [Always Follow Type with Enter](references/cmd-enter-explicit.md) — HIGH (ensures commands actually execute)
   - 3.2 [Handle Multiline Commands Properly](references/cmd-multiline-type.md) — MEDIUM (prevents broken command entry in recordings)
   - 3.3 [Use Correct Type Command Syntax](references/cmd-type-syntax.md) — HIGH (prevents command parsing failures)
   - 3.4 [Use Ctrl Combinations for Terminal Control](references/cmd-ctrl-combinations.md) — HIGH (enables proper terminal interaction patterns)
   - 3.5 [Use Env for Environment Variables](references/cmd-env-variables.md) — MEDIUM (cleaner than export commands, persists throughout recording)
   - 3.6 [Use Hide/Show for Sensitive Operations](references/cmd-hide-show.md) — HIGH (prevents exposing secrets or boring setup in demos)
   - 3.7 [Use Key Repeat Counts](references/cmd-key-repeat.md) — HIGH (reduces tape file verbosity by 5-10×)
   - 3.8 [Use Screenshot for Static Captures](references/cmd-screenshot.md) — MEDIUM (creates PNG snapshots for documentation)
4. [Timing & Synchronization](references/_sections.md#4-timing-&-synchronization) — **HIGH**
   - 4.1 [Add Natural Pauses Between Actions](references/timing-natural-pauses.md) — MEDIUM (creates human-like interaction flow)
   - 4.2 [Add Sleep After Commands for Output](references/timing-sleep-after-enter.md) — HIGH (ensures command output is captured before next action)
   - 4.3 [End Recordings with Final Sleep](references/timing-final-sleep.md) — MEDIUM (prevents abrupt GIF endings)
   - 4.4 [Override TypingSpeed for Emphasis](references/timing-type-speed-override.md) — HIGH (draws attention to important commands)
   - 4.5 [Set Appropriate Wait Timeouts](references/timing-wait-timeout.md) — MEDIUM (prevents infinite hangs and CI failures)
   - 4.6 [Use Explicit Time Units](references/timing-sleep-units.md) — MEDIUM (prevents confusion between seconds and milliseconds)
   - 4.7 [Use PlaybackSpeed for Final Adjustments](references/timing-playback-speed.md) — MEDIUM (adjusts recording duration without re-recording)
   - 4.8 [Use Wait for Dynamic Command Completion](references/timing-wait-pattern.md) — HIGH (eliminates guesswork for variable-duration commands)
5. [Output Optimization](references/_sections.md#5-output-optimization) — **MEDIUM-HIGH**
   - 5.1 [Choose Output Format Based on Use Case](references/output-format-selection.md) — MEDIUM-HIGH (10-50× file size difference between formats)
   - 5.2 [Generate Multiple Output Formats](references/output-multiple-formats.md) — MEDIUM (single render produces all needed formats)
   - 5.3 [Optimize Framerate for File Size](references/output-framerate.md) — MEDIUM-HIGH (2-3× file size reduction with lower framerate)
   - 5.4 [Right-Size Terminal Dimensions](references/output-dimensions-optimize.md) — MEDIUM-HIGH (2-4× file size impact from oversized dimensions)
   - 5.5 [Use LoopOffset for Seamless Loops](references/output-loop-offset.md) — MEDIUM (creates professional-looking continuous playback)
   - 5.6 [Use Relative Paths for Portability](references/output-relative-paths.md) — MEDIUM (ensures tape files work across machines and CI)
6. [Visual Quality](references/_sections.md#6-visual-quality) — **MEDIUM**
   - 6.1 [Add Window Decorations for Polish](references/visual-window-decoration.md) — MEDIUM (creates professional-looking terminal appearance)
   - 6.2 [Adjust Letter and Line Spacing](references/visual-spacing.md) — LOW-MEDIUM (fine-tunes readability for specific fonts)
   - 6.3 [Choose Readable Font Settings](references/visual-font-readable.md) — MEDIUM (improves accessibility and viewer comprehension)
   - 6.4 [Ensure Cursor Visibility](references/visual-cursor-visibility.md) — LOW-MEDIUM (helps viewers track typing position)
   - 6.5 [Select Appropriate Theme](references/visual-theme-selection.md) — MEDIUM (affects brand consistency and readability)
   - 6.6 [Use Padding and Margins Effectively](references/visual-padding-margin.md) — LOW-MEDIUM (prevents content from touching edges)
7. [CI/Automation](references/_sections.md#7-ci/automation) — **MEDIUM**
   - 7.1 [Auto-Commit Generated Assets](references/ci-auto-commit.md) — MEDIUM (keeps documentation synchronized automatically)
   - 7.2 [Cache VHS Dependencies in CI](references/ci-caching.md) — LOW-MEDIUM (reduces CI run time by 30-60 seconds)
   - 7.3 [Generate Platform-Specific Demos](references/ci-matrix-builds.md) — LOW-MEDIUM (ensures demos work across different shells)
   - 7.4 [Use Golden Files for Integration Testing](references/ci-golden-files.md) — MEDIUM (detects unintended output changes)
   - 7.5 [Use Official VHS GitHub Action](references/ci-github-action.md) — MEDIUM (simplifies CI setup and ensures compatibility)
8. [Advanced Patterns](references/_sections.md#8-advanced-patterns) — **LOW**
   - 8.1 [Record Live Sessions Then Edit](references/advanced-recording-live.md) — LOW (2-5× faster tape creation for complex workflows)
   - 8.2 [Use Copy and Paste for Complex Input](references/advanced-clipboard.md) — LOW (simplifies long or complex text entry)
   - 8.3 [Use Server Mode for Remote Access](references/advanced-server-mode.md) — LOW (eliminates per-machine VHS installation)
   - 8.4 [Use Source for Reusable Tape Components](references/advanced-source-include.md) — LOW (enables DRY patterns across multiple tapes)

---

## References

1. [https://github.com/charmbracelet/vhs](https://github.com/charmbracelet/vhs)
2. [https://github.com/charmbracelet/vhs/blob/main/README.md](https://github.com/charmbracelet/vhs/blob/main/README.md)
3. [https://github.com/charmbracelet/vhs-action](https://github.com/charmbracelet/vhs-action)
4. [https://github.com/charmbracelet/vhs/tree/main/examples](https://github.com/charmbracelet/vhs/tree/main/examples)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
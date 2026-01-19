# Developer Experience TUI

**Version 0.1.0**  
DevEx  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive developer experience guide for building TypeScript terminal user interfaces using Ink (React for CLIs) and Clack prompts. Contains 42 rules across 8 categories, prioritized by impact from critical (rendering optimization, input handling) to incremental (robustness and compatibility). Each rule includes detailed explanations, real-world TypeScript examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Rendering & Output](references/_sections.md#1-rendering-&-output) — **CRITICAL**
   - 1.1 [Batch Terminal Output in Single Write](references/render-single-write.md) — CRITICAL (eliminates partial frame flicker)
   - 1.2 [Defer ANSI Escape Code Generation to Final Output](references/render-escape-sequence-batching.md) — HIGH (reduces intermediate string allocations)
   - 1.3 [Overwrite Content Instead of Clear and Redraw](references/render-overwrite-dont-clear.md) — CRITICAL (eliminates blank frame flicker)
   - 1.4 [Target 60fps for Smooth Animation](references/render-60fps-baseline.md) — CRITICAL (16ms frame budget for perceived smoothness)
   - 1.5 [Update Only Changed Regions](references/render-partial-updates.md) — CRITICAL (reduces bandwidth by 80-95%)
   - 1.6 [Use Synchronized Output Protocol for Animations](references/render-synchronized-output.md) — CRITICAL (eliminates 100% of mid-frame flicker)
2. [Input & Keyboard](references/_sections.md#2-input-&-keyboard) — **CRITICAL**
   - 2.1 [Always Provide Escape Routes](references/input-escape-routes.md) — CRITICAL (prevents user frustration and stuck states)
   - 2.2 [Handle Modifier Keys Correctly](references/input-modifier-keys.md) — CRITICAL (prevents missed shortcuts and input bugs)
   - 2.3 [Provide Immediate Visual Feedback for Input](references/input-immediate-feedback.md) — CRITICAL (<100ms response feels instant)
   - 2.4 [Use isActive Option for Focus Management](references/input-isactive-focus.md) — HIGH (prevents input conflicts between components)
   - 2.5 [Use useInput Hook for Keyboard Handling](references/input-useinput-hook.md) — CRITICAL (prevents raw stdin complexity)
3. [Component Patterns](references/_sections.md#3-component-patterns) — **HIGH**
   - 3.1 [Use Border Styles for Visual Structure](references/tuicomp-border-styles.md) — MEDIUM (reduces visual parsing time by 30-50%)
   - 3.2 [Use Box Component with Flexbox for Layouts](references/tuicomp-box-flexbox.md) — HIGH (eliminates manual position calculations)
   - 3.3 [Use measureElement for Dynamic Sizing](references/tuicomp-measure-element.md) — HIGH (enables responsive layouts based on content)
   - 3.4 [Use Percentage Widths for Responsive Layouts](references/tuicomp-percentage-widths.md) — HIGH (prevents overflow on 100% of terminal sizes)
   - 3.5 [Use Static Component for Log Output](references/tuicomp-static-for-logs.md) — HIGH (prevents log lines from re-rendering)
   - 3.6 [Use Text Component for All Visible Content](references/tuicomp-text-styling.md) — HIGH (prevents 100% of styling bugs from raw strings)
4. [State & Lifecycle](references/_sections.md#4-state-&-lifecycle) — **HIGH**
   - 4.1 [Always Clean Up Effects on Unmount](references/tuistate-cleanup-effects.md) — HIGH (prevents memory leaks and orphaned timers)
   - 4.2 [Memoize Expensive Computations with useMemo](references/tuistate-usememo-expensive.md) — MEDIUM (avoids recalculating on every render)
   - 4.3 [Stabilize Callbacks with useCallback](references/tuistate-usecallback-stable.md) — MEDIUM (prevents unnecessary re-renders in children)
   - 4.4 [Use Functional State Updates to Avoid Stale Closures](references/tuistate-functional-updates.md) — HIGH (prevents stale state bugs in callbacks)
   - 4.5 [Use useApp Hook for Application Lifecycle](references/tuistate-useapp-exit.md) — HIGH (prevents terminal state corruption on exit)
5. [Prompt Design](references/_sections.md#5-prompt-design) — **MEDIUM-HIGH**
   - 5.1 [Build Custom Prompts with @clack/core](references/prompt-custom-render.md) — MEDIUM (enables specialized input patterns)
   - 5.2 [Handle Cancellation Gracefully with isCancel](references/prompt-cancellation.md) — MEDIUM-HIGH (prevents crashes and ensures clean exit)
   - 5.3 [Use Clack group() for Multi-Step Prompts](references/prompt-group-flow.md) — MEDIUM-HIGH (enables sequential prompts with shared state)
   - 5.4 [Use Spinner and Tasks for Long Operations](references/prompt-spinner-tasks.md) — MEDIUM-HIGH (prevents perceived hang during async work)
   - 5.5 [Validate Input Early with Descriptive Messages](references/prompt-validation.md) — MEDIUM-HIGH (prevents invalid data from propagating)
6. [UX & Feedback](references/_sections.md#6-ux-&-feedback) — **MEDIUM**
   - 6.1 [Show Next Steps After Completion](references/ux-next-steps.md) — MEDIUM (reduces support requests by providing clear guidance)
   - 6.2 [Show Progress for Operations Over 1 Second](references/ux-progress-indicators.md) — MEDIUM (prevents perceived hangs and user frustration)
   - 6.3 [Use Colors Semantically and Consistently](references/ux-color-semantics.md) — MEDIUM (reduces time-to-comprehension by 2-3×)
   - 6.4 [Use Intro and Outro for Session Framing](references/ux-intro-outro.md) — MEDIUM (improves perceived quality by 30-40% in user studies)
   - 6.5 [Write Actionable Error Messages](references/ux-error-messages.md) — MEDIUM (reduces user frustration and support requests)
7. [Configuration & CLI](references/_sections.md#7-configuration-&-cli) — **MEDIUM**
   - 7.1 [Implement Comprehensive Help System](references/tuicfg-help-system.md) — MEDIUM (enables self-service and reduces support burden)
   - 7.2 [Prefer Flags Over Positional Arguments](references/tuicfg-flags-over-args.md) — MEDIUM (reduces user errors by 50% through self-documentation)
   - 7.3 [Provide Sensible Defaults for All Options](references/tuicfg-sensible-defaults.md) — MEDIUM (reduces friction for common use cases)
   - 7.4 [Support Machine-Readable Output Format](references/tuicfg-json-output.md) — MEDIUM (enables scripting and tool integration)
   - 7.5 [Support Standard Environment Variables](references/tuicfg-env-vars.md) — MEDIUM (enables scripting and CI integration)
8. [Robustness & Compatibility](references/_sections.md#8-robustness-&-compatibility) — **LOW-MEDIUM**
   - 8.1 [Always Restore Terminal State on Exit](references/robust-terminal-restore.md) — LOW-MEDIUM (prevents broken terminal after crashes)
   - 8.2 [Degrade Gracefully for Limited Terminals](references/robust-graceful-degradation.md) — LOW-MEDIUM (maintains usability in 100% of terminal environments)
   - 8.3 [Detect TTY and Adjust Behavior Accordingly](references/robust-tty-detection.md) — LOW-MEDIUM (prevents 100% of CI hangs from interactive prompts)
   - 8.4 [Handle Process Signals Gracefully](references/robust-signal-handling.md) — LOW-MEDIUM (enables clean shutdown and resource cleanup)
   - 8.5 [Use Meaningful Exit Codes](references/robust-exit-codes.md) — LOW-MEDIUM (enables proper error handling in scripts)

---

## References

1. [https://github.com/bombshell-dev/clack](https://github.com/bombshell-dev/clack)
2. [https://github.com/vadimdemedes/ink](https://github.com/vadimdemedes/ink)
3. [https://github.com/vadimdemedes/ink-ui](https://github.com/vadimdemedes/ink-ui)
4. [https://clig.dev/](https://clig.dev/)
5. [https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/](https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
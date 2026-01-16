---
name: devex-developer-experience-tui-best-practices
description: Developer Experience TUI performance and UX guidelines for TypeScript applications using Ink and Clack. This skill should be used when writing, reviewing, or refactoring terminal user interfaces to ensure optimal rendering, input handling, and user experience patterns. Triggers on tasks involving TUI components, CLI prompts, terminal rendering, keyboard input handling, or developer tooling.
---

# DevEx Developer Experience TUI Best Practices

Comprehensive developer experience guide for building TypeScript terminal user interfaces using Ink (React for CLIs) and Clack prompts. Contains 42 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Building CLI tools with interactive prompts using @clack/prompts
- Creating React-based terminal UIs with Ink
- Handling keyboard input and user interactions
- Optimizing terminal rendering and preventing flicker
- Designing developer-friendly CLI experiences

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Rendering & Output | CRITICAL | `render-` |
| 2 | Input & Keyboard | CRITICAL | `input-` |
| 3 | Component Patterns | HIGH | `comp-` |
| 4 | State & Lifecycle | HIGH | `state-` |
| 5 | Prompt Design | MEDIUM-HIGH | `prompt-` |
| 6 | UX & Feedback | MEDIUM | `ux-` |
| 7 | Configuration & CLI | MEDIUM | `config-` |
| 8 | Robustness & Compatibility | LOW-MEDIUM | `robust-` |

## Quick Reference

### 1. Rendering & Output (CRITICAL)

- `render-single-write` - Batch Terminal Output in Single Write
- `render-overwrite-dont-clear` - Overwrite Content Instead of Clear and Redraw
- `render-synchronized-output` - Use Synchronized Output Protocol for Animations
- `render-60fps-baseline` - Target 60fps for Smooth Animation
- `render-partial-updates` - Update Only Changed Regions
- `render-escape-sequence-batching` - Defer ANSI Escape Code Generation to Final Output

### 2. Input & Keyboard (CRITICAL)

- `input-useinput-hook` - Use useInput Hook for Keyboard Handling
- `input-immediate-feedback` - Provide Immediate Visual Feedback for Input
- `input-modifier-keys` - Handle Modifier Keys Correctly
- `input-isactive-focus` - Use isActive Option for Focus Management
- `input-escape-routes` - Always Provide Escape Routes

### 3. Component Patterns (HIGH)

- `comp-box-flexbox` - Use Box Component with Flexbox for Layouts
- `comp-text-styling` - Use Text Component for All Visible Content
- `comp-measure-element` - Use measureElement for Dynamic Sizing
- `comp-static-for-logs` - Use Static Component for Log Output
- `comp-percentage-widths` - Use Percentage Widths for Responsive Layouts
- `comp-border-styles` - Use Border Styles for Visual Structure

### 4. State & Lifecycle (HIGH)

- `state-useapp-exit` - Use useApp Hook for Application Lifecycle
- `state-cleanup-effects` - Always Clean Up Effects on Unmount
- `state-functional-updates` - Use Functional State Updates to Avoid Stale Closures
- `state-usecallback-stable` - Stabilize Callbacks with useCallback
- `state-usememo-expensive` - Memoize Expensive Computations with useMemo

### 5. Prompt Design (MEDIUM-HIGH)

- `prompt-group-flow` - Use Clack group() for Multi-Step Prompts
- `prompt-validation` - Validate Input Early with Descriptive Messages
- `prompt-cancellation` - Handle Cancellation Gracefully with isCancel
- `prompt-spinner-tasks` - Use Spinner and Tasks for Long Operations
- `prompt-custom-render` - Build Custom Prompts with @clack/core

### 6. UX & Feedback (MEDIUM)

- `ux-progress-indicators` - Show Progress for Operations Over 1 Second
- `ux-color-semantics` - Use Colors Semantically and Consistently
- `ux-error-messages` - Write Actionable Error Messages
- `ux-next-steps` - Show Next Steps After Completion
- `ux-intro-outro` - Use Intro and Outro for Session Framing

### 7. Configuration & CLI (MEDIUM)

- `config-sensible-defaults` - Provide Sensible Defaults for All Options
- `config-env-vars` - Support Standard Environment Variables
- `config-flags-over-args` - Prefer Flags Over Positional Arguments
- `config-help-system` - Implement Comprehensive Help System
- `config-json-output` - Support Machine-Readable Output Format

### 8. Robustness & Compatibility (LOW-MEDIUM)

- `robust-tty-detection` - Detect TTY and Adjust Behavior Accordingly
- `robust-signal-handling` - Handle Process Signals Gracefully
- `robust-exit-codes` - Use Meaningful Exit Codes
- `robust-terminal-restore` - Always Restore Terminal State on Exit
- `robust-graceful-degradation` - Degrade Gracefully for Limited Terminals

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/render-single-write.md
rules/input-useinput-hook.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`

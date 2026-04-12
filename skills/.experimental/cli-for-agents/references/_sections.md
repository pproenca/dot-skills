# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Non-interactive Operation (interact)

**Impact:** CRITICAL
**Description:** Interactive prompts, arrow-key menus, and TTY-only behaviours block agents entirely — nothing downstream in the agent's workflow is reachable if the CLI hangs on input.

## 2. Help Text Design (help)

**Impact:** HIGH
**Description:** Agents learn a CLI from `--help`. Missing examples, unlayered top-level help, or help that requires a TTY to render leaves agents unable to discover what the CLI can do. One rule in this category — `help-examples-in-help` — is rated CRITICAL because its failure makes every downstream discovery attempt guesswork.

## 3. Error Messages (err)

**Impact:** HIGH
**Description:** Bad errors cause retry loops that waste context and drift further from success. Good errors unblock agents immediately with a concrete, copy-pasteable next step.

## 4. Destructive Action Safety (safe)

**Impact:** HIGH
**Description:** Without `--dry-run` and non-interactive confirmation bypass, agents either cannot use destructive commands at all or must avoid them out of caution — losing entire capability classes.

## 5. Input Handling (input)

**Impact:** HIGH
**Description:** stdin, pipes, and flag parsing determine whether the CLI composes with other tools. Agents chain commands constantly, so input-side composability is load-bearing.

## 6. Output Format (output)

**Impact:** MEDIUM-HIGH
**Description:** Structured success output lets agents extract IDs and chain commands. Decorative-only output (spinners, boxes, ANSI art) wastes tokens and forces brittle screen-scraping.

## 7. Idempotency & Retries (idem)

**Impact:** MEDIUM-HIGH
**Description:** Agents retry often after transient failures. Non-idempotent commands cause double-effects the agent cannot detect, producing state drift that is expensive to unwind.

## 8. Command Structure (struct)

**Impact:** MEDIUM
**Description:** Predictable resource-verb patterns and standard flag names let agents generalize from one subcommand to another without re-reading help for every invocation.

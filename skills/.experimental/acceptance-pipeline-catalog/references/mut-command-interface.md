---
title: Expose Stable Mutator CLI Contract
impact: HIGH
impactDescription: wrong CLI contract breaks the mutation script and CI integration, causing 100% pipeline failure on option or exit-code mismatch
tags: mut, cli, command, options, exit-codes
---

## Expose Stable Mutator CLI Contract

The mutator command owns the entire mutation testing workflow: parsing, mutation generation, test execution, and reporting. Its CLI interface must be stable because it is invoked from the mutation script and potentially from CI systems.

### Spec Requirements

```sh
gherkin-mutator [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `--feature <path>` | Gherkin feature file to parse and mutate | `features/a-feature.feature` |
| `--work-dir <path>` | Directory for mutation work files | `build/acceptance-mutation` |
| `--workers <count>` | Maximum parallel mutation workers (values < 1 treated as 1) | Implementation-defined |
| `--timeout <duration>` | Timeout for the full mutation run | Implementation-defined |
| `--json` | Emit JSON report instead of text report | Text report |

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All mutations were killed and no errors occurred |
| `1` | At least one mutation survived, or at least one mutation produced a setup/tool error |
| `2` | Command-line usage or option parsing error |

### Why Exit Code 1 Covers Both Survived and Errors

Both outcomes indicate the pipeline is not fully healthy. A survived mutation means weak tests. An error means the infrastructure needs fixing. Both require investigation, so both produce a non-zero exit code that stops CI pipelines.

Exit code 0 is reserved for the ideal state: every mutation was killed, meaning every example value change was detected by the acceptance tests.

### Examples

**Incorrect (non-standard options and missing exit-code contract):**

```sh
# wrong flag names, no defined exit codes
gherkin-mutator --input features/a.feature --out build/ --parallel 4
echo $?  # returns 0 on survived mutations — CI does not catch gaps
```

**Correct (spec-compliant options and three exit codes):**

```sh
gherkin-mutator --feature features/a.feature --work-dir build/acceptance-mutation --workers 4 --timeout 5m --json
# exit 0 = all killed, exit 1 = survived or error, exit 2 = usage error
echo $?
```

### Why Workers < 1 Becomes 1

Rather than erroring on invalid worker counts, the spec normalizes to 1. This is defensive — a misconfigured script that passes `--workers 0` should still run mutations, just sequentially. The error exit code (2) is reserved for actual usage mistakes like unknown flags.

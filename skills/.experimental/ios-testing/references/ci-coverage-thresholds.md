---
title: "Set Coverage Thresholds for Critical Paths"
impact: LOW
impactDescription: "prevents coverage regression on key modules"
tags: ci, coverage, thresholds, quality-gate, xcodebuild
---

## Set Coverage Thresholds for Critical Paths

Without enforced thresholds, test coverage silently declines as features ship without tests. Adding a CI quality gate that checks coverage percentages for critical modules after each build catches regressions at PR time, ensuring payment, auth, and data integrity paths never drop below the team-agreed minimum.

**Incorrect (no coverage enforcement, silent regression):**

```yaml
# .github/workflows/ci.yml
name: CI
on: [pull_request]

jobs:
  test:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          xcodebuild test \
            -scheme App \
            -destination 'platform=iOS Simulator,name=iPhone 16' \
            # no -enableCodeCoverage flag — coverage not even collected
```

**Correct (coverage collected and enforced per module):**

```yaml
# .github/workflows/ci.yml
name: CI
on: [pull_request]

jobs:
  test:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Run tests with coverage
        run: |
          xcodebuild test \
            -scheme App \
            -destination 'platform=iOS Simulator,name=iPhone 16' \
            -enableCodeCoverage YES \
            -resultBundlePath TestResults.xcresult
      - name: Enforce coverage thresholds
        run: |
          # Extract coverage per target from the result bundle
          xcrun xccov view --report --json TestResults.xcresult > coverage.json

          # Check critical module thresholds
          check_threshold() {
            local target="$1"
            local minimum="$2"
            local actual
            actual=$(python3 -c "
          import json, sys
          data = json.load(open('coverage.json'))
          for t in data['targets']:
              if t['name'] == '${target}':
                  print(f\"{t['lineCoverage'] * 100:.1f}\")
                  sys.exit(0)
          print('0.0')
          ")
            echo "${target}: ${actual}% (minimum: ${minimum}%)"
            if (( $(echo "${actual} < ${minimum}" | bc -l) )); then
              echo "FAIL: ${target} coverage ${actual}% is below ${minimum}% threshold"
              return 1
            fi
          }

          failed=0
          check_threshold "PaymentModule" 90 || failed=1  # payment paths must stay above 90%
          check_threshold "AuthModule" 85 || failed=1
          check_threshold "DataModule" 80 || failed=1
          exit $failed
```

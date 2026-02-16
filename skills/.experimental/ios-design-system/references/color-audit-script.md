---
title: Audit for Ungoverned Colors with a Build Script
impact: CRITICAL
impactDescription: a 5-line grep catches 100% of Color(hex:), Color(red:), and Color(.sRGB) escaping the token system — without it, ungoverned colors accumulate silently
tags: color, audit, governance, build-script, automation
---

## Audit for Ungoverned Colors with a Build Script

Design token governance requires enforcement. Documented guidelines alone do not prevent developers from typing `Color(hex: "#333")` in a view — especially under deadline pressure. A build phase script or linter rule that flags raw color initializers in view code catches violations at build time, before they reach code review. The script exempts the design system's own token definition files where raw values are expected.

**Incorrect (no enforcement — ungoverned colors accumulate):**

```swift
// No build script, no linter rule.
// Over 6 months, the codebase accumulates:

// Features/Profile/ProfileView.swift
.foregroundStyle(Color(hex: "#2D3436"))

// Features/Feed/FeedCardView.swift
.background(Color(red: 0.95, green: 0.95, blue: 0.97))

// Features/Settings/SettingsView.swift
.foregroundStyle(Color(.sRGB, red: 0.56, green: 0.56, blue: 0.58))

// Features/Chat/MessageBubble.swift
.background(Color(hex: "#E8F5E9"))

// Nobody notices. 40+ ungoverned colors across the codebase.
// Dark mode is broken in 12 places. Rebrand will miss these.
```

**Correct (build phase script catches violations):**

```bash
#!/bin/bash
# Build Phase: "Check Ungoverned Colors"
# Add via Xcode → Target → Build Phases → New Run Script Phase
# Place AFTER "Compile Sources" phase

# Directories to scan (your feature/view code)
SCAN_DIRS="${SRCROOT}/Sources ${SRCROOT}/Features ${SRCROOT}/Views"

# Directories to exclude (where raw color values are allowed)
EXCLUDE_DIR="DesignSystem"

# Patterns that indicate ungoverned colors
PATTERNS=(
    'Color(hex:'
    'Color(red:'
    'Color(.sRGB'
    'Color(hue:'
    'Color(.displayP3'
    'UIColor(red:'
    'UIColor(hex:'
    '#colorLiteral'
)

FOUND_VIOLATIONS=0

for pattern in "${PATTERNS[@]}"; do
    RESULTS=$(grep -rn "$pattern" \
        --include="*.swift" \
        --exclude-dir="$EXCLUDE_DIR" \
        --exclude-dir="Tests" \
        --exclude-dir=".build" \
        $SCAN_DIRS 2>/dev/null)

    if [ -n "$RESULTS" ]; then
        echo "error: Ungoverned color found. Use semantic tokens from DesignSystem instead."
        echo "$RESULTS" | while IFS= read -r line; do
            FILE=$(echo "$line" | cut -d: -f1)
            LINE_NUM=$(echo "$line" | cut -d: -f2)
            echo "$FILE:$LINE_NUM: error: Ungoverned color: $pattern — Replace with a semantic token (.textPrimary, .backgroundSurface, etc.)"
        done
        FOUND_VIOLATIONS=1
    fi
done

if [ "$FOUND_VIOLATIONS" -eq 1 ]; then
    exit 1
fi
```

**For SwiftLint-based enforcement**, see [`govern-lint-for-tokens`](govern-lint-for-tokens.md) which provides comprehensive SwiftLint custom rules covering colors, spacing, typography, and radii.

**CI integration for comprehensive auditing:**

```swift
// Tests/DesignSystemTests/ColorGovernanceTests.swift
import XCTest

final class ColorGovernanceTests: XCTestCase {
    func testNoUngovernedColorsInFeatureCode() throws {
        let sourceRoot = ProcessInfo.processInfo.environment["SRCROOT"] ?? "."
        let featuresPath = "\(sourceRoot)/Features"

        let ungovernedPatterns = [
            "Color(hex:",
            "Color(red:",
            "Color(.sRGB",
            "Color(hue:",
            "#colorLiteral",
        ]

        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: featuresPath)
        var violations: [(file: String, line: Int, pattern: String)] = []

        while let file = enumerator?.nextObject() as? String {
            guard file.hasSuffix(".swift") else { continue }
            let fullPath = "\(featuresPath)/\(file)"
            let contents = try String(contentsOfFile: fullPath, encoding: .utf8)
            let lines = contents.components(separatedBy: .newlines)

            for (index, line) in lines.enumerated() {
                for pattern in ungovernedPatterns {
                    if line.contains(pattern) {
                        violations.append((file: file, line: index + 1, pattern: pattern))
                    }
                }
            }
        }

        XCTAssertTrue(
            violations.isEmpty,
            "Found \(violations.count) ungoverned color(s):\n" +
            violations.map { "  \($0.file):\($0.line) — \($0.pattern)" }.joined(separator: "\n")
        )
    }
}
```

**Benefits:**
- Violations are caught at build time, not in code review (faster feedback)
- SwiftLint integration shows inline Xcode warnings with fix suggestions
- CI test ensures no regressions even if local build scripts are skipped
- Exemption for DesignSystem directory keeps the system's own definitions clean
- New team members cannot accidentally bypass the token system

Reference: [SwiftLint Custom Rules](https://realm.github.io/SwiftLint/custom_rules.html), [Xcode Build Phases — Apple Developer](https://developer.apple.com/documentation/xcode/running-custom-scripts-during-a-build)

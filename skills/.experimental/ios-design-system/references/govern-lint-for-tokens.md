---
title: Use SwiftLint Rules to Enforce Token Usage
impact: MEDIUM
impactDescription: without automated enforcement, token discipline erodes within 2 sprints — a custom SwiftLint rule catches 100% of violations at PR time
tags: govern, swiftlint, automation, enforcement, ci
---

## Use SwiftLint Rules to Enforce Token Usage

Code review catches design token violations when reviewers remember to look for them. SwiftLint catches them every time. After the initial effort of defining tokens, the hardest part is ensuring the team actually uses them. Custom SwiftLint rules turn token compliance from a social contract into an automated gate.

**Incorrect (relying solely on manual code review):**

```swift
// These violations slip through review because they "look fine" and compile cleanly

struct PaymentCard: View {
    var body: some View {
        VStack(spacing: 12) {                             // Hardcoded value, not Spacing token
            Text("Payment Method")
                .font(.system(size: 17, weight: .semibold))  // Hardcoded font, not text style
                .foregroundStyle(Color(hex: "#1C1C1E"))       // Literal color, not token

            cardContent
        }
        .padding(20)                                       // Hardcoded value
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))  // Color literal
        .clipShape(RoundedRectangle(cornerRadius: 16))     // Hardcoded radius
    }
}
```

**Correct (SwiftLint rules flag violations automatically):**

```yaml
# .swiftlint.yml

custom_rules:
  # Flag raw numeric padding values — should use Spacing tokens
  no_literal_padding:
    regex: '\.padding\(\s*\d'
    message: "Use Spacing tokens (Spacing.sm, .md, .lg) instead of literal values. See DesignSystem/Tokens/Spacing.swift"
    severity: warning

  # Flag raw numeric spacing in stacks — should use Spacing tokens
  no_literal_spacing:
    regex: '(VStack|HStack|LazyVStack|LazyHStack)\(spacing:\s*\d'
    message: "Use Spacing tokens instead of literal values for stack spacing"
    severity: warning

  # Flag Color(hex:), Color(red:), Color(#...) — should use asset catalog tokens
  no_color_literal:
    regex: 'Color\((hex:|red:\s|#)'
    message: "Use semantic color tokens from Colors.xcassets instead of literal colors"
    severity: error

  # Flag Font.system(size:) outside DesignSystem directory — should use text styles
  no_hardcoded_font_size:
    regex: 'Font\.system\(size:'
    message: "Use system text styles (.headline, .body) or AppTypography tokens instead of hardcoded font sizes"
    severity: warning
    excluded: "Sources/DesignSystem/.*"

  # Flag hardcoded corner radius — should use Radius tokens
  no_literal_radius:
    regex: 'cornerRadius:\s*\d'
    message: "Use Radius tokens (Radius.sm, .md, .lg) instead of literal values"
    severity: warning
    excluded: "Sources/DesignSystem/.*"

  # Flag Color("string") usage — should use typed Color extensions
  no_raw_color_string:
    regex: 'Color\("'
    message: "Use typed Color extensions (.backgroundPrimary) instead of Color(\"string\"). See DesignSystem/Tokens/Colors.swift"
    severity: warning
    excluded: "Sources/DesignSystem/.*"
```

```swift
// After enabling rules, the same code triggers clear warnings:

struct PaymentCard: View {
    var body: some View {
        VStack(spacing: 12) {                  // ⚠️ Use Spacing tokens instead of literal values
            Text("Payment Method")
                .font(.system(size: 17))       // ⚠️ Use system text styles or AppTypography
                .foregroundStyle(Color(hex: "#1C1C1E"))  // ❌ Use semantic color tokens

            cardContent
        }
        .padding(20)                           // ⚠️ Use Spacing tokens
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))  // ❌ Use semantic color tokens
        .clipShape(RoundedRectangle(cornerRadius: 16))           // ⚠️ Use Radius tokens
    }
}

// Fixed version — zero violations:
@Equatable
struct PaymentCard: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text("Payment Method")
                .font(.headline)
                .foregroundStyle(.labelPrimary)

            cardContent
        }
        .padding(Spacing.lg)
        .background(.backgroundSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
```

**CI integration:**

```bash
# In CI pipeline (e.g., GitHub Actions)
- name: Lint design system compliance
  run: swiftlint lint --reporter github-actions-logging
```

The `excluded: "Sources/DesignSystem/.*"` pattern is critical — token definitions themselves necessarily use raw values. Only feature code should be linted for token compliance.

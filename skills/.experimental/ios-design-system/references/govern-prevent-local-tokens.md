---
title: Prevent Feature Modules from Defining Local Design Tokens
impact: MEDIUM
impactDescription: local constants in feature modules become permanent shadow tokens — catching them early prevents 80% of design drift
tags: govern, local-tokens, drift, enforcement, pr-review
---

## Prevent Feature Modules from Defining Local Design Tokens

Shadow tokens start innocently: a developer creates `CheckoutColors.cardBackground` because they don't know `Color.backgroundSurface` exists, or they think their feature "temporarily" needs a slightly different value. Within two sprints, the shadow token is referenced by five views and no one remembers it was meant to be temporary. It now diverges from the system without anyone noticing.

**Incorrect (feature modules defining their own design constants):**

```swift
// Features/Checkout/CheckoutConstants.swift — shadow tokens
enum CheckoutLayout {
    static let cardPadding: CGFloat = 16       // Duplicates Spacing.md
    static let sectionSpacing: CGFloat = 24     // Duplicates Spacing.lg
    static let buttonCornerRadius: CGFloat = 12 // Duplicates Radius.md
}

// Features/Checkout/CheckoutColors.swift — shadow color tokens
extension Color {
    static let checkoutBackground = Color(hex: "#F5F5F5")  // Duplicates backgroundSecondary
    static let checkoutAccent = Color(hex: "#14B8A6")       // Duplicates accentPrimary
    static let checkoutCardBg = Color(hex: "#FFFFFF")       // Duplicates backgroundSurface
}

// Features/Profile/ProfileStyles.swift — more shadow tokens
enum ProfileStyles {
    static let headerPadding: CGFloat = 16     // Another Spacing.md duplicate
    static let avatarRadius: CGFloat = 32      // Local to one component, fine
    static let sectionSpacing: CGFloat = 20    // Differs from Spacing.lg (24) — intentional? Bug?
}
```

**Correct (feature modules consume system tokens, request new tokens when needed):**

```swift
// Features/Checkout/CheckoutView.swift — uses system tokens directly
struct CheckoutView: View {
    let cart: Cart

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {        // System token
                CartSummaryCard(cart: cart)
                PaymentMethodSection()
                PlaceOrderButton(total: cart.total)
            }
            .padding(Spacing.md)                  // System token
        }
        .background(.backgroundSecondary)         // System token
    }
}

struct CartSummaryCard: View {
    let cart: Cart

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ForEach(cart.items) { item in
                CartItemRow(item: item)
            }
            Divider()
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(cart.total.formatted(.currency(code: "GBP")))
                    .font(.headline)
            }
        }
        .padding(Spacing.md)                      // System token
        .background(.backgroundSurface)           // System token
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))  // System token
    }
}

// If a feature genuinely needs a value that doesn't exist in the system,
// add it to the DesignSystem directory through a PR:

// DesignSystem/Tokens/Spacing.swift (updated via PR #312)
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    // Added for checkout flow card grid — approved in design review
    static let cardGrid: CGFloat = 20
}
```

**Enforcement strategies (layered):**

```yaml
# 1. SwiftLint — catches most violations automatically
# .swiftlint.yml
custom_rules:
  no_local_cgfloat_constants:
    regex: 'static let \w+:\s*CGFloat\s*='
    included: "Sources/Features/.*"
    excluded: "Sources/DesignSystem/.*"
    message: "Design tokens must be defined in DesignSystem/Tokens/. If this is a component-specific dimension (not a design token), add a // swiftlint:disable:this comment with justification."
    severity: warning

  no_local_color_extensions:
    regex: 'extension Color \{'
    included: "Sources/Features/.*"
    message: "Color extensions must be defined in DesignSystem/Tokens/Colors.swift"
    severity: error
```

```swift
// 2. PR review checklist (CODEOWNERS)
// .github/CODEOWNERS
Sources/DesignSystem/ @design-system-team

// Any change to DesignSystem/ requires approval from the design system maintainers
// This prevents unreviewed token additions
```

```swift
// 3. Component-specific dimensions are fine — document them clearly
struct AvatarView: View {
    // Component dimension, not a design token — specific to avatar rendering
    // Not derived from spacing scale because it matches the avatar image size
    private let diameter: CGFloat = 64

    var body: some View {
        AsyncImage(url: avatarURL) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.backgroundSecondary
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
    }
}
```

The distinction is: **design tokens** (values that participate in the visual system — spacing, colors, radii, type) belong in `DesignSystem/`. **Component dimensions** (avatar size, chart height, map pin offset) that are specific to one component's rendering logic are fine as local constants.

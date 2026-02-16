---
title: Separate Brand Identity from Design System Mechanics
impact: MEDIUM
impactDescription: reduces rebrand effort from N component file changes to 1 asset catalog update — components reference semantic roles, not brand values
tags: theme, brand, separation, architecture, rebranding
---

## Separate Brand Identity from Design System Mechanics

A design system has two layers: the **mechanical layer** (roles like `accentPrimary`, `backgroundSurface`, spacing scales, radius tokens) and the **brand layer** (the specific hex values, font choices, and radius sizes that express a particular brand). When component code references the role, not the brand value, rebranding becomes a palette swap — zero component code changes.

**Incorrect (brand values hardcoded into component code):**

```swift
// Components reference brand-specific names and literal values
struct MembershipCard: View {
    let member: Member

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(member.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("brandTealGreen"))     // Brand name in component

            Text("Member since \(member.joinDate.formatted())")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "#6B7280"))       // Literal hex value

            Divider()
                .background(Color(hex: "#E5E7EB"))           // Another literal
        }
        .padding(16)
        .background(Color(hex: "#F0FDFA"))                   // Brand-specific background
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Rebranding from teal to indigo means finding and replacing every
// "brandTealGreen", "#F0FDFA", etc. across ALL component files
```

**Correct (components reference semantic roles, brand layer assigns values):**

```swift
// Layer 1: Design System — defines semantic roles (in DesignSystem/Tokens/)
extension ShapeStyle where Self == Color {
    // Roles — what the color DOES, not what it LOOKS LIKE
    static var accentPrimary: Color { Color("accentPrimary") }
    static var backgroundPrimary: Color { Color("backgroundPrimary") }
    static var backgroundSurface: Color { Color("backgroundSurface") }
    static var labelPrimary: Color { Color("labelPrimary") }
    static var labelSecondary: Color { Color("labelSecondary") }
    static var separatorOpaque: Color { Color("separatorOpaque") }
}

// Layer 2: Brand — assigns values to roles (in Colors.xcassets)
// accentPrimary.colorset → #14B8A6 (teal-500)
// backgroundSurface.colorset → #F0FDFA (teal-50)
// This is the ONLY place brand-specific values live

// Layer 3: Components — reference roles exclusively
@Equatable
struct MembershipCard: View {
    let member: Member

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(member.name)
                .font(.headline)
                .foregroundStyle(.accentPrimary)              // Semantic role

            Text("Member since \(member.joinDate.formatted())")
                .font(.subheadline)
                .foregroundStyle(.labelSecondary)              // Semantic role

            Divider()
        }
        .padding(Spacing.md)
        .background(.backgroundSurface)                       // Semantic role
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}

// REBRANDING: Change accentPrimary from #14B8A6 (teal) to #6366F1 (indigo)
// in Colors.xcassets. Zero code changes. Every component updates automatically.
```

**The three-layer architecture:**

```text
┌─────────────────────────────────────────┐
│  Components (reference roles)           │  MembershipCard, OrderRow, ProfileHeader
│  .foregroundStyle(.accentPrimary)       │  → Never changes during rebrand
├─────────────────────────────────────────┤
│  Design System (defines roles)          │  Color.accentPrimary, Spacing.md, Radius.lg
│  static let accentPrimary = Color(...)  │  → Stable interface, rarely changes
├─────────────────────────────────────────┤
│  Brand Layer (assigns values to roles)  │  Colors.xcassets: accentPrimary → #14B8A6
│  Asset catalog + token value files      │  → Only layer that changes during rebrand
└─────────────────────────────────────────┘
```

This separation also makes it possible to preview components under different brand palettes by swapping the asset catalog at build time — useful for whitelabel apps or seasonal promotions.

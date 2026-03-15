---
name: ios-taste
description: >
  Designs iOS 18+ SwiftUI experiences with real taste — starting from
  user goals, not pixels. Use this skill whenever the user asks you to
  build SwiftUI views, screens, or experiences. Trigger when the user
  says "build a settings screen", "create a detail view", "design
  this properly", "I want this to feel like a native app", or any
  SwiftUI UI task. Also trigger when reviewing SwiftUI code for design
  quality, or when the user says the output "looks like a demo" or
  "feels generic." When building any user-facing SwiftUI view, lean
  toward triggering this skill.
---

# iOS Taste

Taste doesn't start at the pixel level. It starts at "who is this
person and what do they need?" The visual refinement is the LAST step.
The first step is understanding the user's world deeply enough that
the interface design feels inevitable — like it couldn't have been
designed any other way.

Your default mode skips straight to layout. It produces technically
correct SwiftUI that looks generic because it was never grounded in
a real person's needs. This skill changes the order of operations:
think like a designer first, then write code.

## Phase 1: Design Thinking (Before You Touch SwiftUI)

Before writing a single line of code, answer these questions. Write
the answers down as comments or in your thinking. If you skip this
phase, your output will look like every other AI-generated UI —
correct but soulless.

### 1. Who is the user?

Not "a fitness enthusiast." A real person with a context:

- What moment are they in when they open this screen? (Rushing
  between meetings? Relaxing on the couch? Mid-workout?)
- What did they just do before arriving here? (Finished a run?
  Browsed a list? Got a notification?)
- What do they want to accomplish in under 10 seconds?

This shapes EVERYTHING. A user mid-workout needs giant tap targets
and glanceable data. A user browsing recipes at home wants rich
detail and discovery. A user configuring settings wants to find the
one toggle they care about and leave.

### 2. What should they FEEL?

This is the question that separates designed apps from information
displays. Apple Fitness doesn't show you data — it motivates you to
move. Every design choice serves that emotional goal.

Before choosing components, decide the emotional intent:
- **Motivated** → bold colors, progress visualization, celebration
  moments, large achievement numbers
- **Calm / focused** → muted tones, generous space, subtle motion
- **Efficient** → compact layouts, clear hierarchy, minimal chrome
- **Delighted** → unexpected animation, rich materials, playful
  moments (achievement badges, confetti, 3D icons)
- **Confident** → clean data presentation, trust colors (blue/green),
  professional typography

The emotional intent drives every visual decision downstream: color
palette, scale, spacing, whether data is listed or visualized,
whether the screen feels dense or spacious.

### 3. What are their goals and pain points?

For each screen, identify:
- **Primary goal** — the ONE thing most users come here to do
- **Secondary goals** — things some users occasionally need
- **Pain points** — what frustrates users in this domain?

A fitness settings screen: the primary goal isn't "see all settings."
It's "change the one thing that's been bugging me" — maybe the
weekly goal is too low, or notifications come at the wrong time. The
pain point is wading through 30 options to find the one they need.

### 3. What features serve those goals?

Map goals to features. Not "what features could this screen have?"
but "what's the minimum set of features that makes the primary goal
effortless?" Every feature that doesn't serve a goal is clutter.

Group features by priority:
- **Must-have** — blocks the primary goal without it
- **Should-have** — significantly improves the experience
- **Could-have** — nice but the user doesn't miss it if it's absent

### 4. How do features become screens?

This is information architecture — deciding what goes where:

- **One primary action per screen.** If a screen tries to do two
  things, split it into two screens or use progressive disclosure.
- **Group by user intent, not by data type.** A user doesn't think
  "I want to see my notification settings." They think "I want my
  phone to stop buzzing during workouts." Group features by the
  problem they solve, not by their technical category.
- **Navigation follows the user's mental model.** Settings → Profile
  is obvious. Settings → "Health Integrations" → Apple Health → Data
  Permissions is three levels deep for something the user sets once.
  Consider whether it needs its own screen or can be inline.

### 5. What components serve each feature?

NOW you think about SwiftUI — but through the lens of user intent:

- **Toggle** vs **Picker** — if the choice is binary, use Toggle. If
  there are 3+ options, use Picker. If the options need explanation,
  use a navigation link to a selection screen.
- **Stepper** vs **Slider** — steppers for precise numeric values
  (1, 2, 3 reps). Sliders for ranges where the exact value matters
  less (brightness, volume, a weekly hour target).
- **Inline** vs **Push navigation** — show detail inline when it's
  1-2 lines. Push to a new screen when the detail is rich enough to
  deserve its own context.
- **Sheet** vs **Push** — sheets for self-contained tasks (compose,
  edit profile, filter). Push for drilling into hierarchical content.
- **List** vs **ScrollView** — List for homogeneous collections
  (contacts, settings, messages). ScrollView for heterogeneous
  layouts (a recipe detail with hero image, ingredients, and steps).

The component choice IS the design. A slider for a weekly workout
goal feels exploratory and forgiving. A stepper for the same value
feels precise and clinical. Neither is wrong — the right choice
depends on who the user is and what moment they're in.

## Phase 2: Visual Design

After Phase 1, you know who the user is, what they need, how they
should feel, and what components serve those needs. Now make it
beautiful. The emotional intent from Phase 1 drives every choice here.

### 1. Hierarchy Through Scale

Not just font weight — dramatic scale contrast. The most important
thing on screen should be *physically large*, not just bold.

- **Hero numbers at display scale** — a calorie count, a step count,
  a price should dominate the screen. Use `.system(size: 64)` or
  `.largeTitle` with `.fontDesign(.rounded)`. Apple Fitness shows
  "120" as 40% of the screen. Don't shrink important data into a row.
- **Supporting text whispers** — everything that isn't the hero
  element gets `.caption` or `.footnote` in `.secondary`. The
  contrast between the hero and the support IS the hierarchy.
- **Space as luxury** — leave empty areas. A number floating in a
  sea of black or white is more powerful than the same number
  crammed into a dense list. Space communicates importance.

### 2. Color Is Math, Not Vibes

NEVER pick colors individually. Color harmony is a solved problem —
derive your entire palette from ONE seed hue using HSB math. This is
what every professional design system does (Material Design, Apple
HIG). The formula:

```swift
// ONE seed hue per app (0...1). Everything derives from this.
let seed: Double = 0.05  // e.g. warm terracotta for cooking

// Core palette — analogous harmony (within ±30° of seed)
let primary   = Color(hue: seed, saturation: 0.70, brightness: 0.85)
let secondary = Color(hue: seed + 0.08, saturation: 0.50, brightness: 0.80)
let accent    = Color(hue: seed + 0.50, saturation: 0.65, brightness: 0.85)

// Light mode cards: LOW saturation, HIGH brightness
let cardLight = Color(hue: seed, saturation: 0.08, brightness: 0.96)

// Dark mode cards: LOW brightness — colors glow on black
let cardDark  = Color(hue: seed, saturation: 0.15, brightness: 0.15)

// Collections: vary items WITHIN the analogous range
func itemColor(index: Int, count: Int) -> Color {
    let h = seed + (Double(index) / Double(count)) * 0.16 - 0.08
    return Color(hue: h, saturation: 0.55, brightness: 0.82)
}
```

Rules that never break:
- **One seed hue per app.** A cooking app = warm (seed ~0.05). A
  finance app = blue (seed ~0.6). A fitness app = green (seed ~0.35).
- **Collections use analogous variations**, not random hues. A recipe
  grid should feel like one family (terracotta, amber, rust, clay) —
  not a rainbow.
- **Light mode: desaturate.** Saturation 0.08–0.15 for backgrounds,
  0.40–0.60 for accents. Let content pop, not containers.
- **Dark mode: saturate.** Saturation 0.60–0.90 for accents on black.
  Neon on black always works. Pastels on black look washed out.
- **Contrast is non-negotiable.** White text needs background
  brightness ≤ 0.55. Dark text needs brightness ≥ 0.45. If text
  is hard to read, the color fails regardless of how pretty it is.

Never use `Color.red`, `Color.green`, `Color.blue` directly as
palette colors — they're semantic system colors for status. Build
your palette from `Color(hue:saturation:brightness:)` so every
color is mathematically related to the seed.

### 3. Show Data, Don't List It

When data is the content (fitness metrics, financial stats,
progress), VISUALIZE it instead of putting it in a label:
- **Rings and gauges** for progress toward a goal
- **Sparkline charts** for trends over time
- **Large hero numbers** with unit labels in small caps
- **Color-coded bars** for composition (macro nutrients, time split)

A `LabeledContent("Steps", value: "8,432")` is information. A large
"8,432" in `.title` with a sparkline below it is an *experience*.
The emotional intent from Phase 1 tells you which one to use.

### 4. Card-Based Composition

Don't default to `.insetGrouped` List for everything. Compose with
rounded rect containers when the content is heterogeneous:
- Cards with `RoundedRectangle(cornerRadius: 16)` and
  `.fill(.secondary.opacity(0.15))` on dark backgrounds
- Each card is a self-contained visual unit with its own hierarchy
- Cards can have gradient backgrounds for visual richness (like
  Apple Fitness+ Plans cards)
- Use `LazyVGrid` or `LazyVStack` inside a `ScrollView` for
  card-based layouts

Lists are for homogeneous rows (contacts, messages, settings).
Cards are for dashboards, summaries, and content-rich screens.

### 5. Content Realism

The data IS the design. Every preview tells a coherent story:

- Real names ("Elena Marsh"), plausible numbers ("$47.83", "4.3"),
  varied lengths, temporal realism ("2 hours ago", "Yesterday")
- Data relationships that make sense (Designer → Design dept)
- If your preview data looks fake, your design looks fake

### 6. Restraint

What you leave out defines taste. No instruction headers. No uniform
icons. No tutorial overlays. No demo naming. For every element, ask:
"what happens if I remove this?" If nothing — remove it.

### 4. Craft

The invisible details that feel right:
- `.monospacedDigit()` on changing numbers
- `@ScaledMetric` on custom sizes
- `.contentTransition(.numericText())` on counters
- `.sensoryFeedback()` on meaningful state changes (not haptic spam)
- `LabeledContent` for key-value pairs
- Accessibility as design, not compliance

### 5. Character

Each screen has a distinct personality. Character comes from:
- Domain-appropriate containers and color palettes
- Content-specific typography and interaction patterns
- Cover the nav bar — can you still tell what app this is?

## Applying Both Phases

When asked to build a SwiftUI view:

1. **Phase 1** — Think through the user, their goals, feature
   groupings, screen structure, and component choices. Write brief
   notes (as code comments or in your response) showing your design
   reasoning. This is not optional — it's what separates a designed
   experience from a decorated layout.

2. **Phase 2** — Write the SwiftUI code with all five fundamentals
   applied. Start with realistic data models and preview content.
   Build minimal, add only what earns its place, then polish with
   craft details.

3. **Self-check** — Before finishing, ask: "Would a real user using
   this app in the moment I identified in Phase 1 feel like this
   screen was designed for them?" If not, something in Phase 1 was
   wrong — go back.

## What "No Taste" Looks Like

```swift
// NO TASTE — jumped straight to layout, no user thinking
struct DemoView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Instructions") {
                    Text("This demo shows how lists work")
                }
                Section("Items") {
                    ForEach(1...5, id: \.self) { i in
                        HStack {
                            Image(systemName: "star")
                            Text("Item \(i)")
                            Spacer()
                            Text("Detail")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Demo")
        }
    }
}
```

No user thinking. No goals. Instruction header. Uniform icons.
Numbered placeholders. Generic naming. No character.

## What Taste Looks Like

```swift
// GOLDEN — Weather-inspired fitness dashboard
// User: Alex, 28, just finished a morning run, wants to see today's stats
// Emotional intent: MOTIVATED — celebrate the effort, inspire tomorrow
// Hero: calorie ring dominating the top half
struct FitnessCardView: View {
    let calories: Int = 847
    let goal: Int = 1000

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero ring — 40% of visible screen, not a row in a list
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 20)
                    Circle()
                        .trim(from: 0, to: Double(calories) / Double(goal))
                        .stroke(calorieGradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 4) {
                        Text("\(calories)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                        Text("of \(goal) cal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 220, height: 220)
                .padding(.top, 20)

                // Stat cards — NOT LabeledContent rows
                HStack(spacing: 12) {
                    statCard("Distance", value: "5.2 km", color: .blue)
                    statCard("Time", value: "28:14", color: .green)
                    statCard("Pace", value: "5'26\"", color: .orange)
                }
            }
            .padding()
        }
    }

    private func statCard(_ label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1), in: .rect(cornerRadius: 12))
    }

    private var calorieGradient: AngularGradient {
        AngularGradient(colors: [.red, .orange, .yellow], center: .center)
    }
}
```

Design comment explains user moment and emotional intent. Hero ring
dominates the screen (not a ProgressView in a List row). Stat cards use
color backgrounds, not LabeledContent. You know this is a fitness app
without reading the title — the ring IS the identity.

## Component Palette Quick Reference

When you instinctively reach for a tutorial component, STOP:

| NEVER (reflex) | GOLDEN (reach for this instead) |
|----------------|-------------------------------|
| `List` + `ForEach` | `ScrollView` + `LazyVStack` with cards |
| `Form` + `Section` | `ScrollView` + `GroupBox(.regularMaterial)` |
| `LabeledContent` for metrics | Hero typography `.system(size:design:.rounded)` |
| `ProgressView` | `Circle().trim(from:to:)` or `Canvas` |
| `Button("Label")` | `.borderedProminent` + `.controlSize(.large)` |
| `Toggle` in `Section` | Segmented control or custom pill |
| `.system(size:)` for text | `.largeTitle` / `.title` + `.fontDesign(.rounded)` |
| Default `List` background | Gradients, `.regularMaterial`, colored containers |

Modern iOS 18+ APIs to reach for: `MeshGradient`, `.scrollTransition`,
`.containerRelativeFrame`, `.visualEffect`, `Canvas`, `TimelineView`,
`.scrollTargetBehavior(.paging)`, `UnevenRoundedRectangle`.

Apple reference: Weather (gradient cards), Stocks (hero charts), Health
(colored rings), Fitness (activity cards), Journal (photo cards),
Contacts (gradient posters, glass avatars, per-entity color identity).

## The Screen Becomes the Content

Study iOS Contacts: the detail view isn't a form with a contact's
data. The entire screen IS the contact — a full-bleed gradient that
matches the person's avatar color, a glass-bordered monogram, the
name in massive bold type. It's a poster, not a record.

This is the highest level of taste: the UI dissolves into the
content. The screen doesn't frame the data — it becomes the data.

Techniques for this:
- **Per-entity gradients** — each contact, playlist, or recipe gets
  its own color identity. Use `MeshGradient` or `LinearGradient`
  derived from the entity's accent color. The background extends
  behind the navigation bar with `.ignoresSafeArea()`.
- **Glass and material layering** — avatar circles with
  `.stroke(.ultraThinMaterial)` borders. Action buttons in
  `.ultraThinMaterial` circles. Cards using `.regularMaterial` that
  let the gradient show through. Depth without shadows.
- **Smart typography in lists** — Apple Contacts bolds the LAST name
  and leaves the first name regular weight. This tiny detail makes
  alphabetical scanning dramatically faster. Find the equivalent
  typographic hierarchy for your domain.
- **Edit mode preserves beauty** — even the Contacts edit form uses
  dark cards, colored action buttons (red minus, green plus), and
  the same avatar hero. Edit mode should never degrade to a generic
  form — it maintains the visual language of the view mode.

## The Mindset

You are not a developer who can also design. You are a designer who
thinks about people first and expresses the result in SwiftUI. The
code is the medium. The product is the moment when a human picks up
their phone and the interface feels like it was made just for them.

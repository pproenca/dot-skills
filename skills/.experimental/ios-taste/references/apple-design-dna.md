# Apple Design DNA — Cross-App Synthesis

Extracted from systematic crawling of Apple Fitness, Apple Contacts,
and Apple Weather. Sources: iOS 26.2 simulator + real iPhone 16 Pro Max
(iOS 26.3.1) via WebDriverAgent, March 2026.

## The Three Modes of Apple App Design

### Mode 1: Dashboard (Fitness)
- **Background**: Pure black (#000000)
- **Content**: Cards floating on void
- **Data**: Visualizations (rings, sparklines, trend arrows)
- **Emotion**: Engagement, motivation, identity
- **Typography**: Large values in accent color, small labels in gray
- **Navigation**: Tab bar + card drill-down
- **Use when**: The app's purpose is monitoring, tracking, or progress

### Mode 2: Utility (Contacts)
- **Background**: System/light OR poster gradient
- **Content**: List rows with standard patterns
- **Data**: Structured text (labels + values)
- **Emotion**: Efficiency, familiarity, trust
- **Typography**: Bold key identifier (last name), regular secondary
- **Navigation**: Standard push/pop list-detail
- **Use when**: The app's purpose is finding, managing, or organizing

### Mode 3: Ambient (Weather)
- **Background**: Dynamic atmospheric gradient (the sky IS the app)
- **Content**: Frosted glass module cards on the sky
- **Data**: Per-module visualizations (gauges, compasses, arcs, maps)
- **Emotion**: Immersive, ambient, atmospheric
- **Typography**: Temperature at impossible scale (~121pt), whispered labels
- **Navigation**: Horizontal page swipe between cities, vertical scroll for modules
- **Use when**: The app's purpose is ambient awareness or environmental monitoring

## Universal Design Principles

### 1. The Screen IS The Content
Both apps demonstrate this: Fitness makes the Activity Ring the visual
identity of the app. Contacts makes the poster gradient the person's
visual identity. In neither case is the content "placed on" a background
— the content IS the background.

### 2. One Accent Color, Used Sparingly
Fitness uses neon green (#A8FF00) in exactly these places:
- Profile avatar ring
- CTA buttons (filled)
- Active tab bar icon
- Metric values
That's it. Four placements across the entire app.

### 3. Card vs Row Grammar
- **Card**: Used for dashboard/overview items. Self-contained,
  rounded corners, dark fill, generous padding. Cards say "here's
  a snapshot — tap to dive deeper."
- **Row**: Used for detail/action lists. Full-width, divider-separated,
  minimal padding. Rows say "here's structured data — scan and act."
The transition from card→row signals depth level.

### 4. Onboarding: Two Templates

**Feature List** (Workout tab):
```
Large Title
Subtitle (gray)
[🟢 Icon] Bold Title — Description
[🟢 Icon] Bold Title — Description
[🟢 Icon] Bold Title — Description
Privacy note (small, gray)
[=== Continue ===]
```

**Hero Illustration** (Sharing tab):
```
[Floating circle composition with Memoji/icons]
Large Title (centered)
Description (centered, gray)
Privacy note (small)
[=== Get Started ===]
```
Use Feature List for functionality. Use Hero Illustration for identity/social.

### 5. Button Hierarchy
- **Primary**: Filled with accent color (green for Fitness), dark text
- **Secondary**: Outline in accent color, accent text, transparent fill
- **Tertiary/System**: System blue text, no border
- **Destructive**: Isolated by position (bottom, separate section), NOT red

### 6. Empty States Show Structure
When there's no data, Apple shows the visualization skeleton:
- Empty ring (not "No data" text)
- Chart axes without data points
- Dotted guide lines
The structure teaches the user what data will look like BEFORE they have it.

### 7. Glass-on-Gradient (Contacts Poster)
Detail views can use a gradient background with frosted glass sections:
```
Layer 0: Full-bleed gradient (person's/item's identity)
Layer 1: Semi-transparent frosted cards (grouped actions)
Layer 2: White text on glass
```
This creates depth without cards-on-white and makes utility views feel premium.

### 8. Inline Data Enhancement
Instead of "View on Map →", Contacts embeds a map thumbnail inline.
Instead of "See Trends →", Fitness embeds a sparkline in the metric card.
The preview IS the data. No navigation needed for first-level insight.

### 8b. Modular Card Grid (Weather)
Weather uses a module system where each card has the same anatomy but
a different visualization type:
```
Icon + LABEL (caps, tiny) → Hero Value (large) → Visualization → Natural Language
```
Visualizations include: gradient bars (UV, air quality), compass dial (wind),
sun arc (sunrise/sunset), barometer gauge (pressure), map overlay (wind map),
rendered moon phase, temperature range bars with color gradients.

Full-width modules stack vertically. Half-width modules pair in 2-column rows.
All modules use the same frosted glass material, corner radius, and spacing.

### 8c. Natural Language as Content (Weather)
Most Weather modules include a SENTENCE explaining the number:
- "Wind is making it feel colder."
- "Perfectly clear view."
- "The dew point is 7° right now."
Numbers become understanding. This humanizes data-heavy screens.

### 9. Privacy as Design Element
Both apps handle data/privacy proactively:
- Handshake icon (🤝) for data sharing disclosures
- "About ... & Privacy" links in green
- Disclosures BEFORE the CTA, not after
- AI features default to OFF (opt-in, not opt-out)

### 10. Typography That Scans
- Contacts: Bold LAST name, regular first name → scan by family name
- Fitness: Large COLORED values, small gray labels → scan by numbers
- Both apps optimize for the MOST LIKELY scan pattern of their content

## Measurements Reference

| Element | Size | Notes |
|---------|------|-------|
| Card corner radius | ~16pt | Consistent across both apps |
| Screen edge padding | ~18pt | Content margin from device edge |
| Card internal padding | ~16pt | Content margin inside cards |
| Card vertical gap | ~10pt | Space between stacked cards |
| List row height | ~54pt | Standard content row |
| Monogram circle | ~44pt | List size |
| Monogram circle (detail) | ~120pt | Contact poster size |
| Action button circle | ~58pt | Call, message, etc. |
| Play button | ~45pt | Workout start |
| Metric value font | ~34pt | Step count, distance |
| Card header font | ~17pt | Card titles |
| Section header | ~13pt | A, B, C section letters |
| Tab bar height | ~75pt | Bottom tab bar |

### 11. Haptics as State Transitions (Calendar)
Calendar is the most haptic-rich Apple app. Haptic patterns:
- **Mode change**: Medium impact on long-press (browse → create/edit)
- **Snap points**: Light impact at each 15-minute position during drag
- **Level change**: Medium impact when pinch crosses a zoom boundary
- **Selection**: Selection haptic on day tap

Anti-pattern: haptic on every scroll, every button, every animation.
Calendar uses haptics SURGICALLY — only for mode changes, discrete
positions, and confirmations.

### 12. Time as Visual Space (Calendar)
Calendar uses the Y-axis as a data dimension — vertical position IS time.
This spatial metaphor means:
- Empty space = free time (visible, not just "no events")
- Event height = duration (tall block = long meeting)
- Current time = red "now line" moving down the grid in real-time
- Long-press position → event start time (spatial input, not form input)

### 13. Adaptive Information Density (Calendar)
Calendar offers 4 display modes for the same data: Compact (dots),
Stacked (blocks), Details (Gantt bars), List (text below grid).
The data doesn't change — the representation does. This pattern is
valuable for any data-rich app where users have different density
preferences.

### 14. Hierarchical Zoom (Calendar)
Four zoom levels with pinch transitions: Year → Month → Week → Day.
Each level shows more detail. Today is always marked in RED across
all levels. The zoom feels like temporal cartography — zooming into
time the same way you zoom into a map.

### 16. Semantic Color Per Domain (Health)
Health's 13 categories each have a dedicated color (Activity=orange,
Heart=pink, Sleep=purple, Nutrition=green, etc.). The color persists
everywhere: category icon, list row, detail view labels, chart accents.
This is a DOMAIN COLOR SYSTEM — color encodes content category, not brand.
Different from Fitness (one accent) or Weather (gradient-as-identity).

### 17. Data + Education Inline (Health)
Health embeds educational content ("About Steps" + Mayo Clinic attribution)
directly below data charts. Every metric has its own "About" section.
The app teaches while it tracks. Design lesson: if users might not fully
understand the data, educate inline — not in help overlays.

### 18. Metric Detail Template (Health)
Every Health metric follows: period selector (D/W/M/6M/Y) → summary card
(hero number) → interactive chart (bar/line/scatter varies by data type)
→ educational content → related apps. The chart is ~40% of the screen —
it IS the content, not supplementary.

### 19. Per-Entity Gradient Identity (Weather + Contacts)
Every entity in a collection can have its own visual identity derived
from its DATA, not assigned arbitrarily:
- Weather cities: gradient from current weather conditions
- Contacts: gradient from avatar/poster color
- Potential: recipes from dish colors, playlists from album art
The gradient is truthful — it IS the data, rendered as atmosphere.

## Apps Crawled

### Apple Fitness (com.apple.Fitness)
Screens: 11 captured
- 01: Summary + onboarding overlay
- 02: Summary dashboard (clean)
- 03: Summary scrolled (Trends, Trainer Tips)
- 04: Fitness+ plan completion (celebration)
- 05: Fitness+ browse (empty state)
- 06: Workout tab onboarding (feature list)
- 07: Workout Buddy setup (AI opt-in)
- 08: Workout type selection (card grid)
- 09: Workout types scrolled (more types + Add)
- 10: Sharing tab (hero illustration onboarding)
- 11: Activity Ring detail

### Apple Contacts (com.apple.MobileAddressBook)
Screens: 3 captured (iOS simulator)
- 01: Contact list (alphabetic sections)
- 02: Contact detail (poster view)
- 03: Contact detail scrolled (data + actions)

### Apple Weather (com.apple.weather)
Screens: 7 captured (real iPhone 16 Pro Max via WDA)
- 01: Main forecast (London sunset, hero temperature)
- 02: 10-day forecast scrolled (temperature range bars)
- 03: Modules grid (Air Pollution + Wind Map)
- 04: Modules grid 2 (Feels Like + UV Index + Wind compass)
- 05: Modules grid 3 (Sunrise arc + Precipitation + Visibility + Humidity + Moon)
- 06: Modules bottom (Averages + Pressure gauge + Report + Footer)
- 07: City list (per-city gradient cards)

### Apple Calendar (com.apple.mobilecal)
Screens: 7 captured (real iPhone 16 Pro Max via WDA)
- 01: Week view (today + tomorrow columns, time grid, all-day events)
- 02: Month grid (date cells with event dots, split with event list)
- 03: Year view (12 mini-months, red = now across all levels)
- 04: Multi-calendar events (same holiday from different calendars)
- 06: Details mode (Gantt-like event bars in month grid)
- 07: Current time indicator (red now-line, haptic interaction catalog)
- 08: Long-press event creation (pre-filled time from press position)
- 09: Full creation form (Event/Reminder segmented, grouped sections)

### Apple Health (com.apple.Health)
Screens: 5 captured (real iPhone 16 Pro Max via WDA)
- 01: Welcome onboarding (hero illustration, icon constellation)
- 02: Privacy screen (heart-lock icon, full-page privacy commitment)
- 05: Browse categories (13 categories, semantic colors per domain)
- 06: Editorial content (Cycle Tracking — magazine-style article cards with custom artwork)
- 07: Activity category (time-sectioned cards, sparkline previews, Move ring inline)
- 08: Steps detail (D/W/M/6M/Y period selector, bar chart, educational "About" + Mayo Clinic)

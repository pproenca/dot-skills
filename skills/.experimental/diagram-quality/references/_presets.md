---
title: Canvas Skinparam Presets
impact: CRITICAL
impactDescription: Prevents unreadable diagrams on warm #f4f1ec canvas background
tags: syn, skinparam, theme, canvas, palette
---

# Canvas Skinparam Presets

Copy-paste the appropriate preset block at the top of every diagram, immediately after `@startuml`. These presets match the agent-uml canvas theme:

| Canvas Variable | Hex | Usage |
|----------------|-----|-------|
| `--bg` | `#f4f1ec` | Canvas background (warm beige) |
| `--bg-raised` | `#ffffff` | Element fill (white, visible on beige) |
| `--bg-inset` | `#eae6df` | Subtle inset / header backgrounds |
| `--border` | `#78716c` | Default borders and arrows |
| `--border-strong` | `#b8b0a2` | Emphasis borders |
| `--text` | `#1c1917` | Primary text |
| `--text-muted` | `#78716c` | Secondary text |
| `--accent` | `#b45309` | Warm orange accent (highlights, note borders) |
| `--accent-bg` | `#fef3c7` | Light orange (note backgrounds) |

---

## Component Diagram Preset

```plantuml
skinparam backgroundColor transparent
skinparam defaultFontColor #1c1917
skinparam defaultFontSize 13
skinparam componentBackgroundColor #ffffff
skinparam componentBorderColor #78716c
skinparam componentFontColor #1c1917
skinparam interfaceBackgroundColor #fef3c7
skinparam interfaceBorderColor #b45309
skinparam packageBackgroundColor #f4f1ec
skinparam packageBorderColor #b8b0a2
skinparam arrowColor #78716c
skinparam arrowFontColor #78716c
skinparam noteBackgroundColor #fef3c7
skinparam noteBorderColor #b45309
skinparam noteFontColor #1c1917
```

## Class Diagram Preset

```plantuml
skinparam backgroundColor transparent
skinparam defaultFontColor #1c1917
skinparam defaultFontSize 13
skinparam classBackgroundColor #ffffff
skinparam classBorderColor #78716c
skinparam classFontColor #1c1917
skinparam classHeaderBackgroundColor #eae6df
skinparam classAttributeFontColor #1c1917
skinparam classStereotypeFontColor #78716c
skinparam abstractClassBackgroundColor #ffffff
skinparam abstractClassBorderColor #b8b0a2
skinparam interfaceBackgroundColor #fef3c7
skinparam interfaceBorderColor #b45309
skinparam enumBackgroundColor #ffffff
skinparam enumBorderColor #78716c
skinparam packageBackgroundColor #f4f1ec
skinparam packageBorderColor #b8b0a2
skinparam arrowColor #78716c
skinparam arrowFontColor #78716c
skinparam noteBackgroundColor #fef3c7
skinparam noteBorderColor #b45309
skinparam noteFontColor #1c1917
```

## Sequence Diagram Preset

```plantuml
skinparam backgroundColor transparent
skinparam defaultFontColor #1c1917
skinparam defaultFontSize 13
skinparam participantBackgroundColor #ffffff
skinparam participantBorderColor #78716c
skinparam participantFontColor #1c1917
skinparam actorBorderColor #78716c
skinparam actorBackgroundColor #ffffff
skinparam sequenceArrowColor #78716c
skinparam sequenceArrowFontColor #78716c
skinparam sequenceLifeLineBorderColor #d4cfc6
skinparam sequenceLifeLineBackgroundColor #eae6df
skinparam sequenceGroupBackgroundColor #f4f1ec
skinparam sequenceGroupBorderColor #b8b0a2
skinparam sequenceGroupFontColor #1c1917
skinparam sequenceDividerBackgroundColor #eae6df
skinparam sequenceDividerBorderColor #b8b0a2
skinparam noteBackgroundColor #fef3c7
skinparam noteBorderColor #b45309
skinparam noteFontColor #1c1917
```

## Activity Diagram Preset

```plantuml
skinparam backgroundColor transparent
skinparam defaultFontColor #1c1917
skinparam defaultFontSize 13
skinparam activityBackgroundColor #ffffff
skinparam activityBorderColor #78716c
skinparam activityFontColor #1c1917
skinparam activityDiamondBackgroundColor #fef3c7
skinparam activityDiamondBorderColor #b45309
skinparam activityDiamondFontColor #1c1917
skinparam activityBarColor #78716c
skinparam partitionBackgroundColor #f4f1ec
skinparam partitionBorderColor #b8b0a2
skinparam arrowColor #78716c
skinparam arrowFontColor #78716c
skinparam noteBackgroundColor #fef3c7
skinparam noteBorderColor #b45309
skinparam noteFontColor #1c1917
```

## State Diagram Preset

```plantuml
skinparam backgroundColor transparent
skinparam defaultFontColor #1c1917
skinparam defaultFontSize 13
skinparam stateBackgroundColor #ffffff
skinparam stateBorderColor #78716c
skinparam stateFontColor #1c1917
skinparam stateAttributeFontColor #78716c
skinparam stateStartColor #1c1917
skinparam stateEndColor #1c1917
skinparam arrowColor #78716c
skinparam arrowFontColor #78716c
skinparam noteBackgroundColor #fef3c7
skinparam noteBorderColor #b45309
skinparam noteFontColor #1c1917
```

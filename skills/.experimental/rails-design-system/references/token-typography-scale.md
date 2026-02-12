---
title: Define a Typography Scale with Constrained Options
impact: HIGH
impactDescription: eliminates font size proliferation
tags: token, typography, font, scale, consistency
---

## Define a Typography Scale with Constrained Options

Limit typography to 5-7 size/weight combinations. Every additional option multiplies visual inconsistency. Developers pick whatever "looks right" in their current context, and the app slowly accumulates 12+ distinct text treatments that differ by a pixel or two. A constrained scale forces intentional choices and produces visual coherence.

**Incorrect (unconstrained font sizes across the app):**

```erb
<%# Different developers, different sizing decisions %>
<h1 class="text-3xl font-bold">Page Title</h1>
<h1 class="text-4xl font-semibold">Another Page Title</h1>
<h2 class="text-2xl font-bold tracking-tight">Section</h2>
<h2 class="text-xl font-semibold">Another Section</h2>
<p class="text-base">Body text here</p>
<p class="text-sm leading-6">Body text there</p>
<span class="text-xs text-gray-500">Caption</span>
<span class="text-[13px] text-gray-400">Another caption</span>
<label class="text-sm font-medium">Form label</label>
<label class="text-xs font-semibold uppercase tracking-wide">Another label</label>

<%# 10+ distinct text treatments — none intentional %>
```

**Correct (constrained typography scale):**

```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";

@theme {
  /* Custom font family if needed */
  --font-sans: "Inter", ui-sans-serif, system-ui, sans-serif;
}
```

```erb
<%# Typography scale documented and enforced by convention:

    Display:  text-2xl font-bold        — page titles, hero headings
    Heading:  text-xl font-semibold     — section headings, card titles
    Subhead:  text-lg font-medium       — subsection headings, modal titles
    Body:     text-base font-normal     — default paragraph text, descriptions
    Small:    text-sm font-normal       — secondary text, metadata, timestamps
    Caption:  text-xs text-text-muted   — labels, helper text, footnotes
%>

<%# Page title %>
<h1 class="text-2xl font-bold text-text">Dashboard</h1>

<%# Section heading %>
<h2 class="text-xl font-semibold text-text">Recent Activity</h2>

<%# Subsection %>
<h3 class="text-lg font-medium text-text">Pending Reviews</h3>

<%# Body text %>
<p class="text-base text-text">
  Your team completed 12 reviews this week.
</p>

<%# Secondary info %>
<span class="text-sm text-text-muted">Updated 3 hours ago</span>

<%# Caption / helper text %>
<p class="text-xs text-text-muted">
  All times shown in your local timezone.
</p>
```

**Typography quick reference:**

| Name | Classes | Use for |
|---|---|---|
| Display | `text-2xl font-bold` | Page titles, hero headings |
| Heading | `text-xl font-semibold` | Section headings, card titles |
| Subhead | `text-lg font-medium` | Subsections, modal titles, dialog headers |
| Body | `text-base font-normal` | Paragraphs, descriptions, form inputs |
| Small | `text-sm font-normal` | Metadata, timestamps, table cells |
| Caption | `text-xs text-text-muted` | Helper text, labels, footnotes |

**If the design requires non-standard sizes**, add them as semantic tokens rather than using arbitrary values:

```css
@theme {
  --font-size-hero: 3rem;
  --line-height-hero: 1.1;
}
```

Reference: [Tailwind CSS Font Size](https://tailwindcss.com/docs/font-size)

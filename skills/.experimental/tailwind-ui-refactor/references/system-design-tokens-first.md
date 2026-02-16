---
title: Establish Design Tokens Before Writing Component Code
impact: HIGH
impactDescription: prevents token drift by defining the constrained set of visual values before building any components
tags: system, tokens, tailwind-config, scale, foundation
---

Components that share the same underlying tokens — the same gray-500, the same rounded-lg, the same shadow-sm — feel cohesive without effort. Components that each pick their own values drift apart over time. Define your constrained set of visual tokens before building the first component.

**Incorrect (each component picks ad-hoc values):**
```html
<!-- Card uses arbitrary values, no shared system -->
<div class="rounded-[12px] border border-[#e2e8f0] bg-white p-[22px] shadow-[0_2px_8px_rgba(0,0,0,0.08)]">
  <h3 class="text-[17px] font-semibold text-[#1a1a2e]">Revenue</h3>
  <p class="mt-[10px] text-[28px] font-bold text-[#1a1a2e]">$48,290</p>
  <p class="mt-[6px] text-[13px] text-[#6b7280]">+12% from last month</p>
</div>
```

**Correct (Tailwind's design token scale as the foundation):**
```html
<!-- Every value maps to Tailwind's scale — shared across all components -->
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
  <h3 class="text-sm font-medium text-gray-500">Revenue</h3>
  <p class="mt-2 text-2xl font-bold text-gray-900">$48,290</p>
  <p class="mt-1 text-sm text-green-600">+12% from last month</p>
</div>
```

**The token contract — use Tailwind's scale, not arbitrary values:**
| Token Type | Use | Avoid |
|-----------|-----|-------|
| **Spacing** | `p-4`, `p-6`, `gap-3`, `mt-2` | `p-[22px]`, `mt-[10px]` |
| **Typography** | `text-sm`, `text-base`, `text-2xl` | `text-[17px]`, `text-[13px]` |
| **Color** | `text-gray-900`, `bg-blue-600` | `text-[#1a1a2e]`, `bg-[#3182ce]` |
| **Radius** | `rounded-lg`, `rounded-xl` | `rounded-[12px]` |
| **Shadow** | `shadow-sm`, `shadow`, `shadow-md` | `shadow-[0_2px_8px_...]` |

Arbitrary values (`[...]`) are escape hatches. If you're using more than 2-3 across an entire project, your token system needs expanding — not bypassing.

Reference: John Edson, Design Like Apple — Principle 4: "Design Is Systems Thinking"

---
title: Push Client Boundaries to Leaf Components
impact: HIGH
impactDescription: keeps 60-80% of component tree server-rendered
tags: arch, client-boundary, server-components, bundle-size
---

## Push Client Boundaries to Leaf Components

A `'use client'` directive makes the component and every component it imports client-side. Placing the boundary high in the tree forces static content, data fetching, and layout logic into the client bundle. Push the boundary down to the smallest interactive leaf to keep the majority of the tree server-rendered.

**Incorrect ('use client' on the page-level component forces everything client-side):**

```tsx
// app/dashboard/page.tsx
"use client"; // Every child becomes client-side

import { useState } from "react";

export default function DashboardPage() {
  const [activeTab, setActiveTab] = useState("overview");

  return (
    <div>
      {/* Static content — should be server-rendered but is now client JS */}
      <header>
        <h1>Dashboard</h1>
        <p>Welcome back. Here is your account summary.</p>
      </header>

      {/* Navigation tabs — the only interactive part */}
      <nav>
        {["overview", "analytics", "settings"].map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={activeTab === tab ? "active" : ""}
          >
            {tab}
          </button>
        ))}
      </nav>

      {/* Heavy data display — re-fetched on client, adding waterfall */}
      {activeTab === "overview" && <OverviewPanel />}
      {activeTab === "analytics" && <AnalyticsPanel />}
      {activeTab === "settings" && <SettingsPanel />}
    </div>
  );
}
```

**Correct ('use client' pushed down to the interactive tab switcher leaf):**

```tsx
// app/dashboard/page.tsx — Server Component, no directive
export default function DashboardPage() {
  return (
    <div>
      {/* Static content stays server-rendered — zero client JS */}
      <header>
        <h1>Dashboard</h1>
        <p>Welcome back. Here is your account summary.</p>
      </header>
      {/* Only the tab switcher needs client interactivity */}
      <DashboardTabs
        overviewPanel={<OverviewPanel />}
        analyticsPanel={<AnalyticsPanel />}
        settingsPanel={<SettingsPanel />}
      />
    </div>
  );
}

// components/DashboardTabs.tsx — 'use client' only on the leaf
"use client";
import { type ReactNode, useState } from "react";

export function DashboardTabs({ overviewPanel, analyticsPanel, settingsPanel }: {
  overviewPanel: ReactNode; analyticsPanel: ReactNode; settingsPanel: ReactNode;
}) {
  const [activeTab, setActiveTab] = useState("overview");
  const panels = { overview: overviewPanel, analytics: analyticsPanel, settings: settingsPanel };

  return (
    <div>
      <nav>
        {Object.keys(panels).map((tab) => (
          <button key={tab} onClick={() => setActiveTab(tab)}
            className={activeTab === tab ? "active" : ""}>{tab}</button>
        ))}
      </nav>
      {panels[activeTab as keyof typeof panels]}
    </div>
  );
}
```

Reference: [Composing Server and Client Components](https://react.dev/reference/rsc/use-client#how-use-client-marks-client-code)

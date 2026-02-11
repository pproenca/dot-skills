---
title: Use Asset Catalog Compression and On-Demand Resources
impact: MEDIUM-HIGH
impactDescription: unoptimized images account for 60-80% of app bundle size — asset catalog compression and ODR can reduce download size by 30-50%
tags: asset, optimization, compression, bundle-size, odr
---

## Use Asset Catalog Compression and On-Demand Resources

App Store download size directly affects conversion — Apple reports a 1% drop in installs for every 6 MB increase over 100 MB. Images are usually the largest contributor to bundle size. The asset catalog's built-in compression and On-Demand Resources (ODR) are the two primary tools for keeping the bundle lean without sacrificing visual quality.

**Incorrect (unoptimized full-resolution images in main bundle):**

```swift
// All 4K marketing images baked directly into the app binary
// Onboarding images alone add 15 MB to the bundle
struct OnboardingView: View {
    let pages = [
        "onboarding-hero-4k",       // 3840×2160, 4.2 MB
        "onboarding-features-4k",   // 3840×2160, 3.8 MB
        "onboarding-community-4k",  // 3840×2160, 5.1 MB
    ]

    var body: some View {
        TabView {
            ForEach(pages, id: \.self) { page in
                Image(page)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .tabViewStyle(.page)
    }
}
```

**Correct (optimized dimensions, compression, and ODR for non-essential assets):**

```swift
// Images sized to actual display dimensions (iPhone 15 Pro Max = 1290×2796 logical)
// Asset catalog compression enabled, onboarding images delivered via ODR

struct OnboardingView: View {
    @State private var resourceRequest: NSBundleResourceRequest?
    @State private var imagesLoaded = false

    // These images are tagged "onboarding" in asset catalog → ODR
    let pages = [
        "onboarding-hero",          // 1290×860, compressed, ~180 KB
        "onboarding-features",      // 1290×860, compressed, ~150 KB
        "onboarding-community",     // 1290×860, compressed, ~200 KB
    ]

    var body: some View {
        Group {
            if imagesLoaded {
                TabView {
                    ForEach(pages, id: \.self) { page in
                        Image(page)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .tabViewStyle(.page)
            } else {
                ProgressView("Loading...")
            }
        }
        .task { await loadOnboardingAssets() }
    }

    private func loadOnboardingAssets() async {
        let request = NSBundleResourceRequest(tags: ["onboarding"])
        self.resourceRequest = request

        do {
            try await request.beginAccessingResources()
            imagesLoaded = true
        } catch {
            // Fallback: images may already be cached or included in thin bundle
            imagesLoaded = true
        }
    }
}
```

**Asset catalog compression settings (in Build Settings):**

| Setting | Recommended Value | Effect |
|---------|-------------------|--------|
| Compress PNG Files | YES | Lossless PNG optimization at build time |
| Asset Catalog Compiler - Optimization | `space` | Prioritize smaller binary over build speed |
| On Demand Resources Initial Install Tags | (empty for onboarding) | Exclude tagged assets from initial download |

**ODR tag strategy for typical apps:**

| Tag | Content | When Loaded |
|-----|---------|-------------|
| (no tag) | Core UI assets, brand logo, tab icons | Always in bundle |
| `onboarding` | Welcome flow illustrations | First launch only |
| `tutorials` | Help/tutorial screenshots | On demand |
| `seasonal` | Holiday/promotional banners | On demand |

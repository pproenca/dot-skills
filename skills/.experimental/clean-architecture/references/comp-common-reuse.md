---
title: Avoid Forcing Clients to Depend on Unused Code
impact: HIGH
impactDescription: reduces unnecessary recompilation and deployment
tags: comp, common-reuse, dependencies, coupling
---

## Avoid Forcing Clients to Depend on Unused Code

Classes used together should be in the same component. Classes not used together should be in separate components. Forcing a client to depend on things it doesn't use creates unnecessary coupling.

**Incorrect (monolithic utility package):**

```java
// utils/src/main/java/com/app/utils/
├── StringUtils.java
├── DateUtils.java
├── FileUtils.java
├── HttpUtils.java
├── CryptoUtils.java
├── ImageUtils.java      // Depends on ImageMagick
└── PdfUtils.java        // Depends on iText

// pom.xml for utils module
<dependencies>
    <dependency>imagemagick</dependency>  <!-- 50MB -->
    <dependency>itext-pdf</dependency>     <!-- 20MB -->
    <dependency>bouncycastle</dependency>  <!-- 10MB -->
</dependencies>

// A service that only needs StringUtils
// must now depend on all 80MB of transitive dependencies
```

**Correct (split by usage pattern):**

```java
// string-utils/
├── StringUtils.java
└── pom.xml  // No heavy dependencies

// date-utils/
├── DateUtils.java
└── pom.xml

// image-processing/
├── ImageUtils.java
├── ImageResizer.java
└── pom.xml  // ImageMagick dependency only here

// pdf-generation/
├── PdfUtils.java
├── PdfBuilder.java
└── pom.xml  // iText dependency only here

// crypto/
├── CryptoUtils.java
├── HashingService.java
└── pom.xml  // BouncyCastle dependency only here

// Services import only what they need
// order-service depends on string-utils, date-utils (2MB)
// report-service depends on string-utils, pdf-generation (22MB)
```

**Benefits:**
- Clients only pull dependencies they actually use
- Smaller deployment artifacts
- Changes to image processing don't redeploy order service

Reference: [Clean Architecture - Common Reuse Principle](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch13.xhtml)

# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Accessibility & WCAG Compliance (access)

**Impact:** CRITICAL
**Description:** Accessibility failures exclude 15%+ of users and create legal liability. WCAG compliance is non-negotiable for inclusive design.

## 2. Core Web Vitals Optimization (cwv)

**Impact:** CRITICAL
**Description:** LCP, INP, and CLS directly impact SEO rankings (25-30% weight) and user experience. Only 53% of sites pass all thresholds.

## 3. Visual Hierarchy & Layout (layout)

**Impact:** HIGH
**Description:** Poor hierarchy causes users to miss CTAs and increases cognitive load. Proper structure reduces bounce rates and improves conversions.

## 4. Responsive & Mobile-First Design (resp)

**Impact:** HIGH
**Description:** Mobile traffic exceeds 60% globally. Non-responsive designs lose majority of users and fail Google's mobile-first indexing.

## 5. Typography & Font Loading (typo)

**Impact:** MEDIUM-HIGH
**Description:** Font loading directly affects LCP and CLS. Poor typography reduces readability and comprehension by 25%+.

## 6. Color & Contrast (color)

**Impact:** MEDIUM
**Description:** Insufficient contrast fails WCAG AA (4.5:1 ratio) and excludes users with visual impairments. Color alone must not convey meaning.

## 7. Forms & Validation UX (form)

**Impact:** MEDIUM
**Description:** Form abandonment averages 67%. Proper validation timing, clear errors, and helpful inputs directly impact conversion rates.

## 8. Animation & Performance (anim)

**Impact:** LOW-MEDIUM
**Description:** Poorly optimized animations cause jank below 60fps, trigger expensive reflows, and drain battery on mobile devices.

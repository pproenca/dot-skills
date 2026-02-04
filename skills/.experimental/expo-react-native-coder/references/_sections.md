# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Project Setup & Configuration (setup)

**Impact:** CRITICAL
**Description:** TypeScript configuration, environment variables, app.json/app.config.ts, and EAS setup form the foundation for all features and must be correct from the start.

## 2. Routing & Navigation (route)

**Impact:** CRITICAL
**Description:** Expo Router file-based routing is the backbone of app navigation. Proper stack, tab, and drawer configuration determines the entire user flow.

## 3. Screen Patterns & Layouts (screen)

**Impact:** HIGH
**Description:** Consistent screen patterns (list, detail, form, settings) establish predictable UX and reduce development time through reusable templates.

## 4. Data Fetching & State (data)

**Impact:** HIGH
**Description:** API calls, server functions, caching strategies, and local storage patterns determine app responsiveness and offline capability.

## 5. Authentication & Security (auth)

**Impact:** HIGH
**Description:** Protected routes, session management, secure token storage, and OAuth flows are critical for user data protection.

## 6. Deep Linking & Universal Links (link)

**Impact:** HIGH
**Description:** Custom URL schemes, iOS Universal Links, and Android App Links enable seamless app-to-app and web-to-app transitions.

## 7. Native UX Patterns (ux)

**Impact:** MEDIUM-HIGH
**Description:** Safe areas, status bar styling, haptic feedback, and gesture handling create the native feel users expect on mobile.

## 8. Forms & User Input (form)

**Impact:** MEDIUM
**Description:** TextInput handling, keyboard avoiding views, form validation, and multi-step forms are essential for data collection screens.

## 9. Assets & Theming (asset)

**Impact:** MEDIUM
**Description:** Image optimization, font loading, icon systems, dark mode support, and splash screens define the visual identity.

## 10. Error Handling & Testing (test)

**Impact:** MEDIUM
**Description:** Error boundaries, Jest unit tests, Maestro E2E tests, and crash reporting ensure app reliability in production.

# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Form Configuration (formcfg)

**Impact:** CRITICAL
**Description:** Initial useForm setup determines validation timing, re-render boundaries, and what ends up in the submitted payload. The wrong mode validates on every keystroke; the wrong disabled or shouldUnregister setting silently drops data.

## 2. Field Subscription (sub)

**Impact:** CRITICAL
**Description:** Where a subscription lives decides how much of the tree re-renders. Reading a value at the form root instead of in the leaf that displays it is the difference between re-rendering the whole form and re-rendering one field.

## 3. Controlled Components (ctrl)

**Impact:** HIGH
**Description:** Controller and useController isolate re-renders only when they sit in a child component. Wiring their field props to a third-party control also has to match that library's prop names, or the input renders but never writes back.

## 4. Validation Patterns (valid)

**Impact:** HIGH
**Description:** Where the schema is constructed, how server-side failures re-enter the form, and how error display is paced. Building a schema inside render pays the construction cost on every keystroke.

## 5. State Management (formstate)

**Impact:** MEDIUM-HIGH
**Description:** formState is a per-property Proxy, so a value you never read during render is a value you never re-render for. Submit lifecycle belongs here too: an async handler that throws without a catch strands isSubmitting forever.

## 6. Field Arrays (array)

**Impact:** MEDIUM-HIGH
**Description:** Dynamic field management requires stable keys and one owner per field name. Some options — notably disabled — fail silently rather than loudly.

## 7. Integration Patterns (integ)

**Impact:** MEDIUM
**Description:** Third-party UI library integration (shadcn/Radix, MUI) requires specific wiring, and native inputs need explicit type coercion before values reach a typed schema.

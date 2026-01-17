# Code Refactoring

**Version 0.1.0**  
Fowler/Martin  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive code refactoring guide based on Martin Fowler's refactoring catalog and Robert C. Martin's Clean Code principles, designed for AI agents and LLMs. Contains 43+ rules across 8 categories, prioritized by impact from critical (structure decomposition, reducing coupling) to incremental (micro-refactoring). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Structure & Decomposition](#1-structure-decomposition) — **CRITICAL**
   - 1.1 [Apply Single Responsibility Principle](#11-apply-single-responsibility-principle)
   - 1.2 [Compose Method for Readable Flow](#12-compose-method-for-readable-flow)
   - 1.3 [Extract Class from Large Class](#13-extract-class-from-large-class)
   - 1.4 [Extract Method for Long Functions](#14-extract-method-for-long-functions)
   - 1.5 [Introduce Parameter Object](#15-introduce-parameter-object)
   - 1.6 [Keep Functions Under 20 Lines](#16-keep-functions-under-20-lines)
   - 1.7 [Replace Method with Method Object](#17-replace-method-with-method-object)
2. [Coupling & Dependencies](#2-coupling-dependencies) — **CRITICAL**
   - 2.1 [Apply Interface Segregation Principle](#21-apply-interface-segregation-principle)
   - 2.2 [Fix Feature Envy by Moving Methods](#22-fix-feature-envy-by-moving-methods)
   - 2.3 [Hide Delegate to Reduce Coupling](#23-hide-delegate-to-reduce-coupling)
   - 2.4 [Preserve Whole Object Instead of Fields](#24-preserve-whole-object-instead-of-fields)
   - 2.5 [Remove Middle Man When Excessive](#25-remove-middle-man-when-excessive)
   - 2.6 [Use Dependency Injection](#26-use-dependency-injection)
3. [Naming & Clarity](#3-naming-clarity) — **HIGH**
   - 3.1 [Avoid Abbreviations and Acronyms](#31-avoid-abbreviations-and-acronyms)
   - 3.2 [Avoid Type Encodings in Names](#32-avoid-type-encodings-in-names)
   - 3.3 [Use Consistent Vocabulary](#33-use-consistent-vocabulary)
   - 3.4 [Use Intention-Revealing Names](#34-use-intention-revealing-names)
   - 3.5 [Use Searchable Names](#35-use-searchable-names)
4. [Conditional Logic](#4-conditional-logic) — **HIGH**
   - 4.1 [Consolidate Duplicate Conditional Fragments](#41-consolidate-duplicate-conditional-fragments)
   - 4.2 [Decompose Complex Conditionals](#42-decompose-complex-conditionals)
   - 4.3 [Introduce Special Case Object](#43-introduce-special-case-object)
   - 4.4 [Replace Conditional with Lookup Table](#44-replace-conditional-with-lookup-table)
   - 4.5 [Replace Conditional with Polymorphism](#45-replace-conditional-with-polymorphism)
   - 4.6 [Replace Nested Conditionals with Guard Clauses](#46-replace-nested-conditionals-with-guard-clauses)
5. [Abstraction & Patterns](#5-abstraction-patterns) — **MEDIUM-HIGH**
   - 5.1 [Apply Open-Closed Principle](#51-apply-open-closed-principle)
   - 5.2 [Extract Strategy for Algorithm Variants](#52-extract-strategy-for-algorithm-variants)
   - 5.3 [Extract Superclass for Common Behavior](#53-extract-superclass-for-common-behavior)
   - 5.4 [Prefer Composition Over Inheritance](#54-prefer-composition-over-inheritance)
   - 5.5 [Use Factory for Complex Object Creation](#55-use-factory-for-complex-object-creation)
   - 5.6 [Use Template Method for Shared Skeleton](#56-use-template-method-for-shared-skeleton)
6. [Data Organization](#6-data-organization) — **MEDIUM**
   - 6.1 [Encapsulate Collection](#61-encapsulate-collection)
   - 6.2 [Encapsulate Record into Class](#62-encapsulate-record-into-class)
   - 6.3 [Replace Primitive with Object](#63-replace-primitive-with-object)
   - 6.4 [Replace Temp with Query](#64-replace-temp-with-query)
   - 6.5 [Split Variable with Multiple Assignments](#65-split-variable-with-multiple-assignments)
7. [Error Handling](#7-error-handling) — **MEDIUM**
   - 7.1 [Create Domain-Specific Exception Types](#71-create-domain-specific-exception-types)
   - 7.2 [Fail Fast with Preconditions](#72-fail-fast-with-preconditions)
   - 7.3 [Separate Error Handling from Business Logic](#73-separate-error-handling-from-business-logic)
   - 7.4 [Use Exceptions Instead of Error Codes](#74-use-exceptions-instead-of-error-codes)
8. [Micro-Refactoring](#8-micro-refactoring) — **LOW**
   - 8.1 [Inline Trivial Variables](#81-inline-trivial-variables)
   - 8.2 [Remove Dead Code](#82-remove-dead-code)
   - 8.3 [Rename for Clarity](#83-rename-for-clarity)
   - 8.4 [Simplify Boolean Expressions](#84-simplify-boolean-expressions)

---

## 1. Structure & Decomposition

**Impact: CRITICAL**

Long methods and classes are the root cause of maintenance issues. Breaking them down cascades into all other improvements and is the foundation of effective refactoring.

### 1.1 Apply Single Responsibility Principle

**Impact: CRITICAL (reduces change impact radius by 60-90%)**

A class should have only one reason to change. When a class handles multiple responsibilities, changes to one responsibility risk breaking others.

**Incorrect (class with multiple responsibilities):**

```typescript
class UserService {
  private users: Map<string, User> = new Map()

  createUser(data: UserData): User {
    const user = { id: crypto.randomUUID(), ...data }
    this.users.set(user.id, user)

    // Sending email is a separate responsibility
    const emailBody = `Welcome ${user.name}! Your account is ready.`
    this.sendEmail(user.email, 'Welcome', emailBody)

    // Logging is a separate responsibility
    console.log(`[${new Date().toISOString()}] User created: ${user.id}`)

    return user
  }

  private sendEmail(to: string, subject: string, body: string): void {
    // SMTP logic here
  }
}
```

**Correct (separated responsibilities):**

```typescript
class UserService {
  constructor(
    private userRepository: UserRepository,
    private notificationService: NotificationService,
    private logger: Logger
  ) {}

  createUser(data: UserData): User {
    const user = this.userRepository.create(data)
    this.notificationService.sendWelcomeEmail(user)
    this.logger.info('User created', { userId: user.id })
    return user
  }
}

class UserRepository {
  private users: Map<string, User> = new Map()

  create(data: UserData): User {
    const user = { id: crypto.randomUUID(), ...data }
    this.users.set(user.id, user)
    return user
  }
}

class NotificationService {
  sendWelcomeEmail(user: User): void {
    const body = `Welcome ${user.name}! Your account is ready.`
    this.sendEmail(user.email, 'Welcome', body)
  }

  private sendEmail(to: string, subject: string, body: string): void {
    // SMTP logic here
  }
}
```

**Benefits:**
- Each class can change independently
- Classes are easier to test in isolation
- Code is more reusable across different contexts

Reference: [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single-responsibility_principle)

### 1.2 Compose Method for Readable Flow

**Impact: CRITICAL (reduces cognitive load by 40-60%)**

Transform a method so that its body reads like a series of steps at the same level of abstraction. Each step should have a clear name that reveals its intent.

**Incorrect (mixed abstraction levels):**

```typescript
async function publishArticle(article: Article, author: User): Promise<void> {
  // Low-level validation mixed with high-level flow
  if (!article.title || article.title.trim().length === 0) {
    throw new Error('Title required')
  }
  if (!article.content || article.content.length < 100) {
    throw new Error('Content must be at least 100 characters')
  }
  if (!author.permissions.includes('publish')) {
    throw new Error('User cannot publish')
  }

  article.status = 'published'
  article.publishedAt = new Date()
  article.slug = article.title.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')

  await db.articles.update(article.id, article)

  const followers = await db.users.find({ following: author.id })
  for (const follower of followers) {
    await sendEmail(follower.email, `New article: ${article.title}`, article.excerpt)
  }

  await searchIndex.add({ id: article.id, title: article.title, content: article.content })
}
```

**Correct (composed at consistent abstraction level):**

```typescript
async function publishArticle(article: Article, author: User): Promise<void> {
  validateArticleForPublishing(article)
  verifyPublishPermission(author)

  const publishedArticle = markAsPublished(article)
  await saveArticle(publishedArticle)

  await notifyFollowers(author, publishedArticle)
  await indexForSearch(publishedArticle)
}

function validateArticleForPublishing(article: Article): void {
  if (!article.title?.trim()) {
    throw new Error('Title required')
  }
  if (!article.content || article.content.length < 100) {
    throw new Error('Content must be at least 100 characters')
  }
}

function verifyPublishPermission(author: User): void {
  if (!author.permissions.includes('publish')) {
    throw new Error('User cannot publish')
  }
}

function markAsPublished(article: Article): Article {
  return {
    ...article,
    status: 'published',
    publishedAt: new Date(),
    slug: generateSlug(article.title)
  }
}

function generateSlug(title: string): string {
  return title.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')
}
```

**Benefits:**
- Main method reads like documentation
- Each helper can be tested independently
- Easy to modify individual steps without affecting others

Reference: [Compose Method Pattern](https://wiki.c2.com/?ComposeMethod)

### 1.3 Extract Class from Large Class

**Impact: CRITICAL (improves testability and reduces cognitive load by 40-60%)**

When a class grows too large, it becomes difficult to understand and maintain. Extract cohesive groups of fields and methods into separate classes.

**Incorrect (class doing too much):**

```typescript
class Employee {
  name: string
  email: string
  phone: string
  street: string
  city: string
  state: string
  zipCode: string
  country: string

  getFullAddress(): string {
    return `${this.street}, ${this.city}, ${this.state} ${this.zipCode}, ${this.country}`
  }

  validateAddress(): boolean {
    return this.street.length > 0 && this.city.length > 0 && this.zipCode.length > 0
  }

  formatPhoneForDisplay(): string {
    return this.phone.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3')
  }

  getContactInfo(): string {
    return `${this.email} | ${this.formatPhoneForDisplay()}`
  }
}
```

**Correct (extracted cohesive classes):**

```typescript
class Employee {
  name: string
  contact: ContactInfo
  address: Address

  getContactInfo(): string {
    return this.contact.format()
  }

  getFullAddress(): string {
    return this.address.format()
  }
}

class Address {
  constructor(
    public street: string,
    public city: string,
    public state: string,
    public zipCode: string,
    public country: string
  ) {}

  format(): string {
    return `${this.street}, ${this.city}, ${this.state} ${this.zipCode}, ${this.country}`
  }

  isValid(): boolean {
    return this.street.length > 0 && this.city.length > 0 && this.zipCode.length > 0
  }
}

class ContactInfo {
  constructor(
    public email: string,
    public phone: string
  ) {}

  format(): string {
    return `${this.email} | ${this.formatPhone()}`
  }

  private formatPhone(): string {
    return this.phone.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3')
  }
}
```

**Signs you need to extract:**
- Groups of fields that are always used together
- Methods that operate on a subset of fields
- Fields with common prefixes (address_, contact_)

Reference: [Extract Class](https://refactoring.com/catalog/extractClass.html)

### 1.4 Extract Method for Long Functions

**Impact: CRITICAL (reduces function complexity by 50-80%)**

Long functions are the most common source of code complexity. Extract cohesive blocks of code into well-named methods to improve readability and enable reuse.

**Incorrect (monolithic function with multiple responsibilities):**

```typescript
function processOrder(order: Order): ProcessedOrder {
  // Validate order
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items')
  }
  if (!order.customer.email) {
    throw new Error('Customer email required')
  }

  // Calculate totals
  let subtotal = 0
  for (const item of order.items) {
    subtotal += item.price * item.quantity
  }
  const tax = subtotal * 0.1
  const shipping = subtotal > 100 ? 0 : 10
  const total = subtotal + tax + shipping

  // Format for display
  const formattedItems = order.items.map(item => ({
    name: item.name,
    display: `${item.name} x${item.quantity} - $${(item.price * item.quantity).toFixed(2)}`
  }))

  return { ...order, subtotal, tax, shipping, total, formattedItems }
}
```

**Correct (decomposed into focused methods):**

```typescript
function processOrder(order: Order): ProcessedOrder {
  validateOrder(order)
  const totals = calculateTotals(order.items)
  const formattedItems = formatOrderItems(order.items)

  return { ...order, ...totals, formattedItems }
}

function validateOrder(order: Order): void {
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items')
  }
  if (!order.customer.email) {
    throw new Error('Customer email required')
  }
}

function calculateTotals(items: OrderItem[]): OrderTotals {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const tax = subtotal * 0.1
  const shipping = subtotal > 100 ? 0 : 10
  return { subtotal, tax, shipping, total: subtotal + tax + shipping }
}

function formatOrderItems(items: OrderItem[]): FormattedItem[] {
  return items.map(item => ({
    name: item.name,
    display: `${item.name} x${item.quantity} - $${(item.price * item.quantity).toFixed(2)}`
  }))
}
```

**When to extract:**
- Code block has a clear single purpose
- Block is reusable in other contexts
- Block requires its own documentation/testing

Reference: [Extract Function](https://refactoring.com/catalog/extractFunction.html)

### 1.5 Introduce Parameter Object

**Impact: CRITICAL (reduces parameter count and enables behavior grouping)**

When multiple parameters frequently appear together, bundle them into a single object. This simplifies signatures and provides a home for related behavior.

**Incorrect (long parameter list with data clumps):**

```typescript
function searchProducts(
  minPrice: number,
  maxPrice: number,
  category: string,
  inStock: boolean,
  sortBy: string,
  sortOrder: 'asc' | 'desc',
  page: number,
  pageSize: number
): Product[] {
  // Implementation
}

function countProducts(
  minPrice: number,
  maxPrice: number,
  category: string,
  inStock: boolean
): number {
  // Same filter params repeated
}

// Calling code is hard to read
const products = searchProducts(10, 100, 'electronics', true, 'price', 'asc', 1, 20)
```

**Correct (parameter object with behavior):**

```typescript
interface ProductFilter {
  minPrice?: number
  maxPrice?: number
  category?: string
  inStock?: boolean
}

interface PaginationOptions {
  sortBy?: string
  sortOrder?: 'asc' | 'desc'
  page?: number
  pageSize?: number
}

function searchProducts(filter: ProductFilter, pagination: PaginationOptions): Product[] {
  // Implementation
}

function countProducts(filter: ProductFilter): number {
  // Reuses same filter type
}

// Calling code is self-documenting
const filter: ProductFilter = { minPrice: 10, maxPrice: 100, category: 'electronics', inStock: true }
const pagination: PaginationOptions = { sortBy: 'price', sortOrder: 'asc', page: 1, pageSize: 20 }
const products = searchProducts(filter, pagination)
```

**Alternative (class with validation):**

```typescript
class ProductFilter {
  constructor(
    public minPrice?: number,
    public maxPrice?: number,
    public category?: string,
    public inStock?: boolean
  ) {
    this.validate()
  }

  private validate(): void {
    if (this.minPrice !== undefined && this.maxPrice !== undefined && this.minPrice > this.maxPrice) {
      throw new Error('minPrice cannot exceed maxPrice')
    }
  }

  hasPrice(): boolean {
    return this.minPrice !== undefined || this.maxPrice !== undefined
  }
}
```

**Benefits:**
- Related parameters travel together
- Validation logic has a natural home
- Adding new parameters doesn't change function signatures

Reference: [Introduce Parameter Object](https://refactoring.com/catalog/introduceParameterObject.html)

### 1.6 Keep Functions Under 20 Lines

**Impact: CRITICAL (reduces cognitive load and bug density by 30-50%)**

Functions longer than 20 lines are harder to understand, test, and maintain. Research shows bug density increases with function length.

**Incorrect (long function requiring scrolling):**

```typescript
function processPayment(order: Order, paymentMethod: PaymentMethod): PaymentResult {
  // Validate order
  if (!order.items.length) {
    return { success: false, error: 'Empty order' }
  }

  // Calculate amount
  let amount = 0
  for (const item of order.items) {
    amount += item.price * item.quantity
  }

  // Apply discounts
  if (order.couponCode) {
    const coupon = lookupCoupon(order.couponCode)
    if (coupon && coupon.expiresAt > new Date()) {
      if (coupon.type === 'percentage') {
        amount = amount * (1 - coupon.value / 100)
      } else {
        amount = amount - coupon.value
      }
    }
  }

  // Add tax
  const taxRate = getTaxRate(order.shippingAddress.state)
  amount = amount * (1 + taxRate)

  // Process payment
  let paymentResult
  if (paymentMethod.type === 'credit_card') {
    paymentResult = chargeCreditCard(paymentMethod.cardNumber, amount)
  } else if (paymentMethod.type === 'paypal') {
    paymentResult = chargePayPal(paymentMethod.email, amount)
  } else {
    return { success: false, error: 'Unknown payment method' }
  }

  // Handle result
  if (paymentResult.success) {
    updateOrderStatus(order.id, 'paid')
    sendConfirmationEmail(order.customer.email, order.id)
    return { success: true, transactionId: paymentResult.transactionId }
  } else {
    logPaymentFailure(order.id, paymentResult.error)
    return { success: false, error: paymentResult.error }
  }
}
```

**Correct (composed of focused functions):**

```typescript
function processPayment(order: Order, paymentMethod: PaymentMethod): PaymentResult {
  const validationError = validateOrder(order)
  if (validationError) {
    return { success: false, error: validationError }
  }

  const amount = calculateFinalAmount(order)
  const paymentResult = executePayment(paymentMethod, amount)

  return handlePaymentResult(order, paymentResult)
}

function calculateFinalAmount(order: Order): number {
  const subtotal = calculateSubtotal(order.items)
  const discounted = applyDiscounts(subtotal, order.couponCode)
  return applyTax(discounted, order.shippingAddress.state)
}

function handlePaymentResult(order: Order, result: PaymentResult): PaymentResult {
  if (result.success) {
    updateOrderStatus(order.id, 'paid')
    sendConfirmationEmail(order.customer.email, order.id)
  } else {
    logPaymentFailure(order.id, result.error)
  }
  return result
}
```

**When longer functions are acceptable:**
- Complex algorithms that lose clarity when split
- State machines with necessary sequential steps
- Generated code or configuration

Reference: [Clean Code by Robert C. Martin](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

### 1.7 Replace Method with Method Object

**Impact: CRITICAL (enables extraction from complex methods with many local variables)**

When a long method has many local variables that make extraction difficult, turn the method into its own class. Local variables become instance fields, enabling easy decomposition.

**Incorrect (method with many interdependent locals):**

```typescript
class PriceCalculator {
  calculatePrice(order: Order): PriceBreakdown {
    let basePrice = 0
    let quantity = 0

    for (const item of order.items) {
      basePrice += item.unitPrice * item.quantity
      quantity += item.quantity
    }

    // Volume discount depends on quantity
    let volumeDiscount = 0
    if (quantity > 100) {
      volumeDiscount = basePrice * 0.15
    } else if (quantity > 50) {
      volumeDiscount = basePrice * 0.10
    } else if (quantity > 20) {
      volumeDiscount = basePrice * 0.05
    }

    // Loyalty discount depends on base price after volume
    const afterVolume = basePrice - volumeDiscount
    let loyaltyDiscount = 0
    if (order.customer.loyaltyYears > 5) {
      loyaltyDiscount = afterVolume * 0.10
    } else if (order.customer.loyaltyYears > 2) {
      loyaltyDiscount = afterVolume * 0.05
    }

    // Shipping depends on final price
    const subtotal = afterVolume - loyaltyDiscount
    let shipping = subtotal > 200 ? 0 : 15

    return { basePrice, volumeDiscount, loyaltyDiscount, shipping, total: subtotal + shipping }
  }
}
```

**Correct (extracted to method object):**

```typescript
class PriceCalculator {
  calculatePrice(order: Order): PriceBreakdown {
    return new PriceCalculation(order).compute()
  }
}

class PriceCalculation {
  private basePrice = 0
  private quantity = 0
  private volumeDiscount = 0
  private loyaltyDiscount = 0
  private shipping = 0

  constructor(private order: Order) {}

  compute(): PriceBreakdown {
    this.calculateBasePrice()
    this.calculateVolumeDiscount()
    this.calculateLoyaltyDiscount()
    this.calculateShipping()

    return this.buildResult()
  }

  private calculateBasePrice(): void {
    for (const item of this.order.items) {
      this.basePrice += item.unitPrice * item.quantity
      this.quantity += item.quantity
    }
  }

  private calculateVolumeDiscount(): void {
    if (this.quantity > 100) {
      this.volumeDiscount = this.basePrice * 0.15
    } else if (this.quantity > 50) {
      this.volumeDiscount = this.basePrice * 0.10
    } else if (this.quantity > 20) {
      this.volumeDiscount = this.basePrice * 0.05
    }
  }

  private calculateLoyaltyDiscount(): void {
    const afterVolume = this.basePrice - this.volumeDiscount
    if (this.order.customer.loyaltyYears > 5) {
      this.loyaltyDiscount = afterVolume * 0.10
    } else if (this.order.customer.loyaltyYears > 2) {
      this.loyaltyDiscount = afterVolume * 0.05
    }
  }

  private calculateShipping(): void {
    const subtotal = this.basePrice - this.volumeDiscount - this.loyaltyDiscount
    this.shipping = subtotal > 200 ? 0 : 15
  }

  private buildResult(): PriceBreakdown {
    const subtotal = this.basePrice - this.volumeDiscount - this.loyaltyDiscount
    return {
      basePrice: this.basePrice,
      volumeDiscount: this.volumeDiscount,
      loyaltyDiscount: this.loyaltyDiscount,
      shipping: this.shipping,
      total: subtotal + this.shipping
    }
  }
}
```

**Benefits:**
- Each calculation step can be tested independently
- Easy to add new discount types without modifying existing code
- Local variables become visible state that can be inspected during debugging

Reference: [Replace Method with Method Object](https://refactoring.com/catalog/replaceFunctionWithCommand.html)

---

## 2. Coupling & Dependencies

**Impact: CRITICAL**

Tight coupling makes all subsequent changes expensive. Reducing coupling through dependency injection and proper interfaces is foundational to maintainability.

### 2.1 Apply Interface Segregation Principle

**Impact: CRITICAL (prevents unnecessary dependencies and enables focused testing)**

Clients should not be forced to depend on methods they don't use. Split large interfaces into smaller, focused ones.

**Incorrect (fat interface forces unused dependencies):**

```typescript
interface Worker {
  work(): void
  eat(): void
  sleep(): void
  attendMeeting(): void
  writeReport(): void
}

class Robot implements Worker {
  work(): void { /* ... */ }
  eat(): void { throw new Error('Robots do not eat') }  // Forced to implement
  sleep(): void { throw new Error('Robots do not sleep') }  // Meaningless method
  attendMeeting(): void { throw new Error('Robots do not attend meetings') }
  writeReport(): void { /* ... */ }
}

class Intern implements Worker {
  work(): void { /* ... */ }
  eat(): void { /* ... */ }
  sleep(): void { /* ... */ }
  attendMeeting(): void { throw new Error('Interns cannot attend meetings') }  // Policy violation
  writeReport(): void { throw new Error('Interns cannot write reports') }
}
```

**Correct (segregated interfaces):**

```typescript
interface Workable {
  work(): void
}

interface Feedable {
  eat(): void
  sleep(): void
}

interface MeetingAttendee {
  attendMeeting(): void
}

interface ReportWriter {
  writeReport(): void
}

class Robot implements Workable, ReportWriter {
  work(): void { /* ... */ }
  writeReport(): void { /* ... */ }
}

class Intern implements Workable, Feedable {
  work(): void { /* ... */ }
  eat(): void { /* ... */ }
  sleep(): void { /* ... */ }
}

class SeniorEmployee implements Workable, Feedable, MeetingAttendee, ReportWriter {
  work(): void { /* ... */ }
  eat(): void { /* ... */ }
  sleep(): void { /* ... */ }
  attendMeeting(): void { /* ... */ }
  writeReport(): void { /* ... */ }
}
```

**Benefits:**
- Classes only implement what they actually do
- Changes to one interface don't affect unrelated clients
- Testing is focused on relevant capabilities

Reference: [Interface Segregation Principle](https://en.wikipedia.org/wiki/Interface_segregation_principle)

### 2.2 Fix Feature Envy by Moving Methods

**Impact: CRITICAL (improves cohesion and reduces cross-class dependencies)**

When a method uses more features of another class than its own, move it to that other class. Place behavior where the data lives.

**Incorrect (method envies another class):**

```typescript
class Order {
  customer: Customer
  items: OrderItem[]
}

class Customer {
  name: string
  loyaltyPoints: number
  memberSince: Date
  tier: 'bronze' | 'silver' | 'gold'
}

class OrderPrinter {
  formatOrderSummary(order: Order): string {
    const customer = order.customer
    // Uses 4 Customer fields but no OrderPrinter fields
    const tierLabel = customer.tier.toUpperCase()
    const years = new Date().getFullYear() - customer.memberSince.getFullYear()
    const pointsDisplay = `${customer.loyaltyPoints.toLocaleString()} pts`

    return `${tierLabel} Member: ${customer.name} (${years}yr, ${pointsDisplay})`
  }
}
```

**Correct (method moved to the class it uses):**

```typescript
class Customer {
  name: string
  loyaltyPoints: number
  memberSince: Date
  tier: 'bronze' | 'silver' | 'gold'

  formatSummary(): string {
    const tierLabel = this.tier.toUpperCase()
    const years = this.getMemberYears()
    const pointsDisplay = `${this.loyaltyPoints.toLocaleString()} pts`

    return `${tierLabel} Member: ${this.name} (${years}yr, ${pointsDisplay})`
  }

  getMemberYears(): number {
    return new Date().getFullYear() - this.memberSince.getFullYear()
  }
}

class OrderPrinter {
  formatOrderSummary(order: Order): string {
    return order.customer.formatSummary()  // Delegates to where data lives
  }
}
```

**Signs of feature envy:**
- Method takes another object and accesses multiple fields
- Method chains into another object repeatedly
- Adding a new field to the envied class requires changing the envying class

Reference: [Move Function](https://refactoring.com/catalog/moveFunction.html)

### 2.3 Hide Delegate to Reduce Coupling

**Impact: CRITICAL (eliminates chain dependencies and reduces ripple effects)**

When client code navigates through object chains (a.b.c.method()), changes to intermediate objects break many callers. Create a direct method to hide the navigation.

**Incorrect (exposing delegate chain):**

```typescript
class Person {
  department: Department
}

class Department {
  manager: Person
}

// Client code couples to the entire chain
function getManagerName(person: Person): string {
  return person.department.manager.name  // Knows about Department internals
}

function notifyManager(person: Person, message: string): void {
  const managerEmail = person.department.manager.email  // Chain repeated
  sendEmail(managerEmail, message)
}

// If Department structure changes, ALL callers break
```

**Correct (delegating method hides the chain):**

```typescript
class Person {
  private department: Department

  getManager(): Person {
    return this.department.manager
  }

  getManagerName(): string {
    return this.department.manager.name
  }

  getManagerEmail(): string {
    return this.department.manager.email
  }
}

// Client code only depends on Person interface
function getManagerName(person: Person): string {
  return person.getManagerName()
}

function notifyManager(person: Person, message: string): void {
  sendEmail(person.getManagerEmail(), message)
}

// Department changes only affect Person class
```

**When NOT to hide:**
- The delegate relationship is part of the public API
- Hiding would create an excessively large interface
- The chain is genuinely stable and unlikely to change

Reference: [Hide Delegate](https://refactoring.com/catalog/hideDelegate.html)

### 2.4 Preserve Whole Object Instead of Fields

**Impact: CRITICAL (reduces parameter coupling and simplifies method signatures)**

When you extract several values from an object and pass them as parameters, pass the whole object instead. This reduces coupling to the object's internal structure.

**Incorrect (extracting multiple fields):**

```typescript
function isWithinDeliveryRange(
  customerLat: number,
  customerLng: number,
  customerCity: string,
  customerZipCode: string
): boolean {
  const warehouseLocation = getWarehouse(customerCity)
  const distance = calculateDistance(customerLat, customerLng, warehouseLocation)
  return distance < 50 && isServicedZipCode(customerZipCode)
}

// Calling code extracts fields manually
const customer = getCustomer(id)
const canDeliver = isWithinDeliveryRange(
  customer.address.latitude,
  customer.address.longitude,
  customer.address.city,
  customer.address.zipCode
)  // If Address structure changes, this breaks
```

**Correct (passing whole object):**

```typescript
interface Address {
  latitude: number
  longitude: number
  city: string
  zipCode: string
}

function isWithinDeliveryRange(address: Address): boolean {
  const warehouseLocation = getWarehouse(address.city)
  const distance = calculateDistance(address.latitude, address.longitude, warehouseLocation)
  return distance < 50 && isServicedZipCode(address.zipCode)
}

// Calling code is simpler and decoupled from Address structure
const customer = getCustomer(id)
const canDeliver = isWithinDeliveryRange(customer.address)

// If Address gains a 'region' field, only isWithinDeliveryRange changes
```

**When NOT to use this pattern:**
- You only need one or two fields and don't want to create a dependency on the whole type
- The receiving function would have to import the type from a distant module
- The object is mutable and you want to work with a snapshot of values

Reference: [Preserve Whole Object](https://refactoring.com/catalog/preserveWholeObject.html)

### 2.5 Remove Middle Man When Excessive

**Impact: CRITICAL (eliminates unnecessary indirection and reduces code bloat)**

When a class becomes a simple pass-through with too many delegating methods, let clients call the delegate directly. Balance encapsulation with simplicity.

**Incorrect (excessive delegation):**

```typescript
class Person {
  private department: Department

  getDepartmentName(): string { return this.department.getName() }
  getDepartmentCode(): string { return this.department.getCode() }
  getDepartmentBudget(): number { return this.department.getBudget() }
  getDepartmentManager(): Person { return this.department.getManager() }
  getDepartmentLocation(): string { return this.department.getLocation() }
  getDepartmentEmployeeCount(): number { return this.department.getEmployeeCount() }
  // Person becomes a bloated wrapper around Department
}

// Every new Department method requires a new Person method
```

**Correct (expose delegate when appropriate):**

```typescript
class Person {
  private _department: Department

  // Only hide what genuinely needs hiding
  getManager(): Person {
    return this._department.getManager()
  }

  // Expose the delegate for direct access
  get department(): Department {
    return this._department
  }
}

// Client accesses Department directly for detailed queries
function formatDepartmentInfo(person: Person): string {
  const dept = person.department
  return `${dept.getName()} (${dept.getCode()}) - ${dept.getLocation()}`
}

// Person only delegates what makes semantic sense
function getDirectManager(person: Person): Person {
  return person.getManager()
}
```

**Guidelines for balance:**
- Hide navigation that reveals internal structure
- Expose stable, cohesive objects that have their own API
- Count the delegating methods—if they outnumber real methods, reconsider

Reference: [Remove Middle Man](https://refactoring.com/catalog/removeMiddleMan.html)

### 2.6 Use Dependency Injection

**Impact: CRITICAL (enables testing and reduces coupling by 70-90%)**

Pass dependencies to a class rather than creating them internally. This makes classes testable and loosely coupled.

**Incorrect (hard-coded dependencies):**

```typescript
class OrderService {
  private database = new PostgresDatabase()  // Hard-coded dependency
  private emailService = new SendGridEmailService()  // Can't test without real SendGrid
  private logger = new FileLogger('/var/log/app.log')  // Writes to real file

  async createOrder(orderData: OrderData): Promise<Order> {
    const order = await this.database.insert('orders', orderData)
    await this.emailService.send(order.customerEmail, 'Order Confirmed', order.id)
    this.logger.info(`Order created: ${order.id}`)
    return order
  }
}

// Testing requires real database, email service, and filesystem
const service = new OrderService()  // No way to substitute dependencies
```

**Correct (injected dependencies):**

```typescript
interface Database {
  insert(table: string, data: unknown): Promise<{ id: string }>
}

interface EmailService {
  send(to: string, subject: string, body: string): Promise<void>
}

interface Logger {
  info(message: string): void
}

class OrderService {
  constructor(
    private database: Database,
    private emailService: EmailService,
    private logger: Logger
  ) {}

  async createOrder(orderData: OrderData): Promise<Order> {
    const order = await this.database.insert('orders', orderData)
    await this.emailService.send(order.customerEmail, 'Order Confirmed', order.id)
    this.logger.info(`Order created: ${order.id}`)
    return order
  }
}

// Easy to test with mocks
const mockDatabase = { insert: jest.fn().mockResolvedValue({ id: '123' }) }
const mockEmail = { send: jest.fn() }
const mockLogger = { info: jest.fn() }
const service = new OrderService(mockDatabase, mockEmail, mockLogger)
```

**Benefits:**
- Unit tests run without external services
- Easy to swap implementations (PostgreSQL → MongoDB)
- Dependencies are explicit in the constructor signature

Reference: [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle)

---

## 3. Naming & Clarity

**Impact: HIGH**

Poor naming cascades into misunderstanding, bugs, and increased cognitive load. Clear, intention-revealing names make code self-documenting.

### 3.1 Avoid Abbreviations and Acronyms

**Impact: HIGH (eliminates guesswork and reduces onboarding time)**

Abbreviated names save keystrokes but cost comprehension time. Write out full words unless the abbreviation is universally understood.

**Incorrect (cryptic abbreviations):**

```typescript
interface UsrAcctDto {
  usrId: string
  acctNum: string
  curBal: number
  lstTxnDt: Date
  actv: boolean
  maxWdrwlAmt: number
}

function calcTotBal(accts: UsrAcctDto[]): number {
  return accts
    .filter(a => a.actv)
    .reduce((tot, a) => tot + a.curBal, 0)
}

const mgr = getUserMgr()
const cfg = getAppCfg()
```

**Correct (spelled out for clarity):**

```typescript
interface UserAccountDetails {
  userId: string
  accountNumber: string
  currentBalance: number
  lastTransactionDate: Date
  isActive: boolean
  maximumWithdrawalAmount: number
}

function calculateTotalBalance(accounts: UserAccountDetails[]): number {
  return accounts
    .filter(account => account.isActive)
    .reduce((total, account) => total + account.currentBalance, 0)
}

const userManager = getUserManager()
const applicationConfig = getApplicationConfig()
```

**Acceptable abbreviations:**
- Universally understood: `id`, `url`, `http`, `html`, `api`
- Domain-specific standards: `isbn`, `sku`, `vin`
- Loop counters: `i`, `j` in short loops
- Well-established: `min`, `max`, `avg`, `prev`, `next`

**When to keep abbreviations:**
- External API uses them and consistency matters
- Domain experts universally use the abbreviation
- Full name would be excessively long (>30 characters)

Reference: [Clean Code - Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

### 3.2 Avoid Type Encodings in Names

**Impact: HIGH (prevents name staleness and reduces visual clutter)**

Don't embed type information in variable names. Modern IDEs show types on hover, and encoded types become lies when refactored.

**Incorrect (type encodings in names):**

```typescript
interface IUserService {  // 'I' prefix for interface
  getUser(userId: string): User
}

class UserServiceImpl implements IUserService {  // 'Impl' suffix
  private strUserName: string  // Hungarian notation
  private arrUserIds: string[]  // Type in name
  private nUserCount: number  // 'n' for number
  private bIsActive: boolean  // 'b' for boolean
  private oUserConfig: UserConfig  // 'o' for object
  private lstUsers: User[]  // 'lst' for list

  getUserByIdString(userIdStr: string): User {  // Redundant 'String'
    return this.userMapObject.get(userIdStr)
  }
}
```

**Correct (clean names without encodings):**

```typescript
interface UserService {  // No 'I' prefix needed
  getUser(userId: string): User
}

class DefaultUserService implements UserService {  // Descriptive, not 'Impl'
  private userName: string
  private userIds: string[]
  private userCount: number
  private isActive: boolean
  private userConfig: UserConfig
  private users: User[]

  getUser(userId: string): User {
    return this.userMap.get(userId)
  }
}
```

**Modern alternatives to prefixes:**
- Instead of `IUserService`: Just `UserService` for interface, `HttpUserService` for implementation
- Instead of `Impl` suffix: Use descriptive names like `CachedUserService`, `MockUserService`
- Instead of Hungarian notation: Let the type system and IDE show types

**When encodings are acceptable:**
- Language conventions require them (C# interfaces commonly use `I`)
- Distinguishing otherwise identical names (`abstract class User` vs `class UserEntity`)

Reference: [Clean Code - Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

### 3.3 Use Consistent Vocabulary

**Impact: HIGH (eliminates confusion from synonyms and reduces mental mapping)**

Pick one word for each concept and stick to it throughout the codebase. Mixing synonyms forces readers to wonder if different words mean different things.

**Incorrect (inconsistent terms for same concept):**

```typescript
class UserController {
  fetchUser(id: string): User { /* ... */ }
}

class ProductController {
  getProduct(id: string): Product { /* ... */ }
}

class OrderController {
  retrieveOrder(id: string): Order { /* ... */ }
}

// Elsewhere in the codebase
const customer = loadCustomer(id)  // Is 'customer' different from 'user'?
const buyer = getBuyer(id)  // Another synonym?

// Data layer uses yet another term
class UserRepository {
  findById(id: string): User { /* ... */ }
}
```

**Correct (consistent vocabulary throughout):**

```typescript
// Pick 'get' for all retrieval operations
class UserController {
  getUser(id: string): User { /* ... */ }
}

class ProductController {
  getProduct(id: string): Product { /* ... */ }
}

class OrderController {
  getOrder(id: string): Order { /* ... */ }
}

// Consistent term for the entity
const user = getUser(id)  // Always 'user', never 'customer' or 'buyer'

// Repository layer follows same convention
class UserRepository {
  getById(id: string): User { /* ... */ }
}
```

**Establish conventions for:**
- CRUD operations: `create/get/update/delete` or `add/fetch/modify/remove`
- Collections: `list/find/search/filter` - pick one set
- Status changes: `activate/deactivate` or `enable/disable`
- Entity names: `user` vs `customer` vs `account`

Reference: [Domain-Driven Design - Ubiquitous Language](https://martinfowler.com/bliki/UbiquitousLanguage.html)

### 3.4 Use Intention-Revealing Names

**Impact: HIGH (reduces code comprehension time by 40-60%)**

Names should reveal why something exists, what it does, and how it is used. A reader should understand the purpose without reading the implementation.

**Incorrect (cryptic or generic names):**

```typescript
function proc(lst: number[]): number {
  let t = 0
  for (const x of lst) {
    if (x > 0) {
      t += x
    }
  }
  return t
}

const d = getD()
const flag = checkFlag(d)
if (flag) {
  proc(d.n)
}
```

**Correct (intention-revealing names):**

```typescript
function sumPositiveValues(values: number[]): number {
  let total = 0
  for (const value of values) {
    if (value > 0) {
      total += value
    }
  }
  return total
}

const transaction = getTransaction()
const isApproved = isTransactionApproved(transaction)
if (isApproved) {
  sumPositiveValues(transaction.amounts)
}
```

**Naming guidelines:**
- Variables: Describe what they hold (`customerEmail`, not `str` or `data`)
- Functions: Describe what they do (`calculateShippingCost`, not `calc`)
- Booleans: Use `is`, `has`, `can`, `should` prefixes (`isValid`, `hasPermission`)
- Collections: Use plural nouns (`users`, `orderItems`)

Reference: [Clean Code - Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

### 3.5 Use Searchable Names

**Impact: HIGH (enables quick codebase navigation and reduces debugging time)**

Single-letter names and numeric constants are impossible to search for. Use named constants and descriptive variable names that can be grepped across the codebase.

**Incorrect (unnamed constants and short names):**

```typescript
function calculatePrice(qty: number, p: number): number {
  if (qty > 10) {
    return p * qty * 0.9  // What is 0.9?
  }
  if (qty > 5) {
    return p * qty * 0.95  // What is 0.95?
  }
  return p * qty + 4.99  // What is 4.99?
}

// Trying to search for "the 10% discount" is impossible
// Searching for "0.9" finds every unrelated decimal
```

**Correct (named constants and descriptive names):**

```typescript
const BULK_ORDER_THRESHOLD = 10
const MEDIUM_ORDER_THRESHOLD = 5
const BULK_DISCOUNT_RATE = 0.10
const MEDIUM_DISCOUNT_RATE = 0.05
const STANDARD_SHIPPING_FEE = 4.99

function calculatePrice(quantity: number, unitPrice: number): number {
  if (quantity > BULK_ORDER_THRESHOLD) {
    return unitPrice * quantity * (1 - BULK_DISCOUNT_RATE)
  }
  if (quantity > MEDIUM_ORDER_THRESHOLD) {
    return unitPrice * quantity * (1 - MEDIUM_DISCOUNT_RATE)
  }
  return unitPrice * quantity + STANDARD_SHIPPING_FEE
}

// Searching for "BULK_DISCOUNT" finds all related code instantly
```

**Name everything that has meaning:**
- Thresholds and limits
- Configuration values
- Status codes and error codes
- Array indices with special meaning
- Regex patterns

Reference: [Clean Code - Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

---

## 4. Conditional Logic

**Impact: HIGH**

Complex conditionals are major contributors to cyclomatic and cognitive complexity. Simplifying them dramatically improves readability and testability.

### 4.1 Consolidate Duplicate Conditional Fragments

**Impact: HIGH (reduces code duplication by 30-50%)**

When the same code appears in all branches of a conditional, move it outside the conditional. When multiple conditions lead to the same result, combine them.

**Incorrect (duplicated code in branches):**

```typescript
function calculateShipping(order: Order, customer: Customer): number {
  if (customer.isPremium) {
    logShippingCalculation(order.id)  // Duplicated
    const baseRate = getBaseShippingRate(order.destination)  // Duplicated
    return baseRate * 0.5
  } else if (order.total > 100) {
    logShippingCalculation(order.id)  // Duplicated
    const baseRate = getBaseShippingRate(order.destination)  // Duplicated
    return 0
  } else {
    logShippingCalculation(order.id)  // Duplicated
    const baseRate = getBaseShippingRate(order.destination)  // Duplicated
    return baseRate
  }
}

// Another example: multiple conditions with same result
function getDiscount(dayOfWeek: number): number {
  if (dayOfWeek === 0) {
    return 0.1
  }
  if (dayOfWeek === 6) {
    return 0.1
  }
  if (dayOfWeek === 5 && isAfternoon()) {
    return 0.1
  }
  return 0
}
```

**Correct (consolidated logic):**

```typescript
function calculateShipping(order: Order, customer: Customer): number {
  logShippingCalculation(order.id)  // Moved outside
  const baseRate = getBaseShippingRate(order.destination)  // Moved outside

  if (customer.isPremium) {
    return baseRate * 0.5
  }
  if (order.total > 100) {
    return 0
  }
  return baseRate
}

// Consolidated conditions
function getDiscount(dayOfWeek: number): number {
  if (isWeekendOrFridayAfternoon(dayOfWeek)) {
    return 0.1
  }
  return 0
}

function isWeekendOrFridayAfternoon(dayOfWeek: number): boolean {
  const isWeekend = dayOfWeek === 0 || dayOfWeek === 6
  const isFridayAfternoon = dayOfWeek === 5 && isAfternoon()
  return isWeekend || isFridayAfternoon
}
```

**When NOT to consolidate:**
- The duplication is coincidental, not intentional
- The branches may diverge in the future
- Consolidation obscures the intent of each branch

Reference: [Consolidate Conditional Expression](https://refactoring.com/catalog/consolidateConditionalExpression.html)

### 4.2 Decompose Complex Conditionals

**Impact: HIGH (reduces cognitive complexity by 40-60%)**

Extract complex boolean expressions into well-named functions. The function name documents the business rule.

**Incorrect (complex inline condition):**

```typescript
function calculateDiscount(customer: Customer, order: Order): number {
  if (
    (customer.membershipYears >= 5 && customer.totalPurchases > 10000) ||
    (customer.tier === 'platinum') ||
    (order.items.length >= 10 && order.subtotal > 500 && !order.hasPromotion)
  ) {
    return order.subtotal * 0.2
  }

  if (
    customer.membershipYears >= 2 &&
    customer.totalPurchases > 5000 &&
    order.subtotal > 200
  ) {
    return order.subtotal * 0.1
  }

  return 0
}
```

**Correct (extracted into named predicates):**

```typescript
function calculateDiscount(customer: Customer, order: Order): number {
  if (isEligibleForPremiumDiscount(customer, order)) {
    return order.subtotal * 0.2
  }

  if (isEligibleForStandardDiscount(customer, order)) {
    return order.subtotal * 0.1
  }

  return 0
}

function isEligibleForPremiumDiscount(customer: Customer, order: Order): boolean {
  return isLoyalHighValueCustomer(customer) ||
         isPlatinumMember(customer) ||
         isBulkOrderWithoutPromotion(order)
}

function isLoyalHighValueCustomer(customer: Customer): boolean {
  return customer.membershipYears >= 5 && customer.totalPurchases > 10000
}

function isPlatinumMember(customer: Customer): boolean {
  return customer.tier === 'platinum'
}

function isBulkOrderWithoutPromotion(order: Order): boolean {
  return order.items.length >= 10 && order.subtotal > 500 && !order.hasPromotion
}

function isEligibleForStandardDiscount(customer: Customer, order: Order): boolean {
  return customer.membershipYears >= 2 &&
         customer.totalPurchases > 5000 &&
         order.subtotal > 200
}
```

**Benefits:**
- Business rules are named and documented
- Each predicate can be tested independently
- Changes to eligibility rules are localized

Reference: [Decompose Conditional](https://refactoring.com/catalog/decomposeConditional.html)

### 4.3 Introduce Special Case Object

**Impact: HIGH (eliminates repeated null checks throughout codebase)**

When many places check for a special case (often null) and do the same thing, create a special case object that encapsulates that behavior.

**Incorrect (repeated null checks):**

```typescript
interface Customer {
  name: string
  billingPlan: BillingPlan
  paymentHistory: Payment[]
}

function getCustomerName(customer: Customer | null): string {
  return customer !== null ? customer.name : 'Occupant'
}

function getBillingPlan(customer: Customer | null): BillingPlan {
  return customer !== null ? customer.billingPlan : BillingPlan.BASIC
}

function getPaymentHistory(customer: Customer | null): Payment[] {
  return customer !== null ? customer.paymentHistory : []
}

// Every function that uses Customer needs null checks
function sendInvoice(customer: Customer | null): void {
  const name = customer !== null ? customer.name : 'Occupant'
  const plan = customer !== null ? customer.billingPlan : BillingPlan.BASIC
  // ...more null checks
}
```

**Correct (special case object handles the behavior):**

```typescript
interface Customer {
  name: string
  billingPlan: BillingPlan
  paymentHistory: Payment[]
  isUnknown: boolean
}

class RealCustomer implements Customer {
  constructor(
    public name: string,
    public billingPlan: BillingPlan,
    public paymentHistory: Payment[]
  ) {}

  get isUnknown(): boolean {
    return false
  }
}

class UnknownCustomer implements Customer {
  name = 'Occupant'
  billingPlan = BillingPlan.BASIC
  paymentHistory: Payment[] = []

  get isUnknown(): boolean {
    return true
  }
}

// Factory function returns special case instead of null
function getCustomer(id: string): Customer {
  const customer = database.find(id)
  return customer ?? new UnknownCustomer()
}

// No more null checks needed
function sendInvoice(customer: Customer): void {
  const name = customer.name  // Works for both real and unknown
  const plan = customer.billingPlan  // No null check needed
}
```

**Benefits:**
- Null checks eliminated throughout codebase
- Default behavior centralized in one place
- New special cases can add different default behaviors

Reference: [Introduce Special Case](https://refactoring.com/catalog/introduceSpecialCase.html)

### 4.4 Replace Conditional with Lookup Table

**Impact: HIGH (reduces cyclomatic complexity and improves maintainability)**

When a conditional simply maps values to other values, replace it with a lookup table (object or Map). This is cleaner and often faster.

**Incorrect (long switch for value mapping):**

```typescript
function getStatusLabel(status: string): string {
  switch (status) {
    case 'pending':
      return 'Awaiting Review'
    case 'approved':
      return 'Approved'
    case 'rejected':
      return 'Rejected'
    case 'in_progress':
      return 'In Progress'
    case 'completed':
      return 'Completed'
    case 'cancelled':
      return 'Cancelled'
    default:
      return 'Unknown'
  }
}

function getStatusColor(status: string): string {
  switch (status) {
    case 'pending':
      return '#FFA500'
    case 'approved':
      return '#00FF00'
    case 'rejected':
      return '#FF0000'
    // ... same pattern repeated
  }
}
```

**Correct (lookup table):**

```typescript
interface StatusConfig {
  label: string
  color: string
  icon: string
}

const STATUS_CONFIG: Record<string, StatusConfig> = {
  pending: { label: 'Awaiting Review', color: '#FFA500', icon: 'clock' },
  approved: { label: 'Approved', color: '#00FF00', icon: 'check' },
  rejected: { label: 'Rejected', color: '#FF0000', icon: 'x' },
  in_progress: { label: 'In Progress', color: '#0000FF', icon: 'spinner' },
  completed: { label: 'Completed', color: '#008000', icon: 'check-circle' },
  cancelled: { label: 'Cancelled', color: '#808080', icon: 'ban' }
}

const DEFAULT_STATUS: StatusConfig = { label: 'Unknown', color: '#000000', icon: 'question' }

function getStatusConfig(status: string): StatusConfig {
  return STATUS_CONFIG[status] ?? DEFAULT_STATUS
}

function getStatusLabel(status: string): string {
  return getStatusConfig(status).label
}

function getStatusColor(status: string): string {
  return getStatusConfig(status).color
}
```

**Benefits:**
- Single source of truth for all status-related data
- Adding a new status is one line, not changes to multiple switches
- Configuration can be externalized (loaded from JSON/database)

**When NOT to use:**
- Logic between cases is complex and varies significantly
- Only 2-3 cases exist and unlikely to grow

Reference: [Replace Conditional with Polymorphism](https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html)

### 4.5 Replace Conditional with Polymorphism

**Impact: HIGH (eliminates repeated switch statements and enables Open-Closed Principle)**

When the same switch/if-else on type appears in multiple places, replace it with polymorphism. New types can be added without modifying existing code.

**Incorrect (repeated type-based conditionals):**

```typescript
type ShapeType = 'circle' | 'rectangle' | 'triangle'

interface Shape {
  type: ShapeType
  radius?: number
  width?: number
  height?: number
  base?: number
}

function calculateArea(shape: Shape): number {
  switch (shape.type) {
    case 'circle':
      return Math.PI * shape.radius! ** 2
    case 'rectangle':
      return shape.width! * shape.height!
    case 'triangle':
      return (shape.base! * shape.height!) / 2
    default:
      throw new Error(`Unknown shape: ${shape.type}`)
  }
}

function calculatePerimeter(shape: Shape): number {
  switch (shape.type) {  // Same switch repeated
    case 'circle':
      return 2 * Math.PI * shape.radius!
    case 'rectangle':
      return 2 * (shape.width! + shape.height!)
    case 'triangle':
      // Complex calculation...
  }
}
// Adding a new shape requires modifying EVERY function
```

**Correct (polymorphic solution):**

```typescript
interface Shape {
  calculateArea(): number
  calculatePerimeter(): number
}

class Circle implements Shape {
  constructor(private radius: number) {}

  calculateArea(): number {
    return Math.PI * this.radius ** 2
  }

  calculatePerimeter(): number {
    return 2 * Math.PI * this.radius
  }
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}

  calculateArea(): number {
    return this.width * this.height
  }

  calculatePerimeter(): number {
    return 2 * (this.width + this.height)
  }
}

// Adding a new shape only requires a new class
class Pentagon implements Shape {
  constructor(private sideLength: number) {}

  calculateArea(): number {
    return (Math.sqrt(5 * (5 + 2 * Math.sqrt(5))) / 4) * this.sideLength ** 2
  }

  calculatePerimeter(): number {
    return 5 * this.sideLength
  }
}
```

**When to use polymorphism:**
- Same conditional on type appears 3+ times
- New types are likely to be added
- Behavior differs significantly between types

Reference: [Replace Conditional with Polymorphism](https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html)

### 4.6 Replace Nested Conditionals with Guard Clauses

**Impact: HIGH (reduces nesting depth and cognitive load by 50-70%)**

Deep nesting makes code hard to follow. Use guard clauses to handle edge cases early and keep the main logic at the top level.

**Incorrect (deeply nested conditionals):**

```typescript
function processPayment(order: Order, user: User): PaymentResult {
  if (order !== null) {
    if (order.items.length > 0) {
      if (user !== null) {
        if (user.paymentMethod !== null) {
          if (order.total <= user.creditLimit) {
            // Finally, the actual business logic
            const payment = chargePayment(user.paymentMethod, order.total)
            order.status = 'paid'
            return { success: true, transactionId: payment.id }
          } else {
            return { success: false, error: 'Credit limit exceeded' }
          }
        } else {
          return { success: false, error: 'No payment method' }
        }
      } else {
        return { success: false, error: 'User required' }
      }
    } else {
      return { success: false, error: 'Empty order' }
    }
  } else {
    return { success: false, error: 'Order required' }
  }
}
```

**Correct (guard clauses with early return):**

```typescript
function processPayment(order: Order, user: User): PaymentResult {
  if (!order) {
    return { success: false, error: 'Order required' }
  }
  if (order.items.length === 0) {
    return { success: false, error: 'Empty order' }
  }
  if (!user) {
    return { success: false, error: 'User required' }
  }
  if (!user.paymentMethod) {
    return { success: false, error: 'No payment method' }
  }
  if (order.total > user.creditLimit) {
    return { success: false, error: 'Credit limit exceeded' }
  }

  // Main logic is now at the top level, easy to read
  const payment = chargePayment(user.paymentMethod, order.total)
  order.status = 'paid'
  return { success: true, transactionId: payment.id }
}
```

**Benefits:**
- Validation logic is clearly separated from business logic
- Maximum nesting depth is 1 instead of 5+
- Easy to add new validations without restructuring

Reference: [Replace Nested Conditional with Guard Clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html)

---

## 5. Abstraction & Patterns

**Impact: MEDIUM-HIGH**

Proper abstractions and design patterns enable extensibility without modification (Open-Closed Principle), reducing future refactoring needs.

### 5.1 Apply Open-Closed Principle

**Impact: MEDIUM-HIGH (enables extension without modifying existing tested code)**

Classes should be open for extension but closed for modification. Design so that new behavior can be added without changing existing code.

**Incorrect (requires modification for new types):**

```typescript
class DiscountCalculator {
  calculate(order: Order): number {
    let discount = 0

    // Adding a new discount type requires modifying this method
    if (order.customer.isPremium) {
      discount += order.total * 0.1
    }

    if (order.items.length > 10) {
      discount += order.total * 0.05
    }

    if (order.coupon) {
      if (order.coupon.type === 'percentage') {
        discount += order.total * (order.coupon.value / 100)
      } else if (order.coupon.type === 'fixed') {
        discount += order.coupon.value
      }
      // New coupon type? Modify this method
    }

    if (isHolidaySeason()) {
      discount += order.total * 0.15
    }

    return Math.min(discount, order.total)
  }
}
```

**Correct (extensible via new classes):**

```typescript
interface DiscountRule {
  calculate(order: Order): number
}

class PremiumCustomerDiscount implements DiscountRule {
  calculate(order: Order): number {
    return order.customer.isPremium ? order.total * 0.1 : 0
  }
}

class BulkOrderDiscount implements DiscountRule {
  calculate(order: Order): number {
    return order.items.length > 10 ? order.total * 0.05 : 0
  }
}

class CouponDiscount implements DiscountRule {
  calculate(order: Order): number {
    if (!order.coupon) return 0
    return order.coupon.type === 'percentage'
      ? order.total * (order.coupon.value / 100)
      : order.coupon.value
  }
}

class DiscountCalculator {
  constructor(private rules: DiscountRule[]) {}

  calculate(order: Order): number {
    const totalDiscount = this.rules.reduce(
      (sum, rule) => sum + rule.calculate(order),
      0
    )
    return Math.min(totalDiscount, order.total)
  }
}

// Adding new discount: create new class, inject it - no modification needed
class HolidayDiscount implements DiscountRule {
  calculate(order: Order): number {
    return isHolidaySeason() ? order.total * 0.15 : 0
  }
}

const calculator = new DiscountCalculator([
  new PremiumCustomerDiscount(),
  new BulkOrderDiscount(),
  new CouponDiscount(),
  new HolidayDiscount()  // Added without modifying DiscountCalculator
])
```

**Benefits:**
- New discount rules added without risk to existing rules
- Each rule can be tested independently
- Rules can be conditionally included at runtime

Reference: [Open-Closed Principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)

### 5.2 Extract Strategy for Algorithm Variants

**Impact: MEDIUM-HIGH (enables runtime algorithm swapping and isolated testing)**

When a class supports multiple algorithms for the same operation, extract each algorithm into its own strategy class. This allows runtime switching and independent testing.

**Incorrect (algorithm variants embedded in class):**

```typescript
class PaymentProcessor {
  processPayment(amount: number, method: string, details: PaymentDetails): PaymentResult {
    if (method === 'credit_card') {
      // 20 lines of credit card processing logic
      const encrypted = encryptCardData(details.cardNumber, details.cvv)
      const gateway = connectToStripeGateway()
      const auth = gateway.authorize(encrypted, amount)
      if (!auth.success) {
        return { success: false, error: auth.message }
      }
      const capture = gateway.capture(auth.transactionId)
      return { success: true, transactionId: capture.id }
    } else if (method === 'paypal') {
      // 15 lines of PayPal logic
      const redirect = initiatePayPalFlow(amount, details.returnUrl)
      // ...
    } else if (method === 'crypto') {
      // 25 lines of crypto payment logic
      const wallet = connectToWallet(details.walletAddress)
      // ...
    }
    throw new Error(`Unknown payment method: ${method}`)
  }
}
```

**Correct (strategy pattern):**

```typescript
interface PaymentStrategy {
  processPayment(amount: number, details: PaymentDetails): PaymentResult
}

class CreditCardStrategy implements PaymentStrategy {
  processPayment(amount: number, details: PaymentDetails): PaymentResult {
    const encrypted = encryptCardData(details.cardNumber, details.cvv)
    const gateway = connectToStripeGateway()
    const auth = gateway.authorize(encrypted, amount)
    if (!auth.success) {
      return { success: false, error: auth.message }
    }
    const capture = gateway.capture(auth.transactionId)
    return { success: true, transactionId: capture.id }
  }
}

class PayPalStrategy implements PaymentStrategy {
  processPayment(amount: number, details: PaymentDetails): PaymentResult {
    const redirect = initiatePayPalFlow(amount, details.returnUrl)
    // PayPal-specific logic
    return { success: true, transactionId: redirect.id }
  }
}

class PaymentProcessor {
  constructor(private strategies: Map<string, PaymentStrategy>) {}

  processPayment(amount: number, method: string, details: PaymentDetails): PaymentResult {
    const strategy = this.strategies.get(method)
    if (!strategy) {
      throw new Error(`Unknown payment method: ${method}`)
    }
    return strategy.processPayment(amount, details)
  }
}
```

**Benefits:**
- Each strategy can be unit tested independently
- New payment methods added without modifying PaymentProcessor
- Strategies can be swapped at runtime (A/B testing)

Reference: [Strategy Pattern](https://refactoring.guru/design-patterns/strategy)

### 5.3 Extract Superclass for Common Behavior

**Impact: MEDIUM-HIGH (eliminates duplication across related classes)**

When two classes have similar features, extract common behavior into a superclass. This is appropriate when the classes represent variations of the same concept.

**Incorrect (duplicated behavior across classes):**

```typescript
class Employee {
  name: string
  annualSalary: number

  constructor(name: string, annualSalary: number) {
    this.name = name
    this.annualSalary = annualSalary
  }

  getMonthlyCost(): number {
    return this.annualSalary / 12
  }

  getName(): string {
    return this.name
  }

  getAnnualCost(): number {
    return this.annualSalary
  }
}

class Contractor {
  name: string
  hourlyRate: number
  hoursPerMonth: number

  constructor(name: string, hourlyRate: number, hoursPerMonth: number) {
    this.name = name
    this.hourlyRate = hourlyRate
    this.hoursPerMonth = hoursPerMonth
  }

  getMonthlyCost(): number {  // Same method name, different calculation
    return this.hourlyRate * this.hoursPerMonth
  }

  getName(): string {  // Duplicated
    return this.name
  }

  getAnnualCost(): number {  // Same method name, different calculation
    return this.getMonthlyCost() * 12
  }
}
```

**Correct (extracted superclass):**

```typescript
abstract class Worker {
  constructor(protected name: string) {}

  getName(): string {
    return this.name
  }

  abstract getMonthlyCost(): number

  getAnnualCost(): number {
    return this.getMonthlyCost() * 12
  }
}

class Employee extends Worker {
  constructor(name: string, private annualSalary: number) {
    super(name)
  }

  getMonthlyCost(): number {
    return this.annualSalary / 12
  }
}

class Contractor extends Worker {
  constructor(
    name: string,
    private hourlyRate: number,
    private hoursPerMonth: number
  ) {
    super(name)
  }

  getMonthlyCost(): number {
    return this.hourlyRate * this.hoursPerMonth
  }
}

// Can now work with both types uniformly
function calculateTotalMonthlyCost(workers: Worker[]): number {
  return workers.reduce((sum, worker) => sum + worker.getMonthlyCost(), 0)
}
```

**When NOT to use:**
- Classes don't represent the same conceptual category
- Would violate Liskov Substitution Principle
- Composition would be more flexible

Reference: [Extract Superclass](https://refactoring.com/catalog/extractSuperclass.html)

### 5.4 Prefer Composition Over Inheritance

**Impact: MEDIUM-HIGH (enables flexible behavior combination without class explosion)**

Inheritance creates tight coupling and can lead to fragile base class problems. Compose objects by combining behaviors at runtime.

**Incorrect (inheritance hierarchy for behavior combinations):**

```typescript
class Animal {
  eat(): void { /* ... */ }
}

class FlyingAnimal extends Animal {
  fly(): void { /* ... */ }
}

class SwimmingAnimal extends Animal {
  swim(): void { /* ... */ }
}

// Problem: Duck can fly AND swim - which class to extend?
class FlyingSwimmingAnimal extends FlyingAnimal {
  swim(): void { /* ... */ }  // Duplicated from SwimmingAnimal
}

class Duck extends FlyingSwimmingAnimal {}

// Adding walking, running, climbing leads to class explosion:
// FlyingWalkingAnimal, SwimmingWalkingAnimal, FlyingSwimmingWalkingAnimal...
```

**Correct (composition of behaviors):**

```typescript
interface Behavior {
  perform(): void
}

class FlyingBehavior implements Behavior {
  perform(): void {
    console.log('Flying through the air')
  }
}

class SwimmingBehavior implements Behavior {
  perform(): void {
    console.log('Swimming in water')
  }
}

class WalkingBehavior implements Behavior {
  perform(): void {
    console.log('Walking on land')
  }
}

class Animal {
  private behaviors: Behavior[] = []

  addBehavior(behavior: Behavior): void {
    this.behaviors.push(behavior)
  }

  performBehaviors(): void {
    this.behaviors.forEach(b => b.perform())
  }
}

// Duck composes the behaviors it needs
const duck = new Animal()
duck.addBehavior(new FlyingBehavior())
duck.addBehavior(new SwimmingBehavior())
duck.addBehavior(new WalkingBehavior())

// Penguin has different combination
const penguin = new Animal()
penguin.addBehavior(new SwimmingBehavior())
penguin.addBehavior(new WalkingBehavior())

// Behaviors can even be changed at runtime
```

**When inheritance is appropriate:**
- True "is-a" relationship with LSP compliance
- Behavior rarely changes between subclasses
- Framework requires it (React class components, etc.)

Reference: [Composition Over Inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance)

### 5.5 Use Factory for Complex Object Creation

**Impact: MEDIUM-HIGH (reduces duplication by 40-60% and enables isolated testing)**

When object creation involves complex logic, validation, or conditional instantiation, encapsulate it in a factory. This separates creation concerns from business logic.

**Incorrect (complex creation scattered throughout codebase):**

```typescript
class OrderService {
  createOrder(data: OrderData): Order {
    // Complex creation logic repeated wherever orders are created
    const items = data.items.map(item => {
      const product = productRepository.find(item.productId)
      if (!product) throw new Error(`Product not found: ${item.productId}`)
      if (product.inventory < item.quantity) {
        throw new Error(`Insufficient inventory for ${product.name}`)
      }
      return new OrderItem(product, item.quantity, product.price)
    })

    const customer = customerRepository.find(data.customerId)
    if (!customer) throw new Error('Customer not found')

    const shippingAddress = customer.addresses.find(a => a.id === data.addressId)
    if (!shippingAddress) throw new Error('Address not found')

    const order = new Order(customer, items, shippingAddress)
    order.calculateTotals()
    return order
  }
}

// Same creation logic duplicated in ImportService, MigrationService, etc.
```

**Correct (factory encapsulates creation):**

```typescript
class OrderFactory {
  constructor(
    private productRepository: ProductRepository,
    private customerRepository: CustomerRepository
  ) {}

  create(data: OrderData): Order {
    const items = this.createOrderItems(data.items)
    const customer = this.getValidatedCustomer(data.customerId)
    const shippingAddress = this.getValidatedAddress(customer, data.addressId)

    const order = new Order(customer, items, shippingAddress)
    order.calculateTotals()
    return order
  }

  private createOrderItems(itemsData: OrderItemData[]): OrderItem[] {
    return itemsData.map(item => {
      const product = this.productRepository.find(item.productId)
      if (!product) throw new Error(`Product not found: ${item.productId}`)
      if (product.inventory < item.quantity) {
        throw new Error(`Insufficient inventory for ${product.name}`)
      }
      return new OrderItem(product, item.quantity, product.price)
    })
  }

  private getValidatedCustomer(customerId: string): Customer {
    const customer = this.customerRepository.find(customerId)
    if (!customer) throw new Error('Customer not found')
    return customer
  }

  private getValidatedAddress(customer: Customer, addressId: string): Address {
    const address = customer.addresses.find(a => a.id === addressId)
    if (!address) throw new Error('Address not found')
    return address
  }
}

// Service is now simple
class OrderService {
  constructor(private orderFactory: OrderFactory) {}

  createOrder(data: OrderData): Order {
    return this.orderFactory.create(data)
  }
}
```

**Benefits:**
- Creation logic centralized and testable
- Easy to create test doubles (TestOrderFactory)
- Services focus on business logic, not object construction

Reference: [Factory Method Pattern](https://refactoring.guru/design-patterns/factory-method)

### 5.6 Use Template Method for Shared Skeleton

**Impact: MEDIUM-HIGH (eliminates duplicate control flow across similar algorithms)**

When multiple classes have similar algorithms with different steps, define the skeleton in a base class and let subclasses override specific steps.

**Incorrect (duplicated algorithm structure):**

```typescript
class PDFReportGenerator {
  generate(data: ReportData): void {
    this.logStart('PDF')  // Duplicated
    const validated = this.validateData(data)  // Duplicated
    if (!validated) throw new Error('Invalid data')  // Duplicated

    // PDF-specific formatting
    const content = this.formatAsPDF(data)
    this.writeToPDF(content)

    this.logComplete('PDF')  // Duplicated
    this.sendNotification()  // Duplicated
  }
}

class ExcelReportGenerator {
  generate(data: ReportData): void {
    this.logStart('Excel')  // Duplicated
    const validated = this.validateData(data)  // Duplicated
    if (!validated) throw new Error('Invalid data')  // Duplicated

    // Excel-specific formatting
    const content = this.formatAsExcel(data)
    this.writeToExcel(content)

    this.logComplete('Excel')  // Duplicated
    this.sendNotification()  // Duplicated
  }
}
```

**Correct (template method pattern):**

```typescript
abstract class ReportGenerator {
  // Template method defines the skeleton
  generate(data: ReportData): void {
    this.logStart()
    this.validateData(data)
    const content = this.formatContent(data)  // Abstract - subclass implements
    this.writeOutput(content)  // Abstract - subclass implements
    this.logComplete()
    this.sendNotification()
  }

  private logStart(): void {
    console.log(`Starting ${this.getReportType()} generation`)
  }

  private validateData(data: ReportData): void {
    if (!data.title || !data.rows.length) {
      throw new Error('Invalid report data')
    }
  }

  private logComplete(): void {
    console.log(`Completed ${this.getReportType()} generation`)
  }

  private sendNotification(): void {
    notifyReportComplete(this.getReportType())
  }

  // Hook methods for subclasses to implement
  protected abstract getReportType(): string
  protected abstract formatContent(data: ReportData): string
  protected abstract writeOutput(content: string): void
}

class PDFReportGenerator extends ReportGenerator {
  protected getReportType(): string { return 'PDF' }

  protected formatContent(data: ReportData): string {
    return formatAsPDF(data)
  }

  protected writeOutput(content: string): void {
    writeToPDFFile(content)
  }
}

class ExcelReportGenerator extends ReportGenerator {
  protected getReportType(): string { return 'Excel' }

  protected formatContent(data: ReportData): string {
    return formatAsExcel(data)
  }

  protected writeOutput(content: string): void {
    writeToExcelFile(content)
  }
}
```

**Benefits:**
- Algorithm skeleton defined once
- Subclasses focus on what's different
- Adding new report types only requires implementing abstract methods

Reference: [Template Method Pattern](https://refactoring.guru/design-patterns/template-method)

---

## 6. Data Organization

**Impact: MEDIUM**

How data is structured affects all operations on it. Proper encapsulation and organization reduce coupling and improve code clarity.

### 6.1 Encapsulate Collection

**Impact: MEDIUM (prevents uncontrolled modifications and enforces invariants)**

Never expose raw collections directly. Provide controlled access methods that maintain invariants and prevent external modification.

**Incorrect (exposed mutable collection):**

```typescript
class Course {
  students: Student[] = []  // Exposed directly

  addStudent(student: Student): void {
    this.students.push(student)
  }
}

// Callers can bypass the API and break invariants
const course = new Course()
course.students.push(student)  // Bypasses addStudent validation
course.students.length = 0  // Clears all students unexpectedly
course.students = []  // Replaces entire collection

// No way to enforce max class size or prerequisites
```

**Correct (encapsulated with controlled access):**

```typescript
class Course {
  private _students: Student[] = []
  private readonly maxSize = 30

  addStudent(student: Student): void {
    if (this._students.length >= this.maxSize) {
      throw new Error('Course is full')
    }
    if (this._students.some(s => s.id === student.id)) {
      throw new Error('Student already enrolled')
    }
    this._students.push(student)
  }

  removeStudent(studentId: string): void {
    const index = this._students.findIndex(s => s.id === studentId)
    if (index === -1) {
      throw new Error('Student not found')
    }
    this._students.splice(index, 1)
  }

  // Return a copy to prevent external modification
  get students(): readonly Student[] {
    return [...this._students]
  }

  get studentCount(): number {
    return this._students.length
  }

  hasStudent(studentId: string): boolean {
    return this._students.some(s => s.id === studentId)
  }
}

// Now all access goes through controlled methods
const course = new Course()
course.addStudent(student)  // Validates max size
course.students.push(another)  // No effect - it's a copy
```

**Benefits:**
- Invariants enforced (max size, no duplicates)
- Clear API for collection operations
- Internal representation can change without affecting clients

Reference: [Encapsulate Collection](https://refactoring.com/catalog/encapsulateCollection.html)

### 6.2 Encapsulate Record into Class

**Impact: MEDIUM (enables derived data and controlled mutation)**

When a plain data structure grows behavior or needs derived fields, convert it to a class. This centralizes logic and protects invariants.

**Incorrect (plain object with scattered logic):**

```typescript
interface Order {
  items: { productId: string; quantity: number; price: number }[]
  taxRate: number
  shippingCost: number
}

// Logic scattered across consumers
function getSubtotal(order: Order): number {
  return order.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
}

function getTax(order: Order): number {
  return getSubtotal(order) * order.taxRate
}

function getTotal(order: Order): number {
  return getSubtotal(order) + getTax(order) + order.shippingCost
}

// Different module calculates subtotal differently (bug!)
function printReceipt(order: Order): void {
  const subtotal = order.items.reduce((sum, item) => sum + item.price, 0)  // Missing quantity!
  console.log(`Subtotal: ${subtotal}`)
}
```

**Correct (encapsulated in class):**

```typescript
class Order {
  private _items: OrderItem[] = []

  constructor(
    private readonly taxRate: number,
    private shippingCost: number
  ) {}

  addItem(productId: string, quantity: number, price: number): void {
    this._items.push(new OrderItem(productId, quantity, price))
  }

  get items(): readonly OrderItem[] {
    return [...this._items]
  }

  get subtotal(): number {
    return this._items.reduce((sum, item) => sum + item.total, 0)
  }

  get tax(): number {
    return this.subtotal * this.taxRate
  }

  get total(): number {
    return this.subtotal + this.tax + this.shippingCost
  }

  get itemCount(): number {
    return this._items.reduce((sum, item) => sum + item.quantity, 0)
  }
}

class OrderItem {
  constructor(
    public readonly productId: string,
    public readonly quantity: number,
    public readonly price: number
  ) {}

  get total(): number {
    return this.price * this.quantity
  }
}

// All consumers use the same calculation
function printReceipt(order: Order): void {
  console.log(`Subtotal: ${order.subtotal}`)  // Guaranteed correct
  console.log(`Tax: ${order.tax}`)
  console.log(`Total: ${order.total}`)
}
```

**Benefits:**
- Derived data calculated consistently
- Changes to calculation logic happen in one place
- Impossible to access stale or incorrect calculations

Reference: [Encapsulate Record](https://refactoring.com/catalog/encapsulateRecord.html)

### 6.3 Replace Primitive with Object

**Impact: MEDIUM (enables validation and domain-specific behavior)**

When primitives carry domain meaning beyond their raw value, wrap them in domain objects. This provides a home for validation and behavior.

**Incorrect (primitives scattered throughout):**

```typescript
function createUser(email: string, phone: string, zipCode: string): User {
  // Validation logic repeated everywhere emails are used
  if (!email.includes('@') || !email.includes('.')) {
    throw new Error('Invalid email')
  }
  // Phone validation repeated everywhere
  if (phone.replace(/\D/g, '').length !== 10) {
    throw new Error('Invalid phone')
  }
  // ZIP validation repeated
  if (!/^\d{5}(-\d{4})?$/.test(zipCode)) {
    throw new Error('Invalid ZIP')
  }

  return { email, phone, zipCode }
}

// Elsewhere, same validation repeated
function sendEmail(email: string, subject: string): void {
  if (!email.includes('@')) {  // Inconsistent validation
    throw new Error('Invalid email')
  }
  // ...
}
```

**Correct (domain objects with behavior):**

```typescript
class Email {
  private readonly value: string

  constructor(value: string) {
    if (!this.isValid(value)) {
      throw new Error(`Invalid email: ${value}`)
    }
    this.value = value.toLowerCase().trim()
  }

  private isValid(value: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
  }

  toString(): string {
    return this.value
  }

  getDomain(): string {
    return this.value.split('@')[1]
  }
}

class PhoneNumber {
  private readonly digits: string

  constructor(value: string) {
    this.digits = value.replace(/\D/g, '')
    if (this.digits.length !== 10) {
      throw new Error(`Invalid phone number: ${value}`)
    }
  }

  format(): string {
    return `(${this.digits.slice(0, 3)}) ${this.digits.slice(3, 6)}-${this.digits.slice(6)}`
  }

  toString(): string {
    return this.digits
  }
}

class ZipCode {
  constructor(private readonly value: string) {
    if (!/^\d{5}(-\d{4})?$/.test(value)) {
      throw new Error(`Invalid ZIP code: ${value}`)
    }
  }

  toString(): string {
    return this.value
  }
}

// Usage is clean and validated by construction
function createUser(email: Email, phone: PhoneNumber, zipCode: ZipCode): User {
  return { email, phone, zipCode }  // Already validated
}

const user = createUser(
  new Email('user@example.com'),
  new PhoneNumber('123-456-7890'),
  new ZipCode('12345')
)
```

**Benefits:**
- Validation happens once, at construction
- Formatting and behavior lives with the data
- Type system prevents passing wrong primitives

Reference: [Replace Primitive with Object](https://refactoring.com/catalog/replacePrimitiveWithObject.html)

### 6.4 Replace Temp with Query

**Impact: MEDIUM (enables reuse and makes intent explicit)**

Replace temporary variables with query methods when the value is used multiple times or represents a meaningful concept. This makes the code more self-documenting.

**Incorrect (temporary variable obscures intent):**

```typescript
class Order {
  getPrice(): number {
    const basePrice = this.quantity * this.itemPrice
    let discountFactor: number

    if (basePrice > 1000) {
      discountFactor = 0.95
    } else {
      discountFactor = 0.98
    }

    return basePrice * discountFactor
  }
}

// basePrice concept hidden inside method
// discountFactor logic cannot be reused
```

**Correct (extracted to query methods):**

```typescript
class Order {
  getPrice(): number {
    return this.basePrice * this.discountFactor
  }

  get basePrice(): number {
    return this.quantity * this.itemPrice
  }

  get discountFactor(): number {
    return this.basePrice > 1000 ? 0.95 : 0.98
  }
}

// Now these can be used elsewhere
class OrderPrinter {
  printReceipt(order: Order): void {
    console.log(`Base Price: ${order.basePrice}`)
    console.log(`Discount: ${(1 - order.discountFactor) * 100}%`)
    console.log(`Final: ${order.getPrice()}`)
  }
}
```

**When NOT to replace:**
- Variable is used once and extraction adds no clarity
- Calculation is expensive and would be repeated (use memoization or keep temp)
- Variable represents an intermediate step in a complex algorithm

**Performance consideration:**

```typescript
// If worried about repeated calculation
class Order {
  private _basePrice: number | null = null

  get basePrice(): number {
    if (this._basePrice === null) {
      this._basePrice = this.quantity * this.itemPrice
    }
    return this._basePrice
  }

  // Invalidate cache when data changes
  set quantity(value: number) {
    this._quantity = value
    this._basePrice = null
  }
}
```

Reference: [Replace Temp with Query](https://refactoring.com/catalog/replaceTempWithQuery.html)

### 6.5 Split Variable with Multiple Assignments

**Impact: MEDIUM (clarifies intent and prevents confusion from reused variables)**

When a variable is assigned multiple times for different purposes, split it into separate variables. Each variable should have a single clear purpose.

**Incorrect (variable reused for different purposes):**

```typescript
function calculateShipping(order: Order): number {
  let temp = order.items.reduce((sum, item) => sum + item.weight, 0)  // temp is total weight
  temp = temp * 0.5  // temp is now base shipping cost
  temp = temp + 5  // temp is now shipping cost with handling fee

  if (order.destination.isRemote) {
    temp = temp * 1.5  // temp is now adjusted for remote
  }

  temp = Math.max(temp, 10)  // temp is now minimum shipping
  temp = Math.min(temp, 100)  // temp is now capped shipping

  return temp
}

// What does 'temp' represent at any given line? Impossible to know at a glance
```

**Correct (separate variables with clear purposes):**

```typescript
function calculateShipping(order: Order): number {
  const totalWeight = order.items.reduce((sum, item) => sum + item.weight, 0)
  const baseShippingCost = totalWeight * 0.5
  const costWithHandling = baseShippingCost + 5

  const adjustedCost = order.destination.isRemote
    ? costWithHandling * 1.5
    : costWithHandling

  const MIN_SHIPPING = 10
  const MAX_SHIPPING = 100
  const finalCost = Math.min(Math.max(adjustedCost, MIN_SHIPPING), MAX_SHIPPING)

  return finalCost
}

// Each variable has one clear meaning throughout its scope
```

**Alternative (pure function composition):**

```typescript
function calculateShipping(order: Order): number {
  const totalWeight = calculateTotalWeight(order.items)
  const baseCost = calculateBaseCost(totalWeight)
  const adjustedCost = adjustForDestination(baseCost, order.destination)
  return applyShippingBounds(adjustedCost)
}

function calculateTotalWeight(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.weight, 0)
}

function calculateBaseCost(weight: number): number {
  const HANDLING_FEE = 5
  return weight * 0.5 + HANDLING_FEE
}

function adjustForDestination(cost: number, destination: Destination): number {
  return destination.isRemote ? cost * 1.5 : cost
}

function applyShippingBounds(cost: number): number {
  return Math.min(Math.max(cost, 10), 100)
}
```

**Benefits:**
- Each variable's meaning is immediately clear
- Easier to debug - inspect any variable at any point
- Prevents accidental use of stale value

Reference: [Split Variable](https://refactoring.com/catalog/splitVariable.html)

---

## 7. Error Handling

**Impact: MEDIUM**

Proper error handling prevents cascade failures and improves debuggability. Consistent error patterns make code more predictable and maintainable.

### 7.1 Create Domain-Specific Exception Types

**Impact: MEDIUM (enables precise error handling and better error messages)**

Generic exceptions force callers to parse error messages. Create typed exceptions that carry structured information about what went wrong.

**Incorrect (generic exceptions with string messages):**

```typescript
function transferMoney(from: Account, to: Account, amount: number): void {
  if (amount <= 0) {
    throw new Error('Invalid amount')
  }
  if (from.balance < amount) {
    throw new Error('Insufficient funds')  // No details
  }
  if (from.id === to.id) {
    throw new Error('Cannot transfer to same account')
  }
  if (from.status === 'frozen') {
    throw new Error('Account is frozen')  // Which account?
  }

  // Process transfer...
}

// Caller has to parse strings to determine error type
try {
  transferMoney(source, dest, 100)
} catch (error) {
  if (error.message.includes('Insufficient')) {  // Fragile string matching
    // Handle insufficient funds
  } else if (error.message.includes('frozen')) {
    // Handle frozen account
  }
}
```

**Correct (domain-specific exception hierarchy):**

```typescript
abstract class TransferError extends Error {
  abstract readonly code: string
}

class InsufficientFundsError extends TransferError {
  readonly code = 'INSUFFICIENT_FUNDS'

  constructor(
    public readonly accountId: string,
    public readonly available: number,
    public readonly requested: number
  ) {
    super(`Account ${accountId} has ${available}, but ${requested} was requested`)
  }

  get shortfall(): number {
    return this.requested - this.available
  }
}

class AccountFrozenError extends TransferError {
  readonly code = 'ACCOUNT_FROZEN'

  constructor(
    public readonly accountId: string,
    public readonly reason: string
  ) {
    super(`Account ${accountId} is frozen: ${reason}`)
  }
}

class SameAccountError extends TransferError {
  readonly code = 'SAME_ACCOUNT'

  constructor(public readonly accountId: string) {
    super(`Cannot transfer from account ${accountId} to itself`)
  }
}

function transferMoney(from: Account, to: Account, amount: number): void {
  if (from.balance < amount) {
    throw new InsufficientFundsError(from.id, from.balance, amount)
  }
  if (from.id === to.id) {
    throw new SameAccountError(from.id)
  }
  if (from.status === 'frozen') {
    throw new AccountFrozenError(from.id, from.freezeReason)
  }
  // Process transfer...
}

// Caller uses type-safe handling
try {
  transferMoney(source, dest, 100)
} catch (error) {
  if (error instanceof InsufficientFundsError) {
    showAddFundsPrompt(error.shortfall)  // Access structured data
  } else if (error instanceof AccountFrozenError) {
    showContactSupportMessage(error.accountId, error.reason)
  }
}
```

**Benefits:**
- Type-safe error handling with instanceof
- Structured data available without parsing
- Derived properties (shortfall) on exceptions

Reference: [Clean Code - Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

### 7.2 Fail Fast with Preconditions

**Impact: MEDIUM (reduces debugging time by 50-70%)**

Check preconditions at the start of functions and fail immediately if they're violated. Don't let invalid data propagate through the system.

**Incorrect (late validation allows corruption to spread):**

```typescript
function processOrder(order: Order): Receipt {
  // No validation at entry point
  const items = order.items
  let total = 0

  for (const item of items) {
    const product = getProduct(item.productId)  // Might be null
    total += product.price * item.quantity  // Crashes here, far from source
  }

  const tax = total * order.taxRate  // taxRate might be undefined
  const finalTotal = total + tax  // NaN if taxRate was undefined

  // Creates receipt with corrupted data
  return createReceipt(order.customerId, finalTotal)  // customerId might be null
}

// Error surfaces 3 layers deep, hard to trace back
```

**Correct (fail fast at entry point):**

```typescript
function processOrder(order: Order): Receipt {
  // Validate all preconditions immediately
  assertDefined(order, 'Order is required')
  assertDefined(order.customerId, 'Customer ID is required')
  assertNotEmpty(order.items, 'Order must have at least one item')
  assertPositive(order.taxRate, 'Tax rate must be positive')

  for (const item of order.items) {
    assertDefined(item.productId, 'Product ID is required')
    assertPositive(item.quantity, 'Quantity must be positive')
  }

  // Now safe to process - all data is valid
  const total = calculateTotal(order.items)
  const tax = total * order.taxRate
  return createReceipt(order.customerId, total + tax)
}

// Helper functions for common assertions
function assertDefined<T>(value: T | null | undefined, message: string): asserts value is T {
  if (value === null || value === undefined) {
    throw new PreconditionError(message)
  }
}

function assertNotEmpty<T>(array: T[], message: string): void {
  if (array.length === 0) {
    throw new PreconditionError(message)
  }
}

function assertPositive(value: number, message: string): void {
  if (typeof value !== 'number' || value <= 0 || isNaN(value)) {
    throw new PreconditionError(message)
  }
}
```

**Benefits:**
- Errors caught at the source, not deep in the call stack
- Error messages point directly to the problem
- Invalid state never enters the system

Reference: [Fail Fast Principle](https://martinfowler.com/ieeeSoftware/failFast.pdf)

### 7.3 Separate Error Handling from Business Logic

**Impact: MEDIUM (reduces function complexity by 30-50%)**

Functions should do one thing. Mixing error handling with business logic obscures both. Extract error handling to wrapper functions or middleware.

**Incorrect (error handling mixed with logic):**

```typescript
async function createUserAccount(data: UserData): Promise<User | null> {
  try {
    // Validation mixed with error handling
    try {
      validateEmail(data.email)
    } catch (e) {
      logger.error('Invalid email', { email: data.email, error: e })
      notifyAdmin('Invalid email attempt', data)
      return null
    }

    // Business logic mixed with error handling
    const existingUser = await userRepository.findByEmail(data.email)
    if (existingUser) {
      try {
        await sendDuplicateAccountEmail(data.email)
      } catch (emailError) {
        logger.warn('Failed to send duplicate email', { error: emailError })
        // Continue anyway
      }
      return null
    }

    try {
      const user = await userRepository.create(data)
      try {
        await sendWelcomeEmail(user)
      } catch (welcomeError) {
        logger.warn('Welcome email failed', { userId: user.id })
      }
      return user
    } catch (createError) {
      logger.error('User creation failed', { error: createError })
      throw createError
    }
  } catch (error) {
    logger.error('Unexpected error', { error })
    return null
  }
}
```

**Correct (separated concerns):**

```typescript
// Pure business logic - no error handling
async function createUserAccount(data: UserData): Promise<User> {
  validateUserData(data)

  const existingUser = await userRepository.findByEmail(data.email)
  if (existingUser) {
    throw new DuplicateUserError(data.email)
  }

  const user = await userRepository.create(data)
  await notificationService.sendWelcomeEmail(user)

  return user
}

// Validation in its own function
function validateUserData(data: UserData): void {
  if (!isValidEmail(data.email)) {
    throw new ValidationError('Invalid email format')
  }
  if (!data.password || data.password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters')
  }
}

// Error handling wrapper
async function handleCreateUserAccount(data: UserData): Promise<User | null> {
  try {
    return await createUserAccount(data)
  } catch (error) {
    return handleUserCreationError(error, data)
  }
}

function handleUserCreationError(error: Error, data: UserData): null {
  if (error instanceof ValidationError) {
    logger.warn('Validation failed', { email: data.email, error: error.message })
  } else if (error instanceof DuplicateUserError) {
    logger.info('Duplicate user attempt', { email: data.email })
    sendDuplicateAccountEmail(data.email).catch(e =>
      logger.warn('Failed to send duplicate email', { error: e })
    )
  } else {
    logger.error('User creation failed', { error })
  }
  return null
}
```

**Benefits:**
- Business logic is clear and testable
- Error handling is consistent and centralized
- Easy to modify error handling without touching business logic

Reference: [Clean Code - Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

### 7.4 Use Exceptions Instead of Error Codes

**Impact: MEDIUM (separates error handling from happy path and prevents ignored errors)**

Error codes mix error handling with normal flow and can be silently ignored. Exceptions clearly separate the error path and force handling.

**Incorrect (error codes mixed with return value):**

```typescript
interface Result<T> {
  success: boolean
  data?: T
  errorCode?: number
  errorMessage?: string
}

function processPayment(amount: number): Result<Payment> {
  if (amount <= 0) {
    return { success: false, errorCode: 1001, errorMessage: 'Invalid amount' }
  }

  const balance = getBalance()
  if (balance < amount) {
    return { success: false, errorCode: 1002, errorMessage: 'Insufficient funds' }
  }

  const payment = createPayment(amount)
  return { success: true, data: payment }
}

// Caller can easily forget to check error
function checkout(cart: Cart): void {
  const result = processPayment(cart.total)
  // Oops, forgot to check result.success
  sendConfirmation(result.data!)  // Crashes if payment failed
}
```

**Correct (exceptions for errors):**

```typescript
class PaymentError extends Error {
  constructor(message: string, public readonly code: string) {
    super(message)
    this.name = 'PaymentError'
  }
}

class InsufficientFundsError extends PaymentError {
  constructor(available: number, required: number) {
    super(`Insufficient funds: have ${available}, need ${required}`, 'INSUFFICIENT_FUNDS')
  }
}

class InvalidAmountError extends PaymentError {
  constructor(amount: number) {
    super(`Invalid amount: ${amount}`, 'INVALID_AMOUNT')
  }
}

function processPayment(amount: number): Payment {
  if (amount <= 0) {
    throw new InvalidAmountError(amount)
  }

  const balance = getBalance()
  if (balance < amount) {
    throw new InsufficientFundsError(balance, amount)
  }

  return createPayment(amount)
}

// Caller must handle the exception or let it propagate
function checkout(cart: Cart): void {
  try {
    const payment = processPayment(cart.total)
    sendConfirmation(payment)  // Only runs if payment succeeded
  } catch (error) {
    if (error instanceof InsufficientFundsError) {
      showFundsNeededMessage(error.message)
    } else {
      throw error  // Rethrow unexpected errors
    }
  }
}
```

**When error codes are appropriate:**
- Performance-critical code where exceptions are too expensive
- Interoperating with languages/systems that use error codes
- Expected failure cases that aren't exceptional (e.g., user input validation)

Reference: [Clean Code - Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

---

## 8. Micro-Refactoring

**Impact: LOW**

Small improvements like removing dead code and simplifying expressions accumulate into significant maintainability gains over time.

### 8.1 Inline Trivial Variables

**Impact: LOW (reduces indirection and visual clutter)**

When a variable is used only once and its expression is just as clear, inline it. Extra variables add cognitive overhead without adding clarity.

**Incorrect (unnecessary intermediate variables):**

```typescript
function isValidOrder(order: Order): boolean {
  const hasItems = order.items.length > 0
  const hasCustomer = order.customerId !== null
  const isNotCancelled = order.status !== 'cancelled'

  return hasItems && hasCustomer && isNotCancelled
}

function formatPrice(amount: number): string {
  const roundedAmount = Math.round(amount * 100) / 100
  const formattedAmount = roundedAmount.toFixed(2)
  const priceWithSymbol = '$' + formattedAmount

  return priceWithSymbol
}

function getDiscount(customer: Customer): number {
  const isPremium = customer.tier === 'premium'
  const discount = isPremium ? 0.2 : 0

  return discount
}
```

**Correct (inlined trivial expressions):**

```typescript
function isValidOrder(order: Order): boolean {
  return order.items.length > 0 &&
         order.customerId !== null &&
         order.status !== 'cancelled'
}

function formatPrice(amount: number): string {
  return '$' + (Math.round(amount * 100) / 100).toFixed(2)
}

function getDiscount(customer: Customer): number {
  return customer.tier === 'premium' ? 0.2 : 0
}
```

**When NOT to inline:**
- Variable name adds significant clarity to a complex expression
- Variable is used multiple times
- Expression has side effects (should only execute once)
- Debugging benefits from inspecting intermediate values

**Keep the variable when it documents intent:**

```typescript
// Keep - the name adds meaning
function shouldShowWarning(user: User, action: Action): boolean {
  const hasDestructiveIntent = action.type === 'delete' || action.type === 'purge'
  const lacksConfirmation = !action.confirmed
  const isHighValueTarget = user.accountValue > 10000

  return hasDestructiveIntent && lacksConfirmation && isHighValueTarget
}
```

Reference: [Inline Variable](https://refactoring.com/catalog/inlineVariable.html)

### 8.2 Remove Dead Code

**Impact: LOW (reduces cognitive load and maintenance burden)**

Code that is never executed confuses readers and creates maintenance burden. Delete it; version control preserves history if needed.

**Incorrect (dead code left in place):**

```typescript
class UserService {
  // Old method kept "just in case"
  // async getUser_OLD(id: string): Promise<User> {
  //   return this.db.query('SELECT * FROM users WHERE id = ?', [id])
  // }

  async getUser(id: string): Promise<User> {
    return this.userRepository.findById(id)
  }

  // Method that's never called anywhere
  async getUsersByDepartment(deptId: string): Promise<User[]> {
    return this.userRepository.findByDepartment(deptId)
  }

  // Feature flag that's always false in production
  async getUsers(): Promise<User[]> {
    if (process.env.USE_LEGACY_QUERY === 'true') {  // Never true
      return this.legacyGetUsers()
    }
    return this.userRepository.findAll()
  }

  // Dead code from abandoned feature
  private legacyGetUsers(): Promise<User[]> {
    // Old implementation no longer used
    return this.db.query('SELECT * FROM users_legacy')
  }
}
```

**Correct (dead code removed):**

```typescript
class UserService {
  async getUser(id: string): Promise<User> {
    return this.userRepository.findById(id)
  }

  async getUsers(): Promise<User[]> {
    return this.userRepository.findAll()
  }
}

// If getUsersByDepartment is needed later, recreate it from git history
// git log -p --all -S 'getUsersByDepartment' -- '*.ts'
```

**Signs of dead code:**
- Methods with no callers (IDE can detect)
- Commented-out code blocks
- Feature flags that are always false
- Catch blocks that can never execute
- Conditions that are always true/false

**When NOT to delete:**
- API endpoints that external systems might call
- Hooks/callbacks registered with external frameworks
- Code that appears dead but is invoked via reflection

Reference: [Remove Dead Code](https://refactoring.com/catalog/removeDeadCode.html)

### 8.3 Rename for Clarity

**Impact: LOW (makes code self-documenting and reduces need for comments)**

When a name doesn't clearly convey meaning, rename it. Good names eliminate the need for explanatory comments.

**Incorrect (unclear or misleading names):**

```typescript
// Single letters and abbreviations
function calc(a: number, b: number, t: string): number {
  if (t === 'add') return a + b
  if (t === 'sub') return a - b
  return 0
}

// Generic names
function processData(data: unknown[]): void {
  for (const item of data) {
    doStuff(item)
  }
}

// Names that don't match behavior
function validateUser(user: User): User {  // Doesn't just validate
  user.lastValidated = new Date()
  user.status = 'active'
  return user
}

// Misleading boolean names
const isReady = loadingComplete && !hasError && itemCount > 0
// Should processing continue if isReady is true or false?
```

**Correct (clear, intention-revealing names):**

```typescript
// Descriptive parameter names
function calculate(
  firstOperand: number,
  secondOperand: number,
  operation: 'add' | 'subtract'
): number {
  if (operation === 'add') return firstOperand + secondOperand
  if (operation === 'subtract') return firstOperand - secondOperand
  return 0
}

// Specific names for specific types
function sendNotifications(users: User[]): void {
  for (const user of users) {
    notifyUser(user)
  }
}

// Name matches behavior
function validateAndActivateUser(user: User): User {
  user.lastValidated = new Date()
  user.status = 'active'
  return user
}

// Boolean name answers "should we X?"
const shouldProcessItems = loadingComplete && !hasError && itemCount > 0
if (shouldProcessItems) {
  processItems()
}
```

**Rename method:**
1. Use IDE's rename refactoring (updates all references)
2. Run tests to verify nothing broke
3. If the name appears in logs/databases, plan migration

Reference: [Rename Variable](https://refactoring.com/catalog/renameVariable.html)

### 8.4 Simplify Boolean Expressions

**Impact: LOW (improves readability and reduces cognitive load)**

Complex boolean expressions can often be simplified. Apply boolean algebra and use language features to make conditions clearer.

**Incorrect (overly complex boolean logic):**

```typescript
// Double negatives
if (!user.isNotActive) {
  activateFeatures()
}

// Redundant comparisons
if (isValid === true) {
  process()
}
if (count !== 0) {
  showItems()
}

// Unnecessarily complex conditions
if (status === 'active' || status === 'pending' || status === 'processing') {
  handleInProgress()
}

// Redundant else
function isEligible(user: User): boolean {
  if (user.age >= 18) {
    return true
  } else {
    return false
  }
}

// Nested ternaries
const label = isAdmin ? 'Admin' : isManager ? 'Manager' : isEmployee ? 'Employee' : 'Guest'
```

**Correct (simplified expressions):**

```typescript
// Remove double negative
if (user.isActive) {
  activateFeatures()
}

// Simplify comparisons
if (isValid) {
  process()
}
if (count) {  // Or: if (count > 0) for explicit intent
  showItems()
}

// Use includes for multiple equality checks
const inProgressStatuses = ['active', 'pending', 'processing']
if (inProgressStatuses.includes(status)) {
  handleInProgress()
}

// Return the expression directly
function isEligible(user: User): boolean {
  return user.age >= 18
}

// Use object lookup instead of nested ternaries
const roleLabels: Record<string, string> = {
  admin: 'Admin',
  manager: 'Manager',
  employee: 'Employee'
}
const label = roleLabels[user.role] ?? 'Guest'
```

**Common simplifications:**
- `if (x === true)` → `if (x)`
- `if (x === false)` → `if (!x)`
- `if (arr.length !== 0)` → `if (arr.length)`
- `x ? true : false` → `Boolean(x)` or `!!x`
- `!(!x)` → `x`

Reference: [Simplify Conditional Expression](https://refactoring.com/catalog/consolidateConditionalExpression.html)

---

## References

1. [https://refactoring.com/catalog/](https://refactoring.com/catalog/)
2. [https://refactoring.guru/refactoring/smells](https://refactoring.guru/refactoring/smells)
3. [https://martinfowler.com/books/refactoring.html](https://martinfowler.com/books/refactoring.html)
4. [https://en.wikipedia.org/wiki/SOLID](https://en.wikipedia.org/wiki/SOLID)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
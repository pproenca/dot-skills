# Bug Hunting and Debugging

**Version 0.1.0**  
Software Engineering  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive bug hunting and debugging guide for software engineers, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (systematic reproduction, hypothesis-driven investigation) to incremental (prevention and verification). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct approaches, and specific impact metrics to guide systematic debugging and issue resolution.

---

## Table of Contents

1. [Systematic Reproduction](#1-systematic-reproduction) — **CRITICAL**
   - 1.1 [Capture Full Environmental Context](#11-capture-full-environmental-context)
   - 1.2 [Create Minimal Reproduction Cases](#12-create-minimal-reproduction-cases)
   - 1.3 [Document Exact Reproduction Steps](#13-document-exact-reproduction-steps)
   - 1.4 [Isolate Variables Systematically](#14-isolate-variables-systematically)
   - 1.5 [Make Intermittent Bugs Deterministic](#15-make-intermittent-bugs-deterministic)
2. [Hypothesis-Driven Investigation](#2-hypothesis-driven-investigation) — **CRITICAL**
   - 2.1 [Change One Thing at a Time](#21-change-one-thing-at-a-time)
   - 2.2 [Form Hypothesis Before Investigation](#22-form-hypothesis-before-investigation)
   - 2.3 [Make Testable Predictions from Hypotheses](#23-make-testable-predictions-from-hypotheses)
   - 2.4 [Record All Debugging Experiments](#24-record-all-debugging-experiments)
   - 2.5 [Use Binary Search to Localize Bugs](#25-use-binary-search-to-localize-bugs)
3. [Root Cause Analysis](#3-root-cause-analysis) — **HIGH**
   - 3.1 [Apply Five Whys to Find Root Cause](#31-apply-five-whys-to-find-root-cause)
   - 3.2 [Backtrack from Symptom to Source](#32-backtrack-from-symptom-to-source)
   - 3.3 [Distinguish Symptoms from Causes](#33-distinguish-symptoms-from-causes)
   - 3.4 [Use Fishbone Diagrams for Complex Bugs](#34-use-fishbone-diagrams-for-complex-bugs)
   - 3.5 [Verify Root Cause Before Declaring Fixed](#35-verify-root-cause-before-declaring-fixed)
4. [Strategic Logging](#4-strategic-logging) — **HIGH**
   - 4.1 [Add Correlation IDs Across Services](#41-add-correlation-ids-across-services)
   - 4.2 [Include Full Context in Error Logs](#42-include-full-context-in-error-logs)
   - 4.3 [Log Context Not Noise](#43-log-context-not-noise)
   - 4.4 [Use Appropriate Log Levels](#44-use-appropriate-log-levels)
   - 4.5 [Use Structured Logging for Debugging](#45-use-structured-logging-for-debugging)
5. [Debugger Mastery](#5-debugger-mastery) — **MEDIUM-HIGH**
   - 5.1 [Inspect the Call Stack for Context](#51-inspect-the-call-stack-for-context)
   - 5.2 [Master Step Over, Into, and Out](#52-master-step-over-into-and-out)
   - 5.3 [Place Breakpoints Strategically](#53-place-breakpoints-strategically)
   - 5.4 [Use Conditional Breakpoints for Specific Cases](#54-use-conditional-breakpoints-for-specific-cases)
   - 5.5 [Use Time-Travel Debugging When Available](#55-use-time-travel-debugging-when-available)
   - 5.6 [Use Watch Expressions to Track State](#56-use-watch-expressions-to-track-state)
6. [Bug Triage and Classification](#6-bug-triage-and-classification) — **MEDIUM**
   - 6.1 [Assess User Impact Before Prioritizing](#61-assess-user-impact-before-prioritizing)
   - 6.2 [Detect and Link Duplicate Bug Reports](#62-detect-and-link-duplicate-bug-reports)
   - 6.3 [Factor Reproducibility into Triage](#63-factor-reproducibility-into-triage)
   - 6.4 [Identify and Ship Quick Wins First](#64-identify-and-ship-quick-wins-first)
   - 6.5 [Separate Severity from Priority](#65-separate-severity-from-priority)
7. [Common Bug Patterns](#7-common-bug-patterns) — **MEDIUM**
   - 7.1 [Catch Async/Await Error Handling Mistakes](#71-catch-asyncawait-error-handling-mistakes)
   - 7.2 [Detect Memory Leak Patterns](#72-detect-memory-leak-patterns)
   - 7.3 [Identify Race Condition Symptoms](#73-identify-race-condition-symptoms)
   - 7.4 [Recognize Null Pointer Patterns](#74-recognize-null-pointer-patterns)
   - 7.5 [Recognize Timezone and Date Bugs](#75-recognize-timezone-and-date-bugs)
   - 7.6 [Spot Off-by-One Errors](#76-spot-off-by-one-errors)
   - 7.7 [Watch for Type Coercion Bugs](#77-watch-for-type-coercion-bugs)
8. [Prevention and Verification](#8-prevention-and-verification) — **LOW**
   - 8.1 [Add Regression Tests for Every Fix](#81-add-regression-tests-for-every-fix)
   - 8.2 [Conduct Blameless Post-Mortems](#82-conduct-blameless-post-mortems)
   - 8.3 [Include Bug-Prevention Checks in Code Review](#83-include-bug-prevention-checks-in-code-review)
   - 8.4 [Use Assertions for Invariant Checking](#84-use-assertions-for-invariant-checking)

---

## 1. Systematic Reproduction

**Impact: CRITICAL**

Reproducibility is the foundation of debugging—without reliable reproduction, fixes are guesswork. Establishing consistent reproduction steps enables targeted investigation and verifiable fixes.

### 1.1 Capture Full Environmental Context

**Impact: CRITICAL (prevents environment-specific bugs from escaping)**

Bugs often depend on environmental factors invisible in the code. Capture OS version, browser, locale, timezone, feature flags, database state, and configuration to ensure reproducibility across environments.

**Incorrect (missing environmental context):**

```javascript
// Bug report: "Date parsing broken"
// Developer: "Works on my machine"

function parseUserDate(input) {
  return new Date(input).toLocaleDateString()
}

// Test passes in development
console.log(parseUserDate("2024-01-15"))  // "1/15/2024"
```

**Correct (captures full environment):**

```javascript
// Bug report with environment context:
// OS: Windows 11, Locale: de-DE, Timezone: Europe/Berlin
// Input: "2024-01-15" → Output: "Invalid Date"

function parseUserDate(input) {
  return new Date(input).toLocaleDateString()
}

// Reproduction requires matching environment:
// - Set system locale to de-DE
// - German locale expects "15.01.2024" format
// Root cause: Date constructor interprets format based on locale
```

**Environment checklist:**
- OS and version
- Browser/runtime and version
- Locale and timezone settings
- Feature flags and A/B test groups
- Database state and test data
- Network conditions (latency, offline)
- User permissions and roles

Reference: [BrowserStack - Root Causes for Software Defects](https://www.browserstack.com/guide/root-causes-for-software-defects-and-its-solutions)

### 1.2 Create Minimal Reproduction Cases

**Impact: CRITICAL (reduces noise, exposes root cause)**

Strip away everything that isn't necessary to reproduce the bug. A minimal reproduction case removes distracting code and exposes the essential conditions that trigger the failure.

**Incorrect (full application context obscures the bug):**

```typescript
// Bug: User profile not updating
// "It happens somewhere in the app"

class UserProfilePage extends React.Component {
  // 500 lines of component code
  // Multiple API calls
  // Complex state management
  // Redux integration
  // Form validation
  // The bug is hidden somewhere in here...
}
```

**Correct (minimal reproduction isolates the issue):**

```typescript
// Minimal reproduction: The bug is in the API call

async function updateProfile(userId: string, data: ProfileData) {
  const response = await fetch(`/api/users/${userId}`, {
    method: 'PUT',
    body: JSON.stringify(data),  // Bug: Missing Content-Type header
  })
  return response.json()
}

// Reproduce with:
// updateProfile("123", { name: "Alice" })
// Result: 400 Bad Request - server expects JSON content type
```

**Process for creating minimal reproductions:**
1. Start with the failing code
2. Remove code until the bug disappears
3. Add back the last removed code—that's the trigger
4. Repeat until nothing else can be removed

Reference: [GeeksforGeeks - Debugging Approaches](https://www.geeksforgeeks.org/software-engineering-debugging-approaches/)

### 1.3 Document Exact Reproduction Steps

**Impact: CRITICAL (enables targeted investigation)**

If you cannot reliably reproduce a bug, you cannot fix it. Document the exact sequence of actions, inputs, and environmental conditions that trigger the failure. Never trust a bug report until you've seen the failure yourself.

**Incorrect (vague reproduction steps):**

```markdown
## Bug Report
Title: App crashes sometimes
Steps: Use the app normally, sometimes it crashes
Expected: Should not crash
```

**Correct (precise reproduction steps):**

```markdown
## Bug Report
Title: App crashes when uploading files > 10MB on iOS
Steps:
1. Open app on iOS 17.2, iPhone 15 Pro
2. Navigate to Settings > Import
3. Select a PDF file larger than 10MB
4. Tap "Upload" button
5. Observe crash after upload indicator reaches 40%

Environment: iOS 17.2, iPhone 15 Pro, App v2.3.1
Frequency: 100% reproducible with files > 10MB
Expected: File uploads successfully
Actual: App crashes with no error message
```

**Benefits:**
- Anyone can reproduce the bug independently
- Environmental factors are captured
- Frequency helps prioritize (100% vs intermittent)

Reference: [Atlassian Bug Triage Best Practices](https://www.atlassian.com/agile/software-development/bug-triage)

### 1.4 Isolate Variables Systematically

**Impact: CRITICAL (reduces search space by 50% per iteration)**

When a bug depends on multiple factors, change one variable at a time to identify which conditions are necessary for reproduction. This systematic isolation narrows the search space exponentially.

**Incorrect (changing multiple variables at once):**

```python
# Bug: Payment fails for some users
# Testing approach: Random changes

def debug_payment_failure():
    # Try different user, different browser, different amount
    test_with_user("alice", browser="chrome", amount=100)
    test_with_user("bob", browser="firefox", amount=50)
    # Can't determine which variable matters
```

**Correct (isolating one variable at a time):**

```python
# Bug: Payment fails for some users
# Testing approach: Isolate each variable

def debug_payment_failure():
    # Control: Known failing case
    test_with_user("alice", browser="chrome", amount=100)  # FAILS

    # Test 1: Change only the user
    test_with_user("bob", browser="chrome", amount=100)    # PASSES
    # Conclusion: User-specific issue

    # Test 2: What's different about alice?
    # alice has special characters in address field
```

**When to use this pattern:**
- Bug occurs only under specific conditions
- Multiple environmental factors could be involved
- Intermittent bugs with unclear triggers

Reference: [MIT 6.031 - Reading 13: Debugging](http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)

### 1.5 Make Intermittent Bugs Deterministic

**Impact: CRITICAL (100% reproducibility from random failures)**

Intermittent bugs that "sometimes happen" are often timing-dependent. Introduce artificial delays, increase load, or control random seeds to transform unpredictable failures into reproducible issues.

**Incorrect (hoping to catch the intermittent bug):**

```python
# Bug: "Order total sometimes wrong"
# Approach: Run the test many times and hope it fails

def test_order_total():
    order = create_order()
    add_item(order, price=100)
    add_item(order, price=50)
    assert order.total == 150  # Passes 95% of the time

# Run 100 times, fails randomly, can't debug
```

**Correct (forcing the race condition):**

```python
# Bug: "Order total sometimes wrong"
# Approach: Force the timing issue to occur consistently

def test_order_total_race_condition():
    order = create_order()

    # Simulate concurrent modifications that cause the bug
    with ThreadPoolExecutor() as executor:
        futures = [
            executor.submit(add_item, order, price=100),
            executor.submit(add_item, order, price=50),
        ]
        wait(futures)

    # Now fails consistently: total is 100 or 50, not 150
    # Root cause: Non-atomic total calculation
    assert order.total == 150
```

**Techniques for intermittent bugs:**
- Add `sleep()` calls to widen race windows
- Use thread sanitizers (TSan) to detect races
- Control random seeds for reproducible "random" behavior
- Increase system load to amplify timing issues

Reference: [Cornell CS312 - Debugging Techniques](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)

---

## 2. Hypothesis-Driven Investigation

**Impact: CRITICAL**

Applying the scientific method to debugging eliminates random trial-and-error, reducing debug time by 40-60%. Form hypotheses, design experiments, and systematically narrow down the cause.

### 2.1 Change One Thing at a Time

**Impact: CRITICAL (prevents introducing new bugs while fixing)**

When debugging, change only one variable between experiments. Multiple simultaneous changes make it impossible to know which change fixed (or broke) the behavior.

**Incorrect (multiple changes at once):**

```typescript
// Bug: API returns 500 error
// Attempt: Change several things hoping one fixes it

async function fetchUserData(userId: string) {
  // Changed: URL path, timeout, headers, and error handling all at once
  const response = await fetch(`/api/v2/users/${userId}`, {  // Was /api/v1/
    timeout: 10000,                                           // Was 5000
    headers: { 'Accept': 'application/json' },               // Was missing
  })
  if (!response.ok) {
    return null                                               // Was throwing
  }
  return response.json()
}
// Bug is fixed, but which change fixed it? Unknown.
```

**Correct (one change per experiment):**

```typescript
// Bug: API returns 500 error
// Approach: Test each hypothesis separately

async function fetchUserData(userId: string) {
  // Experiment 1: Just add Accept header
  const response = await fetch(`/api/v1/users/${userId}`, {
    timeout: 5000,
    headers: { 'Accept': 'application/json' },  // Only change
  })
  // Result: Still 500 → Header not the issue

  // Experiment 2: Just increase timeout (revert header)
  const response = await fetch(`/api/v1/users/${userId}`, {
    timeout: 10000,  // Only change
  })
  // Result: Success! Bug was timeout-related

  if (!response.ok) throw new Error('Fetch failed')
  return response.json()
}
```

**Benefits:**
- Know exactly what fixed the bug
- Avoid introducing new bugs from unnecessary changes
- Build understanding of the system

Reference: [MIT 6.031 - Reading 13: Debugging](http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)

### 2.2 Form Hypothesis Before Investigation

**Impact: CRITICAL (40-60% faster bug resolution)**

Before opening the debugger or adding print statements, form a specific hypothesis about what is causing the bug. A hypothesis gives your investigation direction and prevents aimless wandering through code.

**Incorrect (starting investigation without a hypothesis):**

```python
# Bug: User registration fails
# Approach: Start adding print statements everywhere

def register_user(email, password):
    print("Starting registration")           # What are we looking for?
    user = User(email=email)
    print(f"User created: {user}")           # Printing everything
    user.set_password(password)
    print(f"Password set")                   # No clear direction
    db.session.add(user)
    print(f"Added to session")               # Random debugging
    db.session.commit()
    print(f"Committed")                      # Hope to spot something
    return user
```

**Correct (hypothesis-driven investigation):**

```python
# Bug: User registration fails
# Hypothesis: The email validation regex rejects valid emails with plus signs

def register_user(email, password):
    # Test hypothesis: Check if email validation is the issue
    is_valid = validate_email(email)
    print(f"Email validation result for '{email}': {is_valid}")

    if not is_valid:
        # Hypothesis confirmed: alice+test@example.com rejected
        # Root cause: Regex doesn't allow plus signs
        raise ValidationError("Invalid email")

    user = User(email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    return user
```

**The 10-minute rule:** If you've spent 10 minutes debugging without a clear hypothesis, stop and formulate one before continuing.

Reference: [Grinnell College - Hypothesis-driven debugging](https://eikmeier.sites.grinnell.edu/csc-151-s221/readings/hypothesis-driven-debugging.html)

### 2.3 Make Testable Predictions from Hypotheses

**Impact: CRITICAL (validates or eliminates hypotheses quickly)**

A hypothesis explains what you've observed; a prediction states what you expect to observe under new conditions. Make predictions before running experiments—if the prediction fails, the hypothesis is wrong.

**Incorrect (no prediction before testing):**

```javascript
// Bug: Shopping cart shows wrong total
// Hypothesis: "Something is wrong with the calculation"
// No prediction—just running code to see what happens

function calculateTotal(items) {
  let total = 0
  for (const item of items) {
    total += item.price * item.quantity
    console.log(total)  // Just watching values with no expectation
  }
  return total
}
```

**Correct (explicit prediction before testing):**

```javascript
// Bug: Shopping cart shows wrong total
// Hypothesis: Discount is applied twice—once in item price, once in total
// Prediction: If discount is double-applied, total will be 20% too low

function calculateTotal(items) {
  let total = 0
  for (const item of items) {
    // Prediction: item.price already has 10% discount applied
    console.log(`Item price: ${item.price}, Expected pre-discount: ${item.originalPrice}`)
    total += item.price * item.quantity
  }
  // Prediction: This line applies discount again
  total = applyDiscount(total, 0.10)  // Bug found: double discount
  return total
}

// Test: Cart with $100 item, 10% discount
// Expected with single discount: $90
// Actual with double discount: $81
// Prediction confirmed: discount applied twice
```

**Good predictions are:**
- Specific and measurable
- Different from what you'd see if the hypothesis were false
- Easy to test with minimal code changes

Reference: [UCSD CSE 15L - The Scientific Debugging Method](https://cseweb.ucsd.edu/classes/wi10/cse15L/c/method.php)

### 2.4 Record All Debugging Experiments

**Impact: CRITICAL (prevents repeating failed approaches)**

Keep a debugging log of every hypothesis tested, the experiment run, and the result. This prevents wasted time re-trying failed approaches and builds knowledge for similar future bugs.

**Incorrect (no record of debugging attempts):**

```markdown
// Day 1: Try some stuff, doesn't work
// Day 2: Try same stuff again, forgot what I tried
// Day 3: Coworker suggests something I already tried
// Day 4: Finally fix it, can't remember what worked
```

**Correct (debugging log with experiments and results):**

```markdown
## Bug: Order emails not sending (JIRA-1234)

### Hypothesis 1: SMTP credentials expired
**Experiment:** Check SMTP connection with telnet
**Result:** Connection successful, credentials valid
**Conclusion:** Not a credentials issue

### Hypothesis 2: Email queued but worker not processing
**Experiment:** Check Redis queue length and worker logs
**Result:** Queue has 5000 emails, worker shows "memory limit exceeded"
**Conclusion:** Worker crashing before processing emails

### Hypothesis 3: Worker memory leak in email template rendering
**Experiment:** Profile memory during template rendering
**Result:** Memory grows 50MB per email due to leaked DOM references
**Conclusion:** ROOT CAUSE FOUND

### Fix Applied:
- Added cleanup in template rendering (commit abc123)
- Emails now processing successfully
- Monitoring added for queue depth
```

**Benefits:**
- Never repeat failed experiments
- Shareable knowledge with team
- Evidence for post-mortems and documentation

Reference: [SciTools Blog - The Science of Debugging](https://blog.scitools.com/the-science-of-debugging/)

### 2.5 Use Binary Search to Localize Bugs

**Impact: CRITICAL (O(log n) instead of O(n) search through code)**

When a bug could be anywhere in a large codebase or commit history, use binary search to narrow down the location. Check the midpoint, determine which half contains the bug, and repeat until you find it.

**Incorrect (linear search through history):**

```bash
# Bug introduced sometime in the last 100 commits
# Approach: Check each commit one by one

git checkout HEAD~1 && npm test   # Pass
git checkout HEAD~2 && npm test   # Pass
git checkout HEAD~3 && npm test   # Pass
# ... 97 more checkouts (O(n) = 100 checks worst case)
```

**Correct (binary search with git bisect):**

```bash
# Bug introduced sometime in the last 100 commits
# Approach: Binary search through history

git bisect start
git bisect bad HEAD              # Current commit is broken
git bisect good HEAD~100         # 100 commits ago was working

# Git checks out the middle commit
# Run: npm test
git bisect good                  # Test passes, bug is in later half

# Git checks out middle of remaining range
# Run: npm test
git bisect bad                   # Test fails, bug is in earlier half

# After ~7 iterations (log2(100) ≈ 7), exact commit found
git bisect reset
```

**Binary search in code:**

```python
def find_bug_location(process_data):
    # 1000-line function, bug somewhere inside
    data = load_data()

    # Check midpoint: Is data correct here?
    midpoint_result = transform_step_500(data)
    assert is_valid(midpoint_result)  # If fails, bug is in first half

    # Repeat: Check midpoint of remaining half
    # 10 iterations to find exact line (log2(1000) ≈ 10)
```

Reference: [GeeksforGeeks - Debugging Approaches](https://www.geeksforgeeks.org/software-engineering-debugging-approaches/)

---

## 3. Root Cause Analysis

**Impact: HIGH**

Finding the true cause prevents recurring bugs and symptom-only fixes. Use structured techniques like Five Whys and Fishbone diagrams to trace effects back to their origin.

### 3.1 Apply Five Whys to Find Root Cause

**Impact: HIGH (prevents recurring bugs permanently)**

Ask "Why?" repeatedly (typically five times) to move from a symptom to its fundamental cause. Stop when you reach a cause that you can fix permanently, not just patch temporarily.

**Incorrect (fixing the symptom):**

```python
# Bug: Production server crashed at 3 AM

# Symptom-level fix:
def handle_request(request):
    try:
        return process_request(request)
    except MemoryError:
        # Just restart and hope for the best
        restart_server()
        return process_request(request)
```

**Correct (Five Whys analysis):**

```markdown
## Five Whys Analysis: Server Crash

**Why 1:** Why did the server crash?
→ Out of memory error at 3 AM

**Why 2:** Why did memory run out at 3 AM?
→ Batch job processes 10M records, loads all into memory

**Why 3:** Why does it load all records into memory?
→ Uses `fetchAll()` instead of paginated queries

**Why 4:** Why was `fetchAll()` used?
→ Developer copy-pasted from small dataset example

**Why 5:** Why wasn't this caught in code review?
→ No guidelines for large dataset handling

## Root Cause: Missing coding guidelines for batch processing

## Fix:
1. Refactor to use pagination (immediate)
2. Add batch processing guidelines to coding standards (permanent)
3. Add memory monitoring alerts (preventive)
```

```python
# Root cause fix: Paginated processing
def process_batch_records():
    page_size = 1000
    offset = 0
    while True:
        records = fetch_records(limit=page_size, offset=offset)
        if not records:
            break
        process_records(records)
        offset += page_size
```

Reference: [BugaSura - Guide to Root Cause Analysis](https://bugasura.io/blog/root-cause-analysis-for-bug-tracking/)

### 3.2 Backtrack from Symptom to Source

**Impact: HIGH (O(log n) search through data flow)**

Start from where the bug manifests and trace backwards through the code, following data flow in reverse. Each step asks: "Where did this incorrect value come from?"

**Incorrect (forward search from random starting point):**

```javascript
// Bug: User sees "$NaN" for order total
// Approach: Start reading code from the beginning

// order-creation.js - Looks fine
// cart-service.js - Looks fine
// pricing-engine.js - Looks fine
// ... eventually give up
```

**Correct (backtrack from the symptom):**

```javascript
// Bug: User sees "$NaN" for order total
// Approach: Start where NaN appears, trace backwards

// Step 1: Where is "$NaN" rendered?
// OrderSummary.jsx line 45
const total = formatCurrency(order.total)  // order.total is NaN

// Step 2: Where does order.total come from?
// order-service.js line 120
order.total = subtotal + shipping + tax     // shipping is NaN

// Step 3: Where does shipping come from?
// shipping-calculator.js line 55
const shipping = rates[zone]                 // zone is "UNKNOWN"

// Step 4: Where does zone come from?
// address-service.js line 30
const zone = getShippingZone(address.zipCode) // zipCode is undefined

// ROOT CAUSE: Missing zipCode validation in address form
```

**Backtracking process:**
1. Locate the symptom (where bad output appears)
2. Find the variable containing the bad value
3. Find where that variable was assigned
4. Repeat until you find the first incorrect value
5. That assignment is the bug

Reference: [GeeksforGeeks - Debugging Approaches](https://www.geeksforgeeks.org/software-engineering-debugging-approaches/)

### 3.3 Distinguish Symptoms from Causes

**Impact: HIGH (prevents fixing the wrong thing)**

A symptom is what you observe (crash, wrong output, slow response). A cause is why it happens (null reference, wrong algorithm, missing index). Fixing symptoms without finding causes leads to recurring bugs.

**Incorrect (treating symptoms as causes):**

```java
// Bug: NullPointerException in getUserName()
// "Fix": Add null check where crash occurs

public String getUserName(int userId) {
    User user = userRepository.findById(userId);
    // Symptom fix: Hide the null, return default
    if (user == null) {
        return "Unknown";  // Bug hidden, not fixed
    }
    return user.getName();
}

// Problem: Why is user null? That's the real bug!
// Users still can't see their name, they just see "Unknown"
```

**Correct (tracing symptom to cause):**

```java
// Bug: NullPointerException in getUserName()
// Analysis: Why is user null?

public String getUserName(int userId) {
    User user = userRepository.findById(userId);

    // Investigation: When is user null?
    // - User ID 12345 returns null
    // - User 12345 exists in database
    // - But userRepository uses cache
    // - Cache eviction happened during user creation
    // ROOT CAUSE: Race condition in cache population

    return user.getName();
}

// Real fix: Fix cache population race condition
// userRepository.java line 78:
public User findById(int userId) {
    return cache.computeIfAbsent(userId, this::loadFromDatabase);
    // computeIfAbsent is atomic, prevents race condition
}
```

**Symptom vs Cause examples:**
| Symptom | Possible Cause |
|---------|----------------|
| 500 error | Null reference, database down, timeout |
| Slow response | Missing index, N+1 query, memory leak |
| Wrong output | Off-by-one, type coercion, timezone issue |

Reference: [TechTarget - Root Cause Analysis of Software Defects](https://www.techtarget.com/searchsoftwarequality/tip/How-to-handle-root-cause-analysis-of-software-defects)

### 3.4 Use Fishbone Diagrams for Complex Bugs

**Impact: HIGH (prevents missed causes in complex bugs)**

When a bug has multiple potential causes across different domains (code, infrastructure, data, process), use a Fishbone (Ishikawa) diagram to systematically map and explore all contributing factors.

**Incorrect (jumping to conclusions):**

```markdown
Bug: Checkout fails for 5% of users
Assumption: Must be a code bug
Action: Spend 3 days reviewing checkout code
Result: No bug found in code—problem was elsewhere
```

**Correct (systematic cause exploration):**

```markdown
## Fishbone Diagram: Checkout Failures (5% of users)

                    ┌─────────────────────────────────────────┐
                    │       Checkout Failures (5%)            │
                    └─────────────────────────────────────────┘
                                        │
    ┌───────────────┬───────────────────┼───────────────┬───────────────┐
    │               │                   │               │               │
    ▼               ▼                   ▼               ▼               ▼
  Code          Infrastructure       Data           Process         People
    │               │                   │               │               │
    ├─ Validation   ├─ Database         ├─ Corrupt      ├─ Timeout     ├─ Training
    │   logic       │   timeouts        │   cart data   │   config     │   gaps
    │               │                   │               │               │
    ├─ Race         ├─ CDN cache ←────────────────────────────── ROOT CAUSE
    │   condition   │   stale assets   │               │
    │               │                   │               │
    └─ Edge cases   └─ Network          └─ Invalid      └─ Rollback
                        latency             state           process

## Investigation Results:
- Code: No issues found
- Infrastructure: CDN serving stale JavaScript (cache TTL too high)
- Root cause: Old checkout.js cached for users who visited recently
- Fix: Invalidate CDN cache, add cache-busting hashes to assets
```

**When to use Fishbone diagrams:**
- Bug affects only some users/requests
- Multiple teams or systems involved
- Initial investigation yields no clear cause

Reference: [ProSolvr - Software Bugs Root Cause Analysis](https://www.prosolvr.tech/knowledgebase/software-bugs-root-cause-analysis.html)

### 3.5 Verify Root Cause Before Declaring Fixed

**Impact: HIGH (prevents reopened bugs and wasted cycles)**

Before closing a bug, verify that your identified cause actually produces the symptom and that your fix eliminates it. A fix that passes tests but doesn't address the root cause will resurface.

**Incorrect (assuming the fix works):**

```python
# Bug: Users report slow search
# Hypothesis: Missing database index
# Fix: Add index and close ticket

# add_index.sql
CREATE INDEX idx_users_email ON users(email);

# Ticket closed as "Fixed"
# But search is still slow...
# The slow query was on products table, not users table
```

**Correct (verify cause and fix):**

```python
# Bug: Users report slow search
# Hypothesis: Missing database index

# Step 1: Verify hypothesis causes symptom
EXPLAIN ANALYZE SELECT * FROM products WHERE name ILIKE '%phone%';
# Result: Seq Scan on products, cost=0..50000, time=2500ms
# Confirmed: Full table scan is the cause

# Step 2: Apply fix
CREATE INDEX idx_products_name_gin ON products USING gin(name gin_trgm_ops);

# Step 3: Verify fix resolves symptom
EXPLAIN ANALYZE SELECT * FROM products WHERE name ILIKE '%phone%';
# Result: Bitmap Index Scan, cost=0..100, time=15ms
# Confirmed: 166x improvement, fix works

# Step 4: Verify in production
# Monitor search latency after deploy: p99 dropped from 2.5s to 50ms
# NOW close the ticket
```

**Verification checklist:**
- [ ] Can reproduce the bug with your identified cause
- [ ] Fix eliminates the symptom completely
- [ ] Regression test added to prevent recurrence
- [ ] Production metrics confirm improvement

Reference: [Medium - Step-by-Step Guide on Performing Root Cause Analysis](https://medium.com/@zeinkap/step-by-step-guide-on-performing-root-cause-analysis-for-software-bugs-dc4cf19d5ae7)

---

## 4. Strategic Logging

**Impact: HIGH**

Effective logging provides crucial debugging context without overwhelming noise. Use structured logging, appropriate log levels, and correlation IDs to make logs queryable and actionable.

### 4.1 Add Correlation IDs Across Services

**Impact: HIGH (enables cross-service debugging in seconds)**

Generate a unique correlation ID at the entry point and propagate it through all services and log entries. This enables tracing a single request across microservices, queues, and databases.

**Incorrect (isolated logs, can't trace requests):**

```javascript
// Service A
logger.info('Received order request')  // Which request?

// Service B
logger.info('Processing payment')       // For which order?

// Service C
logger.error('Inventory check failed')  // Related to which request?

// Debugging: "Which payment corresponds to which inventory failure?"
// Answer: No way to know
```

**Correct (correlation ID links all logs):**

```javascript
// API Gateway: Generate correlation ID
app.use((req, res, next) => {
  req.correlationId = req.headers['x-correlation-id'] || uuid()
  res.setHeader('x-correlation-id', req.correlationId)
  next()
})

// Service A
logger.info('Received order request', {
  correlationId: req.correlationId,
  userId: req.userId
})

// Service B (receives correlationId in header)
logger.info('Processing payment', {
  correlationId: req.headers['x-correlation-id'],
  amount: payment.amount
})

// Service C
logger.error('Inventory check failed', {
  correlationId: message.correlationId,
  productId: item.productId,
  error: 'Out of stock'
})

// Query: correlationId:"abc-123-def"
// Result: Complete request trace across all services
```

**Propagation points:**
- HTTP headers: `X-Correlation-ID`
- Message queues: Include in message metadata
- Database: Log correlation ID with slow query warnings
- Background jobs: Pass via job context

Reference: [BetterStack - Logging vs Metrics vs Tracing](https://betterstack.com/community/guides/observability/logging-metrics-tracing/)

### 4.2 Include Full Context in Error Logs

**Impact: HIGH (enables debugging without reproduction)**

Error logs should contain everything needed to understand and debug the issue: stack trace, input values, system state, and identifiers. A good error log enables debugging without needing to reproduce the issue.

**Incorrect (minimal error context):**

```typescript
async function processUserUpload(userId: string, file: File) {
  try {
    await uploadService.process(file)
  } catch (error) {
    logger.error('Upload failed')  // What failed? For whom? Why?
    // or
    logger.error(error.message)    // "Network error" - not actionable
    throw error
  }
}

// Log: "Upload failed" or "Network error"
// Debugging: Need to reproduce to understand what happened
```

**Correct (full error context):**

```typescript
async function processUserUpload(userId: string, file: File) {
  const uploadId = generateUploadId()

  try {
    logger.info('upload_started', {
      uploadId,
      userId,
      fileName: file.name,
      fileSize: file.size,
      mimeType: file.type,
    })

    await uploadService.process(file)

  } catch (error) {
    logger.error('upload_failed', {
      uploadId,
      userId,
      fileName: file.name,
      fileSize: file.size,
      mimeType: file.type,
      errorType: error.name,
      errorMessage: error.message,
      errorCode: error.code,
      stackTrace: error.stack,
      // System state
      memoryUsage: process.memoryUsage().heapUsed,
      uploadServiceStatus: await uploadService.healthCheck(),
    })
    throw error
  }
}

// Log: Complete picture of what happened, when, and why
// Debugging: Often solvable without reproduction
```

**Error context checklist:**
- [ ] Unique identifier (correlation/request ID)
- [ ] User/tenant identifier
- [ ] Input values that triggered the error
- [ ] Full stack trace
- [ ] Error code/type for categorization
- [ ] Relevant system state (memory, connections, queue depth)

Reference: [OpenObserve - Microservices Observability](https://openobserve.ai/blog/microservices-observability-logs-metrics-traces/)

### 4.3 Log Context Not Noise

**Impact: HIGH (5-10× reduction in log volume)**

Log the information needed to understand what happened and debug issues, but avoid logging everything. Focus on decision points, state changes, and error context rather than routine operations.

**Incorrect (logging everything):**

```java
public Order processOrder(OrderRequest request) {
    log.info("Entering processOrder");                    // Noise
    log.info("Request received: " + request);             // Noise
    log.info("Validating order");                         // Noise

    for (Item item : request.getItems()) {
        log.info("Processing item: " + item.getId());     // N logs per order
        log.info("Item price: " + item.getPrice());       // More noise
        log.info("Item quantity: " + item.getQuantity()); // Even more noise
    }

    log.info("Calculating total");                        // Noise
    log.info("Total calculated: " + total);               // Useful for debugging
    log.info("Saving order");                             // Noise
    log.info("Order saved");                              // Noise
    log.info("Exiting processOrder");                     // Noise
    return order;
}
// 10+ log lines per order, mostly useless in debugging
```

**Correct (contextual logging):**

```java
public Order processOrder(OrderRequest request) {
    log.info("order_received",
             orderId, request.getOrderId(),
             userId, request.getUserId(),
             itemCount, request.getItems().size());

    try {
        Order order = orderService.create(request);

        log.info("order_created",
                 orderId, order.getId(),
                 total, order.getTotal(),
                 status, order.getStatus());

        return order;
    } catch (ValidationException e) {
        log.warn("order_validation_failed",
                 orderId, request.getOrderId(),
                 reason, e.getMessage(),
                 field, e.getField());         // Context for debugging
        throw e;
    } catch (Exception e) {
        log.error("order_processing_failed",
                  orderId, request.getOrderId(),
                  errorType, e.getClass().getSimpleName(),
                  errorMessage, e.getMessage());
        throw e;
    }
}
// 1-2 log lines per order, all meaningful
```

**Log these:**
- Request received (with key identifiers)
- Major state changes
- Decision branches taken
- Errors with full context

Reference: [Sentry Blog - Observability and Tracing](https://blog.sentry.io/observability-and-tracing-how-to-improve-your-debugging-workflow/)

### 4.4 Use Appropriate Log Levels

**Impact: HIGH (reduces log noise by 90%)**

Use log levels consistently to enable filtering. DEBUG for development details, INFO for normal operations, WARN for recoverable issues, ERROR for failures requiring attention.

**Incorrect (everything at same level):**

```python
def process_payment(payment):
    logger.info(f"Starting payment processing")          # Fine
    logger.info(f"Payment amount: {payment.amount}")     # Should be DEBUG
    logger.info(f"Calling payment gateway")              # Should be DEBUG
    logger.info(f"Gateway response: {response}")         # Should be DEBUG
    logger.info(f"Payment failed: {error}")              # Should be ERROR!
    logger.info(f"Retrying payment")                     # Should be WARN
    logger.info(f"Payment completed")                    # Fine

# Production: All logs at INFO, no way to filter
# "Find all payment failures" = search through millions of INFO logs
```

**Correct (appropriate levels):**

```python
def process_payment(payment):
    logger.info("payment_processing_started",
                payment_id=payment.id)

    logger.debug("payment_details",
                 amount=payment.amount,
                 currency=payment.currency)          # Filtered out in prod

    logger.debug("gateway_request_sent",
                 gateway="stripe")                   # Filtered out in prod

    if response.status == "failed":
        logger.error("payment_failed",
                     payment_id=payment.id,
                     error_code=response.error,
                     user_id=payment.user_id)        # Always visible

        logger.warning("payment_retry_scheduled",
                       payment_id=payment.id,
                       retry_count=1)                # Visible, not critical

    logger.info("payment_completed",
                payment_id=payment.id,
                gateway_ref=response.ref)
```

**Log level guidelines:**
| Level | Use For | Production Visibility |
|-------|---------|----------------------|
| DEBUG | Variable values, flow tracing | Off |
| INFO | Business events, milestones | On |
| WARN | Recoverable issues, retries | On |
| ERROR | Failures requiring attention | On + Alert |

Reference: [Medium - Effective Logging Strategies](https://juliofalbo.medium.com/effective-logging-strategies-for-better-observability-and-debugging-4b90decefdf1)

### 4.5 Use Structured Logging for Debugging

**Impact: HIGH (enables filtering and querying at scale)**

Use structured logging (JSON format with consistent fields) instead of plain text. Structured logs are machine-parseable, enabling filtering, aggregation, and correlation that plain text cannot support.

**Incorrect (plain text logging):**

```python
# Plain text logs are hard to parse and query

def process_order(order_id, user_id):
    print(f"Processing order {order_id} for user {user_id}")
    # ...
    print(f"Order {order_id} total: ${total}")
    # ...
    print(f"ERROR: Payment failed for order {order_id}")

# Log output:
# Processing order 12345 for user 789
# Order 12345 total: $150.00
# ERROR: Payment failed for order 12345

# Query "all failed payments for user 789"? Impossible without regex
```

**Correct (structured logging):**

```python
import structlog

logger = structlog.get_logger()

def process_order(order_id, user_id):
    logger.info("order_processing_started",
                order_id=order_id,
                user_id=user_id)
    # ...
    logger.info("order_total_calculated",
                order_id=order_id,
                total=total,
                currency="USD")
    # ...
    logger.error("payment_failed",
                 order_id=order_id,
                 user_id=user_id,
                 error_code="CARD_DECLINED")

# Log output (JSON):
# {"event": "payment_failed", "order_id": 12345, "user_id": 789, "error_code": "CARD_DECLINED"}

# Query in log aggregator:
# event:payment_failed AND user_id:789
# Instantly find all payment failures for user 789
```

**Benefits:**
- Filter by any field: `user_id:789 AND level:error`
- Aggregate: "Count of payment failures per error code"
- Alert: Notify when error rate exceeds threshold

Reference: [IBM - Three Pillars of Observability](https://www.ibm.com/think/insights/observability-pillars)

---

## 5. Debugger Mastery

**Impact: MEDIUM-HIGH**

Efficient debugger use enables precise state inspection, execution control, and faster bug localization. Master breakpoints, watch expressions, and stepping to maximize debugging efficiency.

### 5.1 Inspect the Call Stack for Context

**Impact: MEDIUM-HIGH (reduces search space by 80-90%)**

The call stack shows the chain of function calls that led to the current point. Inspect it to understand why a function was called with certain arguments and to identify incorrect callers.

**Incorrect (ignoring call stack):**

```javascript
function formatPrice(price) {
  // Bug: price is undefined
  return `$${price.toFixed(2)}`  // TypeError: Cannot read property 'toFixed' of undefined

  // Question: Why is price undefined?
  // Without call stack: Must search entire codebase for formatPrice calls
}
```

**Correct (using call stack to find the source):**

```javascript
function formatPrice(price) {
  // Breakpoint here, examine call stack:
  //
  // Call Stack:
  // > formatPrice(undefined)     <- Current: price is undefined
  //   renderOrderItem(item)      <- Called from here
  //   OrderList.render()         <- Called from here
  //   App.componentDidMount()    <- Root

  return `$${price.toFixed(2)}`
}

// Click on "renderOrderItem" in call stack:
function renderOrderItem(item) {
  // Now we can see the problem:
  const price = item.price        // item.price is undefined
  return formatPrice(price)
  // Root cause: item object is missing price property
}

// Click on "OrderList.render" in call stack:
function render() {
  return items.map(item => renderOrderItem(item))
  // Inspect 'items': Contains objects without 'price' field
  // Bug: API response schema changed, missing price field
}
```

**Call stack debugging tips:**
- Click frames to jump to that point in execution
- Examine local variables at each frame level
- Identify unexpected callers or call patterns
- Find where bad data originated

Reference: [Cornell CS312 - Debugging Techniques](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)

### 5.2 Master Step Over, Into, and Out

**Impact: MEDIUM-HIGH (3-5× faster stepping through code)**

Use step-over to skip trusted functions, step-into to examine suspect functions, and step-out to exit when you've seen enough. Efficient stepping avoids wasting time in irrelevant code.

**Incorrect (stepping into everything):**

```python
def process_order(order):
    validated = validate_order(order)      # Step Into -> 50 lines
    total = calculate_total(order.items)   # Step Into -> 30 lines
    tax = calculate_tax(total)             # Step Into -> 20 lines
    # Bug is in apply_discount, but already spent time in 100 lines
    discounted = apply_discount(total, order.coupon)  # Bug here
    return save_order(order, discounted)

# Inefficient: Stepped through 100 lines of working code
```

**Correct (targeted stepping):**

```python
def process_order(order):
    validated = validate_order(order)      # Step Over (trusted)
    total = calculate_total(order.items)   # Step Over (trusted)
    tax = calculate_tax(total)             # Step Over (trusted)

    # HYPOTHESIS: Bug is in discount calculation
    discounted = apply_discount(total, order.coupon)  # Step Into
    # Inside apply_discount:
    #   discount_rate = get_rate(coupon)  # Step Into (suspect)
    #     # Found: returns None for expired coupons
    #     # Step Out back to apply_discount
    #   return total * (1 - discount_rate)  # total * (1 - None) = NaN

    return save_order(order, discounted)   # Never reached
```

**Stepping strategy:**
| Action | Shortcut | Use When |
|--------|----------|----------|
| Step Over | F10 | Function is trusted, skip internals |
| Step Into | F11 | Function is suspect, examine internals |
| Step Out | Shift+F11 | Seen enough, return to caller |
| Continue | F5 | Run to next breakpoint |

Reference: [GUVI - Debugging in Software Development](https://www.guvi.in/blog/debugging-in-software-development/)

### 5.3 Place Breakpoints Strategically

**Impact: MEDIUM-HIGH (2-5× faster bug localization)**

Place breakpoints at decision points and state transitions, not at every line. A breakpoint should answer a specific question about program state at a critical moment.

**Incorrect (breakpoint on every line):**

```python
def calculate_discount(user, cart):
    breakpoint()  # Stop here
    total = cart.subtotal
    breakpoint()  # Stop here
    discount_rate = get_discount_rate(user)
    breakpoint()  # Stop here
    discount = total * discount_rate
    breakpoint()  # Stop here
    final = total - discount
    breakpoint()  # Stop here
    return final

# 5 pauses to step through, tedious and unfocused
```

**Correct (breakpoint at key decision point):**

```python
def calculate_discount(user, cart):
    total = cart.subtotal
    discount_rate = get_discount_rate(user)

    # HYPOTHESIS: discount_rate is wrong for premium users
    # Place ONE breakpoint where discount_rate is used
    discount = total * discount_rate  # Breakpoint here
    # Inspect: discount_rate, user.tier, expected vs actual

    final = total - discount
    return final

# One pause, examine discount_rate: 0.1 (expected 0.2 for premium)
# Root cause found: get_discount_rate() ignores user tier
```

**Strategic breakpoint locations:**
- Before a condition that might evaluate incorrectly
- At the assignment of a variable you suspect is wrong
- At function entry when you suspect wrong parameters
- Just before the line that throws an exception

Reference: [Graphite - Debugging Best Practices Guide](https://graphite.com/guides/debugging-best-practices-guide)

### 5.4 Use Conditional Breakpoints for Specific Cases

**Impact: MEDIUM-HIGH (avoids N iterations of manual stepping)**

When a bug occurs only for specific inputs or iterations, use conditional breakpoints to pause execution only when those conditions are met. This avoids stepping through thousands of irrelevant iterations.

**Incorrect (regular breakpoint in loop):**

```javascript
function processOrders(orders) {
  for (const order of orders) {
    // Bug: Order #4582 has wrong total
    calculateTotal(order)  // Regular breakpoint
    // Must click "Continue" 4581 times to reach the bug
  }
}
```

**Correct (conditional breakpoint):**

```javascript
function processOrders(orders) {
  for (const order of orders) {
    // Conditional breakpoint: order.id === 4582
    calculateTotal(order)  // Stops only for order #4582
    // Immediately examine the problematic order
  }
}

// In debugger:
// Breakpoint condition: order.id === 4582
// Or: order.total > 10000  (find all large orders)
// Or: order.items.length === 0  (find empty orders)
```

**Conditional breakpoint use cases:**
- Loop iterations: `i === 999` or `i % 1000 === 0`
- Specific users: `user.id === "alice"` or `user.role === "admin"`
- Error conditions: `response.status >= 400`
- Edge cases: `items.length === 0` or `value === null`

**Alternative: Logpoints**
```javascript
// Instead of breaking, log values without pausing
// Logpoint expression: `Order ${order.id}: total=${order.total}`
// Output: Order 4582: total=NaN  <- Found the bug
```

Reference: [TechNetExperts - 25 Debugging Techniques](https://www.technetexperts.com/debugging-techniques-every-developer-should-know/)

### 5.5 Use Time-Travel Debugging When Available

**Impact: MEDIUM-HIGH (eliminates restart cycles during debugging)**

Time-travel debuggers record program execution and let you step backward as well as forward. This is invaluable for finding where state became corrupted without needing to restart and reproduce.

**Incorrect (restart to re-examine earlier state):**

```python
def process_data(data):
    transformed = transform(data)          # Passed this point
    validated = validate(transformed)      # Passed this point
    result = calculate(validated)          # Bug here: wrong result
    # Want to check 'transformed' value, but already stepped past it
    # Must restart debugging from the beginning
    return result

# Debugging session:
# 1. Run to breakpoint at calculate()
# 2. Realize need to see transform() output
# 3. Restart entire session
# 4. Set new breakpoint at transform()
# 5. Repeat for each hypothesis...
```

**Correct (time-travel debugging):**

```python
def process_data(data):
    transformed = transform(data)          # Can return here anytime
    validated = validate(transformed)      # Can return here anytime
    result = calculate(validated)          # Currently stopped here
    return result

# Time-travel debugging session (using rr, VS Code, or browser DevTools):
# 1. Run to breakpoint at calculate()
# 2. Examine 'validated' - looks wrong
# 3. Step BACKWARD to validate() exit
# 4. Examine 'transformed' - also wrong
# 5. Step BACKWARD to transform() entry
# 6. Watch 'data' transform step by step
# 7. Found: transform() mutates input incorrectly at line 45
# No restart needed!
```

**Time-travel tools:**
- **rr** (Linux): Record and replay C/C++/Rust programs
- **VS Code**: Built-in time-travel for JavaScript debugging
- **Chrome DevTools**: Performance recording with state snapshots
- **WinDbg Preview**: Time Travel Debugging for Windows

Reference: [WeAreBrain - 10 Debugging Techniques](https://wearebrain.com/blog/10-effective-debugging-techniques-for-developers/)

### 5.6 Use Watch Expressions to Track State

**Impact: MEDIUM-HIGH (reduces manual inspection by 10×)**

Add watch expressions for variables and computed values you want to monitor as you step through code. Watch expressions update automatically at each debugger pause, revealing how state changes over time.

**Incorrect (manually inspecting variables each step):**

```typescript
function processTransaction(account: Account, amount: number) {
  const balance = account.balance
  // Manual inspection: hover over 'balance'
  const fee = calculateFee(amount)
  // Manual inspection: hover over 'fee'
  const newBalance = balance - amount - fee
  // Manual inspection: hover over 'newBalance'
  account.balance = newBalance
  // Manual inspection: hover over 'account.balance'
  // Tedious, error-prone, lose track of values
}
```

**Correct (watch expressions track state automatically):**

```typescript
function processTransaction(account: Account, amount: number) {
  // Watch expressions (added in debugger):
  // 1. account.balance
  // 2. amount
  // 3. account.balance - amount  (computed expression)
  // 4. typeof fee  (check type)

  const balance = account.balance
  // Watch panel shows: balance=1000, amount=100, difference=900

  const fee = calculateFee(amount)
  // Watch panel shows: fee="10"  <- String! Type bug found

  const newBalance = balance - amount - fee
  // Watch panel shows: newBalance=NaN (string concat, not subtraction)

  account.balance = newBalance
}
```

**Useful watch expressions:**
- `variable` - Simple value tracking
- `array.length` - Collection size
- `object.property?.nested` - Nested values with null safety
- `typeof variable` - Type checking
- `JSON.stringify(object)` - Full object inspection
- `condition ? 'yes' : 'no'` - Condition evaluation

Reference: [Meegle - Debugging Best Practices](https://www.meegle.com/en_us/topics/debugging/debugging-best-practices)

---

## 6. Bug Triage and Classification

**Impact: MEDIUM**

Proper severity and priority classification ensures development resources focus on highest-impact issues. Distinguish technical severity from business priority to make informed decisions.

### 6.1 Assess User Impact Before Prioritizing

**Impact: MEDIUM (10× more user value per development hour)**

Before assigning priority, determine how many users are affected and how severely. A crash affecting 1% of users may be lower priority than a confusing error message affecting 80% of users.

**Incorrect (prioritizing by technical severity alone):**

```markdown
## Triage Decision:

Bug A: Memory leak after 72 hours runtime
- Severity: HIGH (technical complexity)
- Users affected: ~10 (long-running servers)
- Priority assigned: HIGH (based on severity)

Bug B: Confusing error message on signup
- Severity: LOW (just text)
- Users affected: 5,000/day (all new signups)
- Priority assigned: LOW (based on severity)

Result: Team spends week on memory leak while 35,000 users abandon signup
```

**Correct (prioritizing by user impact):**

```markdown
## Triage Decision with Impact Analysis:

Bug A: Memory leak after 72 hours runtime
- Severity: HIGH (technical)
- Users affected: ~10 (long-running servers)
- Business impact: $500/month in restarts
- Priority: MEDIUM (schedule for next sprint)

Bug B: Confusing error message on signup
- Severity: LOW (cosmetic)
- Users affected: 5,000/day
- Business impact: 15% signup abandonment = $50,000/month lost
- Priority: HIGH (fix this sprint)

## Impact Formula:
Impact = (Users Affected) × (Severity per User) × (Revenue/User)
```

**Impact assessment questions:**
- How many users are affected? (1, 100, 10,000?)
- How often does it occur? (Once, daily, every request?)
- What's the workaround cost? (None, minor, major?)
- What's the business cost? (Support tickets, lost revenue, churn?)

Reference: [Marker.io - Bug Triage: How to Organize and Prioritize](https://marker.io/blog/bug-triage)

### 6.2 Detect and Link Duplicate Bug Reports

**Impact: MEDIUM (prevents duplicate investigation effort)**

Before investigating a new bug, search for existing reports of the same issue. Duplicates waste effort and fragment information. Link them to a single canonical issue to consolidate context.

**Incorrect (investigating duplicates independently):**

```markdown
## Bug Database:

JIRA-101: "Login fails on Firefox" (Team A investigating)
JIRA-205: "Can't sign in with Firefox browser" (Team B investigating)
JIRA-312: "Authentication broken in FF" (Team C investigating)

Result: 3 teams, 3 weeks of parallel investigation
All three are the same bug: session cookie SameSite issue
```

**Correct (duplicate detection and linking):**

```markdown
## Bug Database with Duplicate Detection:

JIRA-101: "Login fails on Firefox"
- Status: In Progress
- Root cause: SameSite cookie not set

JIRA-205: "Can't sign in with Firefox browser"
- Status: Duplicate of JIRA-101
- Note: Additional reproduction steps added to JIRA-101

JIRA-312: "Authentication broken in FF"
- Status: Duplicate of JIRA-101
- Note: Affected user count updated in JIRA-101

## Duplicate Detection Checklist:
Before creating/investigating new bug:
1. Search by error message keywords
2. Search by affected component/feature
3. Search by similar user reports in last 30 days
4. Check recent deploys for related changes
```

**Duplicate indicators:**
- Same error message or stack trace
- Same feature/page affected
- Same browser/device/environment
- Reported around the same time (often after a deploy)

Reference: [Quash - Bug Triage Defect Priority vs Severity](https://quashbugs.com/blog/bug-triage-defect-priority-vs-severity)

### 6.3 Factor Reproducibility into Triage

**Impact: MEDIUM (prevents wasted investigation time)**

Bugs that cannot be reliably reproduced are harder to fix and verify. Factor reproducibility into priority: sometimes a lower-severity reproducible bug should be fixed before a higher-severity intermittent one.

**Incorrect (ignoring reproducibility in triage):**

```markdown
## Sprint Planning:

Task 1: Fix critical race condition
- Severity: CRITICAL
- Reproducibility: Random, ~1% of requests
- Estimate: Unknown (can't reliably reproduce)

Task 2: Fix broken pagination
- Severity: MEDIUM
- Reproducibility: 100% reproducible
- Estimate: 2 hours

Decision: Work on critical race condition first
Result: 2 weeks spent trying to reproduce, still unfixed
```

**Correct (reproducibility-aware triage):**

```markdown
## Sprint Planning:

Task 1: Fix critical race condition
- Severity: CRITICAL
- Reproducibility: Random, ~1% of requests, no reproduction steps
- Investigation needed: Add logging to capture conditions
- Action: Add instrumentation this sprint, fix next sprint

Task 2: Fix broken pagination
- Severity: MEDIUM
- Reproducibility: 100% reproducible
- Estimate: 2 hours
- Action: Fix this sprint (quick win)

Task 3: Review race condition logs
- Prerequisite: Task 1 logging deployed for 1 week
- Goal: Establish reliable reproduction steps
- Then: Schedule fix with accurate estimate
```

**Reproducibility levels:**
| Level | Description | Triage Action |
|-------|-------------|---------------|
| 100% | Always happens with specific steps | Estimate and fix |
| Sometimes | Happens under certain conditions | Document conditions, then fix |
| Rarely | Cannot reliably reproduce | Add instrumentation first |
| Once | Happened once, never again | Monitor, don't prioritize |

Reference: [BirdEatsBug - Bug Triage Process](https://birdeatsbug.com/blog/bug-triage-process)

### 6.4 Identify and Ship Quick Wins First

**Impact: MEDIUM (3-5× more bugs fixed per sprint)**

When triaging, identify bugs that are both high-impact and low-effort. Shipping these quick wins first maximizes user benefit per development hour and builds momentum.

**Incorrect (strict priority order ignoring effort):**

```markdown
## Bug Queue (Priority Order):

1. Redesign checkout flow (HIGH priority, 3 weeks effort)
2. Fix typo in error message (MEDIUM priority, 5 minutes effort)
3. Update email template (MEDIUM priority, 30 minutes effort)
4. Refactor payment integration (HIGH priority, 2 weeks effort)

Sprint: Start with #1 (checkout redesign)
After 3 weeks: 0 bugs fixed, users still see typos
```

**Correct (quick wins surfaced):**

```markdown
## Bug Queue (Impact/Effort Analysis):

| Bug | Priority | Effort | Impact/Hour | Action |
|-----|----------|--------|-------------|--------|
| Typo in error message | MEDIUM | 5 min | HIGH | Fix NOW |
| Update email template | MEDIUM | 30 min | MEDIUM | Fix NOW |
| Redesign checkout | HIGH | 3 weeks | MEDIUM | Schedule |
| Refactor payment | HIGH | 2 weeks | HIGH | Schedule |

Sprint Day 1:
- 10:00 AM: Fixed typo (5 min) ✓
- 10:35 AM: Fixed email template (30 min) ✓
- 11:00 AM: Start checkout redesign

After Day 1: 2 bugs fixed, user experience improved
After 3 weeks: Checkout redesign + 12 quick wins shipped
```

**Quick win identification:**
- Fix time < 1 hour
- No architectural changes needed
- Self-contained (no dependencies)
- Clear reproduction steps

Reference: [Guru99 - Bug Defect Triage](https://www.guru99.com/bug-defect-triage.html)

### 6.5 Separate Severity from Priority

**Impact: MEDIUM (enables correct resource allocation)**

Severity measures technical impact (how broken). Priority measures business urgency (how soon to fix). A minor visual bug on a high-traffic landing page may be low severity but high priority. Keep these distinct for proper triage.

**Incorrect (conflating severity and priority):**

```markdown
## Bug Report: Typo in Terms of Service
Severity: LOW
Priority: LOW

Decision: Fix when convenient

## Bug Report: Crash on checkout for users with emojis in name
Severity: HIGH
Priority: HIGH

Decision: Fix immediately
```

**Correct (separate severity from priority):**

```markdown
## Bug Report: Typo in Terms of Service
Severity: LOW (cosmetic issue, no functional impact)
Priority: HIGH (legal team says must fix before audit next week)

Decision: Schedule for immediate sprint

## Bug Report: Crash on checkout for users with emojis in name
Severity: HIGH (complete feature failure)
Priority: LOW (affects 0.01% of users, workaround exists)

Decision: Schedule for next sprint, document workaround

## Severity/Priority Matrix:

|                | High Priority | Low Priority |
|----------------|--------------|--------------|
| High Severity  | Fix NOW      | Fix soon     |
| Low Severity   | Fix soon     | Backlog      |
```

**Classification guidelines:**
| Severity | Definition |
|----------|------------|
| CRITICAL | System down, data loss, security breach |
| HIGH | Major feature broken, no workaround |
| MEDIUM | Feature impaired, workaround exists |
| LOW | Cosmetic, minor inconvenience |

Reference: [Atlassian - Bug Triage](https://www.atlassian.com/agile/software-development/bug-triage)

---

## 7. Common Bug Patterns

**Impact: MEDIUM**

Recognizing classic bug patterns—null pointers, race conditions, off-by-one errors, memory leaks—enables faster diagnosis by matching symptoms to known causes.

### 7.1 Catch Async/Await Error Handling Mistakes

**Impact: MEDIUM (prevents unhandled promise rejections)**

Async/await makes asynchronous code look synchronous, but error handling behaves differently. Unhandled promise rejections, missing try/catch, and forgotten await keywords are common bugs.

**Incorrect (async error handling mistakes):**

```javascript
// Bug 1: Missing try/catch
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`)
  return response.json()  // Network errors crash the app
}

// Bug 2: Forgotten await
async function processOrder(orderId) {
  const order = await getOrder(orderId)
  validateOrder(order)  // If async, validation runs after return!
  return order
}

// Bug 3: Errors lost in Promise.all
async function loadDashboard() {
  const [users, orders, stats] = await Promise.all([
    fetchUsers(),    // If this fails...
    fetchOrders(),   // These still run but error is unclear
    fetchStats()
  ])
}
```

**Correct (proper async error handling):**

```javascript
// Fixed 1: Try/catch for error handling
async function fetchUser(id) {
  try {
    const response = await fetch(`/api/users/${id}`)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    return response.json()
  } catch (error) {
    logger.error('fetch_user_failed', { id, error: error.message })
    throw error  // Re-throw or return fallback
  }
}

// Fixed 2: Await all async operations
async function processOrder(orderId) {
  const order = await getOrder(orderId)
  await validateOrder(order)  // Properly awaited
  return order
}

// Fixed 3: Handle Promise.all failures gracefully
async function loadDashboard() {
  const results = await Promise.allSettled([
    fetchUsers(),
    fetchOrders(),
    fetchStats()
  ])
  // Check each result: { status: 'fulfilled', value } or { status: 'rejected', reason }
  const [usersResult, ordersResult, statsResult] = results
  if (usersResult.status === 'rejected') {
    logger.error('users_fetch_failed', { error: usersResult.reason })
  }
}
```

**Async debugging tips:**
- Add `.catch()` to all promises in development to surface errors
- Use `unhandledRejection` event handler to log missed errors
- ESLint rules: `require-await`, `no-floating-promises`

Reference: [Coders.dev - The Art of Debugging](https://www.coders.dev/blog/the-art-of-debugging-techniques-for-efficient-troubleshooting.html)

### 7.2 Detect Memory Leak Patterns

**Impact: MEDIUM (prevents out-of-memory crashes)**

Memory leaks occur when allocated memory is never released. Symptoms: gradually increasing memory usage, eventual out-of-memory crashes, performance degradation over time. Look for event listeners not removed, caches without bounds, and circular references.

**Incorrect (memory leak patterns):**

```javascript
// Leak 1: Event listeners never removed
class Dashboard {
  constructor() {
    window.addEventListener('resize', this.handleResize)  // Never removed
  }
  // Missing: componentWillUnmount to remove listener
}

// Leak 2: Unbounded cache
const cache = {}
function getCachedData(key) {
  if (!cache[key]) {
    cache[key] = fetchData(key)  // Cache grows forever
  }
  return cache[key]
}

// Leak 3: Closures holding references
function createHandlers(elements) {
  const handlers = []
  for (const el of elements) {
    handlers.push(() => {
      console.log(el)  // Each closure holds reference to element
    })
  }
  return handlers  // Elements can't be garbage collected
}
```

**Correct (memory-safe patterns):**

```javascript
// Fixed 1: Remove event listeners
class Dashboard {
  constructor() {
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
  }
  destroy() {
    window.removeEventListener('resize', this.handleResize)
  }
}

// Fixed 2: Bounded cache with LRU eviction
const cache = new LRUCache({ max: 1000 })
function getCachedData(key) {
  if (!cache.has(key)) {
    cache.set(key, fetchData(key))
  }
  return cache.get(key)
}

// Fixed 3: WeakRef for optional references
function createHandlers(elements) {
  return elements.map(el => {
    const weakRef = new WeakRef(el)
    return () => {
      const element = weakRef.deref()
      if (element) console.log(element)
    }
  })
}
```

**Memory leak detection:**
- Memory profilers: Chrome DevTools, Valgrind, dotMemory
- Monitor heap size over time in production
- Test with long-running automated scenarios

Reference: [Netdata - How to Find Memory Leaks](https://www.netdata.cloud/academy/how-to-find-memory-leak-in-c/)

### 7.3 Identify Race Condition Symptoms

**Impact: MEDIUM (prevents intermittent production failures)**

Race conditions occur when multiple threads or processes access shared state without proper synchronization. Symptoms: intermittent failures, results depend on timing, works in debugger but fails in production.

**Incorrect (unsynchronized shared state):**

```java
public class Counter {
    private int count = 0;

    public void increment() {
        count++;  // Not atomic: read, add, write can interleave
    }

    public int getCount() {
        return count;
    }
}

// Two threads call increment() 1000 times each
// Expected: count = 2000
// Actual: count = 1847 (random, changes each run)
```

**Correct (synchronized access):**

```java
public class Counter {
    private final AtomicInteger count = new AtomicInteger(0);

    public void increment() {
        count.incrementAndGet();  // Atomic operation
    }

    public int getCount() {
        return count.get();
    }
}

// Two threads call increment() 1000 times each
// Result: count = 2000 (always correct)
```

**Race condition indicators:**
- Bug "disappears" when adding logging or breakpoints
- Different results on each run
- Works on developer machine, fails in CI/production
- Failures correlate with load or concurrent users
- "Heisenbug" that changes when observed

**Detection tools:**
- Thread sanitizers (TSan, Helgrind)
- Static analysis for data races
- Stress testing with high concurrency

Reference: [Valgrind Documentation - Helgrind Thread Analyzer](https://valgrind.org/docs/manual/hg-manual.html)

### 7.4 Recognize Null Pointer Patterns

**Impact: MEDIUM (prevents 20-30% of runtime errors)**

Null pointer dereferences occur when code assumes a value exists but it doesn't. Recognize the patterns: missing null checks, optional chaining neglected, uninitialized variables, and failed lookups assumed successful.

**Incorrect (assuming value exists):**

```typescript
function getUserEmail(userId: string): string {
  const user = userRepository.findById(userId)
  return user.email  // Crashes if user not found
}

function getFirstItem(items: Item[]): string {
  return items[0].name  // Crashes if array empty
}

function processConfig(config: Config): void {
  const timeout = config.settings.network.timeout  // Crashes if any level missing
}
```

**Correct (defensive null handling):**

```typescript
function getUserEmail(userId: string): string | null {
  const user = userRepository.findById(userId)
  if (!user) {
    logger.warn('user_not_found', { userId })
    return null
  }
  return user.email
}

function getFirstItem(items: Item[]): string | null {
  if (items.length === 0) {
    return null
  }
  return items[0].name
}

function processConfig(config: Config): void {
  const timeout = config?.settings?.network?.timeout ?? 30000
  // Uses optional chaining and default value
}
```

**Common null pointer sources:**
- Database/API lookups that return no results
- Array access with invalid index
- Object property access on undefined
- Map/dictionary lookups for missing keys
- Race conditions where value not yet initialized

Reference: [Krishna Gupta - Understanding CWE-476 NULL Pointer Dereference](https://krishnag.ceo/blog/understanding-cwe-476-null-pointer-dereference/)

### 7.5 Recognize Timezone and Date Bugs

**Impact: MEDIUM (prevents date calculation errors across timezones)**

Date and timezone bugs are subtle and often only manifest for users in certain locations or at certain times. Symptoms: events on wrong day, off-by-one-day errors near midnight, DST transition bugs.

**Incorrect (timezone-unaware date handling):**

```javascript
// Bug 1: Date comparison ignores timezone
function isToday(eventDate) {
  const today = new Date()
  return eventDate.getDate() === today.getDate()  // Fails across timezones
}

// Bug 2: Creating dates from strings
const deadline = new Date('2024-03-15')  // Parsed as UTC midnight
// In US Pacific (UTC-8): March 14th 4pm!

// Bug 3: Storing local time instead of UTC
const createdAt = new Date().toString()  // "Fri Mar 15 2024 10:30:00 GMT-0800"
// Comparing this string across timezones: chaos
```

**Correct (timezone-aware date handling):**

```javascript
// Fixed 1: Compare using date strings
function isToday(eventDate) {
  const today = new Date()
  return eventDate.toISOString().slice(0, 10) === today.toISOString().slice(0, 10)
}

// Fixed 2: Be explicit about timezone
const deadline = new Date('2024-03-15T00:00:00-08:00')  // Pacific midnight
// Or use a date library:
import { parseISO } from 'date-fns'
import { zonedTimeToUtc } from 'date-fns-tz'

// Fixed 3: Store timestamps in UTC
const createdAt = new Date().toISOString()  // "2024-03-15T18:30:00.000Z"
// Or store Unix timestamp
const createdAtUnix = Date.now()  // 1710526200000

// Display in user's local timezone:
const displayTime = new Date(createdAt).toLocaleString('en-US', {
  timeZone: userTimezone
})
```

**Timezone bug prevention:**
- Store all dates in UTC (ISO 8601 or Unix timestamp)
- Convert to local time only for display
- Use date libraries (date-fns, Luxon) for manipulation
- Test with users in multiple timezones
- Test around DST transitions

Reference: [Wikipedia - Falsehoods Programmers Believe About Time](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

### 7.6 Spot Off-by-One Errors

**Impact: MEDIUM (prevents 10-15% of logic errors)**

Off-by-one errors occur at boundaries: loop iterations, array indices, string slicing. Check whether conditions should use `<` vs `<=`, whether indices start at 0 or 1, and whether ranges are inclusive or exclusive.

**Incorrect (off-by-one in loop):**

```python
def process_items(items):
    # Bug: Skips last item
    for i in range(len(items) - 1):  # Should be range(len(items))
        process(items[i])

def get_substring(text, start, length):
    # Bug: Returns one character too many
    return text[start:start + length + 1]  # Should be start + length

def validate_page_number(page, total_pages):
    # Bug: Rejects valid last page
    if page > total_pages - 1:  # Should be page > total_pages or page >= total_pages
        raise InvalidPageError()
```

**Correct (boundary-aware code):**

```python
def process_items(items):
    # Correct: Process all items
    for i in range(len(items)):
        process(items[i])
    # Or simply: for item in items: process(item)

def get_substring(text, start, length):
    # Correct: Python slicing is exclusive on end
    return text[start:start + length]

def validate_page_number(page, total_pages):
    # Correct: Pages 1 through total_pages are valid
    if page < 1 or page > total_pages:
        raise InvalidPageError()
```

**Off-by-one checklist:**
- [ ] Does the loop include or exclude the last element?
- [ ] Are indices 0-based or 1-based?
- [ ] Is the range/slice inclusive or exclusive on the end?
- [ ] Does `<=` vs `<` matter for the edge case?

Reference: [FSU - Debugging Techniques](https://www.cs.fsu.edu/~baker/opsys/notes/debugging.html)

### 7.7 Watch for Type Coercion Bugs

**Impact: MEDIUM (prevents silent data corruption bugs)**

Type coercion bugs occur when languages implicitly convert between types. JavaScript is notorious for this: string concatenation instead of addition, truthy/falsy surprises, and loose equality comparisons.

**Incorrect (implicit type coercion):**

```javascript
// Bug 1: String concatenation instead of addition
function calculateTotal(price, tax) {
  return price + tax  // If tax is "10" (string): "100" + "10" = "10010"
}
calculateTotal(100, document.getElementById('tax').value)  // Input values are strings!

// Bug 2: Falsy zero treated as missing
function getDiscount(discount) {
  return discount || 10  // Returns 10 when discount is 0!
}
getDiscount(0)  // Expected: 0, Actual: 10

// Bug 3: Loose equality surprises
if (userId == null) {  // True for both null AND undefined
  // ...
}
'0' == false  // true (wat)
[] == false   // true (double wat)
```

**Correct (explicit type handling):**

```javascript
// Fixed 1: Parse input explicitly
function calculateTotal(price, tax) {
  const numericTax = parseFloat(tax)
  if (isNaN(numericTax)) {
    throw new Error('Invalid tax value')
  }
  return price + numericTax
}

// Fixed 2: Explicit undefined check
function getDiscount(discount) {
  return discount !== undefined ? discount : 10
  // Or with nullish coalescing: discount ?? 10
}
getDiscount(0)  // Correctly returns 0

// Fixed 3: Strict equality
if (userId === null) {  // Only true for null, not undefined
  // ...
}
'0' === false  // false (correct)
[] === false   // false (correct)
```

**Type coercion danger zones:**
- Form input values (always strings)
- JSON parsed numbers (may be strings)
- Query parameters (always strings)
- Arithmetic with mixed types
- Boolean coercion of 0, "", null, undefined

Reference: [TMS Outsource - What is Debugging](https://tms-outsource.com/blog/posts/what-is-debugging/)

---

## 8. Prevention and Verification

**Impact: LOW**

Preventing bug recurrence through regression tests, code review, and defensive coding ensures long-term code quality. Verify fixes completely before closing issues.

### 8.1 Add Regression Tests for Every Fix

**Impact: LOW (prevents same bug from recurring)**

Every bug fix should include a test that would have caught the bug. This regression test ensures the bug never returns and documents the expected behavior for future developers.

**Incorrect (fix without test):**

```python
# Bug: Discount calculation wrong for orders over $1000
# PR: Fix discount calculation
# No test added

def apply_discount(total):
    if total > 1000:
        return total * 0.9  # Fixed: was 0.09
    return total

# 6 months later: Someone refactors this code
# Bug reappears because no test protected it
```

**Correct (fix with regression test):**

```python
# Bug: Discount calculation wrong for orders over $1000
# PR: Fix discount calculation + add regression test

def apply_discount(total):
    if total > 1000:
        return total * 0.9
    return total

# test_discounts.py
def test_discount_for_orders_over_1000():
    """Regression test for JIRA-4521: Discount was 0.09 instead of 0.9"""
    result = apply_discount(1500)
    assert result == 1350  # 10% discount = $150 off

def test_no_discount_for_orders_under_1000():
    result = apply_discount(500)
    assert result == 500

def test_discount_at_boundary():
    result = apply_discount(1000)
    assert result == 1000  # Exactly $1000 gets no discount

    result = apply_discount(1001)
    assert result == 900.9  # Just over threshold gets discount
```

**Regression test checklist:**
- [ ] Test reproduces the original bug (fails before fix)
- [ ] Test passes after fix
- [ ] Test covers edge cases around the bug
- [ ] Test documents the expected behavior
- [ ] Reference to original bug ticket in comment

Reference: [MIT 6.031 - Reading 13: Debugging](http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)

### 8.2 Conduct Blameless Post-Mortems

**Impact: LOW (prevents recurring incidents through systematic learning)**

After significant bugs or outages, conduct a blameless post-mortem to understand what went wrong and how to prevent recurrence. Focus on systems and processes, not individual blame.

**Incorrect (blame-focused incident response):**

```markdown
## Incident Report: Database Outage

What happened: Database ran out of disk space, causing 4-hour outage

Root cause: John forgot to set up disk monitoring

Action item: Remind John to be more careful

Result: Same bug happens 3 months later (different person, same oversight)
```

**Correct (blameless post-mortem):**

```markdown
## Post-Mortem: Database Outage (March 15, 2024)

### Timeline:
- 09:00: Disk usage exceeded 90%
- 11:30: Database stopped accepting writes
- 11:45: Alert received (customers reported errors)
- 13:30: Disk expanded, service restored

### Impact:
- 4 hours of degraded service
- ~500 affected customers
- Estimated revenue impact: $5,000

### Root Cause Analysis (5 Whys):
1. Why did DB stop? → Disk full
2. Why was disk full? → No automatic cleanup of old logs
3. Why no cleanup? → Not in provisioning script
4. Why not in script? → No standard for database provisioning
5. Why no standard? → Rapid growth, tech debt

### Contributing Factors:
- No disk space monitoring alerts
- Manual provisioning process
- No capacity planning review

### Action Items:
| Action | Owner | Due Date |
|--------|-------|----------|
| Add disk monitoring to all databases | SRE team | March 22 |
| Create database provisioning template | Platform | March 29 |
| Quarterly capacity planning review | Leads | Ongoing |
| Add runbook for disk space incidents | On-call | March 22 |

### What Went Well:
- Quick identification of root cause
- Effective cross-team collaboration
- Good communication to customers
```

**Post-mortem principles:**
- Blameless: Focus on systems, not people
- Timely: Conduct within 1 week of incident
- Actionable: Every finding has an owner and deadline
- Shared: Publish learnings to prevent repeat incidents

Reference: [Medium - Scientific Debugging](https://medium.com/machine-words/scientific-debugging-part-1-8890b73b6c4c)

### 8.3 Include Bug-Prevention Checks in Code Review

**Impact: LOW (reduces production bugs by 30-50%)**

Code review is an effective bug-prevention tool when reviewers know what to look for. Create a checklist of common bug patterns to catch issues before they ship.

**Incorrect (superficial code review):**

```markdown
## PR Review: Add user authentication

Reviewer comments:
- "LGTM" (Looks Good To Me)
- "Nice work!"

Merged without checking for:
- SQL injection
- Password storage security
- Session management issues
- Error message information leakage
```

**Correct (bug-focused code review):**

```markdown
## PR Review: Add user authentication

### Security Checklist:
- [x] SQL injection: Uses parameterized queries ✓
- [ ] Password storage: Using bcrypt? **ISSUE: Using MD5**
- [x] Session management: Regenerates session ID on login ✓
- [ ] Error messages: **ISSUE: "Invalid password for user X" leaks usernames**

### Common Bug Checklist:
- [x] Null checks on database results ✓
- [x] Input validation on all user data ✓
- [ ] Error handling: **ISSUE: Missing try/catch on line 45**
- [x] Logging includes correlation IDs ✓

### Test Coverage:
- [x] Happy path tested
- [ ] **MISSING: Test for SQL injection attempts**
- [ ] **MISSING: Test for invalid session handling**

Blocking merge until security issues resolved.
```

**Code review bug checklist:**
- [ ] Null/undefined handling
- [ ] Error handling and recovery
- [ ] Input validation and sanitization
- [ ] SQL injection, XSS, CSRF prevention
- [ ] Race conditions in concurrent code
- [ ] Resource cleanup (connections, file handles)
- [ ] Edge cases (empty arrays, zero values)

Reference: [BrowserStack - Root Causes for Software Defects](https://www.browserstack.com/guide/root-causes-for-software-defects-and-its-solutions)

### 8.4 Use Assertions for Invariant Checking

**Impact: LOW (reduces debugging time by catching errors early)**

Add assertions to verify assumptions that should always be true. Assertions catch bugs at the point where invariants are violated, rather than later when symptoms appear far from the cause.

**Incorrect (no assertion, bug discovered far from source):**

```python
def transfer_money(from_account, to_account, amount):
    from_account.balance -= amount
    to_account.balance += amount
    # No validation of inputs
    # Bug: negative amount passed, money flows wrong direction
    # Discovered: Week later in accounting audit
```

**Correct (assertions catch invalid state early):**

```python
def transfer_money(from_account, to_account, amount):
    # Preconditions: Assert inputs are valid
    assert amount > 0, f"Transfer amount must be positive, got {amount}"
    assert from_account is not to_account, "Cannot transfer to same account"
    assert from_account.balance >= amount, "Insufficient funds"

    from_account.balance -= amount
    to_account.balance += amount

    # Postcondition: Assert result is valid
    assert from_account.balance >= 0, "Balance went negative after transfer"

    # Invariant: Total money in system unchanged
    # (In production, use proper transaction validation)
```

**When to use assertions:**
- Function preconditions (valid parameters)
- Postconditions (valid return values)
- Loop invariants (state that must be true each iteration)
- Impossible states ("this should never happen")

**When NOT to use assertions:**
- User input validation (use proper error handling)
- Expected error conditions (use exceptions)
- Assertions can be disabled in production

Reference: [Cornell CS312 - Debugging Techniques](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)

---

## References

1. [http://web.mit.edu/6.031/www/fa17/classes/13-debugging/](http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)
2. [https://www.geeksforgeeks.org/software-engineering-debugging-approaches/](https://www.geeksforgeeks.org/software-engineering-debugging-approaches/)
3. [https://www.atlassian.com/agile/software-development/bug-triage](https://www.atlassian.com/agile/software-development/bug-triage)
4. [https://www.browserstack.com/guide/root-causes-for-software-defects-and-its-solutions](https://www.browserstack.com/guide/root-causes-for-software-defects-and-its-solutions)
5. [https://www.ibm.com/think/insights/observability-pillars](https://www.ibm.com/think/insights/observability-pillars)
6. [https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
7. [https://bugasura.io/blog/root-cause-analysis-for-bug-tracking/](https://bugasura.io/blog/root-cause-analysis-for-bug-tracking/)
8. [https://eikmeier.sites.grinnell.edu/csc-151-s221/readings/hypothesis-driven-debugging.html](https://eikmeier.sites.grinnell.edu/csc-151-s221/readings/hypothesis-driven-debugging.html)
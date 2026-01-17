# Debugging

**Version 1.0.0**  
dot-skills  
January 2025

> **Note:**
> This Debugging guide is mainly for agents and LLMs to follow when debugging,
> investigating, or fixing bugs in codebases. Humans may also find it useful,
> but guidance here is optimized for systematic debugging by AI-assisted workflows.

---

## Abstract

Comprehensive debugging methodology guide for software engineers, designed for AI agents and LLMs. Contains 54 rules across 10 categories, prioritized by impact from critical (problem definition, hypothesis-driven search) to incremental (prevention and learning). Includes bug triage, common bug patterns, and root cause analysis. Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct approaches, and specific impact metrics to guide systematic bug investigation.

---

## Table of Contents

1. [Problem Definition](#1-problem-definition) — **CRITICAL**
   - 1.1 [Check Recent Changes First](#11-check-recent-changes-first)
   - 1.2 [Create Minimal Reproduction Cases](#12-create-minimal-reproduction-cases)
   - 1.3 [Document Symptoms Precisely](#13-document-symptoms-precisely)
   - 1.4 [Reproduce Before Debugging](#14-reproduce-before-debugging)
   - 1.5 [Separate Symptoms from Causes](#15-separate-symptoms-from-causes)
   - 1.6 [State Expected vs Actual Behavior](#16-state-expected-vs-actual-behavior)
2. [Hypothesis-Driven Search](#2-hypothesis-driven-search) — **CRITICAL**
   - 2.1 [Apply the Scientific Method](#21-apply-the-scientific-method)
   - 2.2 [Explain the Problem Aloud (Rubber Duck)](#22-explain-the-problem-aloud-rubber-duck)
   - 2.3 [Find WHERE Before Asking WHAT](#23-find-where-before-asking-what)
   - 2.4 [Rule Out Obvious Causes First](#24-rule-out-obvious-causes-first)
   - 2.5 [Test One Hypothesis at a Time](#25-test-one-hypothesis-at-a-time)
   - 2.6 [Use Binary Search to Localize Bugs](#26-use-binary-search-to-localize-bugs)
3. [Observation Techniques](#3-observation-techniques) — **HIGH**
   - 3.1 [Log Function Inputs and Outputs](#31-log-function-inputs-and-outputs)
   - 3.2 [Read Stack Traces Bottom to Top](#32-read-stack-traces-bottom-to-top)
   - 3.3 [Trace Data Flow Through the System](#33-trace-data-flow-through-the-system)
   - 3.4 [Use Breakpoints Strategically](#34-use-breakpoints-strategically)
   - 3.5 [Use Strategic Logging Over Random Print Statements](#35-use-strategic-logging-over-random-print-statements)
   - 3.6 [Use Watch Expressions for Complex State](#36-use-watch-expressions-for-complex-state)
4. [Root Cause Analysis](#4-root-cause-analysis) — **HIGH**
   - 4.1 [Examine System Boundaries](#41-examine-system-boundaries)
   - 4.2 [Find the Last Known Good State](#42-find-the-last-known-good-state)
   - 4.3 [Question Your Assumptions](#43-question-your-assumptions)
   - 4.4 [Trace Fault Propagation Chains](#44-trace-fault-propagation-chains)
   - 4.5 [Use the 5 Whys Technique](#45-use-the-5-whys-technique)
5. [Tool Mastery](#5-tool-mastery) — **MEDIUM-HIGH**
   - 5.1 [Inspect Memory and Object State](#51-inspect-memory-and-object-state)
   - 5.2 [Master Step Over, Step Into, Step Out](#52-master-step-over-step-into-step-out)
   - 5.3 [Navigate the Call Stack](#53-navigate-the-call-stack)
   - 5.4 [Use Conditional Breakpoints](#54-use-conditional-breakpoints)
   - 5.5 [Use Exception Breakpoints](#55-use-exception-breakpoints)
   - 5.6 [Use Logpoints Instead of Modifying Code](#56-use-logpoints-instead-of-modifying-code)
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
8. [Fix Verification](#8-fix-verification) — **MEDIUM**
   - 8.1 [Add a Test to Prevent Recurrence](#81-add-a-test-to-prevent-recurrence)
   - 8.2 [Check for Regressions After Fixing](#82-check-for-regressions-after-fixing)
   - 8.3 [Understand Why the Fix Works](#83-understand-why-the-fix-works)
   - 8.4 [Verify Fix With Original Reproduction](#84-verify-fix-with-original-reproduction)
9. [Anti-Patterns](#9-anti-patterns) — **MEDIUM**
   - 9.1 [Avoid Blaming the Tool Too Quickly](#91-avoid-blaming-the-tool-too-quickly)
   - 9.2 [Avoid Quick Patches Without Understanding](#92-avoid-quick-patches-without-understanding)
   - 9.3 [Avoid Shotgun Debugging](#93-avoid-shotgun-debugging)
   - 9.4 [Avoid Tunnel Vision on Initial Hypothesis](#94-avoid-tunnel-vision-on-initial-hypothesis)
   - 9.5 [Recognize and Address Debugging Fatigue](#95-recognize-and-address-debugging-fatigue)
10. [Prevention & Learning](#10-prevention-learning) — **LOW-MEDIUM**
   - 10.1 [Add Defensive Code at System Boundaries](#101-add-defensive-code-at-system-boundaries)
   - 10.2 [Conduct Blameless Postmortems](#102-conduct-blameless-postmortems)
   - 10.3 [Document Bug Solutions for Future Reference](#103-document-bug-solutions-for-future-reference)
   - 10.4 [Improve Error Messages When You Debug](#104-improve-error-messages-when-you-debug)

---

## 1. Problem Definition

**Impact: CRITICAL**

Unclear problem statements waste 50%+ of debugging time; precise reproduction and symptom documentation prevent chasing wrong issues entirely.

### 1.1 Check Recent Changes First

**Impact: CRITICAL (80%+ of bugs are caused by recent changes; reduces search space dramatically)**

Most bugs are introduced by recent changes. Before deep investigation, check what changed since the code last worked correctly. This dramatically reduces your search space.

**Incorrect (ignoring change history):**

```bash
# Bug report: "Login stopped working yesterday"

# Developer starts reading the entire auth codebase
# 50 files, 5000 lines of code to review
# 4 hours later, still searching...
```

**Correct (check recent changes):**

```bash
# Bug report: "Login stopped working yesterday"

# Step 1: When did it last work?
git log --oneline --since="3 days ago" -- src/auth/

# Output:
# a1b2c3d Add rate limiting to login endpoint
# e4f5g6h Update password validation regex
# i7j8k9l Refactor session handling

# Step 2: Check the suspicious commits
git show e4f5g6h  # Password validation change

# Found it! Regex now rejects valid passwords with special chars
# 10 minutes instead of 4 hours
```

**Using git bisect for systematic search:**

```bash
# When you know a good commit and bad commit
git bisect start
git bisect bad HEAD                    # Current version is broken
git bisect good v2.0.0                 # This version worked
# Git checks out middle commit
# Test and mark as good or bad
git bisect good  # or: git bisect bad
# Repeat until Git identifies the first bad commit

# Automate with a test script:
git bisect run npm test -- --grep "login"
```

**Change investigation checklist:**
- What was the last known working version/date?
- What commits/deploys happened since then?
- Who made changes to related code?
- Were there any config/environment changes?
- Did dependencies update?

**When NOT to use this pattern:**
- Bug has existed unnoticed for a long time
- Legacy code with unclear change history
- Issues caused by external factors (data, load, third-party services)

Reference: [Git Bisect Documentation](https://git-scm.com/docs/git-bisect)

### 1.2 Create Minimal Reproduction Cases

**Impact: CRITICAL (Reduces debugging scope by 80-95%, making root cause obvious in many cases)**

Reduce the failing case to the smallest possible example that still exhibits the bug. Minimal reproductions eliminate noise, reveal the essential trigger, and often make the root cause immediately obvious.

**Incorrect (debugging in full application context):**

```javascript
// Bug: "User profile doesn't update after edit"
// Debugging in the full app with 200+ components...

// App.jsx (2000 lines)
// ProfilePage.jsx (500 lines)
// ProfileForm.jsx (300 lines)
// useProfile.js (150 lines)
// api/profile.js (100 lines)
// store/userSlice.js (200 lines)

// Developer spends 3 hours stepping through all layers
// Still unclear if issue is in form, API, or state management
```

**Correct (create minimal reproduction):**

```javascript
// Isolate the suspected component chain
// minimal-repro.jsx - 30 lines total

import { useState } from 'react';

function MinimalRepro() {
  const [profile, setProfile] = useState({ name: 'Alice' });

  const updateProfile = async (newName) => {
    // Simulate API call
    const response = await fetch('/api/profile', {
      method: 'PUT',
      body: JSON.stringify({ name: newName })
    });
    const data = await response.json();
    console.log('API returned:', data);  // Debug point 1
    setProfile(data);
    console.log('State after set:', profile);  // Debug point 2
    // BUG FOUND: Logging stale state due to closure!
  };

  return <button onClick={() => updateProfile('Bob')}>Update</button>;
}

// 10 minutes to find bug vs 3 hours in full app
```

**Simplification techniques:**
- Remove unrelated features one at a time
- Replace real APIs with hardcoded data
- Use a fresh project/file if possible
- Delete code until bug disappears, then add last deletion back

**When NOT to use this pattern:**
- Bug only occurs with specific data interactions across systems
- Performance issues requiring full load

Reference: [Why Programs Fail - Simplifying Problems](https://www.whyprogramsfail.com/)

### 1.3 Document Symptoms Precisely

**Impact: CRITICAL (Prevents misdiagnosis and enables pattern matching across similar issues)**

Record exactly what you observe, not what you think is happening. Precise symptom documentation prevents misdiagnosis and creates a reference you can verify against when testing hypotheses.

**Incorrect (vague description):**

```markdown
Bug Report:
- Title: "App is slow"
- Description: "The app feels sluggish sometimes"
- Steps: "Just use the app normally"
- Expected: "Should be fast"
- Actual: "It's slow"

// Developer has no idea where to start
// "Slow" could mean: startup, rendering, API calls, animations...
```

**Correct (precise symptoms):**

```markdown
Bug Report:
- Title: "2-3 second freeze when opening Settings after using search"
- Description: "UI becomes unresponsive for 2-3 seconds"
- Environment: macOS 14.2, App v2.1.0, 16GB RAM
- Steps to reproduce:
  1. Launch app (fresh start, not from background)
  2. Use search feature to find any item
  3. Click Settings icon in top right
  4. OBSERVE: UI freezes, spinner does not appear
  5. After 2-3 seconds, Settings panel opens
- Expected: Settings opens in <200ms
- Actual: 2-3 second freeze with no visual feedback
- Frequency: 100% reproducible with steps above
- Does NOT occur: if Settings opened before search, or on second open

// Clear starting point: something search does affects Settings load
```

**Symptom documentation checklist:**
- What exactly did you observe? (not interpret)
- When did it start? What changed?
- How often does it occur?
- What are the exact error messages (copy/paste, don't paraphrase)
- What works correctly in similar situations?

**When NOT to use this pattern:**
- Obvious crashes with clear stack traces
- Well-understood issues you've seen before

Reference: [MIT 6.031 - Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)

### 1.4 Reproduce Before Debugging

**Impact: CRITICAL (Prevents 50%+ of wasted debugging time on unreproducible or misunderstood issues)**

Never start debugging until you can reliably reproduce the bug. Without reproduction, you cannot verify your fix works and may spend hours chasing phantom issues or misunderstanding the actual problem.

**Incorrect (jumping straight to code):**

```python
# Bug report: "App crashes sometimes when saving"
# Developer immediately starts reading save code...

def save_data(data):
    # Check if this null check helps
    if data is None:  # Add defensive check
        return False
    # Check the file permission
    with open(self.path, 'w') as f:  # Add try/except?
        json.dump(data, f)
    # Hours later: still no idea what causes the crash
```

**Correct (reproduce first):**

```python
# Bug report: "App crashes sometimes when saving"
# Step 1: Gather reproduction details

"""
Reproduction attempt log:
1. Fresh install, create new file, save -> OK
2. Open existing file, edit, save -> OK
3. Open large file (>10MB), edit, save -> CRASH!
4. Open large file, small edit, save -> CRASH!
5. Open large file, don't edit, save -> OK

Hypothesis: Crash occurs when saving edits to large files
Minimal reproduction: Open 15MB JSON file, change one character, save
"""

# NOW start debugging with a clear, reproducible case
```

**Reproduction checklist:**
- Document exact steps to trigger the bug
- Note environment details (OS, version, config)
- Identify the minimal reproduction case
- Confirm you can trigger it consistently (or note frequency if intermittent)

**When NOT to use this pattern:**
- Obvious typos or syntax errors visible in stack trace
- Build failures with clear error messages

Reference: [Why Programs Fail - Reproducing Problems](https://www.whyprogramsfail.com/)

### 1.5 Separate Symptoms from Causes

**Impact: CRITICAL (Prevents fixing symptoms while root cause continues creating new bugs)**

Clearly distinguish between what you observe (symptoms) and why it happens (causes). Fixing symptoms without addressing causes leads to whack-a-mole debugging where bugs keep reappearing in different forms.

**Incorrect (treating symptom as cause):**

```python
# Symptom observed: NullPointerException on line 42

def process_user(user_id):
    user = get_user(user_id)
    # Fix: Add null check (treating symptom)
    if user is None:
        return None  # "Fixed" the crash
    return user.calculate_score()

# Problem: WHY was user None?
# - Invalid user_id passed?
# - Database connection failed?
# - Race condition in user creation?
# - Cache returned stale/deleted user?
# The null check hides the real problem
```

**Correct (investigate cause before fixing):**

```python
# Symptom observed: NullPointerException on line 42

def process_user(user_id):
    user = get_user(user_id)
    # Investigation: WHY is user None?
    if user is None:
        # Diagnostic logging to find root cause
        logger.error(f"User not found: {user_id}")
        logger.error(f"Called from: {traceback.format_stack()}")
        logger.error(f"DB connection status: {db.is_connected()}")
        logger.error(f"Cache status: {cache.get_stats()}")
        raise ValueError(f"User {user_id} not found - see logs for context")
    return user.calculate_score()

# Investigation revealed: user_id came from stale session data
# Real fix: Invalidate session when user is deleted
# Symptom (null user) and cause (stale session) are different
```

**Questions to separate symptoms from causes:**
- What did I observe? (Symptom)
- What could cause this observation? (Hypothesis)
- Is fixing this observation enough, or will the problem manifest elsewhere?
- If I prevent this symptom, does the underlying issue still exist?

**When NOT to use this pattern:**
- Simple bugs where symptom location IS the cause location
- Time-critical production fixes (but schedule root cause investigation)

Reference: [Root Cause Analysis Guide](https://www.techtarget.com/searchsoftwarequality/tip/How-to-handle-root-cause-analysis-of-software-defects)

### 1.6 State Expected vs Actual Behavior

**Impact: CRITICAL (Provides clear success criteria and prevents fixing the wrong thing)**

Explicitly define what should happen before investigating why it doesn't. Without clear expected behavior, you may "fix" code to match your assumptions rather than the actual requirements.

**Incorrect (vague problem statement):**

```javascript
// "The sort doesn't work right"

function sortUsers(users) {
  return users.sort((a, b) => a.name - b.name);  // Bug somewhere here?
}

// Developer "fixes" to:
return users.sort((a, b) => a.name.localeCompare(b.name));

// But wait - what was the EXPECTED behavior?
// - Sort by name alphabetically?
// - Sort by name case-insensitive?
// - Sort by last name, then first name?
// - Sort with numbers handled naturally (item2 before item10)?
// The fix might still be wrong!
```

**Correct (explicit expected vs actual):**

```javascript
// Expected behavior (from requirements):
// - Sort users by display name
// - Case-insensitive (Alice = alice)
// - Handle accented characters (Émile after Emily)
// - Null names sort last

// Actual behavior:
// - Sorts incorrectly: ["bob", "Alice", "émile"] → ["Alice", "bob", "émile"]
// - Should be: ["Alice", "bob", "émile"] (case-insensitive)
// - Also: null names cause crash instead of sorting last

// Clear specification for the fix:
function sortUsers(users) {
  return users.sort((a, b) => {
    // Handle nulls: sort last
    if (!a.name) return 1;
    if (!b.name) return -1;
    // Case-insensitive, locale-aware comparison
    return a.name.localeCompare(b.name, undefined, { sensitivity: 'base' });
  });
}

// Can verify fix matches ALL expected behaviors
```

**Template for stating expected vs actual:**
```markdown
**Expected:** [What should happen according to spec/requirements]
**Actual:** [What currently happens - be specific]
**Difference:** [The gap that needs to be fixed]
**Verification:** [How you'll confirm the fix works]
```

**When NOT to use this pattern:**
- Crashes and exceptions (expected = no crash)
- Performance issues (expected = meets performance target)

Reference: [Cornell CS312 - Debugging](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)

---

## 2. Hypothesis-Driven Search

**Impact: CRITICAL**

Scientific method approach with systematic hypothesis testing eliminates 80%+ of guesswork; binary search techniques halve the search space per iteration.

### 2.1 Apply the Scientific Method

**Impact: CRITICAL (Eliminates 80%+ of random debugging; provides systematic path to root cause)**

Debug like a scientist: observe, hypothesize, predict, test, conclude. This systematic approach eliminates guesswork and ensures you converge on the root cause rather than wandering aimlessly through code.

**Incorrect (random exploration):**

```python
# Bug: Users sometimes get wrong totals in shopping cart

def calculate_total(cart):
    total = 0
    for item in cart.items:
        total += item.price * item.quantity  # Check this
    return total + cart.shipping  # Or check this

# Developer starts adding random print statements
print(f"total: {total}")  # Looks right...
print(f"shipping: {cart.shipping}")  # Looks right...
# Adds more prints, removes some, changes code, reverts...
# 2 hours later: still confused, code is a mess
```

**Correct (scientific method):**

```python
# Bug: Users sometimes get wrong totals in shopping cart

# STEP 1: OBSERVE
# - Total is sometimes higher than expected
# - Happens with certain items, not all orders
# - Difference is always exactly one item's price

# STEP 2: HYPOTHESIZE
# Hypothesis 1: Item counted twice somewhere
# Hypothesis 2: Old cart data mixing with new
# Hypothesis 3: Currency conversion error

# STEP 3: PREDICT (for Hypothesis 1)
# If item is counted twice, the excess should equal
# exactly one item's price in the cart

# STEP 4: TEST
def calculate_total_debug(cart):
    seen_items = []
    total = 0
    for item in cart.items:
        if item.id in seen_items:
            print(f"DUPLICATE FOUND: {item.id}")  # Test prediction
        seen_items.append(item.id)
        total += item.price * item.quantity
    return total + cart.shipping

# STEP 5: CONCLUDE
# Test revealed: item.id appears twice when user clicks
# "Add to Cart" rapidly. Root cause: no debounce on button.
```

**Scientific debugging template:**
1. **Observe:** What exactly do you see? (symptoms, data, errors)
2. **Hypothesize:** What could cause this? (at least 2-3 options)
3. **Predict:** If hypothesis X is true, what else should be true?
4. **Test:** Design experiment to verify/falsify prediction
5. **Conclude:** Was hypothesis correct? Update understanding

**When NOT to use this pattern:**
- Trivial bugs where cause is immediately obvious
- Build/syntax errors with clear error messages

Reference: [MIT 6.031 - Scientific Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)

### 2.2 Explain the Problem Aloud (Rubber Duck)

**Impact: CRITICAL (Reveals gaps in understanding; 50%+ of bugs found during explanation)**

Explain your code and the bug to someone (or something) else, line by line. The act of verbalizing forces you to examine assumptions and often reveals the bug before you finish explaining.

**Incorrect (debugging silently in your head):**

```javascript
// Bug: Function returns wrong result
function calculateDiscount(price, quantity, memberLevel) {
  let discount = 0;
  if (quantity > 10) discount = 0.1;
  if (quantity > 50) discount = 0.2;
  if (memberLevel === 'gold') discount += 0.05;
  if (memberLevel === 'platinum') discount += 0.1;
  return price * quantity * discount;  // Stare at code...
}                                        // Looks right...

// Developer stares at code for 30 minutes
// "I don't see the bug..."
// Keeps re-reading the same lines
```

**Correct (explain to a rubber duck):**

```javascript
// Bug: Function returns wrong result
function calculateDiscount(price, quantity, memberLevel) {
  let discount = 0;

  // "OK duck, this function calculates the discounted price."
  // "First, discount starts at 0..."
  if (quantity > 10) discount = 0.1;
  // "If quantity is over 10, discount is 10%..."
  if (quantity > 50) discount = 0.2;
  // "If over 50, discount is 20%..."
  if (memberLevel === 'gold') discount += 0.05;
  // "Gold members get 5% extra..."
  if (memberLevel === 'platinum') discount += 0.1;
  // "Platinum gets 10% extra..."

  return price * quantity * discount;
  // "Then return price times quantity times discount..."
  // "Wait. That gives the DISCOUNT AMOUNT, not the final price!"
  // "It should be: price * quantity * (1 - discount)"
  // BUG FOUND IN 2 MINUTES
}
```

**Rubber duck debugging process:**
1. Get a rubber duck (or any object, or a colleague)
2. Explain what the code is SUPPOSED to do
3. Explain what it ACTUALLY does, line by line
4. Explain your data at each step
5. The bug usually reveals itself during explanation

**Why this works:**
- Forces you to slow down and be precise
- Exposes assumptions you didn't realize you were making
- Shifts perspective from "writer" to "explainer"
- Engages verbal reasoning alongside visual code reading

**When NOT to use this pattern:**
- Race conditions and timing bugs (hard to verbalize)
- Bugs in code you don't understand at all yet

Reference: [Rubber Duck Debugging](https://rubberduckdebugging.com/)

### 2.3 Find WHERE Before Asking WHAT

**Impact: CRITICAL (Location narrows problem space by 90%+; understanding comes faster with context)**

Focus first on locating exactly WHERE the bug occurs, not understanding WHAT the code does. Once you know the precise location, understanding the bug becomes much easier with the surrounding context.

**Incorrect (trying to understand everything):**

```typescript
// Bug: User subscription status is wrong
// Developer tries to understand the entire subscription system first

// "Let me read through all the subscription code..."
// subscription/types.ts (200 lines)
// subscription/service.ts (500 lines)
// subscription/webhook.ts (300 lines)
// subscription/sync.ts (400 lines)
// billing/integration.ts (600 lines)

// 3 hours later: "I understand how subscriptions work now"
// But still don't know where the bug is
```

**Correct (locate first, understand second):**

```typescript
// Bug: User subscription status is wrong
// Step 1: Find WHERE status becomes wrong

// Add checkpoints at system boundaries:
console.log('After webhook received:', status);       // CORRECT
console.log('After webhook processed:', status);      // CORRECT
console.log('After sync to database:', status);       // CORRECT
console.log('After read from database:', status);     // WRONG! <-- HERE

// Step 2: NOW narrow focus to this specific area
// Only need to understand: database write + read logic
// Read 50 lines instead of 2000

// Step 3: Understand just this section
async function getSubscriptionStatus(userId: string) {
  const cached = await cache.get(`sub:${userId}`);
  if (cached) return cached;  // BUG: Cache not invalidated on update!
  return await db.subscriptions.findOne({ userId });
}

// Found bug in 20 minutes by locating first
```

**WHERE-first debugging steps:**
1. Add coarse checkpoints at major boundaries (API, service, database)
2. Identify which section contains the bug
3. Add finer checkpoints within that section
4. Repeat until you find the exact line/function
5. NOW read and understand just that code

**The "traffic light" technique:**
```python
# Mark checkpoints with pass/fail status
print("🟢 Checkpoint A: data valid")     # Known good
print("🟡 Checkpoint B: checking...")    # Testing now
print("🔴 Checkpoint C: data corrupted")  # Known bad
# Bug is between 🟢 and 🔴
```

**When NOT to use this pattern:**
- Architectural/design bugs requiring broad understanding
- When you're new to the codebase and need context anyway

Reference: [Code with Jason - Binary Search Debugging](https://www.codewithjason.com/binary-search-debugging/)

### 2.4 Rule Out Obvious Causes First

**Impact: CRITICAL (60%+ of bugs have simple causes; checking obvious things first saves hours)**

Before diving deep, check common causes that explain most bugs. Many developers waste hours on complex investigations when the cause is a simple typo, wrong config, or stale cache.

**Incorrect (jumping to complex causes):**

```bash
# Bug: API returns 404 for endpoint that exists

# Developer assumes complex cause:
# "Must be a routing conflict or middleware issue..."
# Spends 2 hours debugging router configuration
# Checks middleware ordering
# Reviews authentication logic
# Adds extensive logging

# Finally runs: curl -v http://localhost:3000/api/users
# Response: "connection refused"
# Server wasn't running.
```

**Correct (check obvious causes first):**

```bash
# Bug: API returns 404 for endpoint that exists

# OBVIOUS CAUSES CHECKLIST (5 minutes max):

# 1. Is the server running?
curl -v http://localhost:3000/health
# ✗ Connection refused - START THE SERVER

# 2. Is the URL correct?
# Check for typos: /api/users vs /api/user vs /users

# 3. Is the method correct?
# POST vs GET vs PUT?

# 4. Is the environment correct?
# Dev vs staging vs prod URL?

# 5. Is the code deployed?
git status  # Uncommitted changes?
git log -1  # Is this the version you think it is?

# 6. Is there a cache involved?
# Browser cache? CDN cache? API cache?

# 7. Did you save the file?
# IDE might not have auto-saved

# 8. Is the config correct?
# Environment variables set? Config file loaded?
```

**The "stupid things" checklist (check first, always):**
1. Is it running? (server, service, database)
2. Is it the right environment? (dev/staging/prod)
3. Is the code saved and deployed?
4. Is there a cache to clear?
5. Are credentials/config correct?
6. Is there a typo in the name/path/URL?
7. Have you tried restarting it?
8. Are you testing the right thing?

**When NOT to use this pattern:**
- You've already verified the obvious causes
- The bug only appeared after a specific code change

Reference: [Debugging Best Practices](https://niveussolutions.com/debugging-techniques-best-practices/)

### 2.5 Test One Hypothesis at a Time

**Impact: CRITICAL (Prevents confounding variables; ensures you know which change fixed the bug)**

Change only one variable per experiment. Making multiple changes simultaneously prevents you from knowing which change had which effect, leading to false conclusions and unfixed bugs.

**Incorrect (multiple simultaneous changes):**

```python
# Bug: API returns 500 error intermittently

# Developer makes several "fixes" at once:
def get_user(user_id):
    try:
        # Change 1: Add timeout
        response = requests.get(url, timeout=30)
        # Change 2: Add retry logic
        if response.status_code != 200:
            response = requests.get(url, timeout=30)
        # Change 3: Add null check
        data = response.json()
        if data is None:
            return default_user
        # Change 4: Add caching
        cache.set(user_id, data)
        return data
    except Exception as e:
        # Change 5: Better error handling
        logger.error(f"Failed: {e}")
        return default_user

# Bug seems fixed... but WHICH change fixed it?
# What if changes 1, 2, 4, 5 are unnecessary overhead?
# What if change 3 is hiding a different bug?
```

**Correct (test one change at a time):**

```python
# Bug: API returns 500 error intermittently

# Original code (reproduce the bug first):
def get_user(user_id):
    response = requests.get(url)
    return response.json()

# Hypothesis 1: Request timeout causes 500
# Test: Add ONLY timeout, test multiple times
def get_user_v1(user_id):
    response = requests.get(url, timeout=30)  # Only change
    return response.json()
# Result: Still fails. Timeout is not the cause.

# Hypothesis 2: Server overloaded, needs retry
# Test: Add ONLY retry (revert timeout)
def get_user_v2(user_id):
    response = requests.get(url)
    if response.status_code == 500:
        time.sleep(1)
        response = requests.get(url)  # Only change
    return response.json()
# Result: Works! Retry after brief delay fixes it.

# Now you KNOW: Server needs brief cooldown between requests
# Can investigate WHY and fix properly, or add targeted retry
```

**Controlled experiment checklist:**
- Revert to known-broken state before each test
- Change exactly one thing
- Test thoroughly (multiple runs if intermittent)
- Document result before moving to next hypothesis
- Keep working changes, revert ineffective ones

**When NOT to use this pattern:**
- Emergency production fixes (fix first, understand later)
- When changes are clearly interdependent

Reference: [A Systematic Approach to Debugging](https://ntietz.com/blog/how-i-debug-2023/)

### 2.6 Use Binary Search to Localize Bugs

**Impact: CRITICAL (Reduces search space by 50% per iteration; finds bug in O(log n) steps)**

When you know a bug exists somewhere in a code path, use binary search to find it. Insert a checkpoint halfway through, determine which half contains the bug, and repeat. This finds bugs in O(log n) steps instead of O(n).

**Incorrect (linear search):**

```javascript
// Bug: Data is corrupted somewhere in this pipeline
function transformOrder(input) {
  const step1 = validate(input);      // Check here... OK
  const step2 = normalize(step1);     // Check here... OK
  const step3 = transform(step2);     // Check here... OK
  const step4 = enrich(step3);        // Check here... still looking...
  const step5 = format(step4);        // Check here...
  const step6 = compress(step5);      // Check here...
  const step7 = encrypt(step6);       // Check here...
  const step8 = serialize(step7);     // Found it!
  return step8;
}
// 8 checkpoints examined linearly = 8 iterations
```

**Correct (binary search):**

```javascript
// Bug: Data is corrupted somewhere in this 8-step pipeline
function transformOrder(input) {
  const step1 = validate(input);
  const step2 = normalize(step1);
  const step3 = transform(step2);
  const step4 = enrich(step3);

  console.log('Checkpoint (step 4):', isDataValid(step4));  // Iteration 1
  // Result: VALID - bug is in steps 5-8

  const step5 = format(step4);
  const step6 = compress(step5);

  console.log('Checkpoint (step 6):', isDataValid(step6));  // Iteration 2
  // Result: VALID - bug is in steps 7-8

  const step7 = encrypt(step6);

  console.log('Checkpoint (step 7):', isDataValid(step7));  // Iteration 3
  // Result: INVALID - bug is in step 7 (encrypt)

  const step8 = serialize(step7);
  return step8;
}
// 3 checkpoints examined with binary search = log2(8) = 3 iterations
```

**Binary search debugging process:**
1. Identify the range: first known-good point to first known-bad point
2. Test the midpoint
3. If midpoint is good, bug is in second half
4. If midpoint is bad, bug is in first half
5. Repeat until you've isolated the bug location

**For git history, use git bisect:**
```bash
git bisect start
git bisect bad HEAD          # Current is broken
git bisect good v1.0.0       # This version worked
# Git picks middle commit, test it, mark good/bad
# Finds culprit commit in log2(n) tests
```

**When NOT to use this pattern:**
- Non-deterministic bugs that don't reproduce reliably
- Bugs that depend on specific data only present at certain points

Reference: [Code with Jason - Binary Search Debugging](https://www.codewithjason.com/binary-search-debugging/)

---

## 3. Observation Techniques

**Impact: HIGH**

Proper logging, strategic breakpoints, and execution tracing reveal actual vs expected behavior without relying on assumptions or mental simulation.

### 3.1 Log Function Inputs and Outputs

**Impact: HIGH (Reveals data transformation issues; enables replay debugging)**

When debugging data issues, log what goes into and comes out of functions. This creates a data flow trace that reveals exactly where values become incorrect.

**Incorrect (logging inside function only):**

```javascript
function transformData(items) {
  console.log("transforming items");  // No actual data
  const result = items.map(item => ({
    id: item.id,
    total: item.price * item.qty,
    name: item.name.toUpperCase()
  }));
  console.log("transform complete");  // Still no data
  return result;
}

// Bug: Totals are wrong
// Logs tell you nothing about actual values
```

**Correct (log inputs and outputs):**

```javascript
function transformData(items) {
  // Log input with identifying info
  console.log("transformData INPUT:", JSON.stringify({
    count: items.length,
    sample: items[0],  // First item as example
    itemIds: items.map(i => i.id)
  }, null, 2));

  const result = items.map(item => ({
    id: item.id,
    total: item.price * item.qty,
    name: item.name.toUpperCase()
  }));

  // Log output with same structure
  console.log("transformData OUTPUT:", JSON.stringify({
    count: result.length,
    sample: result[0],
    totals: result.map(r => ({ id: r.id, total: r.total }))
  }, null, 2));

  return result;
}

// Output:
// transformData INPUT: {
//   "count": 3,
//   "sample": { "id": 1, "price": 10, "qty": "2", "name": "Widget" }
//                                           ^^^ String not number!
// transformData OUTPUT: {
//   "totals": [{ "id": 1, "total": NaN }]  // Reveals the bug
```

**Input/output logging patterns:**

```python
# Decorator pattern for automatic logging
def log_io(func):
    def wrapper(*args, **kwargs):
        logger.debug(f"{func.__name__} called", extra={
            "args": str(args)[:200],  # Truncate large data
            "kwargs": str(kwargs)[:200]
        })
        result = func(*args, **kwargs)
        logger.debug(f"{func.__name__} returned", extra={
            "result_type": type(result).__name__,
            "result_preview": str(result)[:200]
        })
        return result
    return wrapper

@log_io
def calculate_total(items):
    return sum(item.price * item.qty for item in items)
```

**When NOT to use this pattern:**
- Functions called thousands of times (performance impact)
- Functions with huge inputs/outputs (log summaries instead)
- Sensitive data (passwords, PII)

Reference: [Effective Debugging and Logging](https://www.datanovia.com/learn/programming/python/advanced/debugging-and-logging.html)

### 3.2 Read Stack Traces Bottom to Top

**Impact: HIGH (5-10× faster error localization; reveals full call chain context)**

Stack traces show the call chain with the most recent (and usually most relevant) frame at the bottom. Start reading from the bottom where the error occurred, then work up to understand how you got there.

**Incorrect (reading top to bottom):**

```python
Traceback (most recent call last):
  File "main.py", line 5, in <module>      # Start here? No!
    run_app()
  File "app.py", line 23, in run_app
    process_request(request)
  File "handler.py", line 45, in process_request
    data = parse_input(request.body)
  File "parser.py", line 12, in parse_input
    return json.loads(text)
  File "/usr/lib/python3/json/__init__.py", line 346
    raise JSONDecodeError(...)
json.decoder.JSONDecodeError: Expecting value: line 1 column 1

# Developer starts debugging main.py - wrong place!
```

**Correct (reading bottom to top):**

```python
Traceback (most recent call last):
  File "main.py", line 5, in <module>
    run_app()
  File "app.py", line 23, in run_app
    process_request(request)
  File "handler.py", line 45, in process_request
    data = parse_input(request.body)         # 3. Called parse_input
  File "parser.py", line 12, in parse_input  # 2. With what body?
    return json.loads(text)                   # 1. START HERE: json.loads failed
  File "/usr/lib/python3/json/__init__.py", line 346
    raise JSONDecodeError(...)
json.decoder.JSONDecodeError: Expecting value: line 1 column 1

# Reading bottom-to-top:
# 1. BOTTOM: JSONDecodeError on empty/invalid JSON
# 2. UP: In parse_input, calling json.loads(text)
# 3. UP: Called from process_request with request.body
# Question: What was request.body? Likely an empty string.
```

**Stack trace reading strategy:**

```text
BOTTOM (Error Location):
└── What exception? What message?
└── What line threw it?
└── What were the arguments?

MIDDLE (Your Code):
└── Find the topmost frame in YOUR code
└── This is usually where the bug actually is
└── Look at the data being passed

TOP (Entry Point):
└── How did we get here?
└── What triggered this code path?
└── Useful for understanding context
```

**Skip library frames, focus on your code:**

```python
# Look for frames in YOUR code, not libraries:
  File "parser.py", line 12, in parse_input  # <-- YOUR CODE
    return json.loads(text)
  File "/usr/lib/python3/json/__init__.py"   # <-- LIBRARY (skip)
```

**When NOT to use this pattern:**
- Errors in library code due to version bugs
- Stack traces truncated or missing

Reference: [Python Documentation - Traceback](https://docs.python.org/3/library/traceback.html)

### 3.3 Trace Data Flow Through the System

**Impact: HIGH (2-5× faster bug localization; pinpoints exact transformation that corrupts data)**

When data is incorrect, trace its journey through the system to find where it becomes corrupted. Add checkpoints at each transformation to see values before and after.

**Incorrect (guessing where corruption happens):**

```python
# Bug: Final price is wrong
# Developer checks random places, can't find issue

def handle_purchase(product_id, quantity, user):
    product = get_product(product_id)  # Check here
    price = calculate_price(product, quantity)  # Or here
    discount = get_discount(user)  # Or here
    final = apply_discount(price, discount)  # Or here
    return charge(user, final)  # Or here

# After 2 hours: still don't know where price goes wrong
```

**Correct (trace data through each stage):**

```python
# Bug: Final price is wrong
# Trace data through every transformation

def handle_purchase(product_id, quantity, user):
    product = get_product(product_id)
    print(f"[1] product.price = {product.price}")  # 29.99 ✓

    price = calculate_price(product, quantity)
    print(f"[2] price (qty={quantity}) = {price}")  # 59.98 ✓ (2 × 29.99)

    discount = get_discount(user)
    print(f"[3] discount = {discount}")  # 0.1 ✓ (10%)

    final = apply_discount(price, discount)
    print(f"[4] final = {final}")  # 5.998 ✗ WRONG!
                                   # Expected ~53.98, got 5.998
                                   # apply_discount is buggy!

    return charge(user, final)

# Found in 5 minutes: apply_discount does price*discount, not price*(1-discount)
```

**Data flow tracing template:**

```python
def trace_data(label, data):
    """Consistent checkpoint format"""
    print(f"[{label}] type={type(data).__name__}, value={data}")
    return data  # Pass through for chaining

# Usage:
result = trace_data("step1", fetch_data())
result = trace_data("step2", transform(result))
result = trace_data("step3", validate(result))
```

**For complex pipelines, create a flow diagram:**

```text
Input (correct)
    ↓
[Transform A] ✓
    ↓
[Transform B] ✓
    ↓
[Transform C] ✗ ← Bug is here
    ↓
Output (wrong)
```

**When NOT to use this pattern:**
- Bug is in control flow, not data
- Asynchronous flows where data trace is hard to follow

Reference: [Why Programs Fail - Tracking Origins](https://www.whyprogramsfail.com/)

### 3.4 Use Breakpoints Strategically

**Impact: HIGH (10× faster inspection than print statements; enables state exploration)**

Place breakpoints at decision points and state transitions, not randomly. Strategic breakpoints let you inspect program state interactively, enabling deeper exploration than static print statements.

**Incorrect (breakpoints everywhere):**

```python
def process_payment(order, payment_method):
    # Breakpoint here
    total = order.total
    # Breakpoint here
    tax = calculate_tax(total)
    # Breakpoint here
    final = total + tax
    # Breakpoint here
    result = charge_card(payment_method, final)
    # Breakpoint here
    if result.success:
        # Breakpoint here
        update_inventory(order)
        # Breakpoint here
        send_receipt(order)
    # Breakpoint here
    return result

# Developer hits F5/Continue 8 times, loses track of state
```

**Correct (strategic breakpoints):**

```python
def process_payment(order, payment_method):
    total = order.total
    tax = calculate_tax(total)
    final = total + tax

    # BREAKPOINT 1: Before external API call
    # Inspect: final, payment_method, order state
    result = charge_card(payment_method, final)

    # BREAKPOINT 2: After external call, before branching
    # Inspect: result.success, result.error, result.transaction_id
    if result.success:
        update_inventory(order)
        send_receipt(order)

    # BREAKPOINT 3: Before return (conditional)
    # Only hit if debugging return value issues
    return result
```

**Strategic breakpoint locations:**
1. **Before external calls** (APIs, database) - verify inputs
2. **After external calls** - verify responses
3. **At decision points** (if/switch) - understand branching
4. **Loop entry** - verify initial state
5. **After complex calculations** - verify results

**Power features to use:**

```python
# Conditional breakpoint (IDE dependent)
# Break only when: order.total > 1000

# Logpoint (print without stopping)
# Log: f"Processing order {order.id}, total={order.total}"

# Hit count breakpoint
# Break after 10 hits (useful for loops)

# Exception breakpoint
# Break when specific exception is raised
```

**When NOT to use this pattern:**
- Remote debugging where breakpoints cause timeouts
- Multi-threaded race conditions (breakpoints change timing)
- Production environments

Reference: [VS Code Debugging](https://code.visualstudio.com/docs/debugtest/debugging)

### 3.5 Use Strategic Logging Over Random Print Statements

**Impact: HIGH (5× faster bug localization; structured logs enable automated analysis)**

Replace scattered print statements with structured, leveled logging at strategic points. Good logging provides context, can be filtered, persists for analysis, and doesn't require removal before commit.

**Incorrect (random print statements):**

```python
def process_order(order):
    print("here1")  # Where? What?
    print(order)    # Raw dump, hard to parse
    user = get_user(order.user_id)
    print("got user")
    print(user)
    total = calculate_total(order)
    print(f"total is {total}")  # No context
    if total > 1000:
        print("big order!")
        discount = apply_discount(total)
        print(discount)  # Is this the discount or discounted total?
    result = save_order(order)
    print("done")
    return result

# Output:
# here1
# <Order object at 0x...>
# got user
# <User object at 0x...>
# total is 1250
# big order!
# 125
# done
# Which is which? Hard to read, no timestamp, can't filter
```

**Correct (strategic structured logging):**

```python
import logging

logger = logging.getLogger(__name__)

def process_order(order):
    logger.info("Processing order", extra={
        "order_id": order.id,
        "user_id": order.user_id,
        "item_count": len(order.items)
    })

    user = get_user(order.user_id)
    logger.debug("User retrieved", extra={
        "user_id": user.id,
        "member_level": user.member_level
    })

    total = calculate_total(order)
    logger.debug("Total calculated", extra={
        "order_id": order.id,
        "total": total,
        "currency": "USD"
    })

    if total > 1000:
        logger.info("Large order discount applied", extra={
            "order_id": order.id,
            "original_total": total,
            "discount_percent": 10
        })
        total = apply_discount(total)

    result = save_order(order)
    logger.info("Order processed successfully", extra={
        "order_id": order.id,
        "final_total": total
    })
    return result

# Output (JSON format, filterable, parseable):
# {"level": "INFO", "msg": "Processing order", "order_id": 123, ...}
# {"level": "DEBUG", "msg": "User retrieved", "user_id": 456, ...}
```

**Strategic logging placement:**
- Function entry/exit (INFO)
- Major decision points (DEBUG)
- External service calls (INFO with timing)
- Error conditions (ERROR with full context)
- State changes (DEBUG)

**When NOT to use this pattern:**
- Quick one-off investigation (print is fine)
- Performance-critical hot paths (logging has overhead)

Reference: [Advanced Debug Logging Techniques](https://www.infoworld.com/article/4060419/advanced-debug-logging-techniques-a-technical-guide.html)

### 3.6 Use Watch Expressions for Complex State

**Impact: HIGH (3-5× faster state tracking; auto-updates computed values on each step)**

Add watch expressions for computed values and relationships you need to monitor. Watches update automatically as you step through code, revealing exactly when values change unexpectedly.

**Incorrect (manually inspecting each time):**

```javascript
// Bug: Array index sometimes out of bounds
function processItems(items, startIndex) {
  for (let i = startIndex; i < items.length; i++) {
    // Manually type in debug console each step:
    // > items.length
    // > i
    // > i < items.length
    // > items[i]
    // Tedious and error-prone
    processItem(items[i]);
  }
}
```

**Correct (watch expressions):**

```javascript
// Bug: Array index sometimes out of bounds
function processItems(items, startIndex) {
  // Set up watch expressions in debugger:
  // Watch 1: items.length
  // Watch 2: i
  // Watch 3: i < items.length  (the loop condition)
  // Watch 4: items[i]          (current item)
  // Watch 5: items[i + 1]      (lookahead)

  for (let i = startIndex; i < items.length; i++) {
    processItem(items[i]);
    // As you step, watches update automatically:
    // Iteration 0: length=3, i=0, i<length=true, [i]=item0
    // Iteration 1: length=3, i=1, i<length=true, [i]=item1
    // Iteration 2: length=2, i=2, i<length=false <-- length changed!
    // Someone modified items during iteration
  }
}
```

**Useful watch expression patterns:**

```python
# Track object state
watch: user.__dict__
watch: len(items)
watch: type(response)

# Track computed values
watch: total - expected_total
watch: current_time - start_time

# Track relationships
watch: parent.children.includes(child)
watch: request.user.id == response.user_id

# Track conditions
watch: retry_count < max_retries
watch: buffer.length > threshold
```

**Watch expressions vs variables panel:**

| Variables Panel | Watch Expressions |
|-----------------|-------------------|
| Shows all local vars | Shows only what you care about |
| Can be overwhelming | Focused and relevant |
| Raw values only | Computed expressions |
| Updates on frame change | Updates on every step |

**When NOT to use this pattern:**
- Expressions with side effects (will execute every step!)
- Very expensive computations (slows debugging)

Reference: [VS Code Debugging - Watch](https://code.visualstudio.com/docs/debugtest/debugging#_watch)

---

## 4. Root Cause Analysis

**Impact: HIGH**

Finding true causes vs symptoms prevents recurring bugs; structured techniques like 5 Whys and cause-effect chains reach core issues systematically.

### 4.1 Examine System Boundaries

**Impact: HIGH (70%+ of bugs occur at boundaries; interfaces are high-risk areas)**

Most bugs occur at boundaries: between modules, services, systems, or data formats. When debugging, pay special attention to these interfaces where assumptions from one side may not match the other.

**Incorrect (ignoring boundaries):**

```python
# Bug: User data sometimes corrupted after save

# Developer examines UserService internal logic exhaustively
class UserService:
    def save_user(self, user):
        validated = self.validate(user)  # Checks this...
        normalized = self.normalize(validated)  # And this...
        return self.repository.save(normalized)  # Glances at this

# 4 hours later: "Internal logic is perfect, don't understand"
# Never examined the boundary with repository
```

**Correct (examine boundaries first):**

```python
# Bug: User data sometimes corrupted after save

class UserService:
    def save_user(self, user):
        validated = self.validate(user)
        normalized = self.normalize(validated)

        # BOUNDARY EXAMINATION: Service → Repository
        print("Sending to repository:", {
            "type": type(normalized).__name__,
            "data": normalized.__dict__
        })

        result = self.repository.save(normalized)

        # BOUNDARY EXAMINATION: Repository → Service
        print("Received from repository:", {
            "type": type(result).__name__,
            "data": result.__dict__ if result else None
        })

        return result

# Output reveals:
# Sending: {"name": "José García", "email": "jose@..."}
# Received: {"name": "Jos\u00e9 Garc\u00eda", "email": "jose@..."}
# BUG: Repository driver encoding issue at boundary!
```

**Common boundary types to examine:**

```text
┌─────────────────────────────────────────────────────────────┐
│  Frontend ←──────────────────────────────────→ API         │
│            • JSON serialization                             │
│            • Date format conversion                         │
│            • Type coercion (string→number)                  │
├─────────────────────────────────────────────────────────────┤
│  Service ←───────────────────────────────────→ Database    │
│            • ORM mapping                                    │
│            • Encoding/character sets                        │
│            • Null handling                                  │
├─────────────────────────────────────────────────────────────┤
│  Your Code ←─────────────────────────────────→ Library     │
│            • Version differences                            │
│            • Optional vs required params                    │
│            • Error handling conventions                     │
├─────────────────────────────────────────────────────────────┤
│  System ←────────────────────────────────────→ File/Network│
│            • Line endings (CRLF vs LF)                      │
│            • Timeouts                                       │
│            • Path formats                                   │
└─────────────────────────────────────────────────────────────┘
```

**When NOT to use this pattern:**
- Bug is clearly in pure business logic
- Single-module applications with few boundaries

Reference: [Cornell CS312 - Debugging](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)

### 4.2 Find the Last Known Good State

**Impact: HIGH (O(log n) regression detection via git bisect; establishes working baseline)**

Identify when the code last worked correctly. Comparing working vs broken states reveals what changed and caused the bug. This is especially effective for regressions.

**Incorrect (debugging without baseline):**

```bash
# Bug: "Search feature doesn't work"
# Developer looks at current code trying to find bug
# No reference point for what "working" looks like
# Hours of reading code without knowing what changed
```

**Correct (find last known good state):**

```bash
# Bug: "Search feature doesn't work"

# Step 1: When did it last work?
# "It worked last Tuesday, stopped working after Wednesday deploy"

# Step 2: Find the last working commit
git log --oneline --since="last Tuesday" --until="Wednesday"
# abc123 (Wednesday) Add search filters
# def456 (Tuesday) Update search index
# ghi789 (Tuesday) Fix search pagination  ← Last known working

# Step 3: Compare working vs broken
git diff ghi789 abc123 -- src/search/

# Step 4: The diff shows exactly what changed
# Found: Search filters broke when no filters selected
```

**Using git bisect for automated search:**

```bash
# Automated binary search through commits
git bisect start
git bisect bad HEAD                  # Current is broken
git bisect good ghi789              # Tuesday commit worked

# Git checks out middle commit, test it:
npm test -- --grep "search"
# If tests pass:
git bisect good
# If tests fail:
git bisect bad

# Repeat until:
# abc123 is the first bad commit
# This commit introduced the bug
```

**Finding last known good without git:**

```python
# Check different data states
working_data = load_from_backup("tuesday_backup.json")
broken_data = load_from_current()

# Compare
def compare_data(good, bad):
    for key in good:
        if good[key] != bad[key]:
            print(f"Difference in {key}:")
            print(f"  Good: {good[key]}")
            print(f"  Bad: {bad[key]}")

compare_data(working_data, broken_data)
```

**When NOT to use this pattern:**
- Bug existed since feature was created (no "good" state)
- Bug depends on external state that can't be reproduced

Reference: [Git Bisect](https://git-scm.com/docs/git-bisect)

### 4.3 Question Your Assumptions

**Impact: HIGH (Uncovers hidden bugs; 40%+ of debugging time is wasted on false assumptions)**

Explicitly list and verify your assumptions about how the code works. Many bugs hide behind incorrect assumptions that we never think to question.

**Incorrect (assuming code works as expected):**

```javascript
// Bug: Totals don't match between pages

function getOrderTotal(orderId) {
  const order = orders.get(orderId);
  return order.total;  // ASSUMPTION: order.total is always current

  // Developer assumes:
  // - orders.get() returns live data (but is it cached?)
  // - order.total is calculated (but is it stale?)
  // - total means the same thing everywhere (but is it pre-tax here?)
  // Spends hours looking at calculation logic when data is just stale
}
```

**Correct (verify assumptions):**

```javascript
// Bug: Totals don't match between pages

function getOrderTotal(orderId) {
  const order = orders.get(orderId);

  // Verify assumptions explicitly:
  console.log("ASSUMPTION CHECK:", {
    // Is orders.get() returning fresh data?
    "order from cache?": orders.isFromCache(orderId),

    // Is order.total calculated or stored?
    "total property type": typeof order.total,
    "has calculated total?": typeof order.calculateTotal === 'function',

    // What exactly is in total?
    "total value": order.total,
    "includes tax?": order.totalIncludesTax,

    // When was this order last updated?
    "last updated": order.updatedAt,
    "current time": new Date()
  });

  return order.total;
}

// Output reveals: order is cached, total is 2 hours stale
// BUG: Cache not invalidated on order updates
```

**Common assumptions to question:**

| Assumption | Reality Check |
|------------|---------------|
| "This function is called" | Add log to verify |
| "This value is always set" | Check for null/undefined |
| "This data is fresh" | Check timestamps, cache status |
| "These mean the same thing" | Compare definitions |
| "This config is correct" | Print actual config values |
| "This library works as documented" | Test in isolation |
| "This branch runs" | Add log at branch entry |
| "The order of execution is X" | Add sequence logs |

**When NOT to use this pattern:**
- Well-tested code with strong guarantees
- When assumptions are verified by type system

Reference: [A Systematic Approach to Debugging](https://ntietz.com/blog/how-i-debug-2023/)

### 4.4 Trace Fault Propagation Chains

**Impact: HIGH (2-3× faster root cause discovery; traces infection chain from symptom to origin)**

Bugs often manifest far from their origin. Trace the chain backward from where you see the symptom to where the fault was introduced. The infection (bad state) propagates until it causes a visible failure.

**Incorrect (fixing where symptom appears):**

```python
# Symptom: NullPointerException in render_profile()

def render_profile(user):
    # Symptom appears here
    return f"Welcome, {user.name}"  # NPE: user is None

# Developer adds null check here:
def render_profile(user):
    if user is None:
        return "Welcome, Guest"
    return f"Welcome, {user.name}"

# But WHY was user None? Bug still exists upstream!
```

**Correct (trace propagation backward):**

```python
# Symptom: NullPointerException in render_profile()

# Step 1: Where does user come from?
def handle_request(request):
    user = authenticate(request)  # Returns user or None
    return render_profile(user)

# Step 2: Why does authenticate return None?
def authenticate(request):
    token = request.headers.get('Authorization')
    if not token:
        return None  # No token → None user
    return verify_token(token)

# Step 3: Why is there no token?
# Traced to: Frontend forgot to include auth header after refresh

# Propagation chain:
# Missing header → authenticate returns None → render_profile crashes
#    (origin)            (propagation)              (symptom)

# REAL FIX: Frontend must include auth header
# DEFENSE: authenticate should raise AuthError, not return None
```

**Propagation chain diagram:**

```text
DEFECT (Origin)           INFECTION (Propagation)        FAILURE (Symptom)
┌─────────────────┐      ┌─────────────────────┐      ┌────────────────┐
│ Missing header  │ ───► │ user = None         │ ───► │ NPE in render  │
│ in frontend     │      │ passed around       │      │ (visible crash)│
└─────────────────┘      └─────────────────────┘      └────────────────┘
     Fix HERE            Don't just mask here         Not the root cause
```

**Tracing questions:**
1. Where did this bad value come from?
2. What function/module passed it here?
3. Where was it supposed to be set correctly?
4. What condition caused it to be wrong/missing?

**When NOT to use this pattern:**
- Single-location bugs (cause and symptom are same place)
- Bugs from external systems (trace ends at boundary)

Reference: [Why Programs Fail - Cause-Effect Chains](https://www.whyprogramsfail.com/)

### 4.5 Use the 5 Whys Technique

**Impact: HIGH (Reaches true root cause instead of surface symptoms; prevents recurrence)**

Ask "why" repeatedly (typically 5 times) to drill past symptoms to root causes. Each answer becomes the subject of the next question until you reach a cause you can actually fix permanently.

**Incorrect (stopping at first answer):**

```markdown
Problem: Users can't log in

Why? → The authentication service returns 500 errors
Fix: Restart the auth service

# Service restarted, works for a day, then fails again
# Never found out WHY it was returning 500s
```

**Correct (5 Whys to root cause):**

```markdown
Problem: Users can't log in

Why 1: The authentication service returns 500 errors
Why 2: The auth service runs out of database connections
Why 3: Connections are not being released after use
Why 4: A try/finally block is missing in the auth code
Why 5: The developer copied code from a tutorial that didn't include cleanup

ROOT CAUSE: Missing connection cleanup in auth module
ACTUAL FIX: Add proper connection release in finally block
PREVENTION: Add code review checklist item for resource cleanup
```

**5 Whys template:**

```markdown
## 5 Whys Analysis

**Problem Statement:** [Clear description of the bug]

**Why 1:** [First-level cause]
**Why 2:** [Why does Why 1 happen?]
**Why 3:** [Why does Why 2 happen?]
**Why 4:** [Why does Why 3 happen?]
**Why 5:** [Why does Why 4 happen?] ← Usually the root cause

**Root Cause:** [The fundamental issue to fix]
**Corrective Action:** [How to fix the root cause]
**Preventive Action:** [How to prevent similar issues]
```

**Tips for effective 5 Whys:**
- Don't accept "human error" as a cause - ask why the error was possible
- Multiple valid paths may exist - explore each branch
- Stop when you reach something actionable and preventable
- Include technical AND process causes

**When NOT to use this pattern:**
- Trivial bugs with obvious immediate causes
- Time-critical fixes (do 5 Whys afterward)
- When multiple independent factors combined

Reference: [Root Cause Analysis Guide](https://www.softwaretestinghelp.com/root-cause-analysis/)

---

## 5. Tool Mastery

**Impact: MEDIUM-HIGH**

Advanced debugger features like conditional breakpoints, watchpoints, and memory inspection provide 10× faster insight than print statement debugging.

### 5.1 Inspect Memory and Object State

**Impact: MEDIUM-HIGH (Catches 90%+ of reference vs value bugs; reveals prototype chain and hidden properties)**

Expand objects fully in the debugger to see their complete state. Shallow inspection misses nested problems, prototype issues, and non-enumerable properties.

**Incorrect (shallow inspection):**

```javascript
// Bug: Object comparison fails even though they "look equal"
const user1 = await getUser(id);
const user2 = await getUserFromCache(id);

console.log(user1);  // {name: "Alice", age: 30}
console.log(user2);  // {name: "Alice", age: 30}

if (user1 === user2) {  // false - WHY?
  // ...
}

// Shallow inspection shows same values, bug seems impossible
```

**Correct (deep object inspection):**

```javascript
// In debugger, expand objects fully:

user1 = {
  name: "Alice",
  age: 30,
  __proto__: Object.prototype,
  [[ObjectId]]: 12345        // ← Different reference!
}

user2 = {
  name: "Alice",
  age: 30,
  __proto__: Object.prototype,
  [[ObjectId]]: 67890        // ← Different reference!
}

// Also check hidden properties:
console.log(Object.getOwnPropertyDescriptors(user1));
// Reveals: writable, enumerable, configurable flags

console.log(user1.__proto__ === user2.__proto__);  // Check prototype

// Found it: They're different object instances
// Need to compare by value, not reference
```

**Deep inspection techniques:**

```python
# Python: Use vars() or __dict__
print(vars(user))
print(user.__dict__)
print(dir(user))  # All attributes including inherited

# Check type and class
print(type(user))
print(user.__class__.__mro__)  # Method resolution order

# For complex objects
import json
print(json.dumps(user.__dict__, indent=2, default=str))
```

**What to look for in object inspection:**

| Problem | What to Check |
|---------|---------------|
| Identity vs equality | Object IDs/references |
| Missing properties | Enumerable vs non-enumerable |
| Inheritance issues | Prototype chain |
| Lazy loading | Property getters, proxies |
| Circular references | Parent/child pointers |
| Type coercion | Actual types vs displayed values |

**When NOT to use this pattern:**
- Simple primitive values
- Performance profiling (use profiler instead)

Reference: [Chrome DevTools - Object Inspection](https://developer.chrome.com/docs/devtools/javascript/reference/#scope)

### 5.2 Master Step Over, Step Into, Step Out

**Impact: MEDIUM-HIGH (Efficient navigation through code; 5× faster than random stepping)**

Use the right stepping command to navigate efficiently. Step Into for suspicious functions, Step Over for trusted code, Step Out when you've seen enough. Random F10/F11 pressing wastes time.

**Incorrect (random stepping):**

```python
def process(data):
    validated = validate(data)      # F11 into 50-line function
    normalized = normalize(validated)  # F11 into another function
    result = transform(normalized)     # F11 again...
    return save(result)                # Lost in library code

# Developer presses F11 repeatedly, ends up deep in library internals
# Loses context of original debugging goal
```

**Correct (deliberate navigation):**

```python
def process(data):
    validated = validate(data)      # F10 - trust validation
    normalized = normalize(validated)  # F11 - suspicious, investigate
    # ... inside normalize, find issue ...
    # Shift+F11 - step out, back to process()
    result = transform(normalized)     # F10 - trust transform
    return save(result)                # F11 - check save behavior
```

**Stepping commands reference:**

| Action | VS Code | PyCharm | Chrome | Purpose |
|--------|---------|---------|--------|---------|
| Step Over | F10 | F8 | F10 | Execute line, don't enter functions |
| Step Into | F11 | F7 | F11 | Enter function on current line |
| Step Out | Shift+F11 | Shift+F8 | Shift+F11 | Run to end of current function |
| Continue | F5 | F9 | F8 | Run to next breakpoint |
| Run to Cursor | Ctrl+F10 | Alt+F9 | -- | Run to specific line |

**When to use each:**

```python
def process_order(order):
    # Step OVER (F10): Library/utility calls you trust
    logger.info(f"Processing {order.id}")  # Trust logging
    validated = validate(order)  # Trust validation (if working)

    # Step INTO (F11): Suspicious or unfamiliar code
    total = calculate_total(order)  # Bug might be here
    discount = apply_discount(total)  # Or here

    # Step OUT (Shift+F11): When you've seen enough
    # Inside apply_discount, realize bug is elsewhere
    # Step out to return to process_order

    # Run to CURSOR: Skip to specific point
    # Set cursor at return statement, run directly there
    return finalize(order, total - discount)
```

**When NOT to use this pattern:**
- Async code (stepping can be unpredictable)
- Multi-threaded code (other threads keep running)

Reference: [Chrome DevTools Debugging](https://developer.chrome.com/docs/devtools/javascript/reference/)

### 5.3 Navigate the Call Stack

**Impact: MEDIUM-HIGH (3× faster context discovery; reveals parameter values at each call level)**

Use the call stack panel to move up and down the execution chain. Each frame shows local variables at that point, helping you understand how you reached the current state.

**Incorrect (only looking at current frame):**

```python
# Debugger stopped in deep function
def calculate_tax(amount, rate):
    # Breakpoint here
    return amount * rate  # rate is 0.25, but should be 0.08?

# Developer wonders: "Where did 0.25 come from?"
# Only looks at this function, can't see caller context
```

**Correct (navigate call stack):**

```python
# Call Stack shows:
#   calculate_tax        ← Current frame (bottom)
#   apply_pricing
#   process_line_item
#   process_order
#   handle_request       ← Entry point (top)

# Click on apply_pricing frame to see:
def apply_pricing(item, region):
    rate = get_tax_rate(region)  # rate = 0.25 for "EU" region
    return calculate_tax(item.price, rate)

# Click on process_line_item to see:
def process_line_item(item, order):
    region = order.shipping_region  # region = "EU" (wrong!)
    return apply_pricing(item, region)

# Found it! shipping_region should be billing_region for tax
```

**Call stack navigation techniques:**

```text
┌─────────────────────────────────────────────┐
│ Call Stack                                  │
├─────────────────────────────────────────────┤
│ ► calculate_tax (current)     ← Click here  │
│   apply_pricing               ← Or here     │
│   process_line_item           ← Or here     │
│   process_order                             │
│   handle_request                            │
└─────────────────────────────────────────────┘

Clicking a frame shows:
- Local variables at that point
- Line where next function was called
- Parameter values passed to called function
```

**Questions answered by call stack:**
- How did execution reach this point?
- What parameters were passed at each level?
- What were local variables in parent functions?
- Where should I set breakpoints to catch this earlier?

**When NOT to use this pattern:**
- Recursion with 1000+ frames (hard to navigate)
- Async callbacks (stack may not show full context)

Reference: [VS Code Call Stack](https://code.visualstudio.com/docs/debugtest/debugging#_call-stack)

### 5.4 Use Conditional Breakpoints

**Impact: MEDIUM-HIGH (100× faster than hitting breakpoint manually in loops; targets exact conditions)**

Set breakpoints that only trigger when specific conditions are met. This lets you break on the exact iteration or data condition that causes the bug, without manually stepping through irrelevant cases.

**Incorrect (regular breakpoint in loop):**

```python
# Bug: One user out of 10,000 has incorrect balance

def calculate_balances(users):
    for user in users:
        balance = compute_balance(user)  # Breakpoint here
        user.balance = balance

# Hit F5/Continue 5,000+ times to find problematic user
# Or accidentally step past it and have to restart
```

**Correct (conditional breakpoint):**

```python
# Bug: One user out of 10,000 has incorrect balance

def calculate_balances(users):
    for user in users:
        balance = compute_balance(user)
        # Conditional breakpoint: user.id == "user_5432"
        # Or: balance < 0
        # Or: user.name == "John Doe"
        user.balance = balance

# Breakpoint only triggers for the specific problematic user
# Goes directly to the bug in 1 step
```

**Setting conditional breakpoints by IDE:**

```text
VS Code:
1. Right-click breakpoint → "Edit Breakpoint"
2. Enter expression: user.id === "user_5432"

PyCharm/IntelliJ:
1. Right-click breakpoint → "Edit Breakpoint"
2. Check "Condition" and enter: user.id == "user_5432"

Chrome DevTools:
1. Right-click line number → "Add conditional breakpoint"
2. Enter: user.id === "user_5432"
```

**Useful condition patterns:**

```javascript
// Stop on specific value
user.id === "user_5432"

// Stop on error conditions
balance < 0 || isNaN(balance)

// Stop on iteration count
i > 100 && i < 110  // Check iterations 101-109

// Stop on state change
previousValue !== currentValue

// Stop on null/undefined
data === null || data === undefined

// Stop on array conditions
items.length > 1000
```

**When NOT to use this pattern:**
- Condition evaluation is expensive (slows execution)
- You don't know the exact condition to target yet

Reference: [VS Code Debugging](https://code.visualstudio.com/docs/debugtest/debugging#_conditional-breakpoints)

### 5.5 Use Exception Breakpoints

**Impact: MEDIUM-HIGH (5× faster exception debugging; catches errors at throw point with full context)**

Configure the debugger to break when exceptions are thrown, not just when they're caught. This stops execution at the exact moment of failure, showing the complete state before error handling obscures it.

**Incorrect (only seeing caught exception):**

```python
try:
    result = process_complex_data(data)
except Exception as e:
    logger.error(f"Processing failed: {e}")  # Only see: "KeyError: 'user'"
    return None

# Exception message gives location but not context
# What was data? What was the full state at failure?
```

**Correct (exception breakpoint at throw point):**

```python
# Enable "Break on All Exceptions" in debugger

def process_complex_data(data):
    users = data.get('users', [])
    for user in users:
        # DEBUGGER STOPS HERE on the KeyError
        # Can inspect: user = {'name': 'Alice'}, has no 'id' key
        # Can see full data, full users list, loop index
        name = user['name']
        id = user['id']  # KeyError thrown here!

# Now you see:
# - Exactly which user dict was malformed
# - Index in list where it occurred
# - Full context of surrounding data
```

**Setting exception breakpoints by IDE:**

```text
VS Code (Python):
1. Debug sidebar → Breakpoints section
2. Check "Raised Exceptions" or "Uncaught Exceptions"

VS Code (JavaScript):
1. Debug sidebar → Breakpoints section
2. Check "Caught Exceptions" and/or "Uncaught Exceptions"

Chrome DevTools:
1. Sources panel → Breakpoints sidebar
2. Check "Pause on caught exceptions"

PyCharm:
1. Run → View Breakpoints
2. Python Exception Breakpoints → Add specific exceptions
```

**Types of exception breakpoints:**

| Type | Use When |
|------|----------|
| Uncaught only | Production debugging, avoid noise |
| All exceptions | Finding swallowed errors |
| Specific exception | Known error type to investigate |
| Conditional | Exception meets certain criteria |

**When NOT to use this pattern:**
- Library throws many expected exceptions (too noisy)
- Error handling is the thing being debugged

Reference: [VS Code Exception Breakpoints](https://code.visualstudio.com/docs/debugtest/debugging#_exception-breakpoints)

### 5.6 Use Logpoints Instead of Modifying Code

**Impact: MEDIUM-HIGH (100% clean commits; zero risk of shipping debug statements to production)**

Modern debuggers support logpoints (tracepoints) that print messages without modifying source code. This eliminates the risk of committing debug code and doesn't require recompilation.

**Incorrect (adding print statements):**

```python
def process_order(order):
    print(f"DEBUG: order = {order}")  # Added manually
    total = calculate_total(order)
    print(f"DEBUG: total = {total}")  # Added manually
    discount = apply_discount(total, order.user)
    print(f"DEBUG: discount = {discount}")  # Added manually
    return finalize(order, discount)

# Risks:
# - Might commit debug prints to production
# - Have to rebuild/restart after changes
# - Pollutes version control history
# - Easy to forget to remove
```

**Correct (logpoints via debugger):**

```python
def process_order(order):
    # LOGPOINT: "order = {order}"  (set in IDE, not in code)
    total = calculate_total(order)
    # LOGPOINT: "total = {total}"  (set in IDE, not in code)
    discount = apply_discount(total, order.user)
    # LOGPOINT: "discount = {discount}"  (set in IDE, not in code)
    return finalize(order, discount)

# Benefits:
# - No code changes
# - No rebuild needed
# - Nothing to commit/forget
# - Easy to add/remove
```

**Setting logpoints by IDE:**

```text
VS Code:
1. Right-click line → "Add Logpoint"
2. Enter message: "total = {total}, user = {order.user.name}"
3. Logpoint appears as diamond-shaped marker

PyCharm:
1. Click breakpoint → Properties
2. Check "Log message to console"
3. Uncheck "Suspend execution"

Chrome DevTools:
1. Right-click line → "Add logpoint"
2. Enter expression to log
```

**Logpoint expression patterns:**

```javascript
// Simple value logging
"Processing order: {order.id}"

// Multiple values
"User {user.id} balance: {balance}, status: {status}"

// Computed expressions
"Items count: {items.length}, first: {items[0]?.name}"

// Conditional messages (VS Code)
"Large order!" // With condition: order.total > 1000
```

**When NOT to use this pattern:**
- Need permanent logging for production monitoring
- Debugging without IDE (remote, production)

Reference: [VS Code Logpoints](https://code.visualstudio.com/docs/debugtest/debugging#_logpoints)

---

## 6. Bug Triage and Classification

**Impact: MEDIUM**

Proper severity and priority classification ensures development resources focus on highest-impact issues. Distinguish technical severity from business priority to make informed decisions.

### 6.1 Assess User Impact Before Prioritizing

**Impact: MEDIUM (10× improvement in value delivered per engineering hour)**

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

## 8. Fix Verification

**Impact: MEDIUM**

Confirming fixes actually resolve the root cause and don't introduce regressions prevents bug ping-pong and ensures permanent resolution.

### 8.1 Add a Test to Prevent Recurrence

**Impact: MEDIUM (100% regression prevention for this specific bug; serves as executable documentation)**

After fixing a bug, add an automated test that reproduces the original failure. This prevents the bug from being reintroduced and documents the expected behavior.

**Incorrect (fix without test):**

```python
# Bug: Empty usernames allowed during registration
# Fix: Add validation

def register_user(username, password):
    if not username or not username.strip():
        raise ValueError("Username required")  # Fix added
    # ... rest of registration

# Fix committed, no test added
# 6 months later: Developer refactors validation
# Empty usernames allowed again
# No one notices until user reports
```

**Correct (fix with test):**

```python
# Bug: Empty usernames allowed during registration
# Fix: Add validation

def register_user(username, password):
    if not username or not username.strip():
        raise ValueError("Username required")
    # ... rest of registration

# Test added for this specific bug:
class TestUserRegistration:
    """Regression test for bug #1234: Empty username crash"""

    def test_empty_username_rejected(self):
        """Empty username should raise ValueError"""
        with pytest.raises(ValueError, match="Username required"):
            register_user("", "password123")

    def test_whitespace_username_rejected(self):
        """Whitespace-only username should raise ValueError"""
        with pytest.raises(ValueError, match="Username required"):
            register_user("   ", "password123")

    def test_none_username_rejected(self):
        """None username should raise ValueError"""
        with pytest.raises(ValueError, match="Username required"):
            register_user(None, "password123")

# Now if anyone removes or breaks the validation:
# test_empty_username_rejected FAILED
# Regression caught immediately
```

**Test naming convention for bug fixes:**

```python
# Include bug/ticket reference
def test_issue_1234_empty_username():
    """Regression: Empty username allowed (issue #1234)"""

# Or describe the failure scenario
def test_registration_rejects_empty_username():
    """Bug fix: Registration must reject empty usernames"""
```

**What the test should cover:**
- Exact reproduction of original bug
- Edge cases discovered during debugging
- Related scenarios that might have same issue
- Error messages/codes that help future debugging

**When NOT to use this pattern:**
- Bug was in one-time migration or script
- Test would be extremely complex/slow for minimal value

Reference: [Test-Driven Development by Example](https://www.oreilly.com/library/view/test-driven-development/0321146530/)

### 8.2 Check for Regressions After Fixing

**Impact: MEDIUM (Prevents fix from breaking existing functionality; catches unintended side effects)**

After fixing a bug, run the full test suite and manually verify related features. Fixes can inadvertently break other functionality that depended on the buggy behavior.

**Incorrect (only testing the fix):**

```python
# Bug: discount not applied to premium users
# Fix: Change user type check

def apply_discount(user, amount):
    # Old (buggy): if user.type == "premium"
    if user.is_premium:  # Fixed
        return amount * 0.9
    return amount

# Developer tests: premium user gets discount - PASS
# Ships fix
# Customer reports: VIP users no longer get free shipping
# VIP logic depended on user.type == "premium" being false for VIPs
```

**Correct (regression check):**

```python
# Bug: discount not applied to premium users
# Fix: Change user type check

def apply_discount(user, amount):
    if user.is_premium:  # Fixed
        return amount * 0.9
    return amount

# Verification steps:
# 1. Original bug fixed:
#    ✓ Premium user gets 10% discount

# 2. Run related tests:
#    ✓ Standard user: no discount
#    ✓ Premium user: 10% discount
#    ✗ VIP user: lost free shipping! (REGRESSION)

# 3. Investigate: VIP logic was coupled to this code
# 4. Update fix to handle VIP correctly:

def apply_discount(user, amount):
    if user.is_premium and not user.is_vip:
        return amount * 0.9
    return amount
```

**Regression check strategies:**

```bash
# Run full test suite
npm test

# Run tests related to changed files
npm test -- --findRelatedTests src/discount.js

# Run smoke tests on core flows
npm run test:smoke

# Manual verification of related features
# - List all features that touch modified code
# - Test each one manually
```

**What to check for regressions:**
- Features that call the fixed code
- Features that share data with the fixed code
- Features that run before/after the fixed code
- Edge cases that might depend on the old behavior

**When NOT to use this pattern:**
- Trivial fixes with no dependencies (typos, comments)
- New code with no existing dependents

Reference: [Software Testing Help - Regression Testing](https://www.softwaretestinghelp.com/regression-testing-tools-and-methods/)

### 8.3 Understand Why the Fix Works

**Impact: MEDIUM (Prevents cargo cult fixes; ensures fix is correct, not accidental)**

Don't just verify that a fix makes the bug disappear—understand WHY it works. Fixes that work by accident may fail in other conditions or mask deeper issues.

**Incorrect (cargo cult fix):**

```python
# Bug: API returns 500 error intermittently

# Developer tries random things:
response = requests.get(url)
time.sleep(0.1)  # Added this, seems to fix it?
data = response.json()

# "I don't know why, but adding a sleep fixed it"
# Commits the fix
# Bug returns under higher load
# The sleep was just masking a race condition
```

**Correct (understand the fix):**

```python
# Bug: API returns 500 error intermittently

# Investigation:
# - 500 errors correlate with high request rates
# - Server logs show "connection pool exhausted"
# - Connections not being released properly

# Root cause: Missing connection cleanup in error path
response = requests.get(url)
try:
    data = response.json()
except Exception as e:
    response.close()  # Was missing - connections leaked on error!
    raise

# Understanding:
# 1. WHY it failed: Connections leaked when JSON parsing failed
# 2. WHY fix works: Explicit close releases connection back to pool
# 3. WHY sleep "worked": Gave leaked connections time to timeout
# 4. WHY sleep wasn't real fix: High load would still exhaust pool

# Verified understanding:
# - Can explain to colleague why this fixes it
# - Can predict when old behavior would recur
# - Can identify other code paths with same issue
```

**Questions to confirm understanding:**
1. Can you explain the bug's root cause?
2. Can you explain why your fix addresses that cause?
3. Can you predict what would happen without the fix?
4. Could there be other code paths with the same issue?
5. Would a simpler fix work? A more thorough one?

**Red flags of accidental fixes:**
- "I don't know why, but it works now"
- Fix involves adding delays/retries without understanding why
- Fix is much more complex than the problem
- Similar bugs keep appearing elsewhere

**When NOT to use this pattern:**
- Time-critical production issues (understand later)
- Third-party library bugs (can't always understand internals)

Reference: [MIT 6.031 - Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)

### 8.4 Verify Fix With Original Reproduction

**Impact: MEDIUM (Confirms fix actually works; prevents false confidence from unrelated changes)**

After implementing a fix, re-run the exact reproduction steps that originally triggered the bug. A fix isn't confirmed until the original failure case passes.

**Incorrect (assuming fix works):**

```python
# Original bug: crash when saving empty file
# Developer adds null check, assumes it's fixed

def save_file(content):
    if content is None:  # Added fix
        content = ""
    write_to_disk(content)

# Developer runs unrelated test: "test_save_normal_file" - passes
# Marks bug as fixed
# User reports: still crashes on empty files
# Developer's fix handles None but original bug was empty string ""
```

**Correct (verify with original reproduction):**

```python
# Original bug reproduction:
# 1. Open app
# 2. Create new file
# 3. Don't type anything
# 4. Click Save
# 5. CRASH

def save_file(content):
    if not content:  # Fixed: handles None AND empty string
        content = ""
    write_to_disk(content)

# Verification:
# 1. Run EXACT original reproduction steps:
#    - Open app
#    - Create new file
#    - Don't type anything (content is "")
#    - Click Save
# 2. PASS - no crash
# 3. Also verify edge cases:
#    - content = None
#    - content = "   " (whitespace only)
#    - content = valid text
```

**Verification checklist:**
- [ ] Can you still reproduce the bug without the fix?
- [ ] Does the fix prevent the original reproduction?
- [ ] Do related scenarios still work?
- [ ] Are there edge cases of the same bug?
- [ ] Did you test on the same environment as the original report?

**When NOT to use this pattern:**
- Bug was caused by transient external factor (already gone)
- Reproduction requires specific hardware/environment you don't have

Reference: [Why Programs Fail - Fixing the Defect](https://www.whyprogramsfail.com/)

---

## 9. Anti-Patterns

**Impact: MEDIUM**

Recognizing and avoiding shotgun debugging, quick patches, assumption traps, and other counterproductive habits saves hours of wasted effort.

### 9.1 Avoid Blaming the Tool Too Quickly

**Impact: MEDIUM (95%+ of bugs are in your code, not libraries; premature blame wastes time)**

When debugging, assume the bug is in your code, not in the framework, library, or language. While tools do have bugs, they're far less common than bugs in application code. Blaming the tool prematurely stops productive investigation.

**Incorrect (blaming the tool):**

```javascript
// Bug: Data not saving correctly
// Developer's conclusion: "React useState must be broken"

const [user, setUser] = useState(null);

const updateUser = (newData) => {
  setUser(newData);
  console.log(user);  // Still shows old value!
  // "useState is broken, it's not updating!"
  // Files bug report against React
  // Spends hours searching for React bugs
};

// Actual issue: React state updates are asynchronous
// Developer didn't understand the tool, not a tool bug
```

**Correct (assume it's your code):**

```javascript
// Bug: Data not saving correctly
// Hypothesis: My usage of useState is incorrect

const [user, setUser] = useState(null);

const updateUser = (newData) => {
  setUser(newData);
  console.log(user);  // Shows old value

  // Question: Is this expected behavior?
  // Check React documentation on useState...
  // Found: "setState doesn't immediately mutate state"

  // Understanding: useState is working correctly
  // My expectation was wrong

  // Fix: Use callback for immediate value, or useEffect for side effects
  setUser(newData);
  console.log(newData);  // Use newData directly

  // Or:
  useEffect(() => {
    if (user) {
      console.log('User updated:', user);
    }
  }, [user]);
};
```

**Before blaming the tool, verify:**
1. Did you read the documentation?
2. Does a minimal example reproduce the issue?
3. Can you find others with the same "bug"?
4. Is your version up to date?
5. Are you using the API correctly?
6. Have you isolated the issue from your application code?

**When tool bugs are actually likely:**
- Minimal reproduction in isolation still fails
- Issue documented in tool's bug tracker
- Using edge case or new/deprecated feature
- Multiple independent developers report same issue
- Worked before tool version update

**When NOT to use this pattern:**
- You've verified correct usage through documentation
- Minimal reproduction clearly shows tool issue
- Tool's bug tracker confirms the issue

Reference: [MIT 6.031 - Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)

### 9.2 Avoid Quick Patches Without Understanding

**Impact: MEDIUM (Prevents technical debt and recurring bugs; quick fixes often mask real problems)**

Don't apply quick fixes that mask symptoms without understanding the root cause. These create technical debt, hide real problems, and often lead to worse failures later.

**Incorrect (quick patch):**

```python
# Bug: Occasional NullPointerException in process_order

def process_order(order):
    # Quick patch: Just check for None everywhere
    if order is None:
        return None
    if order.user is None:
        return None
    if order.items is None:
        return None

    total = sum(item.price for item in order.items if item is not None)
    if total is None:  # Can't even be None but added anyway
        return None

    return charge_user(order.user, total)

# Symptoms hidden, but:
# - WHY was order None? Still happening somewhere
# - WHY was order.user None? Data corruption? Race condition?
# - These None returns silently fail, no alerts
# - Real bug continues causing data inconsistencies
```

**Correct (understand then fix):**

```python
# Bug: Occasional NullPointerException in process_order

# Step 1: Investigate why order was None
# Added logging: "order is None when called from webhook handler"
# Found: Webhook sends order_id, not order object

# Step 2: Fix at the source
def handle_webhook(data):
    order_id = data.get('order_id')
    if not order_id:
        logger.error("Webhook missing order_id", extra={"data": data})
        raise ValueError("order_id required")

    order = Order.query.get(order_id)
    if not order:
        logger.error(f"Order not found: {order_id}")
        raise ValueError(f"Order {order_id} not found")

    return process_order(order)  # Now guaranteed to have valid order

def process_order(order):
    # No defensive checks needed - contract enforced by caller
    total = sum(item.price for item in order.items)
    return charge_user(order.user, total)
```

**Quick patch red flags:**
- Adding try/except that catches and ignores all exceptions
- Adding null checks everywhere without investigating why nulls occur
- Adding retries without understanding what fails
- Suppressing warning/error logs instead of fixing cause

**When quick patches are acceptable:**
- Critical production issue (patch now, investigate later)
- Third-party bug you can't fix (document and work around)
- Truly defensive code at system boundaries

**Always follow up:**
- Create ticket to investigate root cause
- Schedule time to properly fix after stabilization
- Add monitoring to catch if symptom returns

Reference: [Root Cause Analysis](https://www.techtarget.com/searchsoftwarequality/tip/How-to-handle-root-cause-analysis-of-software-defects)

### 9.3 Avoid Shotgun Debugging

**Impact: MEDIUM (Prevents hours of wasted effort; random changes make bugs harder to find)**

Don't make random changes hoping something will fix the bug. Shotgun debugging wastes time, introduces new bugs, and makes the codebase harder to understand. Each change should test a specific hypothesis.

**Incorrect (shotgun debugging):**

```python
# Bug: User registration fails

def register_user(data):
    # Try adding a sleep
    time.sleep(0.5)

    # Try encoding fix
    data = data.encode('utf-8').decode('utf-8')

    # Try null check
    if data is None:
        data = {}

    # Try lowercase
    data['email'] = data.get('email', '').lower()

    # Try adding retry
    for attempt in range(3):
        try:
            return create_user(data)
        except:
            pass

    # None of this is based on understanding the actual bug
    # Code is now a mess, might work by accident
```

**Correct (hypothesis-driven debugging):**

```python
# Bug: User registration fails

# Step 1: What exactly is failing?
# Error: "IntegrityError: duplicate key email"

# Step 2: Hypothesis: Email uniqueness check is case-sensitive
# Test: Check if different-case duplicate exists
existing = User.query.filter_by(email=data['email'].lower()).first()
print(f"Existing user with email: {existing}")  # Found "ALICE@example.com"

# Step 3: Confirmed hypothesis - make targeted fix
def register_user(data):
    email = data.get('email', '').lower()  # Normalize case
    if User.query.filter_by(email=email).first():
        raise ValueError("Email already registered")
    return create_user({**data, 'email': email})
```

**Signs of shotgun debugging:**
- Adding code without knowing why
- Trying multiple "fixes" at once
- Changes are reverted frequently
- Comments like "not sure why this works"
- Copy-pasting solutions from Stack Overflow without understanding

**Alternative approach:**
1. Stop and reproduce the bug cleanly
2. Form a hypothesis about the cause
3. Design a test for that hypothesis
4. Make ONE change based on results
5. Repeat until bug is found

**When shotgun debugging seems tempting:**
- Take a break - you're likely frustrated
- Explain the problem to someone (rubber duck)
- Write down what you've tried and results
- Start fresh with systematic approach

Reference: [Why Programs Fail](https://www.whyprogramsfail.com/)

### 9.4 Avoid Tunnel Vision on Initial Hypothesis

**Impact: MEDIUM (Prevents wasted hours pursuing wrong theory; 30%+ of bugs aren't where we first look)**

Don't get stuck on your first guess about where the bug is. If evidence doesn't support your hypothesis, let it go and consider alternatives. Confirmation bias makes us see evidence that supports our theory and ignore evidence against it.

**Incorrect (tunnel vision):**

```python
# Bug: Slow page load
# Developer's hypothesis: "Database is slow"

# Spends 3 hours:
# - Adding database indexes
# - Optimizing queries
# - Enabling query caching
# - Profiling database
# Database performance improved 50%, but page still slow

# Evidence ignored:
# - API response time was <100ms in browser network tab
# - Slow load happened even on cache-hit pages
# - JavaScript bundle was 5MB (not checked)

# Actual cause: Unoptimized JavaScript, not database
```

**Correct (open to alternatives):**

```python
# Bug: Slow page load
# Initial hypothesis: "Database is slow"

# Test hypothesis 1: Database
# - Add timing logs: database query = 50ms ✓ Fast
# - Conclusion: Not the database

# Hypothesis falsified! Generate new hypotheses:
# - API processing time?
# - Network latency?
# - Frontend rendering?
# - JavaScript bundle size?

# Test hypothesis 2: API processing
# - Total API time = 80ms ✓ Fast
# - Conclusion: Not the backend

# Test hypothesis 3: Frontend
# - Network tab shows: 5MB JavaScript bundle
# - Parse/execute time: 3 seconds
# - Conclusion: Found it! Unoptimized frontend bundle

# Fixed by code splitting and lazy loading
```

**Signs of tunnel vision:**
- Spending hours on one area without progress
- Ignoring contradictory evidence
- Thinking "it HAS to be here"
- Not considering other possibilities
- Defensive when others suggest alternatives

**Breaking out of tunnel vision:**
1. Set a time limit for each hypothesis (e.g., 30 minutes)
2. Write down ALL possible causes before investigating
3. List evidence FOR and AGAINST your current theory
4. Ask someone else to suggest alternatives
5. Take a break and return with fresh eyes

**When NOT to use this pattern:**
- Strong evidence points to specific location
- You've methodically eliminated other possibilities

Reference: [A Systematic Approach to Debugging](https://ntietz.com/blog/how-i-debug-2023/)

### 9.5 Recognize and Address Debugging Fatigue

**Impact: MEDIUM (Prevents stupid mistakes from tiredness; fresh perspective finds bugs faster)**

Long debugging sessions lead to diminishing returns. Recognize when you're tired, frustrated, or stuck in a loop. Taking a break often leads to faster resolution than pushing through.

**Incorrect (pushing through fatigue):**

```python
# Hour 1: Start investigating login bug
# Hour 2: Still looking, getting frustrated
# Hour 3: Making random changes, reverting them
# Hour 4: Re-reading same code, finding nothing
# Hour 5: "It makes no sense, the code is correct"
# Hour 6: Finally spot the typo: "usernaem" instead of "username"

# 6 hours wasted on a bug that fresh eyes would catch in minutes
# Fatigue signs ignored: frustration, circular thinking, missing obvious things
```

**Correct (recognize and address fatigue):**

```python
# Hour 1: Start investigating login bug, make progress
# Hour 2: Progress slowing, re-reading same sections

# Fatigue check:
# - Am I making progress? No, last 30 minutes unproductive
# - Am I frustrated? Yes
# - Have I tried the same approach twice? Yes
# - When did I last take a break? 2 hours ago

# Decision: Take a break

# After 15-minute walk:
# Return to code, immediately see: "usernaem" typo
# Total time: 2 hours 15 minutes (not 6 hours)
```

**Fatigue warning signs:**
- Re-reading the same code repeatedly
- Making changes without clear reasoning
- Frustration or anger at the code
- Thinking "this is impossible"
- Missing obvious things (typos, wrong file, wrong branch)
- Forgetting what you've already tried

**Fatigue recovery strategies:**

| Strategy | When to Use |
|----------|-------------|
| 5-min stretch | Every hour |
| 15-min walk | When stuck for 30+ min |
| Explain to colleague | When circular thinking starts |
| Switch to different task | After 2 hours no progress |
| Stop for the day | After 4+ hours no progress |
| Sleep on it | Complex bugs, fresh perspective needed |

**The overnight effect:**
Many developers report solving bugs "immediately" the next morning. Sleep consolidates learning and provides fresh perspective that fatigued brains can't achieve.

**When NOT to use this pattern:**
- Critical production issue requiring immediate fix
- You're making steady progress (don't interrupt flow)

Reference: [Psychology of Debugging](https://www.thoughtfulcode.com/rubber-duck-debugging-psychology/)

---

## 10. Prevention & Learning

**Impact: LOW-MEDIUM**

Post-mortems, defensive coding, and knowledge sharing reduce future debugging time by 40-60% through systematic learning from past issues.

### 10.1 Add Defensive Code at System Boundaries

**Impact: LOW-MEDIUM (Catches bugs earlier with better context; prevents cascade failures)**

Add validation and assertions at system boundaries (APIs, module interfaces, data ingestion points). Bugs caught at boundaries have better context and don't propagate through the system.

**Incorrect (no boundary defense):**

```python
# Bug manifests deep in the system
def render_dashboard(data):
    for widget in data['widgets']:
        for metric in widget['metrics']:
            # NullPointerException here
            # No idea where bad data came from
            # Could be API, database, cache, or calculation
            value = metric['current'] / metric['previous']
```

**Correct (defend at boundaries):**

```python
# API boundary - validate incoming requests
@app.route('/api/dashboard')
def get_dashboard():
    data = request.json
    # Validate at entry point
    if not data or 'user_id' not in data:
        raise ValueError("user_id required")  # Clear error source

    dashboard = generate_dashboard(data['user_id'])
    return validate_dashboard_response(dashboard)  # Validate output too

# Module boundary - validate inputs and outputs
def generate_dashboard(user_id: str) -> dict:
    assert user_id, "user_id must not be empty"

    widgets = load_widgets(user_id)
    assert isinstance(widgets, list), f"Expected list, got {type(widgets)}"

    return {
        'user_id': user_id,
        'widgets': [validate_widget(w) for w in widgets]
    }

def validate_widget(widget: dict) -> dict:
    """Validate widget structure at data boundary"""
    required = ['id', 'type', 'metrics']
    missing = [k for k in required if k not in widget]
    if missing:
        raise ValueError(f"Widget missing required fields: {missing}")

    for metric in widget.get('metrics', []):
        if metric.get('previous', 0) == 0:
            logger.warning(f"Zero previous value in widget {widget['id']}")
            metric['previous'] = 1  # Prevent division by zero with logged warning

    return widget
```

**Where to add defensive code:**
1. **API endpoints** - Validate request parameters
2. **Database results** - Check expected structure
3. **External service responses** - Verify format/status
4. **Module public interfaces** - Assert preconditions
5. **Configuration loading** - Validate required settings
6. **User input** - Sanitize and validate

**Defense patterns:**

```python
# Assert preconditions
def calculate(items):
    assert items, "items must not be empty"
    assert all(isinstance(i, Item) for i in items), "all items must be Item type"

# Guard clauses
def process(data):
    if not data:
        logger.warning("process called with empty data")
        return None

# Fail fast with context
def fetch_user(user_id):
    if not user_id:
        raise ValueError(f"user_id required, got: {user_id!r}")
```

**When NOT to use this pattern:**
- Internal functions with trusted callers
- Hot paths where validation overhead matters
- Redundant validation already done upstream

Reference: [Defensive Programming](https://en.wikipedia.org/wiki/Defensive_programming)

### 10.2 Conduct Blameless Postmortems

**Impact: LOW-MEDIUM (Prevents recurrence through systemic fixes; builds team debugging culture)**

After significant bugs or incidents, conduct a blameless postmortem focused on systemic improvements, not individual blame. This transforms bugs from failures into learning opportunities.

**Incorrect (blame-focused):**

```markdown
## Incident Review: Production Database Deleted

### What happened
John accidentally ran DROP TABLE in production.

### Who's responsible
John. He should have been more careful.

### Action items
- Talk to John about being more careful
- John loses production access

# Result: Team fears reporting issues
# No systemic improvements made
# Similar incident happens 3 months later with different person
```

**Correct (blameless postmortem):**

```markdown
## Postmortem: Production Database Table Drop Incident

### Summary
On 2024-01-15, the users table was dropped in production,
causing 2 hours of downtime. Data was restored from backup.

### Timeline
- 14:23 - Engineer connects to database to run migration
- 14:25 - DROP TABLE executed against wrong database
- 14:26 - Errors reported by monitoring
- 14:30 - Incident declared, rollback initiated
- 16:30 - Service restored from backup

### Root Cause Analysis
1. Production and staging connection strings are similar
2. No prompt/confirmation when connecting to production
3. No safeguard against destructive commands in production
4. Local environment defaults to production credentials

### What Went Well
- Monitoring detected issue within 1 minute
- Backup was recent (< 1 hour data loss)
- Team responded quickly

### What Could Be Improved
- No visual distinction between prod/staging terminals
- Destructive commands don't require confirmation
- Easy to accidentally use production credentials

### Action Items
| Item | Owner | Due Date |
|------|-------|----------|
| Add color-coded terminal prompts for production | Team | Jan 22 |
| Implement SQL safeguards requiring confirmation | DevOps | Jan 29 |
| Rotate production credentials, require VPN | Security | Feb 5 |
| Update onboarding docs with safety procedures | Docs | Jan 25 |
```

**Blameless postmortem principles:**
1. **Assume good intent** - People tried to do the right thing
2. **Focus on systems** - What allowed error to happen?
3. **Share openly** - Publish findings to whole team
4. **Follow up** - Track action items to completion
5. **Celebrate learning** - Finding issues is valuable

**When to conduct postmortems:**
- Production incidents affecting users
- Bugs that took >1 day to resolve
- Issues that revealed systemic weaknesses
- Near-misses that could have been serious

Reference: [Google SRE - Postmortem Culture](https://sre.google/sre-book/postmortem-culture/)

### 10.3 Document Bug Solutions for Future Reference

**Impact: LOW-MEDIUM (Reduces future debugging time by 40-60%; creates team knowledge base)**

After solving a non-trivial bug, document the symptoms, investigation process, root cause, and solution. This creates a searchable knowledge base that helps you and teammates solve similar issues faster.

**Incorrect (no documentation):**

```markdown
# Git commit message
Fix: resolved login issue

# 6 months later, same symptoms appear
# No one remembers the original investigation
# Team spends another 4 hours debugging
# Realizes it's the same issue they fixed before
```

**Correct (documented for reference):**

```markdown
# Bug Documentation: Login Timeout on High Load

## Symptoms
- Users report "Login failed" after 30 seconds
- Occurs during peak hours (9-10 AM)
- Server logs show no errors during failure window

## Investigation
1. Checked auth service logs - normal response times
2. Checked database connections - pool at 95% capacity!
3. Traced connection leak to failed auth attempts
4. Found: Connections not released when password check fails

## Root Cause
In `auth.py:validate_password()`, database connection acquired but
not released in the error path. Under high load, pool exhausted.

## Solution
- Added `finally` block to release connection (commit abc123)
- Added connection pool monitoring dashboard
- Added alert for pool > 80% capacity

## Verification
- Load tested with 1000 concurrent logins
- Pool usage stable at 20-30%
- No timeout errors

## Related
- Similar issue in password reset: PR #456
- Connection pool documentation: /docs/database.md
```

**What to document:**
- **Symptoms**: Exact error messages, conditions, frequency
- **Investigation**: Steps taken, dead ends, key findings
- **Root cause**: The actual underlying issue
- **Solution**: What was changed and why
- **Verification**: How you confirmed the fix
- **Related**: Links to similar issues, relevant docs

**Where to document:**
- Bug tracker comments (attached to original issue)
- Team wiki/knowledge base
- Code comments for tricky edge cases
- ADR (Architecture Decision Record) for significant changes

**When NOT to use this pattern:**
- Trivial bugs (typos, obvious mistakes)
- One-off issues unlikely to recur

Reference: [Root Cause Analysis - Documentation](https://www.softwaretestinghelp.com/root-cause-analysis/)

### 10.4 Improve Error Messages When You Debug

**Impact: LOW-MEDIUM (Reduces future debugging time; helps next developer (including future you))**

When a bug takes a long time to find because error messages were unhelpful, improve those messages as part of your fix. Pay forward the debugging effort to help the next person.

**Incorrect (leaving poor error messages):**

```python
# Original code with unhelpful error
def process_order(order_id):
    order = get_order(order_id)
    if not order:
        raise Exception("Error")  # What error? What order?

# Developer spends 2 hours finding bug
# Fixes the immediate issue
# Leaves the poor error message unchanged
# Next developer will also struggle
```

**Correct (improve messages while fixing):**

```python
# After spending 2 hours debugging, improve the error for next time
def process_order(order_id):
    if not order_id:
        raise ValueError(
            f"order_id is required but got: {order_id!r}. "
            f"Check if the API request includes 'order_id' field."
        )

    order = get_order(order_id)
    if not order:
        raise OrderNotFoundError(
            f"Order {order_id} not found. "
            f"Possible causes: "
            f"1) Order was deleted, 2) Wrong environment, "
            f"3) order_id from different tenant. "
            f"Query: SELECT * FROM orders WHERE id = '{order_id}'"
        )

    if order.status == 'cancelled':
        raise InvalidOrderStateError(
            f"Cannot process cancelled order {order_id}. "
            f"Order was cancelled at {order.cancelled_at} by {order.cancelled_by}. "
            f"Use /api/orders/{order_id}/reinstate to restore if needed."
        )
```

**Good error message components:**
- **What happened**: Clear description of the failure
- **Context**: Relevant data values (IDs, states)
- **Why it might have happened**: Common causes
- **What to do**: Suggested next steps or fixes

**Error message improvements to make:**

| Bad Message | Good Message |
|-------------|--------------|
| "Error" | "Database connection failed: timeout after 30s connecting to db.example.com:5432" |
| "Invalid input" | "Invalid email format: 'user@' - expected format: user@domain.com" |
| "Not found" | "User 'alice' not found in organization 'acme'. Did you mean 'alice.smith'?" |
| "Permission denied" | "Permission denied: user 'bob' lacks 'admin' role required for /api/admin. Contact your org admin." |

**When NOT to use this pattern:**
- Error message is already clear and helpful
- Security-sensitive errors (don't leak implementation details)
- High-frequency errors where message generation is expensive

Reference: [Why Programs Fail - Observing Facts](https://www.whyprogramsfail.com/)

---

## References

1. [https://www.whyprogramsfail.com/](https://www.whyprogramsfail.com/)
2. [https://web.mit.edu/6.031/www/sp17/classes/11-debugging/](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)
3. [https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
4. [https://code.visualstudio.com/docs/debugtest/debugging](https://code.visualstudio.com/docs/debugtest/debugging)
5. [https://developer.chrome.com/docs/devtools/javascript/reference/](https://developer.chrome.com/docs/devtools/javascript/reference/)
6. [https://rubberduckdebugging.com/](https://rubberduckdebugging.com/)
7. [https://git-scm.com/docs/git-bisect](https://git-scm.com/docs/git-bisect)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
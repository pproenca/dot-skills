# Debugging

**Version 1.0.0**  
dot-skills  
January 2025

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive debugging methodology guide for software engineers, designed for AI agents and LLMs. Contains 54 rules across 10 categories, prioritized by impact from critical (problem definition, hypothesis-driven search) to incremental (prevention and learning). Includes bug triage, common bug patterns, and root cause analysis. Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct approaches, and specific impact metrics to guide systematic bug investigation.

---

## Table of Contents

1. [Problem Definition](references/_sections.md#1-problem-definition) — **CRITICAL**
   - 1.1 [Check Recent Changes First](references/prob-recent-changes.md) — CRITICAL (80%+ of bugs are caused by recent changes; reduces search space dramatically)
   - 1.2 [Create Minimal Reproduction Cases](references/prob-minimal-reproduction.md) — CRITICAL (Reduces debugging scope by 80-95%, making root cause obvious in many cases)
   - 1.3 [Document Symptoms Precisely](references/prob-document-symptoms.md) — CRITICAL (Prevents misdiagnosis and enables pattern matching across similar issues)
   - 1.4 [Reproduce Before Debugging](references/prob-reproduce-before-debug.md) — CRITICAL (Prevents 50%+ of wasted debugging time on unreproducible or misunderstood issues)
   - 1.5 [Separate Symptoms from Causes](references/prob-separate-symptoms-causes.md) — CRITICAL (Prevents fixing symptoms while root cause continues creating new bugs)
   - 1.6 [State Expected vs Actual Behavior](references/prob-state-expected-actual.md) — CRITICAL (Provides clear success criteria and prevents fixing the wrong thing)
2. [Hypothesis-Driven Search](references/_sections.md#2-hypothesis-driven-search) — **CRITICAL**
   - 2.1 [Apply the Scientific Method](references/hypo-scientific-method.md) — CRITICAL (Eliminates 80%+ of random debugging; provides systematic path to root cause)
   - 2.2 [Explain the Problem Aloud (Rubber Duck)](references/hypo-rubber-duck.md) — CRITICAL (Reveals gaps in understanding; 50%+ of bugs found during explanation)
   - 2.3 [Find WHERE Before Asking WHAT](references/hypo-where-not-what.md) — CRITICAL (Location narrows problem space by 90%+; understanding comes faster with context)
   - 2.4 [Rule Out Obvious Causes First](references/hypo-rule-out-obvious.md) — CRITICAL (60%+ of bugs have simple causes; checking obvious things first saves hours)
   - 2.5 [Test One Hypothesis at a Time](references/hypo-one-change-at-time.md) — CRITICAL (Prevents confounding variables; ensures you know which change fixed the bug)
   - 2.6 [Use Binary Search to Localize Bugs](references/hypo-binary-search.md) — CRITICAL (Reduces search space by 50% per iteration; finds bug in O(log n) steps)
3. [Observation Techniques](references/_sections.md#3-observation-techniques) — **HIGH**
   - 3.1 [Log Function Inputs and Outputs](references/obs-log-inputs-outputs.md) — HIGH (Reveals data transformation issues; enables replay debugging)
   - 3.2 [Read Stack Traces Bottom to Top](references/obs-stack-trace-reading.md) — HIGH (5-10× faster error localization; reveals full call chain context)
   - 3.3 [Trace Data Flow Through the System](references/obs-trace-data-flow.md) — HIGH (2-5× faster bug localization; pinpoints exact transformation that corrupts data)
   - 3.4 [Use Breakpoints Strategically](references/obs-breakpoint-strategy.md) — HIGH (10× faster inspection than print statements; enables state exploration)
   - 3.5 [Use Strategic Logging Over Random Print Statements](references/obs-strategic-logging.md) — HIGH (5× faster bug localization; structured logs enable automated analysis)
   - 3.6 [Use Watch Expressions for Complex State](references/obs-watch-expressions.md) — HIGH (3-5× faster state tracking; auto-updates computed values on each step)
4. [Root Cause Analysis](references/_sections.md#4-root-cause-analysis) — **HIGH**
   - 4.1 [Examine System Boundaries](references/rca-examine-boundaries.md) — HIGH (70%+ of bugs occur at boundaries; interfaces are high-risk areas)
   - 4.2 [Find the Last Known Good State](references/rca-last-known-good.md) — HIGH (O(log n) regression detection via git bisect; establishes working baseline)
   - 4.3 [Question Your Assumptions](references/rca-question-assumptions.md) — HIGH (Uncovers hidden bugs; 40%+ of debugging time is wasted on false assumptions)
   - 4.4 [Trace Fault Propagation Chains](references/rca-fault-propagation.md) — HIGH (2-3× faster root cause discovery; traces infection chain from symptom to origin)
   - 4.5 [Use the 5 Whys Technique](references/rca-five-whys.md) — HIGH (Reaches true root cause instead of surface symptoms; prevents recurrence)
5. [Tool Mastery](references/_sections.md#5-tool-mastery) — **MEDIUM-HIGH**
   - 5.1 [Inspect Memory and Object State](references/tool-memory-inspection.md) — MEDIUM-HIGH (Catches 90%+ of reference vs value bugs; reveals prototype chain and hidden properties)
   - 5.2 [Master Step Over, Step Into, Step Out](references/tool-step-commands.md) — MEDIUM-HIGH (Efficient navigation through code; 5× faster than random stepping)
   - 5.3 [Navigate the Call Stack](references/tool-call-stack-navigation.md) — MEDIUM-HIGH (3× faster context discovery; reveals parameter values at each call level)
   - 5.4 [Use Conditional Breakpoints](references/tool-conditional-breakpoints.md) — MEDIUM-HIGH (100× faster than hitting breakpoint manually in loops; targets exact conditions)
   - 5.5 [Use Exception Breakpoints](references/tool-exception-breakpoints.md) — MEDIUM-HIGH (5× faster exception debugging; catches errors at throw point with full context)
   - 5.6 [Use Logpoints Instead of Modifying Code](references/tool-logpoints.md) — MEDIUM-HIGH (100% clean commits; zero risk of shipping debug statements to production)
6. [Bug Triage and Classification](references/_sections.md#6-bug-triage-and-classification) — **MEDIUM**
   - 6.1 [Assess User Impact Before Prioritizing](references/triage-user-impact-assessment.md) — MEDIUM (10× improvement in value delivered per engineering hour)
   - 6.2 [Detect and Link Duplicate Bug Reports](references/triage-duplicate-detection.md) — MEDIUM (prevents duplicate investigation effort)
   - 6.3 [Factor Reproducibility into Triage](references/triage-reproducibility-matters.md) — MEDIUM (prevents wasted investigation time)
   - 6.4 [Identify and Ship Quick Wins First](references/triage-quick-wins-first.md) — MEDIUM (3-5× more bugs fixed per sprint)
   - 6.5 [Separate Severity from Priority](references/triage-severity-vs-priority.md) — MEDIUM (enables correct resource allocation)
7. [Common Bug Patterns](references/_sections.md#7-common-bug-patterns) — **MEDIUM**
   - 7.1 [Catch Async/Await Error Handling Mistakes](references/pattern-async-await-errors.md) — MEDIUM (prevents unhandled promise rejections)
   - 7.2 [Detect Memory Leak Patterns](references/pattern-memory-leak.md) — MEDIUM (prevents out-of-memory crashes)
   - 7.3 [Identify Race Condition Symptoms](references/pattern-race-condition.md) — MEDIUM (prevents intermittent production failures)
   - 7.4 [Recognize Null Pointer Patterns](references/pattern-null-pointer.md) — MEDIUM (prevents 20-30% of runtime errors)
   - 7.5 [Recognize Timezone and Date Bugs](references/pattern-timezone-issues.md) — MEDIUM (prevents date calculation errors across timezones)
   - 7.6 [Spot Off-by-One Errors](references/pattern-off-by-one.md) — MEDIUM (prevents 10-15% of logic errors)
   - 7.7 [Watch for Type Coercion Bugs](references/pattern-type-coercion.md) — MEDIUM (prevents silent data corruption bugs)
8. [Fix Verification](references/_sections.md#8-fix-verification) — **MEDIUM**
   - 8.1 [Add a Test to Prevent Recurrence](references/verify-add-test.md) — MEDIUM (100% regression prevention for this specific bug; serves as executable documentation)
   - 8.2 [Check for Regressions After Fixing](references/verify-regression-check.md) — MEDIUM (Prevents fix from breaking existing functionality; catches unintended side effects)
   - 8.3 [Understand Why the Fix Works](references/verify-understand-why-fix-works.md) — MEDIUM (Prevents cargo cult fixes; ensures fix is correct, not accidental)
   - 8.4 [Verify Fix With Original Reproduction](references/verify-reproduce-fix.md) — MEDIUM (Confirms fix actually works; prevents false confidence from unrelated changes)
9. [Anti-Patterns](references/_sections.md#9-anti-patterns) — **MEDIUM**
   - 9.1 [Avoid Blaming the Tool Too Quickly](references/anti-blame-tool.md) — MEDIUM (95%+ of bugs are in your code, not libraries; premature blame wastes time)
   - 9.2 [Avoid Quick Patches Without Understanding](references/anti-quick-patch.md) — MEDIUM (Prevents technical debt and recurring bugs; quick fixes often mask real problems)
   - 9.3 [Avoid Shotgun Debugging](references/anti-shotgun-debugging.md) — MEDIUM (Prevents hours of wasted effort; random changes make bugs harder to find)
   - 9.4 [Avoid Tunnel Vision on Initial Hypothesis](references/anti-tunnel-vision.md) — MEDIUM (Prevents wasted hours pursuing wrong theory; 30%+ of bugs aren't where we first look)
   - 9.5 [Recognize and Address Debugging Fatigue](references/anti-debug-fatigue.md) — MEDIUM (Prevents stupid mistakes from tiredness; fresh perspective finds bugs faster)
10. [Prevention & Learning](references/_sections.md#10-prevention-&-learning) — **LOW-MEDIUM**
   - 10.1 [Add Defensive Code at System Boundaries](references/prev-defensive-coding.md) — LOW-MEDIUM (Catches bugs earlier with better context; prevents cascade failures)
   - 10.2 [Conduct Blameless Postmortems](references/prev-postmortem.md) — LOW-MEDIUM (Prevents recurrence through systemic fixes; builds team debugging culture)
   - 10.3 [Document Bug Solutions for Future Reference](references/prev-document-solution.md) — LOW-MEDIUM (Reduces future debugging time by 40-60%; creates team knowledge base)
   - 10.4 [Improve Error Messages When You Debug](references/prev-improve-error-messages.md) — LOW-MEDIUM (Reduces future debugging time; helps next developer (including future you))

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
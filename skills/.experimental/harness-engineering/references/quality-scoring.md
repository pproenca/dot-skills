# Quality Scoring

Quality scoring gives agents and humans a shared understanding of where each
domain stands and where investment is needed. Scores are a baseline for tracking
improvement, not a judgment.

## Dimensions

Grade each domain across these six dimensions:

| Dimension | What it measures |
|-----------|-----------------|
| Code quality | Clarity, consistency, adherence to principles, absence of code smells |
| Test coverage | Meaningful test coverage (not just line coverage — boundary and behavior tests) |
| Documentation | Accuracy and completeness of domain-specific docs, inline comments where needed |
| Observability | Structured logging, metrics, tracing, error reporting |
| Reliability | Error handling, retry logic, graceful degradation, edge case coverage |
| Security | Input validation, auth boundaries, data classification, secret handling |

## Grading Scale

| Grade | Meaning | Description |
|-------|---------|-------------|
| A | Exemplary | Fully harnessed. Principles followed, tests comprehensive, docs current, observable. |
| B | Good | Solid foundation. Minor gaps that don't affect agent effectiveness. |
| C | Adequate | Functional but with notable gaps. Agents can work here but may stumble. |
| D | Weak | Significant gaps. Agents will likely produce inconsistent results in this domain. |
| F | Missing/broken | No meaningful coverage in this dimension. Agents are flying blind. |

## How to Score

During assessment, evaluate each dimension for each domain by examining:

1. **Code quality**: Read 2–3 representative files. Check principle adherence,
   naming consistency, file organization. Look for god-files, duplicated logic,
   or inconsistent patterns.

2. **Test coverage**: Check test files exist, tests are meaningful (not just
   snapshot tests of implementation details), boundary tests are present.
   If coverage metrics are available, note them.

3. **Documentation**: Does the domain have relevant docs/ entries? Are they
   current? Would an agent understand the domain by reading ARCHITECTURE.md +
   the domain's docs?

4. **Observability**: Is logging structured? Are there metrics for key operations?
   Can an agent query logs to understand what happened? Are errors reported
   with enough context to diagnose?

5. **Reliability**: Are error paths handled? Are retries configured for external
   calls? Are timeouts set? Does the domain degrade gracefully?

6. **Security**: Are inputs validated at boundaries? Are auth checks present?
   Is sensitive data classified and handled appropriately? Are secrets managed
   through config, not hardcoded?

## Gap Tracking

For each grade below B, note the specific gaps:
- What's missing or broken
- Impact on agent effectiveness
- Suggested remediation (if obvious)

Gaps feed directly into the garbage collection and doc-gardening patterns.
They also inform which follow-up exec-plans to create.

## Review Cadence

Quality scores go stale. Set a review cadence based on the repo's change velocity:

| Change velocity | Suggested cadence |
|----------------|-------------------|
| High (daily deploys) | Monthly review |
| Medium (weekly deploys) | Quarterly review |
| Low (occasional releases) | Semi-annual review |

Track `last_reviewed` per domain in quality.yml. The harness update flow uses
this to flag domains that are overdue for review.

## Scoring New Domains

When a new domain is identified (either during initial assessment or during
an update), score all dimensions immediately — even if the scores are low.
Having explicit D or F grades is better than having no entry, because it
makes the gap visible and trackable.

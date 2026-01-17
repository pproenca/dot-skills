---
title: Assess Full Impact Before Approving Changes
impact: MEDIUM
impactDescription: prevents 80% of timeline surprises from scope changes
tags: change, impact, assessment, analysis
---

## Assess Full Impact Before Approving Changes

Never approve a change request without full impact assessment. Small-seeming changes often have hidden costs in dependencies, testing, and downstream effects. "Just add a button" can mean weeks of work.

**Incorrect (approving without assessment):**

```markdown
## Change Discussion

PM: "Can we add a 'share to Twitter' button?"
Dev: "Yeah, that's just a button and API call"
PM: "Great, approved!"

// Hidden impacts discovered during implementation:
// - Need Twitter developer account approval (2 weeks)
// - Need to handle OAuth flow
// - Need rate limiting
// - Need content preview generation
// - Need compliance review for data sharing
// Actual effort: 3 weeks, not 1 day
```

**Correct (full impact assessment):**

```markdown
## Impact Assessment Template

### Change: Add "Share to Twitter" Button

#### Direct Effort

| Component | Task | Effort | Confidence |
|-----------|------|--------|------------|
| Frontend | Button UI and placement | 2h | High |
| Frontend | Twitter card preview | 4h | High |
| Backend | Twitter API integration | 8h | Medium |
| Backend | OAuth flow implementation | 16h | Medium |
| Backend | Rate limiting | 4h | High |
| Testing | Integration tests | 8h | High |
| Testing | Manual QA | 4h | High |
| **Subtotal** | | **46h** | |

#### Indirect Effort

| Area | Task | Effort | Confidence |
|------|------|--------|------------|
| DevOps | Twitter API credentials setup | 2h | High |
| Security | OAuth security review | 4h | Medium |
| Legal | Data sharing compliance | 8h | Low |
| Design | Share preview mockups | 4h | High |
| Docs | User documentation update | 2h | High |
| **Subtotal** | | **20h** | |

#### External Dependencies

| Dependency | Lead Time | Risk | Mitigation |
|------------|-----------|------|------------|
| Twitter developer account | 1-2 weeks | High | Apply immediately |
| Security review slot | 3-5 days | Medium | Book in advance |
| Legal review | 1 week | Low | Standard process |

#### Timeline Analysis

```text
Current Timeline:
Week 1 ████████ Feature A
Week 2 ████████ Feature B
Week 3 ████████ Feature C
Week 4 ████████ Testing + Launch

With This Change:
Week 1 ████████ Feature A
Week 2 ███░░░░░ Feature B (partial) + Twitter setup
Week 3 ░░░░████ Feature B (complete) + Security review
Week 4 ████████ Feature C
Week 5 ████████ Twitter feature
Week 6 ████████ Testing + Launch

Impact: +2 weeks to launch
```

#### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Twitter API approval delayed | 30% | High (+2w) | Apply before approval |
| Twitter API changes | 10% | Medium | Abstract integration |
| Rate limit issues | 20% | Low | Implement backoff |
| Preview rendering bugs | 40% | Low | Extensive testing |

#### Opportunity Cost

What gets delayed or dropped:
- Feature C pushed to v2 (affects 3 customer commitments)
- OR: Deadline slips 2 weeks (affects marketing campaign)

#### Total Cost Summary

```yaml
direct_effort: 46 hours (1.15 weeks)
indirect_effort: 20 hours (0.5 weeks)
waiting_time: 2 weeks (Twitter approval)
risk_buffer: 1 week
total_timeline_impact: 2-3 weeks

development_cost: $6,600
opportunity_cost: Delayed Feature C or launch
hidden_costs:
  - Ongoing Twitter API maintenance
  - Rate limit monitoring
  - Token refresh handling
```

### Recommendation

**Option A (Recommended):** Defer to v2
- Ship v1 on time
- Better user feedback on core features first
- Implement Twitter sharing with proper planning

**Option B:** Slip timeline by 2 weeks
- Include Twitter sharing
- Delays marketing campaign
- Risk of further delays

**Option C:** Drop Feature C
- Include Twitter sharing
- On-time launch
- Breaks 3 customer commitments
```

**Impact assessment must include:**
- Direct and indirect effort
- External dependencies with lead times
- Timeline visualization
- Risk assessment
- Opportunity cost analysis
- Clear recommendation

Reference: [Wrike - Change Impact Analysis](https://www.wrike.com/project-management-guide/faq/what-is-change-impact-analysis/)

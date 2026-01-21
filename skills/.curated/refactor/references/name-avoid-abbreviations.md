---
title: Avoid Abbreviations and Acronyms
impact: HIGH
impactDescription: eliminates guesswork and reduces onboarding time
tags: name, abbreviations, clarity, consistency
---

## Avoid Abbreviations and Acronyms

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

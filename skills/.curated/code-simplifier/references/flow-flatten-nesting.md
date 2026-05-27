---
title: Flatten Deep Nesting to Maximum 2-3 Levels
impact: HIGH
impactDescription: Each nesting level beyond 2 increases cognitive load by 25% and bug probability by 15%
tags: flow, nesting, refactoring, complexity, extraction
---

## Flatten Deep Nesting to Maximum 2-3 Levels

Code nested beyond 2-3 levels becomes exponentially harder to understand. Each level requires holding more context in working memory. When you find yourself at 4+ levels, it's a signal to extract functions, use early returns, or restructure the logic. Flat code is maintainable code.

**Incorrect (excessive nesting):**

```typescript
function processTransactions(accounts: Account[]) {
  for (const account of accounts) {
    if (account.isActive) {
      for (const transaction of account.transactions) {
        if (transaction.status === 'pending') {
          if (transaction.amount > 0) {
            for (const rule of account.rules) {
              if (rule.applies(transaction)) {
                if (rule.action === 'flag') {
                  if (transaction.amount > rule.threshold) {
                    transaction.flagged = true;
                    transaction.flagReason = rule.reason;
                    notifyCompliance(account, transaction);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

**Correct (flattened with extraction and early continues):**

```typescript
function processTransactions(accounts: Account[]) {
  const activeAccounts = accounts.filter(a => a.isActive);

  for (const account of activeAccounts) {
    processPendingTransactions(account);
  }
}

function processPendingTransactions(account: Account) {
  const pendingTransactions = account.transactions.filter(
    t => t.status === 'pending' && t.amount > 0
  );

  for (const transaction of pendingTransactions) {
    applyRules(account, transaction);
  }
}

function applyRules(account: Account, transaction: Transaction) {
  for (const rule of account.rules) {
    if (!rule.applies(transaction)) {
      continue;
    }
    if (rule.action !== 'flag') {
      continue;
    }
    if (transaction.amount <= rule.threshold) {
      continue;
    }

    transaction.flagged = true;
    transaction.flagReason = rule.reason;
    notifyCompliance(account, transaction);
  }
}
```

**Incorrect (nested conditionals for validation):**

```typescript
function validateForm(form: FormData): ValidationResult {
  if (form.email) {
    if (isValidEmail(form.email)) {
      if (form.password) {
        if (form.password.length >= 8) {
          if (form.password === form.confirmPassword) {
            if (form.acceptedTerms) {
              return { valid: true };
            } else {
              return { valid: false, error: 'Must accept terms' };
            }
          } else {
            return { valid: false, error: 'Passwords do not match' };
          }
        } else {
          return { valid: false, error: 'Password too short' };
        }
      } else {
        return { valid: false, error: 'Password required' };
      }
    } else {
      return { valid: false, error: 'Invalid email' };
    }
  } else {
    return { valid: false, error: 'Email required' };
  }
}
```

**Correct (flat validation chain):**

```typescript
function validateForm(form: FormData): ValidationResult {
  if (!form.email) {
    return { valid: false, error: 'Email required' };
  }
  if (!isValidEmail(form.email)) {
    return { valid: false, error: 'Invalid email' };
  }
  if (!form.password) {
    return { valid: false, error: 'Password required' };
  }
  if (form.password.length < 8) {
    return { valid: false, error: 'Password too short' };
  }
  if (form.password !== form.confirmPassword) {
    return { valid: false, error: 'Passwords do not match' };
  }
  if (!form.acceptedTerms) {
    return { valid: false, error: 'Must accept terms' };
  }

  return { valid: true };
}
```

**Incorrect (nested object traversal):**

```typescript
function getDeepValue(config: Config) {
  if (config) {
    if (config.settings) {
      if (config.settings.display) {
        if (config.settings.display.theme) {
          if (config.settings.display.theme.colors) {
            return config.settings.display.theme.colors.primary;
          }
        }
      }
    }
  }
  return DEFAULT_COLOR;
}
```

**Correct (optional chaining or extraction):**

```typescript
function getDeepValue(config: Config) {
  return config?.settings?.display?.theme?.colors?.primary ?? DEFAULT_COLOR;
}

// Or for complex logic:
function getDeepValue(config: Config) {
  const theme = getTheme(config);
  if (!theme?.colors) {
    return DEFAULT_COLOR;
  }
  return theme.colors.primary;
}

function getTheme(config: Config): Theme | undefined {
  return config?.settings?.display?.theme;
}
```

### Flattening Strategies

1. **Early returns/continues** - Exit the current scope ASAP
2. **Extract helper functions** - Each handles one level of complexity
3. **Filter before iterate** - Move conditions out of loops
4. **Use optional chaining** - For safe property access
5. **Use lookup tables** - Replace nested conditionals with data

### Benefits

- Each function fits in working memory
- Code can be tested in smaller units
- Easier to parallelize or optimize specific parts
- Clearer separation of concerns

### When NOT to Apply

- State machines with inherent nesting
- Parser/compiler code with recursive descent
- When extraction would require excessive parameter passing

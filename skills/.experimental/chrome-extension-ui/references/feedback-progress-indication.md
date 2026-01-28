---
title: Show Progress for Long Operations
impact: MEDIUM
impactDescription: reduces abandonment during multi-step processes
tags: feedback, progress, long-running, percentage, steps
---

## Show Progress for Long Operations

Display progress indicators for operations taking more than 2 seconds. Show either percentage complete or steps remaining so users know the operation is progressing.

**Incorrect (no progress feedback):**

```typescript
// popup.js - User has no idea how long this will take
async function processFiles(files) {
  showMessage('Processing...')

  for (const file of files) {
    await processFile(file)
  }

  showMessage('Done!')
}
// User sees "Processing..." for 30 seconds with no indication of progress
// User thinks it's frozen and closes the popup
```

**Correct (clear progress indication):**

```typescript
// popup.js - Progress visible throughout operation
async function processFiles(files) {
  const progressBar = document.getElementById('progress-bar')
  const progressText = document.getElementById('progress-text')
  const progressContainer = document.getElementById('progress-container')

  progressContainer.style.display = 'block'
  progressBar.style.width = '0%'

  const total = files.length
  let completed = 0

  for (const file of files) {
    progressText.textContent = `Processing ${file.name}...`

    await processFile(file)

    completed++
    const percentage = Math.round((completed / total) * 100)
    progressBar.style.width = `${percentage}%`
    progressText.textContent = `${completed} of ${total} files (${percentage}%)`
  }

  progressText.textContent = 'Complete!'
  setTimeout(() => {
    progressContainer.style.display = 'none'
  }, 1500)
}
```

**Step-based progress for multi-stage operations:**

```typescript
// popup.js - Named steps for complex processes
async function setupExtension() {
  const steps = [
    { id: 'auth', label: 'Signing in...', fn: authenticate },
    { id: 'sync', label: 'Syncing data...', fn: syncData },
    { id: 'index', label: 'Building index...', fn: buildIndex },
    { id: 'finalize', label: 'Finalizing...', fn: finalize }
  ]

  const progressEl = document.getElementById('setup-progress')

  for (let i = 0; i < steps.length; i++) {
    const step = steps[i]

    // Update UI to show current step
    progressEl.innerHTML = `
      <div class="step-progress">
        <div class="step-indicator">Step ${i + 1} of ${steps.length}</div>
        <div class="step-label">${step.label}</div>
        <div class="step-dots">
          ${steps.map((s, idx) => `
            <span class="dot ${idx < i ? 'complete' : ''} ${idx === i ? 'active' : ''}"></span>
          `).join('')}
        </div>
      </div>
    `

    try {
      await step.fn()
    } catch (error) {
      progressEl.innerHTML = `
        <div class="step-error">
          <p>Failed at: ${step.label}</p>
          <button onclick="retryFrom(${i})">Retry</button>
        </div>
      `
      return
    }
  }

  progressEl.innerHTML = '<div class="step-complete">Setup complete!</div>'
}
```

**Indeterminate progress for unknown duration:**

```typescript
// popup.js - When you can't calculate percentage
async function searchDatabase(query) {
  const progressEl = document.getElementById('search-progress')

  progressEl.innerHTML = `
    <div class="indeterminate-progress">
      <div class="progress-bar-indeterminate"></div>
      <span>Searching...</span>
    </div>
  `

  const results = await performSearch(query)

  progressEl.innerHTML = ''
  return results
}
```

```css
/* Indeterminate progress animation */
.progress-bar-indeterminate {
  height: 4px;
  background: linear-gradient(90deg, transparent, #4A90D9, transparent);
  background-size: 200% 100%;
  animation: indeterminate 1.5s infinite linear;
}

@keyframes indeterminate {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

Reference: [Progress Indicators](https://www.nngroup.com/articles/progress-indicators/)

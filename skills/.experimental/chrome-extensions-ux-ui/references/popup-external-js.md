---
title: Keep JavaScript in External Files
impact: HIGH
impactDescription: required by Content Security Policy
tags: popup, javascript, csp, security, manifest-v3
---

## Keep JavaScript in External Files

Place all JavaScript in separate .js files linked via `<script src>`. Manifest V3 prohibits inline scripts (`onclick`, `<script>` tags with code) due to Content Security Policy requirements.

**Incorrect (inline JavaScript blocked by CSP):**

```html
<!-- popup.html - These will NOT work in Manifest V3 -->
<button onclick="handleClick()">Click me</button>

<script>
  function handleClick() {
    console.log('clicked')
  }

  document.getElementById('btn').addEventListener('click', () => {
    toggleExtensionState()
  })
</script>

<!-- Error: Refused to execute inline script because it violates CSP -->
```

**Correct (external JavaScript files):**

```html
<!-- popup.html - Script in external file -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="popup.css">
</head>
<body>
  <button id="action-btn">Click me</button>
  <script src="popup.js"></script>
</body>
</html>
```

```typescript
// popup.js - All JavaScript here
document.addEventListener('DOMContentLoaded', () => {
  const button = document.getElementById('action-btn')

  button.addEventListener('click', () => {
    handleClick()
  })
})

function handleClick() {
  console.log('clicked')
}
```

**Handling dynamic HTML:**

```typescript
// popup.js - Use event delegation instead of inline handlers
const container = document.getElementById('item-list')

// Event delegation - single listener handles dynamic content
container.addEventListener('click', (event) => {
  const button = event.target.closest('[data-action]')
  if (!button) return

  const action = button.dataset.action
  const itemId = button.dataset.itemId

  switch (action) {
    case 'edit':
      editItem(itemId)
      break
    case 'delete':
      deleteItem(itemId)
      break
  }
})

function renderItems(items) {
  container.innerHTML = items.map(item => `
    <div class="item">
      <span>${item.name}</span>
      <button data-action="edit" data-item-id="${item.id}">Edit</button>
      <button data-action="delete" data-item-id="${item.id}">Delete</button>
    </div>
  `).join('')
}
```

Reference: [Content Security Policy](https://developer.chrome.com/docs/extensions/develop/migrate/improve-security)

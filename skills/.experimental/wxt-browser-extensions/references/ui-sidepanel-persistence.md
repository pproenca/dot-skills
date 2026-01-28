---
title: Preserve Sidepanel State Across Opens
impact: MEDIUM
impactDescription: prevents state loss on sidepanel close/reopen
tags: ui, sidepanel, state, persistence
---

## Preserve Sidepanel State Across Opens

Unlike popups, sidepanels can persist state while open. Save state to storage on changes to survive sidepanel closes and browser restarts.

**Incorrect (state lost on close):**

```typescript
// sidepanel/App.tsx
function App() {
  // State lost every time sidepanel closes
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedTab, setSelectedTab] = useState('search')
  const [scrollPosition, setScrollPosition] = useState(0)

  return (
    <div>
      <Tabs value={selectedTab} onChange={setSelectedTab} />
      <SearchInput value={searchQuery} onChange={setSearchQuery} />
    </div>
  )
}
```

**Correct (state persisted to storage):**

```typescript
// utils/storage.ts
export const sidepanelState = storage.defineItem<SidepanelState>('session:sidepanelState', {
  fallback: {
    searchQuery: '',
    selectedTab: 'search',
    scrollPosition: 0
  }
})

// sidepanel/App.tsx
function App() {
  const [state, setState] = useState<SidepanelState | null>(null)

  // Load state on mount
  useEffect(() => {
    sidepanelState.getValue().then(setState)
  }, [])

  // Save state on changes (debounced)
  const debouncedSave = useMemo(
    () => debounce((newState: SidepanelState) => {
      sidepanelState.setValue(newState)
    }, 300),
    []
  )

  const updateState = (updates: Partial<SidepanelState>) => {
    const newState = { ...state, ...updates }
    setState(newState)
    debouncedSave(newState)
  }

  if (!state) return <Loading />

  return (
    <div>
      <Tabs
        value={state.selectedTab}
        onChange={(tab) => updateState({ selectedTab: tab })}
      />
      <SearchInput
        value={state.searchQuery}
        onChange={(query) => updateState({ searchQuery: query })}
      />
    </div>
  )
}
```

**Note:** Use `session:` storage area for UI state that should clear on browser restart, `local:` for persistent preferences.

Reference: [Chrome Side Panel API](https://developer.chrome.com/docs/extensions/reference/api/sidePanel)

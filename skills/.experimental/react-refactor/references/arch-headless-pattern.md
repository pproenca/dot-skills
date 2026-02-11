---
title: Extract Headless Components for Logic Reuse
impact: CRITICAL
impactDescription: enables 5x more reuse scenarios for the same behavior
tags: arch, headless, hooks, separation-of-concerns, reuse
---

## Extract Headless Components for Logic Reuse

When behavior is welded to a specific UI, reusing the same logic with a different visual design requires duplicating the entire component. A headless hook extracts the behavior into a reusable unit, and thin UI wrappers render it however they need.

**Incorrect (behavior locked to specific UI):**

```tsx
function Autocomplete({ options, onSelect }: AutocompleteProps) {
  const [query, setQuery] = useState("");
  const [highlightIndex, setHighlightIndex] = useState(-1);
  const [isOpen, setIsOpen] = useState(false);

  const filtered = options.filter((opt) =>
    opt.label.toLowerCase().includes(query.toLowerCase())
  );

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") setHighlightIndex((i) => Math.min(i + 1, filtered.length - 1));
    if (e.key === "ArrowUp") setHighlightIndex((i) => Math.max(i - 1, 0));
    if (e.key === "Enter" && highlightIndex >= 0) {
      onSelect(filtered[highlightIndex]);
      setIsOpen(false);
    }
  };

  // Behavior + rendering fused — cannot reuse keyboard nav with a different dropdown UI
  return (
    <div className="autocomplete">
      <input value={query} onChange={(e) => { setQuery(e.target.value); setIsOpen(true); }} onKeyDown={handleKeyDown} />
      {isOpen && (
        <ul className="autocomplete__list">
          {filtered.map((opt, i) => (
            <li key={opt.id} className={i === highlightIndex ? "highlighted" : ""} onClick={() => onSelect(opt)}>
              {opt.label}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

**Correct (headless hook — behavior decoupled from rendering):**

```tsx
function useAutocomplete<T extends { id: string; label: string }>({ options, onSelect }: UseAutocompleteOptions<T>) {
  const [query, setQuery] = useState("");
  const [highlightIndex, setHighlightIndex] = useState(-1);
  const [isOpen, setIsOpen] = useState(false);

  const filtered = options.filter((opt) =>
    opt.label.toLowerCase().includes(query.toLowerCase())
  );

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") setHighlightIndex((i) => Math.min(i + 1, filtered.length - 1));
    if (e.key === "ArrowUp") setHighlightIndex((i) => Math.max(i - 1, 0));
    if (e.key === "Enter" && highlightIndex >= 0) {
      onSelect(filtered[highlightIndex]);
      setIsOpen(false);
    }
  };

  return { query, setQuery, filtered, highlightIndex, isOpen, setIsOpen, handleKeyDown };
}

// Thin UI wrapper — swap this for any visual design
function Autocomplete<T extends { id: string; label: string }>({ options, onSelect }: AutocompleteProps<T>) {
  const { query, setQuery, filtered, highlightIndex, isOpen, setIsOpen, handleKeyDown } =
    useAutocomplete({ options, onSelect });

  return (
    <div className="autocomplete">
      <input value={query} onChange={(e) => { setQuery(e.target.value); setIsOpen(true); }} onKeyDown={handleKeyDown} />
      {isOpen && (
        <ul>{filtered.map((opt, i) => (
          <li key={opt.id} className={i === highlightIndex ? "highlighted" : ""} onClick={() => onSelect(opt)}>
            {opt.label}
          </li>
        ))}</ul>
      )}
    </div>
  );
}
```

Reference: [Headless UI Pattern - React Patterns](https://www.patterns.dev/react/headless-component-pattern/)

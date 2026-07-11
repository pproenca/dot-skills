---
title: No useEffect chains as implicit state machines
tags: state, useeffect, react, transitions
---

## No useEffect chains as implicit state machines

The wrong default is sequencing logic through effects — effect A sets state that appears in effect B's dependency array, which sets state that triggers effect C. That is a state machine with its transition table scattered across the file and its steps separated by full re-render cycles, so it is slower than computing directly, and any other write to the intermediate state silently fires the rest of the chain. The React team's guidance is explicit — calculate what you can during render, and put the whole cascade in the event handler that starts it.

**Evidence of violation:** a `useEffect` whose body sets state, where that state appears in another `useEffect`'s dependency array which also sets state — a chain of two or more links reachable from one originating update. The carve-out is synchronization with an external system (network, subscription, DOM, non-React widget); a link whose body only talks to an external system is not a chain link, because that is what effects are for.

**Incorrect (transition table scattered across effects):**

```tsx
const [card, setCard] = useState<Card | null>(null)
const [goldCardCount, setGoldCardCount] = useState(0)
const [round, setRound] = useState(1)

useEffect(() => {
  if (card?.gold) setGoldCardCount(c => c + 1)
}, [card])

useEffect(() => {
  if (goldCardCount > 3) {
    setRound(r => r + 1)
    setGoldCardCount(0)
  }
}, [goldCardCount])
```

**Correct (the whole transition runs in the event that causes it):**

```tsx
const [card, setCard] = useState<Card | null>(null)
const [goldCardCount, setGoldCardCount] = useState(0)
const [round, setRound] = useState(1)

function handlePlaceCard(nextCard: Card) {
  setCard(nextCard)
  if (nextCard.gold) {
    const nextGoldCount = goldCardCount + 1
    if (nextGoldCount > 3) {
      setGoldCardCount(0)
      setRound(round + 1)
    } else {
      setGoldCardCount(nextGoldCount)
    }
  }
}
```

Reference: [react.dev — You Might Not Need an Effect (chains of computations)](https://react.dev/learn/you-might-not-need-an-effect#chains-of-computations)

---
title: Surface Safety Guarantees and Insurance Before Listings
impact: CRITICAL
impactDescription: reduces risk-overweighting on rare bad outcomes
tags: owner, safety, insurance
---

## Surface Safety Guarantees and Insurance Before Listings

Slovic's affect-heuristic research and Kahneman's work on probability weighting both show that humans dramatically overweight rare negative outcomes when evaluating risk, especially when the outcome involves someone or something they love. A pet owner considering leaving their dog with a stranger is not doing an expected-value calculation — they are imagining the worst case and assigning it disproportionate weight. Explicit, prominent insurance coverage, emergency support, and a clear dispute resolution path directly counter this cognitive bias and are among the highest-leverage conversion levers for pet owners specifically. These signals belong above the fold, before any listing is shown.

**Incorrect (safety information buried in a footer or FAQ):**

```typescript
function HeroSection({ listings }: Props) {
  return (
    <>
      <Hero title="Find a sitter" />
      <ListingGrid listings={listings} />
      <Footer links={["About", "Safety", "Terms"]} />
    </>
  )
}
```

**Correct (safety coverage surfaced prominently above the listings):**

```typescript
function HeroSection({ listings, visitorRole }: Props) {
  return (
    <>
      <Hero title="Find a sitter for your pet" />
      {visitorRole === "owner" && (
        <SafetyStripe
          items={[
            { icon: "shield", label: "£25,000 home and pet injury cover included" },
            { icon: "phone", label: "24/7 vet line and emergency support" },
            { icon: "check", label: "ID verification and police check on every sitter" },
            { icon: "arrow-back", label: "Full refund if a sitter cancels" },
          ]}
          linkToPolicy="/safety"
        />
      )}
      <ListingGrid listings={listings} />
    </>
  )
}
```

Reference: [Slovic et al — The Affect Heuristic](https://www.decisionresearch.org/wp-content/uploads/2017/06/rd6501.pdf)

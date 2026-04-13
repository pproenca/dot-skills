---
title: Show Typical Daily Commitment per Stay, Not Vague Descriptions
impact: HIGH
impactDescription: enables accurate effort-to-benefit calculation
tags: sitter, effort, realism
---

## Show Typical Daily Commitment per Stay, Not Vague Descriptions

A pet sitter is effectively calculating a mental trade — free accommodation in exchange for pet care — and that trade only makes sense when the effort side of the equation is known. Vague descriptions like "a friendly dog that needs some walks" leave the sitter guessing, and the guesses usually underestimate the work. Showing typical daily commitment explicitly (hours of active care, number of walks, feeding schedule, medication, whether the sitter can leave the home unattended) gives the visitor the other side of the equation and converts visitors whose travel plans actually fit while correctly filtering out those whose plans do not.

**Incorrect (vague pet-care description on preview listings):**

```typescript
function ListingPreview({ listing }: { listing: Listing }) {
  return (
    <div>
      <img src={listing.heroImage} />
      <h4>{listing.title}</h4>
      <p>{listing.shortDescription}</p>
      <p>{listing.pets.length} pets · {listing.nights} nights</p>
    </div>
  )
}
```

**Correct (explicit daily commitment breakdown):**

```typescript
function ListingPreview({ listing }: { listing: Listing }) {
  return (
    <div>
      <img src={listing.heroImage} />
      <h4>{listing.title}</h4>
      <DailyCommitment>
        <Row icon="clock" label="Active pet care">
          {listing.dailyActiveCareHours} hours/day
        </Row>
        <Row icon="walk" label="Walks">
          {listing.dailyWalks} × {listing.walkDurationMinutes} min
        </Row>
        <Row icon="home" label="Can leave home">
          Max {listing.maxHoursAloneWithPet} hours
        </Row>
        <Row icon="pill" label="Medication">
          {listing.medicationRequired ? "Twice daily tablets" : "None"}
        </Row>
      </DailyCommitment>
      <p>{listing.nights} nights in {listing.city}</p>
    </div>
  )
}
```

Reference: [BJ Fogg — A Behavior Model for Persuasive Design](https://bjfogg.com/fbm_files/page4_1.pdf)

---
title: Use Perceptual Hash to Distinguish "Wrong Component" from "Off by a Pixel"
impact: HIGH
impactDescription: routes 90%+ of regressions to the correct triage path (component vs layout bug)
tags: diff, perceptual-hash, phash, triage
---

## Use Perceptual Hash to Distinguish "Wrong Component" from "Off by a Pixel"

When a snapshot fails, the next question is "is this the right component just misplaced, or did we render an entirely wrong component?" SSIM gives you a similarity score but not this category split. A perceptual hash (pHash, dHash) reduces each image to a 64-bit fingerprint where small visual changes produce small Hamming distances. Bucket the failure by Hamming distance: `< 5` = same component, off by sub-pixel jitter; `5..15` = same component, layout drifted; `> 15` = wrong component entirely. Each bucket has a different fix path.

**Incorrect (single "failed" status, manual triage every time):**

```ts
const score = ssim(baseline, actual).mssim;
if (score < 0.99) {
  console.error('snapshot failed', score);
  // Now a human opens both PNGs and decides: rebaseline, fix layout, or revert.
}
```

**Correct (pHash bucket → automatic triage):**

```ts
import { phash } from 'sharp-phash';

function hammingDistance(a: bigint, b: bigint): number {
  let x = a ^ b, count = 0;
  while (x) { count += Number(x & 1n); x >>= 1n; }
  return count;
}

type FailureBucket =
  | { kind: 'aa-jitter';    action: 'ignore' }       // 0..4
  | { kind: 'layout-drift'; action: 'investigate-layout-rule' }  // 5..15
  | { kind: 'wrong-component'; action: 'investigate-tree-rule' };  // 16..64

async function triageFailure(baseline: Buffer, actual: Buffer): Promise<FailureBucket> {
  const [hB, hA] = await Promise.all([phash(baseline), phash(actual)]);
  const dist = hammingDistance(BigInt('0x' + hB), BigInt('0x' + hA));

  if (dist < 5)  return { kind: 'aa-jitter',       action: 'ignore' };
  if (dist < 16) return { kind: 'layout-drift',    action: 'investigate-layout-rule' };
  return                { kind: 'wrong-component', action: 'investigate-tree-rule' };
}

// Wire to CI: each failure self-classifies and surfaces the likely culprit category.
//   aa-jitter → don't even file a failure (raise threshold)
//   layout-drift → audit recent changes to layout- rules
//   wrong-component → audit recent changes to tree-/iter- rules (component selection)
```

**Why Hamming distance on pHash beats SSIM for triage:** SSIM is a continuous score that doesn't classify the *type* of difference. Two failures with SSIM 0.94 can be very different bugs — one is a 2px shift of the right component, the other is the wrong component rendered. pHash quantifies "perceptual identity," which is the dimension that maps to the bug category.

**Tuning the bucket boundaries:** the 5/15 thresholds work for 64-bit pHash on 256×256 components. For smaller (icon-sized) components, scale down proportionally (3/10). Calibrate by hashing 50 known-good snapshots and 50 deliberately-broken ones, then pick boundaries that minimize misclassification.

Reference: [Perceptual Hash Algorithm — Neal Krawetz](https://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like-It.html)

---
title: "Map ignoreLayout to position: absolute as a Flex Escape Hatch"
impact: CRITICAL
impactDescription: prevents 100% of badge/overlay misplacement when designer marks a child as out-of-flow
tags: layout, ignore-layout, position-absolute, flex-escape-hatch
---

## Map ignoreLayout to position: absolute as a Flex Escape Hatch

When a flex item has `flexItem.ignoreLayout: true`, the designer is saying "this child is positioned independently of the flex algorithm — leave its frame alone." The CSS equivalent is `position: absolute` with explicit top/left, and the parent flex container needs `position: relative` to become the absolute child's containing block. Missing this mapping causes badges, overlay buttons, and floating action indicators to be incorrectly stretched, gap-spaced, or laid out in main-axis order with their siblings.

**Incorrect (every flex child gets flex layout):**

```tsx
// Sketch: row-flex group with [Avatar, Name, Status] siblings AND a Badge child
//         that has flexItem.ignoreLayout: true positioned top-right of the avatar.
<div className={styles.row}>
  <Avatar />
  <Name />
  <Status />
  <Badge />   {/* gets laid out as the 4th flex item — wrong position */}
</div>
```

```css
.row { display: flex; gap: 8px; }
/* Badge appears at the end of the row instead of overlaying the avatar. */
```

**Correct (ignoreLayout → absolute escape hatch):**

```ts
function emitChild(child: Layer): { css: CssProps; tag: string } {
  const isAbsolute = child.flexItem?.ignoreLayout === true;
  if (!isAbsolute) return { css: childCss(child), tag: 'div' };

  // ignoreLayout: child's frame is parent-relative absolute position.
  return {
    css: {
      position: 'absolute',
      top:  `${child.frame.y}px`,
      left: `${child.frame.x}px`,
      width:  `${child.frame.width}px`,
      height: `${child.frame.height}px`,
      ...childCss(child),
    },
    tag: 'div',
  };
}

function emitParent(group: Group): CssProps {
  const hasIgnoreLayoutChild = group.layers.some(c => c.flexItem?.ignoreLayout);
  return {
    ...mapFlex(group.layout),
    // Required for absolute children to anchor to this parent.
    ...(hasIgnoreLayoutChild && { position: 'relative' }),
  };
}
```

```tsx
<div className={styles.row}>           {/* position: relative; display: flex */}
  <Avatar />
  <Name />
  <Status />
  <Badge className={styles.badge} />   {/* position: absolute over avatar */}
</div>
```

```css
.row { position: relative; display: flex; gap: 8px; }
.badge { position: absolute; top: 0; left: 24px; }
```

**Why parent needs `position: relative`:** an absolute child anchors to its nearest *positioned* ancestor. Without `position: relative` on the flex parent, the badge anchors to the page (or a more distant ancestor), and your snapshot test passes against a baseline that's also wrong because the test page happens to have the same scroll position.

**Related — preserveSpaceWhenHidden:** the sibling `flexItem.preserveSpaceWhenHidden` is the equivalent of `visibility: hidden` (keeps layout slot) vs. `display: none` (removes it). Map it explicitly when emitting conditional render branches.

Reference: [MDN — position: absolute and containing blocks](https://developer.mozilla.org/en-US/docs/Web/CSS/Containing_block)

---
title: Let Gesture Variants Flow to Children
impact: MEDIUM
impactDescription: reduces gesture prop duplication
tags: gesture, variants, propagation, children, whileHover
---

## Let Gesture Variants Flow to Children

Variants automatically propagate to children, so gesture states like `whileHover` flow down the component tree. Duplicating gesture props on parent and children is redundant and creates maintenance burden. Define variants once on the parent and reference them in children.

**Incorrect (duplicated gesture props on parent and children):**

```tsx
function FeatureCard({ title, description, icon }: FeatureCardProps) {
  return (
    <motion.div
      className="card"
      whileHover={{ scale: 1.02 }}  // Gesture defined here
    >
      <motion.div
        className="icon-wrapper"
        whileHover={{ rotate: 10 }}  // Must manually add whileHover again
      >
        {icon}
      </motion.div>
      <motion.h3
        whileHover={{ color: "#3b82f6" }}  // Must manually add whileHover again
      >
        {title}
      </motion.h3>
      <p>{description}</p>
    </motion.div>
  );
}
```

**Correct (variants propagate to children automatically):**

```tsx
const cardVariants = {
  rest: { scale: 1 },
  hover: { scale: 1.02 },
};

const iconVariants = {
  rest: { rotate: 0 },
  hover: { rotate: 10 },  // Triggers when parent enters "hover"
};

const titleVariants = {
  rest: { color: "#1f2937" },
  hover: { color: "#3b82f6" },  // Triggers when parent enters "hover"
};

function FeatureCard({ title, description, icon }: FeatureCardProps) {
  return (
    <motion.div
      className="card"
      variants={cardVariants}
      initial="rest"
      whileHover="hover"  // Children inherit this state automatically
    >
      <motion.div className="icon-wrapper" variants={iconVariants}>
        {icon}
      </motion.div>
      <motion.h3 variants={titleVariants}>
        {title}
      </motion.h3>
      <p>{description}</p>
    </motion.div>
  );
}
```

Reference: [Framer Motion - Variants](https://www.framer.com/motion/animation/#variants)

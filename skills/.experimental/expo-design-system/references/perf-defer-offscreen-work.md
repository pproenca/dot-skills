---
title: Defer Off-Screen Work Until After Transitions
impact: MEDIUM
impactDescription: prevents dropped frames during navigation transitions
tags: perf, interactions, transitions, scheduling
---

## Defer Off-Screen Work Until After Transitions

Running an expensive computation in a screen's mount effect makes it compete with the push animation, dropping frames exactly when the user is watching the transition. `InteractionManager.runAfterInteractions` schedules the work for after animations settle, so the screen slides in smoothly and the heavy build happens once it is on screen.

**Incorrect (heavy work during the navigation animation):**

```typescript
function PatientScreen({ patient }: { patient: Patient }) {
  const [report, setReport] = useState<VisitReport>()
  useEffect(() => {
    setReport(buildVisitReport(patient)) // synchronous and heavy, runs during the push animation
  }, [])
  return <ReportView report={report} />
}
// The expensive build competes with the transition and drops frames on entry.
```

**Correct (defer until interactions settle):**

```typescript
import { InteractionManager } from 'react-native'

function PatientScreen({ patient }: { patient: Patient }) {
  const [report, setReport] = useState<VisitReport>()
  useEffect(() => {
    const task = InteractionManager.runAfterInteractions(() => setReport(buildVisitReport(patient)))
    return () => task.cancel()
  }, [])
  return <ReportView report={report} />
}
// The screen animates in first, then the report builds once the transition completes.
```

Reference: [Reanimated performance](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)

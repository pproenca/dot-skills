---
title: Use State Machines for Complex UI Workflows
impact: CRITICAL
impactDescription: reduces valid states from 2^n to exactly N defined states
tags: state, state-machine, workflows, finite-states
---

## Use State Machines for Complex UI Workflows

Boolean flags scale combinatorially: 4 booleans create 16 possible states, most of which are invalid (e.g., loading AND error AND success simultaneously). A state machine defines only the valid states and legal transitions between them, making illegal states unrepresentable.

**Incorrect (boolean flags — 2^4 = 16 possible states, 12 are invalid):**

```tsx
function FileUploader() {
  const [isIdle, setIsIdle] = useState(true);
  const [isValidating, setIsValidating] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [isComplete, setIsComplete] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [progress, setProgress] = useState(0);

  async function handleUpload(file: File) {
    setIsIdle(false);
    setIsValidating(true);
    try {
      await validateFile(file);
      setIsValidating(false);
      setIsUploading(true);
      await uploadFile(file, (pct) => setProgress(pct));
      setIsUploading(false);
      setIsComplete(true);
      // Bug: what if user retries? Must reset ALL flags correctly
    } catch (err) {
      // Bug: isValidating or isUploading remains true
      setError(err.message);
    }
  }
}
```

**Correct (state machine — exactly 5 valid states):**

```tsx
type UploadState =
  | { status: "idle" }
  | { status: "validating"; file: File }
  | { status: "uploading"; file: File; progress: number }
  | { status: "complete"; file: File; url: string }
  | { status: "error"; message: string; file: File };

type UploadAction =
  | { type: "SELECT_FILE"; file: File }
  | { type: "VALIDATION_PASSED" }
  | { type: "UPLOAD_PROGRESS"; progress: number }
  | { type: "UPLOAD_COMPLETE"; url: string }
  | { type: "FAIL"; message: string }
  | { type: "RETRY" };

function uploadReducer(state: UploadState, action: UploadAction): UploadState {
  switch (state.status) {
    case "idle":
      if (action.type === "SELECT_FILE") return { status: "validating", file: action.file };
      return state;
    case "validating":
      if (action.type === "VALIDATION_PASSED") return { status: "uploading", file: state.file, progress: 0 };
      if (action.type === "FAIL") return { status: "error", message: action.message, file: state.file };
      return state;
    case "uploading":
      if (action.type === "UPLOAD_PROGRESS") return { ...state, progress: action.progress };
      if (action.type === "UPLOAD_COMPLETE") return { status: "complete", file: state.file, url: action.url };
      if (action.type === "FAIL") return { status: "error", message: action.message, file: state.file };
      return state;
    case "error":
      if (action.type === "RETRY") return { status: "validating", file: state.file };
      return state;
    case "complete":
      return state; // Terminal state — no transitions
  }
}

function FileUploader() {
  const [state, dispatch] = useReducer(uploadReducer, { status: "idle" });

  // Each render branch handles exactly one state — no impossible combinations
  if (state.status === "uploading") return <ProgressBar progress={state.progress} />;
  if (state.status === "error") return <ErrorRetry message={state.message} onRetry={() => dispatch({ type: "RETRY" })} />;
  if (state.status === "complete") return <UploadSuccess url={state.url} />;
}
```

Reference: [Stately - Introduction to State Machines](https://stately.ai/docs/state-machines-and-statecharts)

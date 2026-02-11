---
title: Dispose Heavy Resources in Cleanup Functions
impact: LOW-MEDIUM
impactDescription: prevents 5-50MB per resource retention
tags: mem, cleanup, worker, canvas, object-url
---

## Dispose Heavy Resources in Cleanup Functions

Canvas contexts, Web Workers, object URLs, and media streams allocate significant memory outside the JavaScript heap. These resources are not automatically garbage collected when a component unmounts — they require explicit disposal calls or they persist for the lifetime of the page.

**Incorrect (resources allocated without disposal):**

```tsx
function ImageEditor({ imageFile }: { imageFile: File }) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const objectUrl = URL.createObjectURL(imageFile) // 5-20MB blob retained
    const worker = new Worker("/image-processing-worker.js") // thread + memory allocated
    const img = new Image()

    img.onload = () => {
      const ctx = canvasRef.current?.getContext("2d")
      ctx?.drawImage(img, 0, 0)

      worker.postMessage({ type: "analyze", imageData: objectUrl })
      worker.onmessage = (e) => {
        console.log("Analysis complete:", e.data)
      }
    }

    img.src = objectUrl
    // No cleanup — object URL, worker, and canvas context persist after unmount
    // Each mount leaks ~25MB (object URL + worker heap + canvas buffer)
  }, [imageFile])

  return <canvas ref={canvasRef} width={1920} height={1080} />
}
```

**Correct (explicit disposal for each resource type):**

```tsx
function ImageEditor({ imageFile }: { imageFile: File }) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const objectUrl = URL.createObjectURL(imageFile)
    const worker = new Worker("/image-processing-worker.js")
    const img = new Image()

    img.onload = () => {
      const ctx = canvasRef.current?.getContext("2d")
      ctx?.drawImage(img, 0, 0)

      worker.postMessage({ type: "analyze", imageData: objectUrl })
      worker.onmessage = (e) => {
        console.log("Analysis complete:", e.data)
      }
    }

    img.src = objectUrl

    return () => {
      URL.revokeObjectURL(objectUrl) // frees blob memory
      worker.terminate() // kills thread and releases worker heap
      const ctx = canvasRef.current?.getContext("2d")
      if (ctx && canvasRef.current) {
        canvasRef.current.width = 0 // releases canvas buffer memory
        canvasRef.current.height = 0
      }
    }
  }, [imageFile])

  return <canvas ref={canvasRef} width={1920} height={1080} />
}
```

Reference: [MDN — URL.revokeObjectURL()](https://developer.mozilla.org/en-US/docs/Web/API/URL/revokeObjectURL_static)

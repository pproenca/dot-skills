---
title: Release Heavy Resources When Not Needed
impact: LOW-MEDIUM
impactDescription: 50-200MB memory freed when releasing camera/video/maps
tags: mem, resources, camera, video, release
---

## Release Heavy Resources When Not Needed

Explicitly release camera, video players, maps, and other heavy native resources when components are hidden or backgrounded. These don't automatically garbage collect.

**Incorrect (camera stays active when hidden):**

```typescript
function CameraScreen() {
  const [hasPermission, setHasPermission] = useState(null)

  useEffect(() => {
    Camera.requestCameraPermissionsAsync().then(({ status }) => {
      setHasPermission(status === 'granted')
    })
  }, [])

  if (!hasPermission) return <PermissionRequest />

  return (
    <Camera style={styles.camera} type={Camera.Constants.Type.back}>
      <CameraOverlay />
    </Camera>
  )
}
// Camera continues running when navigating away
```

**Correct (release camera when not visible):**

```typescript
import { useFocusEffect } from '@react-navigation/native'

function CameraScreen() {
  const [hasPermission, setHasPermission] = useState(null)
  const [isFocused, setIsFocused] = useState(true)

  useEffect(() => {
    Camera.requestCameraPermissionsAsync().then(({ status }) => {
      setHasPermission(status === 'granted')
    })
  }, [])

  useFocusEffect(
    useCallback(() => {
      setIsFocused(true)
      return () => setIsFocused(false)  // Release when screen loses focus
    }, [])
  )

  if (!hasPermission) return <PermissionRequest />
  if (!isFocused) return <View style={styles.camera} />  // Placeholder

  return (
    <Camera style={styles.camera} type={Camera.Constants.Type.back}>
      <CameraOverlay />
    </Camera>
  )
}
```

**Video player resource management:**

```typescript
import { useVideoPlayer, VideoView } from 'expo-video'
import { useFocusEffect } from '@react-navigation/native'

function VideoScreen({ videoUrl }) {
  const player = useVideoPlayer(videoUrl)

  useFocusEffect(
    useCallback(() => {
      // Resume when focused
      player.play()

      return () => {
        // Pause and release when unfocused
        player.pause()
      }
    }, [player])
  )

  return <VideoView player={player} style={styles.video} />
}
```

**App state handling for background:**

```typescript
import { AppState } from 'react-native'

function MediaPlayer({ source }) {
  const playerRef = useRef(null)
  const appState = useRef(AppState.currentState)

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (appState.current === 'active' && nextAppState.match(/inactive|background/)) {
        playerRef.current?.pause()
      }
      appState.current = nextAppState
    })

    return () => subscription.remove()
  }, [])

  return <Video ref={playerRef} source={source} />
}
```

**Heavy resources to manage:**
- Camera preview
- Video players
- Audio sessions
- Map views
- WebGL contexts
- Large image caches

Reference: [Expo Camera Documentation](https://docs.expo.dev/versions/latest/sdk/camera/)

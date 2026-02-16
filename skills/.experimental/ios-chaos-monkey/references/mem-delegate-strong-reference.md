---
title: "Strong Delegate Reference Prevents Deallocation"
impact: HIGH
impactDescription: "entire view controller hierarchy leaked on each navigation"
tags: mem, delegate, strong-reference, weak, protocol
---

## Strong Delegate Reference Prevents Deallocation

A delegate property declared as `var delegate: SomeDelegate` creates a strong reference to the delegate. When the delegate (typically a ViewController) also holds a strong reference to the delegating object (a MediaPlayer), a retain cycle forms. The entire ViewController hierarchy leaks on every navigation push/pop.

**Incorrect (leaks PlayerViewController on every navigation pop):**

```swift
import Foundation

protocol MediaPlayerDelegate: AnyObject {
    func playerDidFinish(_ player: MediaPlayer)
}

final class MediaPlayer {
    var delegate: MediaPlayerDelegate? // strong reference — retains the delegate
    private var trackURL: URL?

    func play(url: URL) {
        trackURL = url
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            self.delegate?.playerDidFinish(self)
        }
    }

    deinit { print("MediaPlayer deallocated") }
}

final class PlayerViewController: UIViewController, MediaPlayerDelegate {
    private let player = MediaPlayer() // VC owns player

    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self // player now owns VC — cycle formed
    }

    func playerDidFinish(_ player: MediaPlayer) {
        print("Playback complete")
    }

    deinit { print("PlayerViewController deallocated") }
}
```

**Proof Test (exposes the leak — neither object deallocates):**

```swift
import XCTest
@testable import MyApp

final class MediaPlayerDelegateLeakTests: XCTestCase {

    func testPlayerViewControllerDeallocatesAfterDismissal() {
        weak var weakVC: PlayerViewController?
        weak var weakPlayer: MediaPlayer?

        autoreleasepool {
            let vc = PlayerViewController()
            weakVC = vc
            vc.loadViewIfNeeded()
            // Both vc and its player should be released here
        }

        XCTAssertNil(weakVC, "PlayerViewController leaked — delegate retained it")
    }
}
```

**Correct (weak delegate breaks the cycle, both objects deallocate):**

```swift
import Foundation

protocol MediaPlayerDelegate: AnyObject {
    func playerDidFinish(_ player: MediaPlayer)
}

final class MediaPlayer {
    weak var delegate: MediaPlayerDelegate? // weak breaks the retain cycle
    private var trackURL: URL?

    func play(url: URL) {
        trackURL = url
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            self.delegate?.playerDidFinish(self)
        }
    }

    deinit { print("MediaPlayer deallocated") }
}

final class PlayerViewController: UIViewController, MediaPlayerDelegate {
    private let player = MediaPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self // safe — player holds weak reference
    }

    func playerDidFinish(_ player: MediaPlayer) {
        print("Playback complete")
    }

    deinit { print("PlayerViewController deallocated") }
}
```

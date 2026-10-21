# InSeconds Founder Feed: iOS Practical Assessment

A small SwiftUI app that shows a scrollable feed of founder stories (mock data), a detail screen, and bundled video playback using `AVPlayer`. Built with **MVVM**. I chose **Option A** (bundled video playback with AVKit).

## Environment

- Xcode: [FILL IN: version you built with, e.g. 26.4]
- iOS deployment target: 17.0 (uses `NavigationStack`, `ContentUnavailableView`, two-parameter `onChange`)
- Tested on: [FILL IN: simulator model + iOS version, and/or physical device]
- Language: Swift 5 / SwiftUI
- No third-party libraries. No API keys, tokens or secrets in the repo.

## Setup / Run

1. Clone the repository.
2. Open `InSecondsFeed.xcodeproj` in Xcode.
3. Select the `InSecondsFeed` scheme and any iPhone simulator (iOS 17+).
4. Press **Cmd+R** to run



## Architecture

```
View  <--observes--  ViewModel  --uses-->  Service (protocol)  -->  Model
```

| Layer | Files | Responsibility |
|---|---|---|
| Model | `FounderVideo` | Plain data. No SwiftUI / AVFoundation imports. |
| Service | `FeedServiceProtocol`, `MockFeedService` | Provides the feed. The mock simulates latency and success / empty / failure. A real `URLSession` service can replace it without touching UI or view models. |
| ViewModel | `FeedViewModel` | Feed loading state machine (`idle / loading / loaded / empty / failed`), pull-to-refresh, retry. |
| ViewModel | `VideoPlayerViewModel` | Owns one `AVPlayer`; handles status, play/pause state, end of video, errors and cleanup. |
| Views | `FeedView`, `FeedItemCard`, `VideoDetailView`, `VideoPlayerSection`, components | Render state only; no business logic. |

Key decisions:
- **Dependency injection** through initialisers; the composition root is `InSecondsFeedApp`.
- **`NavigationStack` + value-based `NavigationLink`** gives a standard back button and swipe-back.
- **Thumbnails are generated placeholders** (gradient + SF Symbol), so there is no network or asset dependency.
- **UI state is modelled as enums**, so impossible combinations (for example loading and error at once) cannot occur.
- **`ObservableObject`** is used for view models for familiarity and broad compatibility; migrating to `@Observable` (iOS 17) would be straightforward.

## Loading / empty / error handling

- **Loading:** full-screen spinner on first load; pull-to-refresh keeps existing content visible.
- **Empty:** `ContentUnavailableView` with a Refresh button.
- **Error:** message plus "Try again". If a refresh fails while content is already shown, the content stays.
- **Playback:** `unavailable` (no video or file missing; no retry) vs `failed` (AVFoundation error; Retry button).

## Playback and player lifecycle

- A single `AVPlayer` is created in `VideoDetailView.onAppear` (`prepare()`), and only for the opened item.
- `AVPlayerItem.status` is observed (Combine KVO) to move `loading -> ready / failed`.
- `timeControlStatus` drives the play/pause icon, so the UI reflects the real player state.
- At the end of the video the player rewinds to zero so play replays it.
- On `onDisappear`, `stop()` pauses, calls `replaceCurrentItem(with: nil)`, releases the player, cancels observers and deactivates the audio session.
- When the app leaves the foreground (`scenePhase != .active`), playback pauses.
- `AVAudioSession` uses `.playback`, so audio plays even in silent mode.
- `AVPlayerViewController` is wrapped with system controls hidden, so the custom button is the single control.

### If this were a real scrolling feed (avoiding extra AVPlayer instances)

- Feed cells show only thumbnails; they never own a player.
- Keep one shared player (or a small pool of 2-3) in a `PlayerManager`; only the visible/active cell attaches to it.
- Autoplay only the cell that is mostly in view and pause it when it scrolls away. Preload just the next item's `AVPlayerItem`, not a full `AVPlayer`.
- Release items for off-screen cells, react to memory warnings, and use HLS plus caching for network videos.

## What I completed

- Feed with 6 mock items (title, founder, description, placeholder thumbnail) in a `LazyVStack`, adaptive to iPhone sizes
- Tap opens a detail screen, with clear navigation back to the feed
- Loading, empty and error states, plus pull-to-refresh
- Option A: bundled `sample_video.mp4` playback with play/pause, tap-to-toggle, and pause/release on leaving the screen
- MVVM with a protocol-based service; unit tests for both view models
- The last feed item intentionally has no video, to demonstrate the "video unavailable" fallback

## Known limitations

- All feed items with video reuse the same sample file.
- No seek bar, fullscreen or mute controls.
- Audio interruptions (for example phone calls) are not handled explicitly; only app backgrounding is.
- No pagination or persistence; mock service only.
- The player view model is not behind a protocol, so player tests depend on the bundled file.
- No UI tests.

## With more time

- Real networking layer, pagination and image caching
- Seek, fullscreen and mute controls; Picture-in-Picture
- Autoplay vertical feed using a shared player manager (as described above)
- Player behind a protocol for fuller unit tests; UI and snapshot tests
- Audio interruption handling and an accessibility audit (Dynamic Type, VoiceOver)

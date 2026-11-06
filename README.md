# Timer for iOS

[![Tests](https://github.com/dkaera/sample_timer_ios/actions/workflows/tests.yml/badge.svg?branch=develop)](https://github.com/dkaera/sample_timer_ios/actions/workflows/tests.yml)
[![Coverage](https://codecov.io/gh/dkaera/sample_timer_ios/branch/develop/graph/badge.svg)](https://codecov.io/gh/dkaera/sample_timer_ios)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](https://www.swift.org/)

A native SwiftUI port of the Android timer at `/Users/kaera/repo_git_private/timer`.

## Open and run

1. Open `Timer.xcodeproj` in Xcode.
2. Select the **Timer** scheme and an iPhone or iPad simulator.
3. Press **Run** (Command-R).

Requires Xcode 15 or newer and iOS 17 or newer. No external packages are required. For a physical device, choose your development team under **Signing & Capabilities** and use your own bundle identifier if needed.

## Behavior

- Focus: 25 minutes; Short Break: 5 minutes; Long Break: 15 minutes.
- Start/pause preserves remaining time. Reset stops the timer and restores the current mode's duration.
- Selecting any mode stops and resets the timer, including selecting the current mode.
- Countdown ring, large time display, mode selection, and button sizing follow the Android screen.
- Uses the blue/lavender palette from the supplied Android screenshot, with corresponding dark-mode colors. The iOS palette is fixed; Android 12+ can dynamically derive its colors from wallpaper.
- At zero, the timer stops, plays a system sound in the foreground, and shows “Time's up!”. Reset or select a mode to start again. There is no automatic mode switching.
- iOS additions: saved timer state, deadline-based counting while suspended, and optional local notifications when the app is in the background. Permission is requested when starting a timer. Denying permission leaves the foreground timer usable. Background notifications use Apple's [local notification API](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app); sound delivery follows device notification and Focus settings.
- Supports iPhone, iPad, landscape, scrolling on compact screens, VoiceOver labels, and scalable timer text.

## Source

- `Timer/TimerEngine.swift`: independently testable timer state and transitions.
- `Timer/TimerModel.swift`: screen updates, persistence, foreground sound, and notification scheduling.
- `Timer/TimerScreen.swift`: SwiftUI screen and colors.
- `Timer/TimerApp.swift`: app entry point and scene lifecycle.

## Verification

Core unit tests (no simulator required):

```sh
swift test
```

Simulator UI test (choose an installed simulator):

```sh
xcodebuild -project Timer.xcodeproj -scheme Timer \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1' \
  CODE_SIGNING_ALLOWED=NO test
```

The unit tests cover default durations, countdown rounding, pause/resume, reset, mode changes, completion after suspension, and state restoration. The UI tests cover mode selection, a ticking countdown, pause, and reset. Background notification delivery and sound should also be checked on a physical iPhone before release.

# Cross-platform roadmap

## Current Android application
The existing Android application remains in :app and keeps its native Android UI and Android TextToSpeech integration.

## Desktop first slice
The :desktop module is a Compose Multiplatform desktop shell. GitHub Actions builds native packages on native runners:
- Windows: MSI installer
- macOS: DMG package (Intel/Apple Silicon runner architecture is determined by the selected GitHub runner)
- Linux: DEB package

The current desktop shell is a platform bring-up prototype. It does not yet share the complete Android lesson, quiz, progress, image, or speech implementation.

## iPhone and iPad
iOS requires an Xcode project, Apple signing configuration, and an iOS-specific UI/application entry point. This is a separate implementation milestone; Android APKs and desktop installers cannot be installed on iPhone/iPad. App Store/TestFlight distribution requires the appropriate Apple developer setup.

## Next engineering milestones
1. Extract curriculum and quiz data into a platform-neutral shared module.
2. Connect desktop UI to the shared lesson and quiz repository.
3. Add offline-capable speech/audio strategy for each platform.
4. Add a Kotlin Multiplatform iOS target and SwiftUI host app.
5. Build and test iOS Simulator/device archives on macOS runners with signing configured.

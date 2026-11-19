# Chotto Pathshala — Privacy Policy

**Last updated: 19 November 2026**

Chotto Pathshala is an offline-first learning app for children. The code includes a user-initiated YouTube IFrame player, but the app-level playback gate defaults to off. No current catalogue video is approved for playback.

## Information stored on the device

Lesson-completion progress, app preferences (language, theme, sound/voice and text size), and saved-video bookmarks are stored locally on the device. These values are used only to remember the learner's progress and app settings. The app does not send them to a developer-operated server or cloud account.

On Android, app-data backup is disabled for this release. You can remove the locally saved information by clearing Chotto Pathshala's storage/data in device settings or uninstalling the app.

## Information the app does not collect

The release described by this policy has no sign-in or account system. It does not ask for a child's name, email address, phone number, precise location, contacts, photos, camera access or microphone recordings. There is no advertising SDK, analytics SDK, crash-reporting SDK or in-app tracking SDK in this release.

The app has no account creation, public profile, chat, social feed or user-upload feature.

## Network connections and video content

The Android app includes the INTERNET permission because the code contains an embedded YouTube IFrame player. The app-level playback flag defaults to false, and the current catalogue has zero approved videos, so the player cannot be opened in the current default build. No YouTube player is loaded merely by opening the app, opening the video list or tapping a locked video card.

If a future build enables the player after the required child-directed client setup and individual video reviews, the player is created only after the user taps the Load player button. Autoplay is false; the video remains paused until the user uses YouTube's own Play control. When the embedded player loads, YouTube receives basic technical/request data; when playback begins, additional playback-related data may be sent to YouTube. The app uses YouTube's privacy-enhanced player host, but this does not mean that no data is processed. YouTube processes this information under its own terms and privacy policy. YouTube controls the video player, any YouTube-supplied advertising and related-video experience; the app cannot remove all YouTube-side processing or ads.

For Made for Kids videos, the developer must check the video's current Made for Kids status through the YouTube Data API and ensure tracking is turned off and data handling complies with applicable child-privacy laws. Each video must also pass the app's age-suitability, embedding and rights review. Parents should supervise use of online video features. See YouTube's Developer Policies and Made for Kids guidance before enabling playback.

The current default build remains locked. If the app-level flag or catalogue review state changes, this policy and the Play Console Data safety declaration must be reviewed against the exact signed AAB before publication.

## Text-to-speech

The app can use the text-to-speech service supplied by the device operating system to speak built-in lesson text. The speech engine selected in Android, iOS or desktop settings may be local or may use an online provider. If it uses an online service, that provider may process the text under its own terms and privacy policy. Chotto Pathshala does not send learner-entered text to a developer-operated speech server.

## Children and parents

The app is designed for child learners. Parents and caregivers should supervise use of the device, configure system-level speech/privacy settings and supervise any future online video playback. The app does not provide a social, messaging or user-upload service.

## Data retention and deletion

Progress and settings remain in the app's local storage until the app data is cleared or the app is uninstalled. The developer does not have a cloud copy of this local progress.

## Contact

For privacy questions or requests, use the developer contact email shown on the Chotto Pathshala Google Play listing. A working contact email must be provided in the Play listing before publication.

## Changes to this policy

If app functionality or data practices change, this policy and the in-app privacy information will be updated before the changed version is released.

---

This policy describes the intended release configuration. The developer must verify the final signed app bundle, merged Android manifest, dependency list and selected text-to-speech providers before submitting Play Console declarations. This document is not legal advice.

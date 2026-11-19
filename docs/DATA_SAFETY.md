# Chotto Pathshala — Data Safety preparation

Audit date: 19 November 2026  
Scope: feature/advanced-learning child-facing release with a default-locked YouTube IFrame player.

This is a preparation worksheet, not a completed Google Play declaration. Final Play Console answers must be based on the exact signed AAB, merged manifest, dependency/SDK scan and actual device text-to-speech providers used during testing.

## Repository-level findings

| Area | Current implementation | Data Safety preparation |
|---|---|---|
| Accounts / authentication | No sign-in or account system | No account data collected by app |
| Lesson progress | Stored in local app preferences | On-device only; not transmitted by app |
| Language / theme / sound / text size | Stored locally | On-device only; not transmitted by app |
| Saved video bookmarks | Video IDs stored in local app preferences | On-device only; not transmitted by app |
| Ads | No ad SDK found in app dependencies | No in-app ads in this release |
| Analytics / crash reporting | No analytics or crash-reporting SDK in app dependencies | No app telemetry SDK configured |
| Location / contacts / camera / microphone | Not used by app features | No app request for these permissions in the Play build |
| YouTube / online video | Official IFrame player package is present behind per-video approval and a false-by-default app gate; no current catalogue record is approved | Default build does not create the player. If the gate is enabled, YouTube receives basic technical/request data when the IFrame loads and additional playback-related data when the user starts playback. Reconcile this flow with Play Console definitions and YouTube policy. |
| Network permission | Android INTERNET permission is retained for the IFrame; unrelated network-state and sensitive permissions are stripped | Verify the merged release manifest and actual outbound traffic after build |
| Android app-data backup | Generated release manifest sets allowBackup=false | Verify the merged release manifest retains backup disabled |
| Text-to-speech | Uses the operating-system TTS service for built-in lesson text | Check the selected system voice engine; some engines may use an online provider governed by its own policy |

## Provisional Play Console approach

- Do not copy a previous Data Safety declaration.
- Do not assume a no data collected / no data shared declaration. The safe default disables the player, but an enabled YouTube IFrame sends basic data when it loads and playback-related data after the user starts a video. Determine the declaration from the exact signed AAB, actual flag value, outbound-traffic test, YouTube integration and selected TTS engine.
- Local lesson progress and preferences are not uploaded by the app in this release.
- If a build enables the gated video player, document YouTube as a third-party data recipient as required by the current Play Console definitions; review YouTube-controlled content/ads and revise Data Safety and privacy disclosures before publishing.
- Ensure this worksheet, the public privacy policy and Play Console answers remain consistent.

## Release evidence required

- [ ] Run python tool/check_child_safety.py in the Android release workflow.
- [ ] Inspect the merged release manifest from the built AAB and confirm that no unneeded permissions were merged from a plugin.
- [ ] Re-run dependency/SBOM review for the YouTube IFrame and URL-launcher dependencies.
- [ ] Test both default-gated and explicitly enabled builds on a fresh Android profile; inspect when YouTube network requests begin and which data is sent.
- [ ] Test built-in TTS with the actual system voice providers used by the target audience.
- [ ] Confirm the public privacy-policy URL and developer contact email.
- [ ] Complete and save the Play Console Data safety form only after the checks above.

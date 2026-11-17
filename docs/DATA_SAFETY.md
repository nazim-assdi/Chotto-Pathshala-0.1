# Chotto Pathshala — Data Safety preparation

Audit date: 17 November 2026  
Scope: feature/advanced-learning child-facing release after video removal.

This is a preparation worksheet, not a completed Google Play declaration. Final Play Console answers must be based on the exact signed AAB, merged manifest, dependency/SDK scan and actual device text-to-speech providers used during testing.

## Repository-level findings

| Area | Current implementation | Data Safety preparation |
|---|---|---|
| Accounts / authentication | No sign-in or account system | No account data collected by app |
| Lesson progress | Stored in local app preferences | On-device only; not transmitted by app |
| Language / theme / sound / text size | Stored locally | On-device only; not transmitted by app |
| Ads | No ad SDK found in app dependencies | No in-app ads in this release |
| Analytics / crash reporting | No analytics or crash-reporting SDK in app dependencies | No app telemetry SDK configured |
| Location / contacts / camera / microphone | Not used by app features | No app request for these permissions in the Play build |
| YouTube / online video | Player and feed code/dependencies removed; feature disabled | No YouTube request from this release configuration |
| Network permission | Release manifest configuration removes INTERNET and other unnecessary permissions | Verify the merged release manifest after build |
| Android app-data backup | Generated release manifest sets allowBackup=false | Verify the merged release manifest retains backup disabled |
| Text-to-speech | Uses the operating-system TTS service for built-in lesson text | Check the selected system voice engine; some engines may use an online provider governed by its own policy |

## Provisional Play Console approach

- Do not copy a previous Data Safety declaration.
- If the final AAB and merged manifest confirm no app/SDK data is transmitted off-device, the app may qualify for a no data collected / no data shared declaration. Confirm this against Play Console's current definitions and the selected TTS engine before submission.
- Local lesson progress and preferences are not uploaded by the app in this release.
- If a future build adds video, analytics, cloud backup, login, advertising, crash reporting, external APIs or online speech, re-audit SDK and network behaviour and revise Data Safety before publishing.
- Ensure this worksheet, the public privacy policy and Play Console answers remain consistent.

## Release evidence required

- [ ] Run python tool/check_child_safety.py in the Android release workflow.
- [ ] Inspect the merged release manifest from the built AAB and confirm that no unneeded permissions were merged from a plugin.
- [ ] Re-run dependency/SBOM review for new SDKs.
- [ ] Test on a fresh Android device/profile and inspect outbound network activity.
- [ ] Test built-in TTS with the actual system voice providers used by the target audience.
- [ ] Confirm the public privacy-policy URL and developer contact email.
- [ ] Complete and save the Play Console Data safety form only after the checks above.

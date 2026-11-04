# ছোট্ট পাঠশালা — Phase 1 foundation

This phase improves the existing Android foundation without removing the bundled lessons or quiz bank.

## Included in Phase 1
- Android launcher icon and application label.
- Internet permission reserved for later opt-in services; no third-party API is called by this phase.
- Bengali, English, and Arabic app locale declarations plus RTL support.
- Neutral illustration fallback instead of silently showing the book illustration for every unmatched word.
- Level cards use existing drawable illustrations rather than emoji-only labels.
- Arabic subject illustration mapping is separated from Islamic Studies.
- Android CI artifact is named for ছোট্ট পাঠশালা.

## Important boundaries
- This phase does not integrate a cloud provider, TTS API, account system, or cloud sync.
- Existing Android TTS remains device-provided. Voice availability and offline support depend on the installed TTS engine.
- The existing drawable collection is vector artwork, not a complete photorealistic 3D library. The 3D asset library is a subsequent content task.
- The current Android lesson and quiz JSON remains intact. Full Arabic and mathematics curriculum coverage is not claimed by this foundation phase.
- Desktop and iOS are still prototype shells until the shared learning engine is implemented in later phases.

## Build and validation
Run:
- `python scripts/validate_content.py`
- `gradle assembleDebug`

Build outputs are produced by the Android GitHub Actions workflow.

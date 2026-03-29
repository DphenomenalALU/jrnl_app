# Known Limitations & Future Work

## No-Blaze deployment
- Cloud Functions are run locally using Firebase Emulators during development/testing. Production deployment is deferred because Functions Gen 2 requires the Blaze plan.
- Firebase Storage may also be unavailable on the project plan; voice uploads can be emulated locally, but production Storage is deferred unless the project is upgraded.

## Transcription
- The transcription pipeline has a clear integration point but may still use placeholder/mock text unless a real STT provider is wired (e.g., Gemini Speech / Google STT / Whisper).

## Notifications
- Daily reminders are implemented with local notifications and preferences. Future work: richer scheduling (weekdays-only, custom messages) and deeper settings UX.

## AI insights quality
- Gemini insights are generated server-side; future work includes better prompt templates, safety guardrails, and optional user controls (tone, length).

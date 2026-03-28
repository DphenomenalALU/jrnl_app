# Firebase Security Rules (Summary)

This project uses owner-only access rules for user data.

## Firestore

Rules file: `firestore.rules`

- `prompts/{promptId}`: read-only for signed-in users (no client writes).
- `users/{uid}`: read/write only if `request.auth.uid == uid`.
- `users/{uid}/entries/{entryId}`: read/write only if `request.auth.uid == uid`.
- `users/{uid}/private/{docId}`: read/write only if `request.auth.uid == uid`.

Why this protects users:
- No user can read or modify another user’s profile, entries, transcripts, or insights.
- Prompts are shared read-only to keep the app consistent without exposing user data.

## Storage

Rules file: `storage.rules`

- `users/{uid}/**`: read/write only if `request.auth.uid == uid`.

Why this protects users:
- Voice recordings are only accessible to the owner, matching the Firestore entry ownership model.


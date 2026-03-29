# Firebase Security Rules (Summary)

This project uses **public profiles + private user content** access rules.

## Firestore

Rules file: `firestore.rules`

- `prompts/{promptId}`: read-only for signed-in users (no client writes).
- `users/{uid}`: **read** allowed for signed-in users (leaderboard + viewing profiles); **write** allowed only if owner.
- `users/{uid}/entries/{entryId}`: read/write only if `request.auth.uid == uid`.
- `users/{uid}/private/{docId}`: read/write only if `request.auth.uid == uid`.

Why this protects users:
- Users can only modify their own data.
- Journal entries (including transcripts + AI insights) are owner-only.
- Private subcollection docs are owner-only (place for PII).
- Only non-sensitive profile fields in `users/{uid}` are readable by other signed-in users so leaderboard works.

## Storage

Rules file: `storage.rules`

- `voices/{uid}/{entryId}.m4a`: read/write only if `request.auth.uid == uid`.

Why this protects users:
- Voice recordings are only accessible to the owner, matching the Firestore entry ownership model.

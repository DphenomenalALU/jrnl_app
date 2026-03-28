# Firestore ERD (Matches Implementation)

This document is the source-of-truth ERD for JRNL’s Firestore schema. It should match the collections and field names used in code.

## Collections

### `prompts/{promptId}`
- `text` (string) — prompt text shown on Home/Journal
- `date` (timestamp) — prompt effective date (used for “latest active” query)
- `active` (bool) — whether prompt is selectable (default `true`)

### `users/{uid}`
- `displayName` (string)
- `photoUrl` (string?, nullable)
- `bio` (string?, nullable)
- `location` (string?, nullable)
- `xpTotal` (number/int) — leaderboard ranking
- `streakCount` (number/int)
- `tier` (string?, nullable)
- `createdAt` (timestamp?, nullable)

### `users/{uid}/entries/{entryId}`
- `mode` (string) — `'text' | 'voice'`
- `promptText` (string)
- `bodyText` (string)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)
- `energyIndex` (number/int?, nullable)
- `moodIndex` (number/int?, nullable)
- `internalIndex` (number/int?, nullable)
- `status` (string) — `'draft' | 'uploading' | 'uploaded' | 'transcribing' | 'transcribed' | 'done'`
- `audioUrl` (string?, nullable) — Storage download URL for voice
- `transcript` (string?, nullable)
- `aiInsight` (string?, nullable)

### `users/{uid}/private/{docId}` (reserved)
Used for private per-user data that should not be readable by others. Keep PII or sensitive metadata here if needed.

## Queries that require indexes

- Latest active prompt:
  - `prompts` where `active == true` order by `date desc` limit 1
- Leaderboard:
  - `users` order by `xpTotal desc` (pagination)


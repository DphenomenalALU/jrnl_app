import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();

function allowMockTranscripts(): boolean {
  const raw =
    (functions.config().app?.mock_transcript as string | undefined) ??
    (functions.config().app?.use_mock_data as string | undefined) ??
    process.env.MOCK_TRANSCRIPT ??
    process.env.USE_MOCK_DATA ??
    "false";
  return raw === "true" || raw === "1";
}

// ---------------------------------------------------------------------------
// transcribeVoiceEntry
// ---------------------------------------------------------------------------
// Callable function: triggered by the Flutter client after a voice entry is
// uploaded to Storage (status == "uploaded").
//
// What it does:
//   1. Reads the entry document to get the audioUrl.
//   2. Marks status as "transcribing".
//   3. Calls the Google Cloud Speech-to-Text API (or a placeholder).
//   4. Writes the transcript back to Firestore and marks status "transcribed".
//
// Required Firebase env config (set with `firebase functions:config:set`):
//   speechkey.key = <Google Cloud Speech API key>
//
// For the MVP the function accepts the response without an actual STT call.
// In development you can enable mock transcripts via app.use_mock_data=true.
// ---------------------------------------------------------------------------
export const transcribeVoiceEntry = functions.https.onCall(
  async (data: { uid?: string; entryId?: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Sign-in required."
      );
    }

    const uid = context.auth.uid;
    const entryId = data.entryId;
    if (!entryId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "entryId is required."
      );
    }

    const entryRef = db
      .collection("users")
      .doc(uid)
      .collection("entries")
      .doc(entryId);

    const snap = await entryRef.get();
    if (!snap.exists) {
      throw new functions.https.HttpsError("not-found", "Entry not found.");
    }

    const entry = snap.data()!;
    const audioUrl: string | undefined = entry["audioUrl"];
    if (!audioUrl) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Entry has no audioUrl."
      );
    }

    // Mark as transcribing.
    await entryRef.update({
      status: "transcribing",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const speechKey = functions.config().speechkey?.key as string | undefined;

    let transcript = "";
    if (!speechKey) {
      if (!allowMockTranscripts()) {
        // Revert state so the UI can show "uploaded" again.
        await entryRef.update({
          status: "uploaded",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        throw new functions.https.HttpsError(
          "failed-precondition",
          "No speech-to-text key configured."
        );
      }
      transcript = "[Mock transcript — enable STT key for production.]";
    } else {
      // TODO: Use `speechKey` to call a real STT provider.
      transcript = "[Transcription placeholder — wire a real STT API here.]";
    }

    await entryRef.update({
      transcript,
      status: "transcribed",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { transcript };
  }
);

// ---------------------------------------------------------------------------
// generateInsights
// ---------------------------------------------------------------------------
// Callable function: called from the Flutter client when the user taps
// "EXPLORE DEEPLY".  Takes the entry text (or transcript) and returns an
// AI-generated insight string.
//
// Required Firebase env config:
//   gemini.key = <Gemini API key>
// ---------------------------------------------------------------------------
export const generateInsights = functions.https.onCall(
  async (data: { uid?: string; entryId?: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Sign-in required."
      );
    }

    const uid = context.auth.uid;
    const entryId = data.entryId;
    if (!entryId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "entryId is required."
      );
    }

    const entryRef = db
      .collection("users")
      .doc(uid)
      .collection("entries")
      .doc(entryId);

    const snap = await entryRef.get();
    if (!snap.exists) {
      throw new functions.https.HttpsError("not-found", "Entry not found.");
    }

    const entry = snap.data()!;
    const text: string =
      (entry["transcript"] as string | undefined) ||
      (entry["bodyText"] as string | undefined) ||
      "";

    if (!text.trim()) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Entry has no text to analyse."
      );
    }

    const geminiKey: string | undefined =
      (functions.config().gemini?.key as string | undefined) ||
      process.env.GEMINI_API_KEY;
    const geminiModel: string =
      (functions.config().gemini?.model as string | undefined) ||
      process.env.GEMINI_MODEL ||
      "gemini-2.5-flash-lite";

    // -----------------------------------------------------------------------
    // LLM integration point.
    //
    // In dev you can enable mock insights via:
    //   firebase functions:config:set app.use_mock_data=true
    //
    // For production, set a Gemini key:
    //   firebase functions:config:set gemini.key="..." gemini.model="gemini-2.5-flash-lite"
    // -----------------------------------------------------------------------
    let insight: string;
    if (!geminiKey) {
      if (!allowMockInsights()) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          'AI insights are not configured. Set functions config "gemini.key" (or enable mocks with app.use_mock_data=true).'
        );
      }
      insight =
        "Mock insight (dev/emulator).";
    } else {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 25_000);
      try {
        const prompt =
          `Analyze the following journal entry and return:\n` +
          `1) A 2–4 sentence insight.\n` +
          `2) Exactly 3 bullet points titled \"Next steps\".\n` +
          `Avoid diagnosis. Keep total under 120 words.\n\n` +
          text;

        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(
            geminiModel
          )}:generateContent`,
          {
            method: "POST",
            headers: {
              "content-type": "application/json",
              "x-goog-api-key": geminiKey,
            },
            body: JSON.stringify({
              systemInstruction: {
                role: "system",
                parts: [
                  {
                    text: "You are an empathetic journaling coach. Respond concisely and kindly.",
                  },
                ],
              },
              contents: [{ role: "user", parts: [{ text: prompt }] }],
              generationConfig: {
                temperature: 0.7,
                maxOutputTokens: 260,
              },
            }),
            signal: controller.signal,
          }
        );
        if (!response.ok) {
          const body = await response.text().catch(() => "");
          throw new Error(
            `Gemini error ${response.status}: ${body.slice(0, 400)}`
          );
        }
        const json = (await response.json()) as {
          candidates?: Array<{
            content?: { parts?: Array<{ text?: string }> };
          }>;
        };
        insight =
          json.candidates?.[0]?.content?.parts
            ?.map((p) => p.text ?? "")
            .join("")
            .trim() ?? "";
        if (!insight) {
          throw new Error("Gemini returned an empty insight.");
        }
      } catch (err) {
        throw new functions.https.HttpsError(
          "internal",
          `AI provider call failed: ${String(err)}`
        );
      } finally {
        clearTimeout(timeout);
      }
    }

    await entryRef.update({
      aiInsight: insight,
      status: "done",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { insight };
  }
);

// ---------------------------------------------------------------------------
// seedEmulatorData (local dev helper)
// ---------------------------------------------------------------------------
// HTTP function: seeds a demo dataset for Firebase Emulators.
// Safe-guarded to only run on demo projects / emulator environments.
// ---------------------------------------------------------------------------
export const seedEmulatorData = functions.https.onRequest(
  async (req, res): Promise<void> => {
    const projectId = process.env.GCLOUD_PROJECT ?? "";
    const isEmulator =
      process.env.FUNCTIONS_EMULATOR === "true" || projectId.startsWith("demo-");
    if (!isEmulator) {
      res.status(403).json({ ok: false, error: "Forbidden" });
      return;
    }

    const now = new Date();
    const dayMs = 24 * 60 * 60 * 1000;

    const promptDocs = [
      {
        id: `seed-prompt-${now.toISOString().slice(0, 10)}`,
        text: "What was one small win you had today — and what made it possible?",
        date: new Date(now.getTime()),
        active: true,
      },
      {
        id: `seed-prompt-${new Date(now.getTime() - dayMs)
          .toISOString()
          .slice(0, 10)}`,
        text: "What’s been taking up mental space lately, and what’s one next step you can take?",
        date: new Date(now.getTime() - dayMs),
        active: true,
      },
      {
        id: `seed-prompt-${new Date(now.getTime() - 2 * dayMs)
          .toISOString()
          .slice(0, 10)}`,
        text: "Name one thing you’re grateful for — and one thing you want to improve tomorrow.",
        date: new Date(now.getTime() - 2 * dayMs),
        active: true,
      },
    ];

    const leaderboardUsers = [
      { uid: "seed_user_1", displayName: "Amina", xpTotal: 120, streakCount: 4 },
      { uid: "seed_user_2", displayName: "Kofi", xpTotal: 340, streakCount: 10 },
      { uid: "seed_user_3", displayName: "Lina", xpTotal: 80, streakCount: 2 },
      { uid: "seed_user_4", displayName: "Sam", xpTotal: 260, streakCount: 7 },
    ];

    const batch = db.batch();

    for (const p of promptDocs) {
      batch.set(
        db.collection("prompts").doc(p.id),
        {
          text: p.text,
          date: admin.firestore.Timestamp.fromDate(p.date),
          active: p.active,
        },
        { merge: true }
      );
    }

    for (const u of leaderboardUsers) {
      batch.set(
        db.collection("users").doc(u.uid),
        {
          uid: u.uid,
          displayName: u.displayName,
          xpTotal: u.xpTotal,
          streakCount: u.streakCount,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    await batch.commit();
    res.json({ ok: true, prompts: promptDocs.length, users: leaderboardUsers.length });
  }
);

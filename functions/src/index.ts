import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();

function isTruthy(value: unknown): boolean {
  if (value === true) return true;
  if (typeof value === "number") return value === 1;
  if (typeof value !== "string") return false;
  return ["1", "true", "yes", "y", "on"].includes(value.trim().toLowerCase());
}

function allowMockTranscripts(): boolean {
  const cfg = functions.config();
  return (
    isTruthy(cfg?.app?.mock_transcript) ||
    isTruthy(cfg?.app?.use_mock_data) ||
    isTruthy(process.env.MOCK_TRANSCRIPT) ||
    isTruthy(process.env.USE_MOCK_DATA)
  );
}

function allowMockInsights(): boolean {
  const cfg = functions.config();
  return (
    isTruthy(cfg?.app?.mock_insight) ||
    isTruthy(cfg?.app?.use_mock_data) ||
    isTruthy(process.env.MOCK_INSIGHT) ||
    isTruthy(process.env.USE_MOCK_DATA)
  );
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

    const speechKey: string | undefined =
      (functions.config().speechkey?.key as string | undefined) ||
      process.env.SPEECH_KEY;

    if (!speechKey && !allowMockTranscripts()) {
      await entryRef.update({
        status: "uploaded",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      throw new functions.https.HttpsError(
        "failed-precondition",
        'Speech-to-text is not configured. Set functions config "speechkey.key" (or enable mocks with app.use_mock_data=true).'
      );
    }

    // -----------------------------------------------------------------------
    // STT integration point.
    //
    // Replace the block below with a real Google Speech-to-Text (or Whisper)
    // call.  Example with Google STT:
    //
    //   const speech = new SpeechClient();
    //   const [response] = await speech.recognize({
    //     audio: { uri: `gs://...` },
    //     config: { encoding: "MP3", sampleRateHertz: 44100, languageCode: "en-US" },
    //   });
    //   const transcript = response.results
    //     ?.map(r => r.alternatives?.[0]?.transcript).join(" ") ?? "";
    // -----------------------------------------------------------------------
    const transcript =
      allowMockTranscripts()
        ? "[Mock transcript — dev only. Disable mocks for production.]"
        : "[Transcription placeholder — wire a real STT API here.]";

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
        "[Mock insight — dev only. Disable mocks + configure an AI key for production.]";
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

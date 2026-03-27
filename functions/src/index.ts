import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();

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
// For the MVP the function accepts the response without an actual STT call
// and returns a placeholder if no API key is configured.
// ---------------------------------------------------------------------------
export const transcribeVoiceEntry = functions.https.onCall(
  async (data: { uid: string; entryId: string }) => {
    const { uid, entryId } = data;
    if (!uid || !entryId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "uid and entryId are required."
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
      "[Transcription placeholder — wire a real STT API here.]";

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
//   anthropic.key = <Anthropic API key>
// ---------------------------------------------------------------------------
export const generateInsights = functions.https.onCall(
  async (data: { uid: string; entryId: string }) => {
    const { uid, entryId } = data;
    if (!uid || !entryId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "uid and entryId are required."
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

    // -----------------------------------------------------------------------
    // LLM integration point.
    //
    // Replace the block below with a real Anthropic (or OpenAI) call.
    // Example with Anthropic Messages API:
    //
    //   const anthropicKey = functions.config().anthropic?.key;
    //   const response = await fetch("https://api.anthropic.com/v1/messages", {
    //     method: "POST",
    //     headers: {
    //       "x-api-key": anthropicKey,
    //       "anthropic-version": "2023-06-01",
    //       "content-type": "application/json",
    //     },
    //     body: JSON.stringify({
    //       model: "claude-opus-4-6",
    //       max_tokens: 512,
    //       messages: [{ role: "user", content: `Analyse this journal entry and give a short, empathetic insight:\n\n${text}` }],
    //     }),
    //   });
    //   const json = await response.json();
    //   const insight = json.content?.[0]?.text ?? "";
    // -----------------------------------------------------------------------
    const insight =
      "[AI insight placeholder — wire the Anthropic API key in Firebase config.]";

    await entryRef.update({
      aiInsight: insight,
      status: "done",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { insight };
  }
);

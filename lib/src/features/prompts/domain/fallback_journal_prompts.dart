/// Curated prompts when Firestore has no active prompt (real mode).
/// One entry is chosen per sign-in session via the prompts presentation layer.
const List<String> kFallbackJournalPrompts = [
  'What is one small thing that brought you clarity today?',
  'What did you leave unsaid today?',
  'Where did you feel most like yourself today?',
  'What would you tell a close friend who felt exactly how you feel right now?',
  'What are you avoiding naming out loud—and why?',
  'What moment today do you wish you could replay—and what would you change?',
  'What felt heavier than it needed to?',
  'What tiny win deserves more credit than you gave it?',
  'If today had a headline, what would it be?',
  'What are you grateful for that is easy to overlook?',
];

/// Single default when mock mode runs without a prompt document (rare).
const String kDemoJournalPromptDefault =
    'What is one small thing that brought you clarity today?';

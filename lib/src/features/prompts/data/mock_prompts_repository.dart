import '../domain/prompt.dart';
import '../domain/prompts_repository.dart';

class MockPromptsRepository implements PromptsRepository {
  const MockPromptsRepository();

  Prompt _mockPrompt() {
    return Prompt(
      id: 'mock_prompt',
      text: 'Mock prompt: What is one small thing that brought you clarity today?',
      date: DateTime.now(),
      active: true,
    );
  }

  @override
  Stream<Prompt?> watchLatestActive() {
    return Stream.value(_mockPrompt());
  }

  @override
  Future<Prompt?> getLatestActive() async {
    return _mockPrompt();
  }
}


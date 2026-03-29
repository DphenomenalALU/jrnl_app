import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/src/features/prompts/data/mock_prompts_repository.dart';

void main() {
  group('MockPromptsRepository', () {
    test('watchLatestActive yields a prompt', () async {
      const repo = MockPromptsRepository();
      final prompt = await repo.watchLatestActive().first;
      expect(prompt, isNotNull);
      expect(prompt!.active, isTrue);
      expect(prompt.text, isNotEmpty);
    });

    test('getLatestActive yields a prompt', () async {
      const repo = MockPromptsRepository();
      final prompt = await repo.getLatestActive();
      expect(prompt, isNotNull);
      expect(prompt!.active, isTrue);
    });
  });
}

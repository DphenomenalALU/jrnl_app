import '../domain/prompt.dart';

abstract interface class PromptsRepository {
  Stream<Prompt?> watchLatestActive();
  Future<Prompt?> getLatestActive();
}


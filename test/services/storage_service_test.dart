import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_f1/services/storage_service.dart';

void main() {
  group('StorageService', () {
    test('uses safe defaults when no preferences have been saved', () async {
      final service = StorageService(store: _FakeStore());

      final settings = await service.loadSettings();

      expect(settings.bestScore, 0);
      expect(settings.soundEnabled, isTrue);
      expect(settings.highestRound, 0);
    });

    test('persists values and keeps high-score and round records', () async {
      final store = _FakeStore();
      final service = StorageService(store: store);

      await service.saveBestScore(120);
      await service.saveBestScore(40);
      await service.saveSoundEnabled(false);
      await service.saveHighestRound(4);
      await service.saveHighestRound(2);

      final settings = await service.loadSettings();
      expect(settings.bestScore, 120);
      expect(settings.soundEnabled, isFalse);
      expect(settings.highestRound, 4);
    });

    test('rejects invalid score and completed-round values', () async {
      final service = StorageService(store: _FakeStore());

      await expectLater(service.saveBestScore(-1), throwsArgumentError);
      await expectLater(service.saveHighestRound(0), throwsArgumentError);
    });
  });
}

class _FakeStore implements KeyValueStore {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _values[key] = value;
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Offline preferences used by the game.
class StorageService {
  StorageService({KeyValueStore? store}) : _store = store;

  static const String bestScoreKey = 'best_score';
  static const String soundEnabledKey = 'sound_enabled';
  static const String highestRoundKey = 'highest_round';

  final KeyValueStore? _store;

  /// The native API is created only when a read or write is attempted.
  /// This keeps first-run UI defaults available when a platform channel is not
  /// ready yet (including widget tests).
  late final KeyValueStore _preferences =
      _store ?? SharedPreferencesKeyValueStore();

  /// Reads all settings with safe defaults for a player's first launch.
  Future<GameSettings> loadSettings() async => GameSettings(
        bestScore: await _preferences.getInt(bestScoreKey) ?? 0,
        soundEnabled: await _preferences.getBool(soundEnabledKey) ?? true,
        highestRound: await _preferences.getInt(highestRoundKey) ?? 0,
      );

  /// Keeps the highest recorded score instead of overwriting it with a lower one.
  Future<void> saveBestScore(int score) async {
    if (score < 0) {
      throw ArgumentError.value(score, 'score', 'Cannot be negative.');
    }
    final storedScore = await _preferences.getInt(bestScoreKey) ?? 0;
    if (score > storedScore) {
      await _preferences.setInt(bestScoreKey, score);
    }
  }

  Future<void> saveSoundEnabled(bool enabled) =>
      _preferences.setBool(soundEnabledKey, enabled);

  /// Stores the furthest completed round, never a lower value.
  Future<void> saveHighestRound(int round) async {
    if (round < 1) {
      throw ArgumentError.value(round, 'round', 'Must be at least one.');
    }
    final storedRound = await _preferences.getInt(highestRoundKey) ?? 0;
    if (round > storedRound) {
      await _preferences.setInt(highestRoundKey, round);
    }
  }
}

class GameSettings {
  const GameSettings({
    required this.bestScore,
    required this.soundEnabled,
    required this.highestRound,
  });

  final int bestScore;
  final bool soundEnabled;
  final int highestRound;
}

/// Small adapter so persistence rules can be tested without platform channels.
abstract interface class KeyValueStore {
  Future<int?> getInt(String key);
  Future<bool?> getBool(String key);
  Future<void> setInt(String key, int value);
  Future<void> setBool(String key, bool value);
}

class SharedPreferencesKeyValueStore implements KeyValueStore {
  SharedPreferencesKeyValueStore({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<int?> getInt(String key) => _preferences.getInt(key);

  @override
  Future<bool?> getBool(String key) => _preferences.getBool(key);

  @override
  Future<void> setInt(String key, int value) => _preferences.setInt(key, value);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
}

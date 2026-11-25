import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data/f1_word_dictionary.dart';
import '../models/game_result.dart';
import '../models/grid_cell.dart';
import '../services/game_session.dart';
import '../services/puzzle_generator.dart';
import '../services/round_config.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/letter_grid.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.initialRound = 1,
    this.initialScore = 0,
    this.initialBestScore = 0,
    this.storageService,
    this.onRoundCompleted,
  });

  final int initialRound;
  final int initialScore;
  final int initialBestScore;
  final StorageService? storageService;

  /// Step 9 will use this hook to show the result screen and start next round.
  final ValueChanged<GameSession>? onRoundCompleted;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameSession _session;
  late final StorageService _storage;
  late final RoundConfig _roundConfig;
  Timer? _raceTimer;
  late int _secondsRemaining;
  int _incorrectSwipes = 0;
  bool _roundEnded = false;
  String _preview = '';
  String _feedback = 'SWIPE A WORD TO START';

  int get _currentRound => _session.currentRound;
  int get _currentScore => _session.currentScore;
  int get _bestScore => _session.bestScore;

  @override
  void initState() {
    super.initState();
    _storage = widget.storageService ?? StorageService();
    _roundConfig = RoundConfig.forRound(widget.initialRound);
    _secondsRemaining = _roundConfig.timeLimitSeconds;
    _session = GameSession(
      puzzleGenerator: PuzzleGenerator(),
      dictionary: f1Words,
      currentRound: widget.initialRound,
      currentScore: widget.initialScore,
      bestScore: widget.initialBestScore,
      gridSize: _roundConfig.gridSize,
      wordCount: _roundConfig.wordCount,
    );
    _raceTimer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
  }

  @override
  void dispose() {
    _raceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('THE GRID')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ROUND $_currentRound',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SWIPE THE GRID',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Scoreboard(
                    score: _currentScore,
                    bestScore: _bestScore,
                  ),
                  const SizedBox(height: 10),
                  _RaceStatus(
                    secondsRemaining: _secondsRemaining,
                    incorrectSwipes: _incorrectSwipes,
                    maxIncorrectSwipes: _roundConfig.maxIncorrectSwipes,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: _session.puzzle.targetWords
                        .map(
                          (word) => Chip(
                            label: Text(word),
                            backgroundColor: _session.foundWords.contains(word)
                                ? const Color(0xFF137A45)
                                : AppColors.surface,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  LetterGrid(
                    grid: _session.puzzle.grid,
                    foundCells: _session.foundCells,
                    onSelectionChanged: (cells) => setState(
                      () => _preview = cells.map((cell) => cell.letter).join(),
                    ),
                    onSelectionCompleted: _validateSelection,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _preview.isEmpty ? '—' : _preview,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.racingRed,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, .12),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      _feedback,
                      key: ValueKey(_feedback),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validateSelection(List<GridCell> cells) {
    if (_roundEnded) {
      return;
    }
    final selectedWord = cells.map((cell) => cell.letter).join();
    final matchedWord = _session.matchingTarget(selectedWord);
    final result = _session.submitSelection(cells);
    final hasUsedFinalMiss = result == SelectionResult.invalid &&
        _incorrectSwipes + 1 >= _roundConfig.maxIncorrectSwipes;

    setState(() {
      _preview = '';
      if (result == SelectionResult.invalid) {
        _incorrectSwipes++;
      }
      switch (result) {
        case SelectionResult.found:
          _feedback = '$matchedWord FOUND';
          break;
        case SelectionResult.roundCompleted:
          _feedback = '$matchedWord FOUND — ROUND COMPLETE!';
          break;
        case SelectionResult.duplicate:
          _feedback = '$matchedWord ALREADY FOUND';
          break;
        case SelectionResult.invalid:
          _feedback = 'NO MATCH — TRY AGAIN';
          break;
      }
    });
    if (result == SelectionResult.roundCompleted) {
      _endRound(completed: true);
    } else if (hasUsedFinalMiss) {
      _endRound(completed: false);
    } else if (result == SelectionResult.found) {
      _saveBestScore();
    }
    _playSelectionHaptic(result);
  }

  void _onTimerTick(Timer _) {
    if (!mounted || _roundEnded) {
      return;
    }
    if (_secondsRemaining <= 1) {
      setState(() => _secondsRemaining = 0);
      _endRound(completed: false);
      return;
    }
    setState(() => _secondsRemaining--);
  }

  void _endRound({required bool completed}) {
    if (_roundEnded) {
      return;
    }
    _roundEnded = true;
    _raceTimer?.cancel();
    if (completed) {
      _saveCompletedRound();
    } else {
      _saveBestScore();
      _playLossHaptic();
    }
    widget.onRoundCompleted?.call(_session);
    if (!mounted) {
      return;
    }
    final result = GameResult(
      roundNumber: _session.currentRound,
      score: _session.currentScore,
      wordsFound: _session.foundWords.length,
      totalWords: _session.puzzle.targetWords.length,
      completed: completed,
    );
    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          result: result,
          bestScore: _session.bestScore,
          onNextRound: () => navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => completed
                  ? GameScreen(
                      initialRound: _session.currentRound + 1,
                      initialScore: _session.currentScore,
                      initialBestScore: _session.bestScore,
                      storageService: _storage,
                    )
                  : GameScreen(
                      initialBestScore: _session.bestScore,
                      storageService: _storage,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBestScore() async {
    try {
      await _storage.saveBestScore(_session.bestScore);
    } catch (_) {
      // The current round remains playable if persistence is unavailable.
    }
  }

  Future<void> _playSelectionHaptic(SelectionResult result) async {
    try {
      switch (result) {
        case SelectionResult.roundCompleted:
          await HapticFeedback.mediumImpact();
          break;
        case SelectionResult.found:
          await HapticFeedback.lightImpact();
          break;
        case SelectionResult.duplicate:
        case SelectionResult.invalid:
          await HapticFeedback.selectionClick();
          break;
      }
    } catch (_) {
      // Haptics are optional and should never interrupt play on unsupported devices.
    }
  }

  Future<void> _playLossHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Haptics are optional and should never interrupt play on unsupported devices.
    }
  }

  Future<void> _saveCompletedRound() async {
    try {
      await _storage.saveBestScore(_session.bestScore);
      await _storage.saveHighestRound(_session.currentRound);
    } catch (_) {
      // Results and next-round progression do not depend on disk availability.
    }
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.score, required this.bestScore});

  final int score;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ScoreValue(label: 'SCORE', value: score),
        _ScoreValue(label: 'BEST', value: bestScore),
      ],
    );
  }
}

class _ScoreValue extends StatelessWidget {
  const _ScoreValue({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _RaceStatus extends StatelessWidget {
  const _RaceStatus({
    required this.secondsRemaining,
    required this.incorrectSwipes,
    required this.maxIncorrectSwipes,
  });

  final int secondsRemaining;
  final int incorrectSwipes;
  final int maxIncorrectSwipes;

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RaceStatusValue(
          icon: Icons.timer_outlined,
          label: '$minutes:$seconds',
          semanticLabel: '$secondsRemaining seconds remaining',
        ),
        _RaceStatusValue(
          icon: Icons.close_rounded,
          label: '$incorrectSwipes / $maxIncorrectSwipes',
          semanticLabel:
              '$incorrectSwipes of $maxIncorrectSwipes incorrect swipes',
        ),
      ],
    );
  }
}

class _RaceStatusValue extends StatelessWidget {
  const _RaceStatusValue({
    required this.icon,
    required this.label,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

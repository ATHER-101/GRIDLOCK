import 'package:material_ui/material_ui.dart';

import '../models/game_result.dart';
import '../theme/app_colors.dart';

/// Shows the completed round and lets the player proceed to the next one.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.bestScore,
    required this.onNextRound,
  });

  final GameResult result;
  final int bestScore;
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ROUND RESULTS')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    result.completed
                        ? Icons.emoji_events_rounded
                        : Icons.timer_off_rounded,
                    color: result.completed
                        ? AppColors.racingRed
                        : AppColors.muted,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result.completed ? 'ROUND COMPLETE' : 'ROUND FAILED',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ROUND ${result.roundNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ResultStat(label: 'TOTAL SCORE', value: '${result.score}'),
                  const SizedBox(height: 12),
                  _ResultStat(
                    label: 'WORDS FOUND',
                    value: '${result.wordsFound} / ${result.totalWords}',
                  ),
                  const SizedBox(height: 12),
                  _ResultStat(label: 'PERSONAL BEST', value: '$bestScore'),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: onNextRound,
                    icon: Icon(
                      result.completed
                          ? Icons.arrow_forward_rounded
                          : Icons.restart_alt_rounded,
                    ),
                    label: Text(
                      result.completed ? 'NEXT ROUND' : 'START AGAIN',
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
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

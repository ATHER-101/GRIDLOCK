import 'package:material_ui/material_ui.dart';

import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialBestScore = 0,
    this.storageService,
  });

  final int initialBestScore;
  final StorageService? storageService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _logoAsset = 'lib/assets/images/f1_logo-bgless.png';
  final _logoKey = GlobalKey();
  late final AnimationController _launchController;
  late final Animation<double> _homeOpacity;
  Rect? _logoDestination;
  bool _soundEnabled = true;
  late final StorageService _storage;
  late int _bestScore;

  @override
  void initState() {
    super.initState();
    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _homeOpacity = CurvedAnimation(
      parent: _launchController,
      curve: const Interval(.32, 1, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderObject = _logoKey.currentContext?.findRenderObject();
      if (!mounted || renderObject is! RenderBox || !renderObject.hasSize) {
        _launchController.forward();
        return;
      }
      final origin = renderObject.localToGlobal(Offset.zero);
      setState(() {
        _logoDestination = origin & renderObject.size;
      });
      _launchController.forward();
    });
    _storage = widget.storageService ?? StorageService();
    _bestScore = widget.initialBestScore;
    _loadSettings();
  }

  @override
  void dispose() {
    _launchController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    GameSettings settings;
    try {
      settings = await _storage.loadSettings();
    } catch (_) {
      // Keep first-run defaults if the platform store is temporarily unavailable.
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _bestScore =
          settings.bestScore > _bestScore ? settings.bestScore : _bestScore;
      _soundEnabled = settings.soundEnabled;
    });
  }

  void _toggleSound() {
    setState(() => _soundEnabled = !_soundEnabled);
    _saveSoundPreference();
  }

  Future<void> _saveSoundPreference() async {
    try {
      await _storage.saveSoundEnabled(_soundEnabled);
    } catch (_) {
      // The visual setting still applies for this game session.
    }
  }

  @override
  Widget build(BuildContext context) {
    final compactLayout = MediaQuery.sizeOf(context).height < 680;
    return Scaffold(
      body: Stack(
        children: [
          const _RacingBackground(),
          FadeTransition(
            opacity: _homeOpacity,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: _soundEnabled ? 'Sound on' : 'Sound off',
                              onPressed: _toggleSound,
                              icon: Icon(
                                _soundEnabled
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compactLayout ? 12 : 28),
                        Image.asset(
                          _logoAsset,
                          key: _logoKey,
                          height: compactLayout ? 112 : 150,
                          fit: BoxFit.contain,
                          semanticLabel: 'GRIDLOCK Formula 1 logo',
                        ),
                        SizedBox(height: compactLayout ? 14 : 24),
                        const Text(
                          'GRIDLOCK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Text(
                          'F1 WORD GRID',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.racingRed,
                            fontSize: 22,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'FIND THE WORDS. OWN THE GRID.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: compactLayout ? 34 : 52),
                        _BestScoreCard(score: _bestScore),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => GameScreen(
                                initialBestScore: _bestScore,
                                storageService: _storage,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.grid_3x3_rounded),
                          label: const Text('PLAY GRID'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_logoDestination != null)
            AnimatedBuilder(
              animation: _launchController,
              builder: (context, child) {
                final size = MediaQuery.sizeOf(context);
                final destination = _logoDestination!;
                final initialWidth = size.width - 56;
                final initialHeight = initialWidth * 130 / 425;
                final initial = Rect.fromCenter(
                  center: Offset(size.width / 2, size.height / 2),
                  width: initialWidth,
                  height: initialHeight,
                );
                final progress = CurvedAnimation(
                  parent: _launchController,
                  curve: Curves.easeInOutCubic,
                ).value;
                final rect = Rect.lerp(initial, destination, progress)!;
                final opacity = 1 -
                    Curves.easeIn.transform(
                      ((_launchController.value - .84) / .16).clamp(0.0, 1.0),
                    );
                return Positioned.fromRect(
                  rect: rect,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: opacity,
                      child: Image.asset(_logoAsset, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BestScoreCard extends StatelessWidget {
  const _BestScoreCard({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERSONAL BEST',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TOP LAP SCORE',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '$score',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RacingBackground extends StatelessWidget {
  const _RacingBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.background)),
          Positioned(
            right: -105,
            top: 190,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.surfaceLight.withValues(alpha: .42),
                    AppColors.background.withValues(alpha: 0),
                  ],
                ),
                border: Border.all(
                  color: AppColors.muted.withValues(alpha: .14),
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 205,
                  height: 205,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceLight.withValues(alpha: .55),
                      width: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

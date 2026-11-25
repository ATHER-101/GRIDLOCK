import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WordHuntF1App());
}

class WordHuntF1App extends StatelessWidget {
  const WordHuntF1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRIDLOCK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

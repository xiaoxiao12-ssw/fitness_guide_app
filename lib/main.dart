import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'pages/exercise_list_page.dart';
import 'pages/diet_estimator_page.dart';
import 'pages/fat_loss_predictor_page.dart';
import 'pages/favorites_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const FitnessGuideApp());
}

class FitnessGuideApp extends StatefulWidget {
  const FitnessGuideApp({super.key});

  @override
  State<FitnessGuideApp> createState() => _FitnessGuideAppState();
}

class _FitnessGuideAppState extends State<FitnessGuideApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    HapticFeedback.lightImpact();
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          _themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '少伟健身通',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: MainNavigationScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const MainNavigationScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ExerciseListPage(),
    DietEstimatorPage(),
    FatLossPredictorPage(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final activeAccent = AppTheme.accentPrimary(isDark);

    return Scaffold(
      extendBody: false,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // 悬浮深浅色快速切换胶囊按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 14,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onToggleTheme,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurfaceElevated.withOpacity(0.9)
                        : Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? AppTheme.neonLime : const Color(0xFF475569),
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.07),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.fitness_center_rounded, '动作库', activeAccent, isDark),
                _navItem(1, Icons.restaurant_rounded, '饮食估算', activeAccent, isDark),
                _navItem(2, Icons.auto_graph_rounded, '减脂预测', activeAccent, isDark),
                _navItem(3, Icons.bookmark_rounded, '我的收藏', activeAccent, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label,
    Color activeAccent,
    bool isDark,
  ) {
    final selected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? activeAccent.withOpacity(isDark ? 0.14 : 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: selected ? 23 : 21,
                color: selected ? activeAccent : AppTheme.textSecondary(isDark),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? activeAccent : AppTheme.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/exercise_list_page.dart';
import 'pages/favorites_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const FitnessGuideApp());
}

class FitnessGuideApp extends StatefulWidget {
  const FitnessGuideApp({super.key});

  @override
  State<FitnessGuideApp> createState() => _FitnessGuideAppState();
}

class _FitnessGuideAppState extends State<FitnessGuideApp> {
  ThemeMode _themeMode = ThemeMode.dark; // 健身 App 默认采用硬核暗黑高级质感

  void _toggleTheme() {
    HapticFeedback.lightImpact();
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '少伟健身通',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFFEA580C),
          primary: const Color(0xFFEA580C), // 活力燃脂橙
          secondary: const Color(0xFF0284C7), // 力量极光蓝
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFEA580C),
          primary: const Color(0xFFEA580C),
          secondary: const Color(0xFF38BDF8),
          surface: const Color(0xFF1E293B),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF8FAFC),
          ),
          iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E293B),
          elevation: 0,
        ),
      ),
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
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // 悬浮深浅色切换按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                tooltip: isDark ? "切换为浅色主题" : "切换为硬核暗黑主题",
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
                  size: 22,
                ),
                onPressed: widget.onToggleTheme,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          indicatorColor: const Color(0xFFEA580C).withOpacity(0.18),
          height: 65,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined, size: 22),
              selectedIcon: Icon(Icons.fitness_center_rounded, color: Color(0xFFEA580C), size: 24),
              label: '动作库 (58+)',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded, size: 22),
              selectedIcon: Icon(Icons.bookmark_rounded, color: Color(0xFFEA580C), size: 24),
              label: '我的收藏',
            ),
          ],
        ),
      ),
    );
  }
}

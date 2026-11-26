import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../data/exercise_repository.dart';
import '../services/favorite_service.dart';
import '../theme/app_theme.dart';
import 'exercise_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Exercise> _favoriteExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    FavoriteService.version.addListener(_loadFavorites);
  }

  @override
  void dispose() {
    FavoriteService.version.removeListener(_loadFavorites);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final ids = await FavoriteService.getFavoriteIds();
    final all = ExerciseRepository.getAllExercises();
    final favs = all.where((e) => ids.contains(e.id)).toList();
    if (mounted) {
      setState(() {
        _favoriteExercises = favs;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFav(String id) async {
    HapticFeedback.lightImpact();
    await FavoriteService.toggleFavorite(id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('我的训练收藏夹')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteExercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 34, horizontal: 24),
                      decoration: AppTheme.cardDecoration(isDark, radius: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.electroOrange.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_border_rounded,
                              size: 42,
                              color: AppTheme.electroOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '还没有收藏动作',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '在动作库点击书签图标，即可把今天要练的黄金动作加入专属计划！',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: AppTheme.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  itemCount: _favoriteExercises.length,
                  itemBuilder: (context, index) {
                    final ex = _favoriteExercises[index];
                    final cue = ExerciseRepository.getQuickCue(ex);
                    return Dismissible(
                      key: Key(ex.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 22),
                        decoration: BoxDecoration(
                          color: AppTheme.emberRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.white),
                      ),
                      onDismissed: (_) => _removeFav(ex.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: AppTheme.cardDecoration(isDark, radius: 20),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExerciseDetailPage(exercise: ex),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      color: const Color(0xFFF4F7FC),
                                      padding: const EdgeInsets.all(4),
                                      child: Image.network(
                                        ex.thumbUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.fitness_center_rounded,
                                          color: AppTheme.electroOrange,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ex.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.textPrimary(isDark),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          cue.action,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.iceCyan,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${ex.bodyPart} · ${ex.equipment} · ${ex.recommendedSets} · ${ex.repRange}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                AppTheme.textSecondary(isDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.textSecondary(isDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

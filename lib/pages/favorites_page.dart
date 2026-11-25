import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../data/exercise_repository.dart';
import '../services/favorite_service.dart';
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
    setState(() => _isLoading = true);
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
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("我的训练收藏夹"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteExercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "暂无收藏的动作",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "在动作列表点击书签图标，即可将常用动作收藏于此，制定专属训练计划！",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteExercises.length,
                  itemBuilder: (context, index) {
                    final ex = _favoriteExercises[index];
                    return Dismissible(
                      key: Key(ex.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) => _removeFav(ex.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              ex.imageUrl0,
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => const Icon(Icons.fitness_center_rounded),
                            ),
                          ),
                          title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "${ex.bodyPart} · ${ex.equipment} · ${ex.subMuscles.join('/')}",
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ExerciseDetailPage(exercise: ex),
                              ),
                            ).then((_) => _loadFavorites());
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

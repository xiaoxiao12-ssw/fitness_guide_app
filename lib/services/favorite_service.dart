import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favKey = 'fitness_favorite_exercise_ids_v2';

  /// 收藏变更通知器（保留原有 _favKey 与所有方法签名不变，新增实时刷新能力）
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favKey) ?? [];
  }

  static Future<bool> isFavorite(String id) async {
    final ids = await getFavoriteIds();
    return ids.contains(id);
  }

  static Future<bool> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = List<String>.from(prefs.getStringList(_favKey) ?? []);
    if (ids.contains(id)) {
      ids.remove(id);
      await prefs.setStringList(_favKey, ids);
      version.value++;
      return false;
    } else {
      ids.add(id);
      await prefs.setStringList(_favKey, ids);
      version.value++;
      return true;
    }
  }
}

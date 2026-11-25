import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diet_entry.dart';

class PortionEstimate {
  final String tag;
  final String desc;
  final int baseCalories;
  final double baseProtein;

  const PortionEstimate({
    required this.tag,
    required this.desc,
    required this.baseCalories,
    required this.baseProtein,
  });
}

class DietService {
  static const String _storageKey = 'fitness_diet_entries_v1';

  /// 全局变更通知器（饮食页与减脂预测页实时联动）
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static String todayDateKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 常见饮食快捷点选库（点一下立刻累加当日大卡与蛋白质）
  static const List<QuickFoodItem> quickFoods = [
    QuickFoodItem(id: 'rice', emoji: '🍚', name: '米饭', unit: '1碗(200g)', calories: 230, protein: 4.5, category: '主食'),
    QuickFoodItem(id: 'chicken', emoji: '🍗', name: '鸡胸肉', unit: '150g', calories: 195, protein: 36.0, category: '蛋白'),
    QuickFoodItem(id: 'egg', emoji: '🥚', name: '水煮蛋', unit: '1个', calories: 75, protein: 6.3, category: '蛋白'),
    QuickFoodItem(id: 'noodles', emoji: '🍜', name: '面条', unit: '1大碗', calories: 460, protein: 14.0, category: '常见餐'),
    QuickFoodItem(id: 'milktea', emoji: '🧋', name: '奶茶', unit: '常规中杯', calories: 380, protein: 3.0, category: '饮品'),
    QuickFoodItem(id: 'takeout', emoji: '🍱', name: '外卖盒饭', unit: '1份盖浇', calories: 760, protein: 24.0, category: '常见餐'),
    QuickFoodItem(id: 'beef', emoji: '🥩', name: '瘦牛肉', unit: '150g', calories: 245, protein: 34.0, category: '蛋白'),
    QuickFoodItem(id: 'whey', emoji: '🥛', name: '蛋白粉', unit: '1勺(30g)', calories: 120, protein: 24.0, category: '蛋白'),
    QuickFoodItem(id: 'sweetpotato', emoji: '🍠', name: '红薯/玉米', unit: '1根(180g)', calories: 165, protein: 3.5, category: '主食'),
    QuickFoodItem(id: 'salad', emoji: '🥗', name: '轻食沙拉', unit: '1份低脂', calories: 320, protein: 20.0, category: '常见餐'),
    QuickFoodItem(id: 'milk', emoji: '🧃', name: '纯牛奶', unit: '250ml', calories: 150, protein: 8.0, category: '饮品'),
    QuickFoodItem(id: 'banana', emoji: '🍌', name: '香蕉', unit: '1根', calories: 105, protein: 1.3, category: '主食'),
  ];

  /// 拍照记录用的份量/油盐自动估算模板
  static const List<PortionEstimate> portionPresets = [
    PortionEstimate(tag: '轻食少油', desc: '水煮/少油炒/轻食沙拉', baseCalories: 380, baseProtein: 28),
    PortionEstimate(tag: '正常家常', desc: '一荤一素配适中主食', baseCalories: 580, baseProtein: 26),
    PortionEstimate(tag: '重油外卖', desc: '盖浇饭/麻辣烫/炸鸡快餐', baseCalories: 840, baseProtein: 22),
    PortionEstimate(tag: '轻份加餐', desc: '水果/酸奶/小份点心', baseCalories: 240, baseProtein: 10),
  ];

  static const List<String> mealTypes = ['早餐', '午餐', '晚餐', '加餐'];

  /// 根据餐食类型 + 份量标签自动估算热量与蛋白质
  static ({int calories, double protein}) estimateByMealAndPortion(
    String mealType,
    String portionTag,
  ) {
    final preset = portionPresets.firstWhere(
      (p) => p.tag == portionTag,
      orElse: () => portionPresets[1],
    );
    double factor = 1.0;
    if (mealType == '早餐') factor = 0.80;
    if (mealType == '晚餐') factor = 0.92;
    if (mealType == '加餐') factor = 0.65;

    return (
      calories: (preset.baseCalories * factor).round(),
      protein: double.parse((preset.baseProtein * factor).toStringAsFixed(1)),
    );
  }

  /// 预留的多模态 AI 识图估算接口（后续可直接接入 Gemini / GPT-4o / 通义千问 VL）
  ///
  /// 接入方式示例：
  /// 1. 将 `imageFile.readAsBytes()` 转为 Base64
  /// 2. POST 至多模态视觉大模型 API，提示其返回 JSON: `{foodName, estimatedCalories, estimatedProtein}`
  /// 3. 解析为 [AiFoodEstimate] 返回，UI 层会自动填入估算卡片
  static Future<AiFoodEstimate?> estimateMealWithVisionAI(
    File imageFile, {
    String? apiEndpoint,
    String? apiKey,
  }) async {
    if (apiEndpoint == null || apiEndpoint.isEmpty || apiKey == null || apiKey.isEmpty) {
      // 未配置云端 API Key 时返回 null，界面自动降级为离线标签快速估算
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return null;
    }
    // TODO: 接入真实 HTTP 多模态视觉模型请求后，在此解析并返回 AiFoodEstimate
    return null;
  }

  static Future<List<DietEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(DietEntry.fromJson)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      return [];
    }
  }

  static Future<List<DietEntry>> getEntriesForDate(String dateKey) async {
    final all = await getAllEntries();
    return all.where((e) => e.dateKey == dateKey).toList();
  }

  static Future<int> getTodayTotalCalories() async {
    final todayList = await getEntriesForDate(todayDateKey());
    return todayList.fold<int>(0, (sum, e) => sum + e.calories);
  }

  static Future<void> addEntry(DietEntry entry) async {
    final all = await getAllEntries();
    all.insert(0, entry);
    // 仅保留最近 200 条记录防止本地存储无限增长
    final trimmed = all.take(200).toList();
    await _saveAll(trimmed);
  }

  static Future<void> deleteEntry(String id) async {
    final all = await getAllEntries();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
  }

  static Future<void> clearTodayEntries() async {
    final today = todayDateKey();
    final all = await getAllEntries();
    all.removeWhere((e) => e.dateKey == today);
    await _saveAll(all);
  }

  static Future<void> _saveAll(List<DietEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
    version.value++;
  }
}

class DietEntry {
  final String id;
  final String dateKey; // YYYY-MM-DD
  final String name;
  final String mealType; // 早餐 / 午餐 / 晚餐 / 加餐
  final int calories; // 大卡 (kcal)
  final double protein; // 蛋白质 (g)
  final String? portionTag; // 轻食少油 / 正常家常 / 重油外卖 / 快捷点选
  final String? imagePath; // 本地拍照/相册图片路径
  final int timestamp;

  const DietEntry({
    required this.id,
    required this.dateKey,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    this.portionTag,
    this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateKey': dateKey,
        'name': name,
        'mealType': mealType,
        'calories': calories,
        'protein': protein,
        'portionTag': portionTag,
        'imagePath': imagePath,
        'timestamp': timestamp,
      };

  factory DietEntry.fromJson(Map<String, dynamic> json) => DietEntry(
        id: (json['id'] ?? '').toString(),
        dateKey: (json['dateKey'] ?? '').toString(),
        name: (json['name'] ?? '未命名餐食').toString(),
        mealType: (json['mealType'] ?? '午餐').toString(),
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
        portionTag: json['portionTag']?.toString(),
        imagePath: json['imagePath']?.toString(),
        timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      );
}

class QuickFoodItem {
  final String id;
  final String emoji;
  final String name;
  final String unit;
  final int calories;
  final double protein;
  final String category; // 主食 / 蛋白 / 常见餐 / 饮品加餐

  const QuickFoodItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.category,
  });
}

/// 预留的多模态 AI 识图估算返回结构
class AiFoodEstimate {
  final String foodName;
  final int estimatedCalories;
  final double estimatedProtein;
  final String confidenceNote;

  const AiFoodEstimate({
    required this.foodName,
    required this.estimatedCalories,
    required this.estimatedProtein,
    required this.confidenceNote,
  });
}

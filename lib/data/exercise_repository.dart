import '../models/exercise.dart';
import 'chest_data.dart';
import 'back_data.dart';
import 'shoulder_data.dart';
import 'arms_data.dart';

class ExerciseRepository {
  static final List<Exercise> _allExercises = [
    ...chestExercises,
    ...backExercises,
    ...shoulderExercises,
    ...armsExercises,
  ];

  static List<Exercise> getAllExercises() => List.unmodifiable(_allExercises);

  static Exercise? getExerciseById(String id) {
    try {
      return _allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<String> getBodyParts() => ['全部', '胸部', '背部', '肩部', '手臂'];

  static List<String> getEquipments() => ['全部', '杠铃', '哑铃', '绳索', '固定器械', '自重'];

  /// 获取指定部位的所有细分肌束选项
  static List<String> getSubMusclesForPart(String bodyPart) {
    if (bodyPart == '胸部') {
      return ['全部细分', '上胸', '中胸', '下胸', '胸肌中缝'];
    } else if (bodyPart == '背部') {
      return ['全部细分', '背阔肌', '大圆肌', '菱形肌', '斜方肌', '竖脊肌'];
    } else if (bodyPart == '肩部') {
      return ['全部细分', '三角肌前束', '三角肌中束', '三角肌后束'];
    } else if (bodyPart == '手臂') {
      return ['全部细分', '肱二头肌', '肱三头肌', '肱肌', '前臂肌群'];
    }
    return ['全部细分'];
  }

  /// 综合多维筛选
  static List<Exercise> filterExercises({
    String bodyPart = '全部',
    String equipment = '全部',
    String subMuscle = '全部细分',
    String query = '',
  }) {
    return _allExercises.where((item) {
      // 1. 部位筛选
      if (bodyPart != '全部' && item.bodyPart != bodyPart) {
        return false;
      }

      // 2. 器械筛选
      if (equipment != '全部' && item.equipment != equipment) {
        return false;
      }

      // 3. 细分肌束筛选
      if (subMuscle != '全部细分') {
        final matchesSub = item.subMuscles.any((s) => s.contains(subMuscle)) ||
            item.targetMuscle.contains(subMuscle);
        if (!matchesSub) return false;
      }

      // 4. 关键词搜索
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchesQuery = item.name.toLowerCase().contains(q) ||
            item.englishName.toLowerCase().contains(q) ||
            item.targetMuscle.toLowerCase().contains(q) ||
            item.subMuscles.any((s) => s.toLowerCase().contains(q)) ||
            item.equipment.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }

      return true;
    }).toList();
  }
}

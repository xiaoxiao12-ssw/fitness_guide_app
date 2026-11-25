import '../models/exercise.dart';
import 'chest_data.dart';
import 'back_data.dart';
import 'shoulder_data.dart';
import 'arms_data.dart';
import 'exercise_quick_guides.dart';

class ExerciseRepository {
  static final List<Exercise> _allExercises = [
    ...chestExercises,
    ...backExercises,
    ...shoulderExercises,
    ...armsExercises,
  ];

  /// 普通健身房易得器械优先排序权重（哑铃/杠铃 > 龙门架/绳索 > 徒手/单双杠 > 固定器械）
  static int _equipmentPriority(String eq) {
    switch (eq) {
      case '哑铃':
        return 0;
      case '杠铃':
        return 1;
      case '绳索':
        return 2;
      case '自重':
        return 3;
      case '固定器械':
      default:
        return 4;
    }
  }

  static List<Exercise> getAllExercises() {
    final sorted = List<Exercise>.from(_allExercises)
      ..sort((a, b) => _equipmentPriority(a.equipment).compareTo(_equipmentPriority(b.equipment)));
    return List.unmodifiable(sorted);
  }

  static Exercise? getExerciseById(String id) {
    try {
      return _allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<String> getBodyParts() => ['全部', '胸部', '背部', '肩部', '手臂'];

  /// 适配普通健身房的 4 大高频器械筛选标签
  static List<String> getEquipments() => [
        '全部',
        '哑铃/杠铃',
        '龙门架/绳索',
        '徒手/单双杠',
      ];

  /// 判断动作器械是否匹配筛选标签
  static bool matchesEquipmentFilter(Exercise item, String filter) {
    switch (filter) {
      case '全部':
        return true;
      case '哑铃/杠铃':
        return item.equipment == '哑铃' || item.equipment == '杠铃';
      case '龙门架/绳索':
        return item.equipment == '绳索';
      case '徒手/单双杠':
        return item.equipment == '自重';
      default:
        return item.equipment == filter;
    }
  }

  /// 获取动作的 3 句极简大白话口诀（准备姿势 / 发力动作 / 避坑提醒）
  static ExerciseQuickCue getQuickCue(Exercise ex) {
    final mapped = exerciseQuickCueMap[ex.id];
    if (mapped != null) return mapped;
    return const ExerciseQuickCue(
      setup: '挺胸沉肩，收紧核心站稳',
      action: '控制下放，目标肌群发力推拉',
      warning: '别耸肩甩腰，避免关节代偿',
    );
  }

  /// 一键平替：为当前动作推荐 1~2 个同肌群的【哑铃】或【徒手】替代动作
  static List<Exercise> getSubstitutes(Exercise ex) {
    final result = <Exercise>[];
    final ids = equipmentSwapMap[ex.id];
    if (ids != null) {
      for (final id in ids) {
        final found = getExerciseById(id);
        if (found != null && found.id != ex.id) {
          result.add(found);
        }
      }
    }

    // 兜底自动匹配同部位的哑铃或自重动作
    if (result.isEmpty) {
      final candidates = _allExercises.where((item) =>
          item.id != ex.id &&
          item.bodyPart == ex.bodyPart &&
          (item.equipment == '哑铃' || item.equipment == '自重'));
      result.addAll(candidates.take(2));
    }

    return result.take(2).toList();
  }

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

  /// 综合多维筛选（默认按普通健身房高频易得器械优先排序）
  static List<Exercise> filterExercises({
    String bodyPart = '全部',
    String equipment = '全部',
    String subMuscle = '全部细分',
    String query = '',
  }) {
    final list = _allExercises.where((item) {
      if (bodyPart != '全部' && item.bodyPart != bodyPart) {
        return false;
      }

      if (!matchesEquipmentFilter(item, equipment)) {
        return false;
      }

      if (subMuscle != '全部细分') {
        final matchesSub = item.subMuscles.any((s) => s.contains(subMuscle)) ||
            item.targetMuscle.contains(subMuscle);
        if (!matchesSub) return false;
      }

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

    // 默认按普通健身房易得器械优先排序（哑铃/杠铃/龙门架/徒手排在前，固定器械在后）
    list.sort((a, b) => _equipmentPriority(a.equipment).compareTo(_equipmentPriority(b.equipment)));
    return list;
  }
}

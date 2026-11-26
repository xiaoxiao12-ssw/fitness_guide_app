import '../models/exercise.dart';
import 'chest_data.dart';
import 'back_data.dart';
import 'shoulder_data.dart';
import 'arms_data.dart';
import 'legs_data.dart';
import 'core_data.dart';
import 'exercise_quick_guides.dart';

class ExerciseRepository {
  static final List<Exercise> _allExercises = [
    ...chestExercises,
    ...backExercises,
    ...shoulderExercises,
    ...armsExercises,
    ...legsExercises,
    ...coreExercises,
  ];

  /// 普通健身房易得器械优先排序权重（哑铃 > 杠铃 > 龙门架绳索 > 徒手自重）
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
      default:
        return 4;
    }
  }

  static List<Exercise> getAllExercises() {
    final sorted = List<Exercise>.from(_allExercises)
      ..sort((a, b) => _equipmentPriority(a.equipment).compareTo(_equipmentPriority(b.equipment)));
    return List.unmodifiable(sorted);
  }

  static int get totalCount => _allExercises.length;

  static Exercise? getExerciseById(String id) {
    try {
      return _allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<String> getBodyParts() => ['全部', '胸部', '背部', '肩部', '手臂', '腿臀', '核心'];

  /// 适配普通健身房的 4 大高频黄金器械筛选标签
  static List<String> getEquipments() => [
        '全部',
        '哑铃',
        '杠铃',
        '龙门架/绳索',
        '徒手/单双杠',
      ];

  static bool matchesEquipmentFilter(Exercise item, String filter) {
    switch (filter) {
      case '全部':
        return true;
      case '哑铃':
        return item.equipment == '哑铃';
      case '杠铃':
        return item.equipment == '杠铃';
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
    return ExerciseQuickCue(
      setup: ex.prepCue,
      action: ex.concentricCue,
      warning: '控制节奏不借力，保护关节',
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
    switch (bodyPart) {
      case '胸部':
        return ['全部细分', '上胸', '中胸', '下胸', '胸肌中缝'];
      case '背部':
        return ['全部细分', '背阔肌', '大圆肌', '菱形肌', '斜方肌', '竖脊肌'];
      case '肩部':
        return ['全部细分', '三角肌前束', '三角肌中束', '三角肌后束', '斜方肌'];
      case '手臂':
        return ['全部细分', '肱二头肌', '肱三头肌', '肱肌', '前臂'];
      case '腿臀':
        return ['全部细分', '股四头肌', '臀大肌', '腘绳肌', '小腿'];
      case '核心':
        return ['全部细分', '腹直肌', '下腹', '腹斜肌', '深层核心'];
      default:
        return ['全部细分'];
    }
  }

  /// 综合多维筛选（按普通健身房高频易得器械优先排序）
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
            item.bodyPart.toLowerCase().contains(q) ||
            item.subMuscles.any((s) => s.toLowerCase().contains(q)) ||
            item.equipment.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }

      return true;
    }).toList();

    list.sort((a, b) => _equipmentPriority(a.equipment).compareTo(_equipmentPriority(b.equipment)));
    return list;
  }
}

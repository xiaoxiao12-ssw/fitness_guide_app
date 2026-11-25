import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fat_loss_profile.dart';

class FatLossService {
  static const String _profileKey = 'fitness_fat_loss_profile_v1';

  /// 全局变更通知器（减脂预测页与饮食估算页共享每日 TDEE）
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static Future<FatLossProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return const FatLossProfile();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return FatLossProfile.fromJson(map);
    } catch (_) {
      return const FatLossProfile();
    }
  }

  static Future<void> saveProfile(FatLossProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    version.value++;
  }

  /// 纯本地科学减脂预测算法（Mifflin-St Jeor 基础代谢 + MET 力量/有氧消耗 + 7700 kcal/kg 脂肪热值）
  static FatLossProjection calculateProjection(
    FatLossProfile profile, {
    int todayDietCalories = 0,
  }) {
    final double w = profile.currentWeightKg.clamp(35.0, 180.0);
    final double h = profile.heightCm.clamp(130.0, 220.0);
    final int age = profile.age.clamp(14, 80);

    // 1. 基础代谢 BMR (Mifflin-St Jeor 公式)
    final double bmr = _computeBmr(weightKg: w, heightCm: h, age: age, isMale: profile.isMale);

    // 2. 日常非运动活动消耗（轻体力/上班上学基线系数 1.25）
    final double dailyBaseline = bmr * 1.25;

    // 3. 单次训练消耗（力量 MET ≈ 5.0，中等强度有氧 MET ≈ 7.5）
    final double strengthBurn = 5.0 * w * (profile.strengthMinutes / 60.0);
    final double cardioBurn = 7.5 * w * (profile.cardioMinutes / 60.0);
    final double singleWorkoutBurn = strengthBurn + cardioBurn;

    // 4. 折算到每日的总消耗 TDEE
    final double dailyTdee = dailyBaseline + (singleWorkoutBurn * profile.workoutsPerWeek) / 7.0;

    // 5. 有效每日摄入（若用户选择同步今日饮食且今日已记录 >= 600 kcal 则采用今日记录，否则用设定值）
    final double effectiveIntake = (profile.useTodayDietIntake && todayDietCalories >= 600)
        ? todayDietCalories.toDouble()
        : profile.plannedDailyIntake.toDouble();

    final double dailyDeficit = dailyTdee - effectiveIntake;
    final double kgToLose = max(0.0, w - profile.targetWeightKg);

    if (kgToLose <= 0.05) {
      return FatLossProjection(
        bmr: bmr,
        singleWorkoutBurn: singleWorkoutBurn,
        strengthBurn: strengthBurn,
        cardioBurn: cardioBurn,
        dailyTdee: dailyTdee,
        effectiveDailyIntake: effectiveIntake,
        dailyDeficit: dailyDeficit,
        kgToLose: 0,
        estimatedWeeks: 0,
        targetDate: DateTime.now(),
        weeklyCurve: [WeeklyWeightPoint(week: 0, weightKg: w)],
        alreadyReached: true,
        hasDeficit: dailyDeficit > 0,
      );
    }

    if (dailyDeficit <= 20) {
      // 无明显热量缺口，生成 8 周平缓/微增趋势曲线提示用户调整
      final curve = <WeeklyWeightPoint>[];
      final weeklyDelta = (dailyDeficit * 7.0) / 7700.0; // <= 0
      for (int week = 0; week <= 8; week++) {
        curve.add(WeeklyWeightPoint(
          week: week,
          weightKg: double.parse((w - weeklyDelta * week).toStringAsFixed(2)),
        ));
      }
      return FatLossProjection(
        bmr: bmr,
        singleWorkoutBurn: singleWorkoutBurn,
        strengthBurn: strengthBurn,
        cardioBurn: cardioBurn,
        dailyTdee: dailyTdee,
        effectiveDailyIntake: effectiveIntake,
        dailyDeficit: dailyDeficit,
        kgToLose: kgToLose,
        estimatedWeeks: 0,
        targetDate: null,
        weeklyCurve: curve,
        alreadyReached: false,
        hasDeficit: false,
      );
    }

    // 6. 逐周动态模拟（考虑体重下降带来的基础代谢轻微自适应下降，更贴近真实减脂）
    final curve = <WeeklyWeightPoint>[WeeklyWeightPoint(week: 0, weightKg: w)];
    double simWeight = w;
    int weeks = 0;
    const int maxWeeks = 104;

    while (simWeight > profile.targetWeightKg && weeks < maxWeeks) {
      weeks++;
      final simBmr = _computeBmr(weightKg: simWeight, heightCm: h, age: age, isMale: profile.isMale);
      final simWorkout = (5.0 * simWeight * (profile.strengthMinutes / 60.0)) +
          (7.5 * simWeight * (profile.cardioMinutes / 60.0));
      final simTdee = simBmr * 1.25 + (simWorkout * profile.workoutsPerWeek) / 7.0;
      final simDeficit = max(40.0, simTdee - effectiveIntake);
      final weeklyLossKg = (simDeficit * 7.0) / 7700.0;

      simWeight = max(profile.targetWeightKg, simWeight - weeklyLossKg);
      curve.add(WeeklyWeightPoint(
        week: weeks,
        weightKg: double.parse(simWeight.toStringAsFixed(2)),
      ));
    }

    final targetDate = DateTime.now().add(Duration(days: weeks * 7));

    return FatLossProjection(
      bmr: bmr,
      singleWorkoutBurn: singleWorkoutBurn,
      strengthBurn: strengthBurn,
      cardioBurn: cardioBurn,
      dailyTdee: dailyTdee,
      effectiveDailyIntake: effectiveIntake,
      dailyDeficit: dailyDeficit,
      kgToLose: kgToLose,
      estimatedWeeks: weeks,
      targetDate: targetDate,
      weeklyCurve: curve,
      alreadyReached: false,
      hasDeficit: true,
    );
  }

  static double _computeBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    final base = 10.0 * weightKg + 6.25 * heightCm - 5.0 * age;
    return isMale ? base + 5.0 : base - 161.0;
  }
}

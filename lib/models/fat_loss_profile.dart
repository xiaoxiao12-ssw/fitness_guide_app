class FatLossProfile {
  final bool isMale;
  final int age;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final int workoutsPerWeek;
  final int strengthMinutes;
  final int cardioMinutes;
  final int plannedDailyIntake;
  final bool useTodayDietIntake;

  const FatLossProfile({
    this.isMale = true,
    this.age = 24,
    this.heightCm = 175.0,
    this.currentWeightKg = 76.0,
    this.targetWeightKg = 68.0,
    this.workoutsPerWeek = 4,
    this.strengthMinutes = 40,
    this.cardioMinutes = 20,
    this.plannedDailyIntake = 1850,
    this.useTodayDietIntake = false,
  });

  FatLossProfile copyWith({
    bool? isMale,
    int? age,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    int? workoutsPerWeek,
    int? strengthMinutes,
    int? cardioMinutes,
    int? plannedDailyIntake,
    bool? useTodayDietIntake,
  }) {
    return FatLossProfile(
      isMale: isMale ?? this.isMale,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      strengthMinutes: strengthMinutes ?? this.strengthMinutes,
      cardioMinutes: cardioMinutes ?? this.cardioMinutes,
      plannedDailyIntake: plannedDailyIntake ?? this.plannedDailyIntake,
      useTodayDietIntake: useTodayDietIntake ?? this.useTodayDietIntake,
    );
  }

  Map<String, dynamic> toJson() => {
        'isMale': isMale,
        'age': age,
        'heightCm': heightCm,
        'currentWeightKg': currentWeightKg,
        'targetWeightKg': targetWeightKg,
        'workoutsPerWeek': workoutsPerWeek,
        'strengthMinutes': strengthMinutes,
        'cardioMinutes': cardioMinutes,
        'plannedDailyIntake': plannedDailyIntake,
        'useTodayDietIntake': useTodayDietIntake,
      };

  factory FatLossProfile.fromJson(Map<String, dynamic> json) => FatLossProfile(
        isMale: json['isMale'] is bool ? json['isMale'] as bool : true,
        age: (json['age'] as num?)?.toInt() ?? 24,
        heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
        currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble() ?? 76.0,
        targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 68.0,
        workoutsPerWeek: (json['workoutsPerWeek'] as num?)?.toInt() ?? 4,
        strengthMinutes: (json['strengthMinutes'] as num?)?.toInt() ?? 40,
        cardioMinutes: (json['cardioMinutes'] as num?)?.toInt() ?? 20,
        plannedDailyIntake: (json['plannedDailyIntake'] as num?)?.toInt() ?? 1850,
        useTodayDietIntake: json['useTodayDietIntake'] is bool
            ? json['useTodayDietIntake'] as bool
            : false,
      );
}

class WeeklyWeightPoint {
  final int week;
  final double weightKg;

  const WeeklyWeightPoint({required this.week, required this.weightKg});
}

class FatLossProjection {
  final double bmr;
  final double singleWorkoutBurn;
  final double strengthBurn;
  final double cardioBurn;
  final double dailyTdee;
  final double effectiveDailyIntake;
  final double dailyDeficit;
  final double kgToLose;
  final int estimatedWeeks;
  final DateTime? targetDate;
  final List<WeeklyWeightPoint> weeklyCurve;
  final bool alreadyReached;
  final bool hasDeficit;

  const FatLossProjection({
    required this.bmr,
    required this.singleWorkoutBurn,
    required this.strengthBurn,
    required this.cardioBurn,
    required this.dailyTdee,
    required this.effectiveDailyIntake,
    required this.dailyDeficit,
    required this.kgToLose,
    required this.estimatedWeeks,
    required this.targetDate,
    required this.weeklyCurve,
    required this.alreadyReached,
    required this.hasDeficit,
  });
}

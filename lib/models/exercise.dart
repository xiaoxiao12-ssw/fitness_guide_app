class ExerciseMistake {
  final String mistake;
  final String correction;
  final String risk;

  const ExerciseMistake({
    required this.mistake,
    required this.correction,
    required this.risk,
  });

  Map<String, dynamic> toMap() => {
    'mistake': mistake,
    'correction': correction,
    'risk': risk,
  };

  factory ExerciseMistake.fromMap(Map<String, dynamic> map) => ExerciseMistake(
    mistake: map['mistake'] ?? '',
    correction: map['correction'] ?? '',
    risk: map['risk'] ?? '',
  );
}

class Exercise {
  final String id;
  final String name; // 动作中文名
  final String englishName; // 英文名
  final String dbDirectory; // GitHub free-exercise-db 对应目录名
  final String bodyPart; // 胸部 / 背部 / 肩部 / 手臂
  final String targetMuscle; // 目标主肌群 (如 胸大肌)
  final List<String> subMuscles; // 细分肌束 (如 上胸/锁骨头, 中胸/胸肋头)
  final List<String> secondaryMuscles; // 协同肌群 (如 肱三头肌, 前三角肌)
  final String equipment; // 杠铃 / 哑铃 / 绳索 / 固定器械 / 自重
  final int difficulty; // 1 ~ 5 星级

  // 准备姿态
  final String gripWidth; // 握距说明
  final String stance; // 站距/足距说明
  final String benchAngle; // 椅背角度/身体倾角
  final String scapularAndCore; // 肩胛骨状态与核心

  // 动作全流程拆解
  final String eccentric; // 离心阶段 (下放节奏与控制)
  final String bottomPause; // 底部停顿 (拉伸与消除惯性)
  final String concentric; // 向心阶段 (发力轨迹与驱动)
  final String peakContraction; // 顶峰收缩 (意念挤压点)

  // 呼吸配合
  final String breathingTip;

  // 科学训练参数
  final String recommendedSets; // 推荐组数
  final String repRange; // 次数区间
  final String rpe; // RPE 强度建议
  final int restSeconds; // 组间休息秒数

  // 避坑与防受伤指南 (3个代偿错误及纠正)
  final List<ExerciseMistake> commonMistakes;

  // 进阶/退阶替代方案
  final List<String> alternatives;

  const Exercise({
    required this.id,
    required this.name,
    required this.englishName,
    required this.dbDirectory,
    required this.bodyPart,
    required this.targetMuscle,
    required this.subMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.gripWidth,
    required this.stance,
    required this.benchAngle,
    required this.scapularAndCore,
    required this.eccentric,
    required this.bottomPause,
    required this.concentric,
    required this.peakContraction,
    required this.breathingTip,
    required this.recommendedSets,
    required this.repRange,
    required this.rpe,
    required this.restSeconds,
    required this.commonMistakes,
    required this.alternatives,
  });

  /// CDN 起始位置图片 (0.jpg)
  String get imageUrl0 =>
      "https://fastly.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises/$dbDirectory/0.jpg";

  /// CDN 顶峰收缩位置图片 (1.jpg)
  String get imageUrl1 =>
      "https://fastly.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises/$dbDirectory/1.jpg";

  /// 备用 CDN / GitHub 源路径 (0.jpg)
  String get fallbackUrl0 =>
      "https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises/$dbDirectory/0.jpg";

  /// 备用 CDN / GitHub 源路径 (1.jpg)
  String get fallbackUrl1 =>
      "https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises/$dbDirectory/1.jpg";

  /// Raw 源路径
  String get rawUrl0 =>
      "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$dbDirectory/0.jpg";

  String get rawUrl1 =>
      "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$dbDirectory/1.jpg";

  /// Bilibili 高清视频教学跳转 URL
  String get bilibiliSearchUrl =>
      "https://search.bilibili.com/all?keyword=${Uri.encodeComponent('$name 标准动作教学')}";
}

enum MotionPattern {
  pressUp,      // 卧推 / 推举（向上发力推）
  flyIn,        // 飞鸟 / 夹胸（向中线弧线夹拢）
  pullDown,     // 引体 / 高位下拉（垂直向下拉）
  rowBack,      // 划船（向后水平拉）
  raiseSide,    // 侧平举 / 反向飞鸟（向两侧展开）
  raiseFront,   // 前平举 / 耸肩（向前上方抬起）
  curlUp,       // 弯举（弧线向上卷曲）
  pushDown,     // 绳索下压（垂直向下压）
  extOverhead,  // 过顶/仰卧臂屈伸（伸肘发力）
  squat,        // 深蹲 / 箭步蹲（垂直蹬起）
  hinge,        // 硬拉 / 罗马尼亚硬拉 / 挺身（屈髋伸髋）
  hipThrust,    // 臀推（顶髋向上）
  calfRaise,    // 提踵（踮脚向上）
  crunch,       // 卷腹 / 健腹轮（屈曲核心）
  legRaise,     // 举腿 / 死虫 / 空中蹬车（下腹抬腿）
}

class ExerciseMistake {
  final String mistake;
  final String correction;
  final String risk;

  const ExerciseMistake({
    required this.mistake,
    required this.correction,
    required this.risk,
  });
}

class Exercise {
  final String id;
  final String name; // 动作中文名
  final String englishName; // 英文名
  final String gifPath; // ExerciseGymGifsDB 相对路径 (如 pectorals/barbell-bench-press.gif)
  final String bodyPart; // 胸部 / 背部 / 肩部 / 手臂 / 腿臀 / 核心
  final String targetMuscle; // 目标主肌群
  final List<String> subMuscles; // 细分肌束
  final List<String> secondaryMuscles; // 协同肌群
  final String equipment; // 哑铃 / 杠铃 / 绳索 / 自重
  final int difficulty; // 1 ~ 5
  final MotionPattern motionPattern; // 发力轨迹与离线动画模式

  // 动作节奏与呼吸提示（支持4阶段节拍器）
  final int eccentricSec; // 离心下放秒数（默认3秒）
  final int concentricSec; // 向心发力秒数（默认1秒）
  final int peakSec; // 顶峰停顿秒数（默认1秒）
  final String prepCue; // 阶段1：准备起始提示
  final String concentricCue; // 阶段2：向心发力提示
  final String peakCue; // 阶段3：顶峰控制提示
  final String eccentricCue; // 阶段4：离心还原提示
  final String breathingTip; // 呼吸节奏总结

  // 科学训练参数
  final String recommendedSets;
  final String repRange;
  final String rpe;
  final int restSeconds;

  // 常见代偿错误及纠正
  final List<ExerciseMistake> commonMistakes;

  const Exercise({
    required this.id,
    required this.name,
    required this.englishName,
    required this.gifPath,
    required this.bodyPart,
    required this.targetMuscle,
    required this.subMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.motionPattern,
    this.eccentricSec = 3,
    this.concentricSec = 1,
    this.peakSec = 1,
    required this.prepCue,
    required this.concentricCue,
    required this.peakCue,
    required this.eccentricCue,
    required this.breathingTip,
    required this.recommendedSets,
    required this.repRange,
    required this.rpe,
    required this.restSeconds,
    this.commonMistakes = const [],
  });

  /// 主 CDN 完整连贯动作 GIF（Fastly jsDelivr，国内访问速度快）
  String get gifUrl =>
      "https://fastly.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@main/$gifPath";

  /// 备用 CDN 完整连贯动作 GIF（Global jsDelivr）
  String get gifFallbackUrl =>
      "https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@main/$gifPath";

  /// 第三备用源（GitHub Raw）
  String get gifRawUrl =>
      "https://raw.githubusercontent.com/JahelCuadrado/ExerciseGymGifsDB/main/$gifPath";

  /// 列表页超轻量 WebP 缩略图（主 CDN）
  String get thumbUrl =>
      "https://fastly.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@main/${gifPath.replaceAll('.gif', '.thumb.webp')}";

  /// 列表页缩略图备用 CDN
  String get thumbFallbackUrl =>
      "https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@main/${gifPath.replaceAll('.gif', '.thumb.webp')}";

  /// Bilibili 外部 App 跳转 URL
  String get bilibiliSearchUrl =>
      "https://search.bilibili.com/all?keyword=${Uri.encodeComponent('$name 标准动作 教学')}";

  /// Bilibili 移动端内嵌 WebView 预览 URL
  String get bilibiliMobileSearchUrl =>
      "https://m.bilibili.com/search?keyword=${Uri.encodeComponent('$name 标准动作 教学')}";

  /// 节奏文本（如：吸气慢放 3秒 · 呼气发力 1秒 · 顶峰停 1秒）
  String get tempoSummary =>
      "慢放 ${eccentricSec}秒 · 发力 ${concentricSec}秒 · 顶峰 ${peakSec}秒";

  /// 所有精选 69 动作均为普通健身房高频黄金动作
  bool get isCommonGymFriendly => true;

  /// 是否可一键平替为哑铃/徒手动作
  bool get needsEquipmentSwap => equipment != '自重';
}

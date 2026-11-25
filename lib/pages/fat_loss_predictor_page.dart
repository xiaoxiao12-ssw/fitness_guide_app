import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/fat_loss_profile.dart';
import '../services/diet_service.dart';
import '../services/fat_loss_service.dart';

class FatLossPredictorPage extends StatefulWidget {
  const FatLossPredictorPage({super.key});

  @override
  State<FatLossPredictorPage> createState() => _FatLossPredictorPageState();
}

class _FatLossPredictorPageState extends State<FatLossPredictorPage> {
  FatLossProfile _profile = const FatLossProfile();
  int _todayDietCalories = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
    DietService.version.addListener(_refreshTodayDiet);
  }

  @override
  void dispose() {
    DietService.version.removeListener(_refreshTodayDiet);
    super.dispose();
  }

  Future<void> _loadAll() async {
    final profile = await FatLossService.loadProfile();
    final todayCal = await DietService.getTodayTotalCalories();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _todayDietCalories = todayCal;
      _isLoading = false;
    });
  }

  Future<void> _refreshTodayDiet() async {
    final todayCal = await DietService.getTodayTotalCalories();
    if (!mounted) return;
    setState(() => _todayDietCalories = todayCal);
  }

  void _updateProfile(FatLossProfile next) {
    setState(() => _profile = next);
    FatLossService.saveProfile(next);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final proj = FatLossService.calculateProjection(
      _profile,
      todayDietCalories: _todayDietCalories,
    );

    final String headlineText;
    final String sublineText;
    if (proj.alreadyReached) {
      headlineText = "🎉 已达成目标体重 ${_profile.targetWeightKg.toStringAsFixed(1)} kg！";
      sublineText = "当前体重已达到或低于目标，建议转为增肌/保持期";
    } else if (!proj.hasDeficit || proj.targetDate == null) {
      headlineText = "⚠️ 当前暂无有效热量缺口";
      sublineText = "日均摄入已接近或高于消耗，建议降低摄入或增加有氧/训练频次";
    } else {
      final d = proj.targetDate!;
      headlineText = "预计还需 ${proj.estimatedWeeks} 周（约 ${d.month} 月 ${d.day} 日）达成目标体重";
      if (proj.dailyDeficit > 950) {
        sublineText = "缺口偏大（>${proj.dailyDeficit.round()}千卡/天），注意补足蛋白质防掉肌肉";
      } else {
        sublineText = "需减重 ${proj.kgToLose.toStringAsFixed(1)} kg · 节奏稳健健康，最易坚持！";
      }
    }

    // 进度条视觉进度（以建议理想缺口 500 kcal 或已达成比例呈现）
    final double deficitQuality = proj.alreadyReached
        ? 1.0
        : (proj.dailyDeficit / 600.0).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("力量 + 有氧减脂预测"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 预测结果 Hero 看板 + 进度条
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: proj.hasDeficit
                            ? const Color(0xFF10B981).withOpacity(0.45)
                            : const Color(0xFFF59E0B).withOpacity(0.45),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C).withOpacity(0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "本地算法实时推演",
                                style: TextStyle(
                                  color: Color(0xFFFB923C),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "${_profile.currentWeightKg.toStringAsFixed(1)} → ${_profile.targetWeightKg.toStringAsFixed(1)} kg",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          headlineText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sublineText,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 14),

                        // 减脂效率可视化进度条
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("每日减脂推进效率", style: TextStyle(color: Colors.white60, fontSize: 11)),
                            Text(
                              proj.hasDeficit
                                  ? "约 -${((proj.dailyDeficit * 7) / 7700).toStringAsFixed(2)} kg / 周"
                                  : "0.00 kg / 周",
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: deficitQuality,
                            minHeight: 9,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              proj.hasDeficit ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 3 项核心代谢指标
                        Row(
                          children: [
                            Expanded(
                              child: _heroMetric(
                                "每日热量缺口",
                                "${proj.dailyDeficit >= 0 ? '-' : '+'}${proj.dailyDeficit.abs().round()}",
                                "kcal/天",
                                proj.hasDeficit ? const Color(0xFF34D399) : const Color(0xFFFCA5A5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _heroMetric(
                                "单次训练消耗",
                                "${proj.singleWorkoutBurn.round()}",
                                "力${proj.strengthBurn.round()}+氧${proj.cardioBurn.round()}",
                                const Color(0xFFFB923C),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _heroMetric(
                                "日均总消耗",
                                "${proj.dailyTdee.round()}",
                                "BMR ${proj.bmr.round()}",
                                const Color(0xFF38BDF8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. 每周体重变化预测曲线（纯本地 CustomPainter，无需联网）
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.show_chart_rounded, color: Color(0xFFEA580C), size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "每周体重变化预测曲线",
                                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Text(
                              "共 ${max(1, proj.weeklyCurve.length - 1)} 周",
                              style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 185,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _WeightCurvePainter(
                              points: proj.weeklyCurve,
                              targetWeightKg: _profile.targetWeightKg,
                              isDark: isDark,
                              hasDeficit: proj.hasDeficit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. 身体数据配置卡
                  _sectionCard(
                    isDark: isDark,
                    icon: Icons.person_outline_rounded,
                    iconColor: const Color(0xFF0284C7),
                    title: "身体基础与减脂目标",
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text("性别", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 14),
                            ChoiceChip(
                              label: const Text("男生"),
                              selected: _profile.isMale,
                              showCheckmark: false,
                              selectedColor: const Color(0xFF0284C7).withOpacity(0.2),
                              onSelected: (_) => _updateProfile(_profile.copyWith(isMale: true)),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text("女生"),
                              selected: !_profile.isMale,
                              showCheckmark: false,
                              selectedColor: const Color(0xFFEC4899).withOpacity(0.2),
                              onSelected: (_) => _updateProfile(_profile.copyWith(isMale: false)),
                            ),
                            const Spacer(),
                            Text(
                              "年龄 ${_profile.age} 岁",
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () => _updateProfile(
                                _profile.copyWith(age: max(16, _profile.age - 1)),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => _updateProfile(
                                _profile.copyWith(age: min(70, _profile.age + 1)),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        _sliderRow(
                          label: "当前身高",
                          valueText: "${_profile.heightCm.round()} cm",
                          value: _profile.heightCm,
                          min: 145,
                          max: 205,
                          divisions: 60,
                          color: const Color(0xFF0284C7),
                          onChanged: (v) => _updateProfile(_profile.copyWith(heightCm: v.roundToDouble())),
                        ),
                        _sliderRow(
                          label: "当前体重",
                          valueText: "${_profile.currentWeightKg.toStringAsFixed(1)} kg",
                          value: _profile.currentWeightKg,
                          min: 40,
                          max: 130,
                          divisions: 180,
                          color: const Color(0xFFEA580C),
                          onChanged: (v) {
                            final rounded = double.parse(v.toStringAsFixed(1));
                            _updateProfile(_profile.copyWith(currentWeightKg: rounded));
                          },
                        ),
                        _sliderRow(
                          label: "目标体重",
                          valueText: "${_profile.targetWeightKg.toStringAsFixed(1)} kg",
                          value: _profile.targetWeightKg,
                          min: 40,
                          max: 120,
                          divisions: 160,
                          color: const Color(0xFF10B981),
                          onChanged: (v) {
                            final rounded = double.parse(v.toStringAsFixed(1));
                            _updateProfile(_profile.copyWith(targetWeightKg: rounded));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. 力量 + 有氧训练计划配置卡
                  _sectionCard(
                    isDark: isDark,
                    icon: Icons.fitness_center_rounded,
                    iconColor: const Color(0xFFEA580C),
                    title: "每周力量 + 有氧训练计划",
                    child: Column(
                      children: [
                        _sliderRow(
                          label: "每周训练频次",
                          valueText: "${_profile.workoutsPerWeek} 次 / 周",
                          value: _profile.workoutsPerWeek.toDouble(),
                          min: 1,
                          max: 7,
                          divisions: 6,
                          color: const Color(0xFFEA580C),
                          onChanged: (v) => _updateProfile(_profile.copyWith(workoutsPerWeek: v.round())),
                        ),
                        _sliderRow(
                          label: "每次力量训练",
                          valueText: "${_profile.strengthMinutes} 分钟",
                          value: _profile.strengthMinutes.toDouble(),
                          min: 0,
                          max: 90,
                          divisions: 18,
                          color: const Color(0xFF8B5CF6),
                          onChanged: (v) => _updateProfile(_profile.copyWith(strengthMinutes: v.round())),
                        ),
                        _sliderRow(
                          label: "每次有氧训练",
                          valueText: "${_profile.cardioMinutes} 分钟",
                          value: _profile.cardioMinutes.toDouble(),
                          min: 0,
                          max: 90,
                          divisions: 18,
                          color: const Color(0xFF10B981),
                          onChanged: (v) => _updateProfile(_profile.copyWith(cardioMinutes: v.round())),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. 每日饮食热量联动卡
                  _sectionCard(
                    isDark: isDark,
                    icon: Icons.restaurant_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: "每日饮食摄入联动",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: const Color(0xFF10B981),
                          title: const Text(
                            "自动同步「饮食估算」今日热量",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _todayDietCalories >= 600
                                ? "今日已记录 $_todayDietCalories kcal（已具备同步条件）"
                                : "今日已记录 $_todayDietCalories kcal（满 600 kcal 后自动接管，不足时按下方计划估算）",
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          value: _profile.useTodayDietIntake,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            _updateProfile(_profile.copyWith(useTodayDietIntake: val));
                          },
                        ),
                        const SizedBox(height: 4),
                        _sliderRow(
                          label: "计划日均饮食摄入",
                          valueText: "${_profile.plannedDailyIntake} kcal",
                          value: _profile.plannedDailyIntake.toDouble().clamp(1100, 3200),
                          min: 1100,
                          max: 3200,
                          divisions: 42,
                          color: const Color(0xFF10B981),
                          onChanged: (v) => _updateProfile(
                            _profile.copyWith(
                              plannedDailyIntake: v.round(),
                              useTodayDietIntake: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _heroMetric(String label, String value, String sub, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(color: Colors.white54, fontSize: 9.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 19),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            Text(
              valueText,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// 纯本地离线绘制：每周体重变化预测折线与渐变面积图
class _WeightCurvePainter extends CustomPainter {
  final List<WeeklyWeightPoint> points;
  final double targetWeightKg;
  final bool isDark;
  final bool hasDeficit;

  const _WeightCurvePainter({
    required this.points,
    required this.targetWeightKg,
    required this.isDark,
    required this.hasDeficit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const double padL = 42;
    const double padR = 16;
    const double padT = 16;
    const double padB = 26;

    final double plotW = size.width - padL - padR;
    final double plotH = size.height - padT - padB;
    if (plotW <= 0 || plotH <= 0) return;

    double minW = targetWeightKg;
    double maxW = targetWeightKg;
    for (final p in points) {
      if (p.weightKg < minW) minW = p.weightKg;
      if (p.weightKg > maxW) maxW = p.weightKg;
    }
    final double span = max(2.0, maxW - minW);
    final double yMin = minW - span * 0.14;
    final double yMax = maxW + span * 0.14;

    double toX(int idx) {
      if (points.length <= 1) return padL + plotW / 2;
      return padL + (idx / (points.length - 1)) * plotW;
    }

    double toY(double kg) {
      final t = ((kg - yMin) / (yMax - yMin)).clamp(0.0, 1.0);
      return padT + plotH * (1.0 - t);
    }

    final gridPaint = Paint()
      ..color = isDark ? Colors.white12 : Colors.black12
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: isDark ? Colors.grey[400] : Colors.grey[600],
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    // 水平参考线 & Y轴刻度
    for (int i = 0; i <= 3; i++) {
      final t = i / 3.0;
      final y = padT + plotH * t;
      final kgVal = yMax - (yMax - yMin) * t;
      canvas.drawLine(Offset(padL, y), Offset(size.width - padR, y), gridPaint);
      _drawText(canvas, '${kgVal.toStringAsFixed(1)}', Offset(4, y - 6), labelStyle);
    }

    // 目标体重虚线
    final double targetY = toY(targetWeightKg);
    final targetPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.75)
      ..strokeWidth = 1.4;
    const double dashW = 5;
    const double gapW = 4;
    double dx = padL;
    while (dx < size.width - padR) {
      canvas.drawLine(
        Offset(dx, targetY),
        Offset(min(dx + dashW, size.width - padR), targetY),
        targetPaint,
      );
      dx += dashW + gapW;
    }
    _drawText(
      canvas,
      '目标 ${targetWeightKg.toStringAsFixed(1)}kg',
      Offset(size.width - padR - 64, max(2, targetY - 14)),
      const TextStyle(
        color: Color(0xFF10B981),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );

    // 构造曲线路径
    final lineColor = hasDeficit ? const Color(0xFFEA580C) : const Color(0xFFF59E0B);
    final linePath = Path();
    final areaPath = Path();

    final firstOffset = Offset(toX(0), toY(points.first.weightKg));
    linePath.moveTo(firstOffset.dx, firstOffset.dy);
    areaPath.moveTo(firstOffset.dx, padT + plotH);
    areaPath.lineTo(firstOffset.dx, firstOffset.dy);

    for (int i = 1; i < points.length; i++) {
      final prev = Offset(toX(i - 1), toY(points[i - 1].weightKg));
      final curr = Offset(toX(i), toY(points[i].weightKg));
      final midX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
      areaPath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    final lastOffset = Offset(toX(points.length - 1), toY(points.last.weightKg));
    areaPath.lineTo(lastOffset.dx, padT + plotH);
    areaPath.close();

    // 渐变面积填充
    final areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withOpacity(0.32), lineColor.withOpacity(0.01)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(padL, padT, plotW, plotH));
    canvas.drawPath(areaPath, areaPaint);

    // 折线主体
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, strokePaint);

    // 关键节点圆点与 X 轴周标签
    final int step = max(1, (points.length / 5).ceil());
    final dotFill = Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dotStroke = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final isEdge = i == 0 || i == points.length - 1;
      if (isEdge || i % step == 0) {
        final pt = Offset(toX(i), toY(points[i].weightKg));
        canvas.drawCircle(pt, isEdge ? 4.5 : 3.2, dotFill);
        canvas.drawCircle(pt, isEdge ? 4.5 : 3.2, dotStroke);

        final weekLabel = i == 0 ? '现在' : '第${points[i].week}周';
        _drawText(
          canvas,
          weekLabel,
          Offset(pt.dx - 16, padT + plotH + 6),
          labelStyle,
        );
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WeightCurvePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.targetWeightKg != targetWeightKg ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hasDeficit != hasDeficit;
  }
}

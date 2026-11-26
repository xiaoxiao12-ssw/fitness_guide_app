import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../theme/app_theme.dart';

/// 动作阶段枚举（4阶段完整发力拆解）
enum MotionPhase {
  prep,       // 0: 准备起始
  concentric, // 1: 发力收缩（向心）
  peak,       // 2: 顶峰控制
  eccentric,  // 3: 慢速还原（离心）
}

/// 动态发力轨迹箭头 + 目标肌群高亮脉冲层
class MotionTrajectoryPainter extends CustomPainter {
  final MotionPattern pattern;
  final MotionPhase phase;
  final double phaseProgress; // 0.0 ~ 1.0 within current phase
  final double cycleProgress; // 0.0 ~ 1.0 overall

  const MotionTrajectoryPainter({
    required this.pattern,
    required this.phase,
    required this.phaseProgress,
    required this.cycleProgress,
  });

  Color get _activeColor {
    switch (phase) {
      case MotionPhase.prep:
        return const Color(0xFF94A3B8);
      case MotionPhase.concentric:
        return AppTheme.electroOrange;
      case MotionPhase.peak:
        return AppTheme.neonLime;
      case MotionPhase.eccentric:
        return AppTheme.iceCyan;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final color = _activeColor;
    final bool isReturn = phase == MotionPhase.eccentric;
    final bool isPeak = phase == MotionPhase.peak;

    // 1. 目标发力热区脉冲光环（定位在对应肌群区域）
    final hotspot = _muscleHotspot(w, h);
    final pulse = isPeak
        ? 1.0 + 0.25 * math.sin(phaseProgress * math.pi * 2)
        : 0.85 + 0.15 * math.sin(cycleProgress * math.pi * 4);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(isPeak ? 0.36 : 0.20),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: hotspot, radius: 42 * pulse));
    canvas.drawCircle(hotspot, 42 * pulse, glowPaint);

    final ringPaint = Paint()
      ..color = color.withOpacity(isPeak ? 0.85 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPeak ? 2.2 : 1.4;
    canvas.drawCircle(hotspot, 14 * pulse, ringPaint);

    canvas.drawCircle(
      hotspot,
      3.5,
      Paint()..color = color,
    );

    // 2. 动态发力轨迹流动箭头
    final double flowT = (phaseProgress * 1.4) % 1.0;
    final arrowPaint = Paint()
      ..color = color.withOpacity(phase == MotionPhase.prep ? 0.45 : 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (pattern) {
      case MotionPattern.pressUp:
      case MotionPattern.squat:
      case MotionPattern.hipThrust:
      case MotionPattern.calfRaise:
        // 垂直向上向心 / 向下离心双轨发光箭头
        _drawFlowArrow(
          canvas,
          Offset(w * 0.16, isReturn ? h * 0.28 : h * 0.72),
          Offset(w * 0.16, isReturn ? h * 0.72 : h * 0.28),
          flowT,
          arrowPaint,
          color,
        );
        _drawFlowArrow(
          canvas,
          Offset(w * 0.84, isReturn ? h * 0.28 : h * 0.72),
          Offset(w * 0.84, isReturn ? h * 0.72 : h * 0.28),
          flowT,
          arrowPaint,
          color,
        );
        break;

      case MotionPattern.pullDown:
      case MotionPattern.pushDown:
        // 垂直向下向心 / 向上离心
        _drawFlowArrow(
          canvas,
          Offset(w * 0.16, isReturn ? h * 0.72 : h * 0.28),
          Offset(w * 0.16, isReturn ? h * 0.28 : h * 0.72),
          flowT,
          arrowPaint,
          color,
        );
        _drawFlowArrow(
          canvas,
          Offset(w * 0.84, isReturn ? h * 0.72 : h * 0.28),
          Offset(w * 0.84, isReturn ? h * 0.28 : h * 0.72),
          flowT,
          arrowPaint,
          color,
        );
        break;

      case MotionPattern.flyIn:
        // 左右弧线向中线合拢 / 展开
        _drawCurvedArrow(
          canvas,
          Offset(w * (isReturn ? 0.42 : 0.16), h * 0.56),
          Offset(w * 0.28, h * 0.34),
          Offset(w * (isReturn ? 0.16 : 0.42), h * 0.44),
          flowT,
          arrowPaint,
          color,
        );
        _drawCurvedArrow(
          canvas,
          Offset(w * (isReturn ? 0.58 : 0.84), h * 0.56),
          Offset(w * 0.72, h * 0.34),
          Offset(w * (isReturn ? 0.84 : 0.58), h * 0.44),
          flowT,
          arrowPaint,
          color,
        );
        break;

      case MotionPattern.raiseSide:
        // 两侧扇形向上展开 / 慢放
        _drawCurvedArrow(
          canvas,
          Offset(w * (isReturn ? 0.16 : 0.32), h * (isReturn ? 0.36 : 0.68)),
          Offset(w * 0.18, h * 0.54),
          Offset(w * (isReturn ? 0.32 : 0.16), h * (isReturn ? 0.68 : 0.36)),
          flowT,
          arrowPaint,
          color,
        );
        _drawCurvedArrow(
          canvas,
          Offset(w * (isReturn ? 0.84 : 0.68), h * (isReturn ? 0.36 : 0.68)),
          Offset(w * 0.82, h * 0.54),
          Offset(w * (isReturn ? 0.68 : 0.84), h * (isReturn ? 0.68 : 0.36)),
          flowT,
          arrowPaint,
          color,
        );
        break;

      case MotionPattern.rowBack:
        // 水平/斜后拉轨迹
        _drawFlowArrow(
          canvas,
          Offset(w * (isReturn ? 0.74 : 0.24), h * 0.52),
          Offset(w * (isReturn ? 0.24 : 0.74), h * 0.46),
          flowT,
          arrowPaint,
          color,
        );
        break;

      case MotionPattern.curlUp:
      case MotionPattern.raiseFront:
      case MotionPattern.crunch:
      case MotionPattern.legRaise:
        // 弧线向上卷曲轨迹
        _drawCurvedArrow(
          canvas,
          Offset(w * 0.20, h * (isReturn ? 0.32 : 0.70)),
          Offset(w * 0.10, h * 0.50),
          Offset(w * 0.22, h * (isReturn ? 0.70 : 0.32)),
          flowT,
          arrowPaint,
          color,
        );
        break;

      case MotionPattern.extOverhead:
      case MotionPattern.hinge:
        // 斜上伸展轨迹
        _drawCurvedArrow(
          canvas,
          Offset(w * 0.80, h * (isReturn ? 0.30 : 0.70)),
          Offset(w * 0.90, h * 0.50),
          Offset(w * 0.78, h * (isReturn ? 0.70 : 0.30)),
          flowT,
          arrowPaint,
          color,
        );
        break;
    }
  }

  Offset _muscleHotspot(double w, double h) {
    switch (pattern) {
      case MotionPattern.pressUp:
      case MotionPattern.flyIn:
        return Offset(w * 0.50, h * 0.42);
      case MotionPattern.pullDown:
      case MotionPattern.rowBack:
        return Offset(w * 0.50, h * 0.44);
      case MotionPattern.raiseSide:
      case MotionPattern.raiseFront:
        return Offset(w * 0.50, h * 0.34);
      case MotionPattern.curlUp:
      case MotionPattern.pushDown:
      case MotionPattern.extOverhead:
        return Offset(w * 0.56, h * 0.44);
      case MotionPattern.squat:
      case MotionPattern.hinge:
      case MotionPattern.hipThrust:
        return Offset(w * 0.50, h * 0.58);
      case MotionPattern.calfRaise:
        return Offset(w * 0.50, h * 0.74);
      case MotionPattern.crunch:
      case MotionPattern.legRaise:
        return Offset(w * 0.50, h * 0.54);
    }
  }

  void _drawFlowArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    double flowT,
    Paint strokePaint,
    Color color,
  ) {
    // 柔和轨迹底线
    final bgLine = Paint()
      ..color = color.withOpacity(0.22)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, bgLine);

    // 发光流动光点
    final dotPos = Offset.lerp(start, end, flowT)!;
    canvas.drawCircle(dotPos, 4.5, Paint()..color = color.withOpacity(0.9));
    canvas.drawCircle(dotPos, 9.0, Paint()..color = color.withOpacity(0.22));

    // 箭头头部
    final dir = (end - start);
    final angle = math.atan2(dir.dy, dir.dx);
    const double headLen = 10.0;
    const double spread = 0.52;
    final p1 = Offset(
      end.dx - headLen * math.cos(angle - spread),
      end.dy - headLen * math.sin(angle - spread),
    );
    final p2 = Offset(
      end.dx - headLen * math.cos(angle + spread),
      end.dy - headLen * math.sin(angle + spread),
    );
    final headPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(end.dx, end.dy)
      ..lineTo(p2.dx, p2.dy);
    canvas.drawPath(headPath, strokePaint);
  }

  void _drawCurvedArrow(
    Canvas canvas,
    Offset p0,
    Offset ctrl,
    Offset p2,
    double flowT,
    Paint strokePaint,
    Color color,
  ) {
    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, p2.dx, p2.dy);

    final bgPaint = Paint()
      ..color = color.withOpacity(0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bgPaint);

    // 二次贝塞尔曲线流动光点
    final inv = 1.0 - flowT;
    final bx = inv * inv * p0.dx + 2 * inv * flowT * ctrl.dx + flowT * flowT * p2.dx;
    final by = inv * inv * p0.dy + 2 * inv * flowT * ctrl.dy + flowT * flowT * p2.dy;
    canvas.drawCircle(Offset(bx, by), 4.2, Paint()..color = color);
    canvas.drawCircle(Offset(bx, by), 8.5, Paint()..color = color.withOpacity(0.22));

    // 终点切线箭头
    final angle = math.atan2(p2.dy - ctrl.dy, p2.dx - ctrl.dx);
    const double headLen = 10.0;
    const double spread = 0.52;
    final h1 = Offset(
      p2.dx - headLen * math.cos(angle - spread),
      p2.dy - headLen * math.sin(angle - spread),
    );
    final h2 = Offset(
      p2.dx - headLen * math.cos(angle + spread),
      p2.dy - headLen * math.sin(angle + spread),
    );
    final headPath = Path()
      ..moveTo(h1.dx, h1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(h2.dx, h2.dy);
    canvas.drawPath(headPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant MotionTrajectoryPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.phaseProgress != phaseProgress ||
        oldDelegate.pattern != pattern;
  }
}

/// 离线/网络异常时的 60fps 流畅本地生物力学骨架动画回退组件（彻底告别僵硬静态图）
class OfflineBiomechanicalPainter extends CustomPainter {
  final MotionPattern pattern;
  final double motionT; // 0.0 (起始位) -> 1.0 (顶峰位) 平滑往复
  final Color accentColor;

  const OfflineBiomechanicalPainter({
    required this.pattern,
    required this.motionT,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    final scale = math.min(size.width, size.height) * 0.34;

    // 柔和网格科技底座
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (int i = -2; i <= 2; i++) {
      final y = cy + scale * 1.15 + i * 10;
      canvas.drawLine(Offset(cx - scale * 1.5, y), Offset(cx + scale * 1.5, y), gridPaint);
    }

    final bonePaint = Paint()
      ..color = Colors.white.withOpacity(0.88)
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final barPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()..color = accentColor;
    final muscleGlow = Paint()
      ..color = accentColor.withOpacity(0.28 + 0.25 * motionT)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // 根据动作模式计算连续关节坐标
    final t = Curves.easeInOutCubic.transform(motionT.clamp(0.0, 1.0));

    if (pattern == MotionPattern.squat || pattern == MotionPattern.calfRaise) {
      // 深蹲 / 提踵连续动画
      final drop = pattern == MotionPattern.squat ? t * scale * 0.52 : -t * scale * 0.14;
      final hip = Offset(cx - drop * 0.35, cy + scale * 0.1 + drop);
      final shoulder = Offset(cx + drop * 0.18, cy - scale * 0.55 + drop);
      final head = Offset(shoulder.dx + 4, shoulder.dy - scale * 0.24);
      final knee = Offset(cx + scale * 0.22 + drop * 0.35, cy + scale * 0.55 + drop * 0.3);
      final ankle = Offset(cx, cy + scale * 1.02);

      // 发光臀腿核心区
      canvas.drawCircle(Offset.lerp(hip, knee, 0.45)!, 22, muscleGlow);
      // 躯干与下肢
      canvas.drawLine(shoulder, hip, bonePaint);
      canvas.drawLine(hip, knee, bonePaint);
      canvas.drawLine(knee, ankle, bonePaint);
      canvas.drawCircle(head, scale * 0.15, bonePaint);
      // 杠铃杆
      canvas.drawLine(
        Offset(shoulder.dx - scale * 0.5, shoulder.dy),
        Offset(shoulder.dx + scale * 0.5, shoulder.dy),
        barPaint,
      );
      for (final p in [shoulder, hip, knee]) {
        canvas.drawCircle(p, 4.5, jointPaint);
      }
    } else if (pattern == MotionPattern.hinge || pattern == MotionPattern.hipThrust) {
      // 硬拉 / 臀推连续屈髋动画
      final angle = -0.15 - (1.0 - t) * 0.95;
      final hip = Offset(cx - scale * 0.15, cy + scale * 0.15);
      final shoulder = Offset(
        hip.dx + math.sin(-angle) * scale * 0.72,
        hip.dy - math.cos(-angle) * scale * 0.72,
      );
      final head = Offset(
        shoulder.dx + math.sin(-angle) * scale * 0.22,
        shoulder.dy - math.cos(-angle) * scale * 0.22,
      );
      final knee = Offset(cx + scale * 0.08, cy + scale * 0.58);
      final ankle = Offset(cx + scale * 0.02, cy + scale * 1.02);
      final hand = Offset(shoulder.dx + scale * 0.06, shoulder.dy + scale * 0.62);

      canvas.drawCircle(hip, 24, muscleGlow);
      canvas.drawLine(shoulder, hip, bonePaint);
      canvas.drawLine(hip, knee, bonePaint);
      canvas.drawLine(knee, ankle, bonePaint);
      canvas.drawLine(shoulder, hand, bonePaint);
      canvas.drawCircle(head, scale * 0.14, bonePaint);
      canvas.drawCircle(hand, 12, barPaint..style = PaintingStyle.stroke);
      for (final p in [shoulder, hip, knee]) {
        canvas.drawCircle(p, 4.5, jointPaint);
      }
    } else if (pattern == MotionPattern.crunch || pattern == MotionPattern.legRaise) {
      // 核心卷腹 / 举腿连续动画
      final hip = Offset(cx, cy + scale * 0.45);
      final torsoAngle = pattern == MotionPattern.crunch ? -0.15 - t * 0.75 : -0.12;
      final legAngle = pattern == MotionPattern.legRaise ? 0.15 + t * 1.15 : 0.45;
      final shoulder = Offset(
        hip.dx - math.cos(torsoAngle) * scale * 0.75,
        hip.dy + math.sin(torsoAngle) * scale * 0.75,
      );
      final head = Offset(shoulder.dx - scale * 0.18, shoulder.dy - scale * 0.12);
      final foot = Offset(
        hip.dx + math.cos(legAngle) * scale * 0.85,
        hip.dy - math.sin(legAngle) * scale * 0.85,
      );

      canvas.drawCircle(Offset(cx - scale * 0.15, cy + scale * 0.30), 22, muscleGlow);
      canvas.drawLine(shoulder, hip, bonePaint);
      canvas.drawLine(hip, foot, bonePaint);
      canvas.drawCircle(head, scale * 0.14, bonePaint);
      for (final p in [shoulder, hip]) {
        canvas.drawCircle(p, 4.5, jointPaint);
      }
    } else {
      // 上肢多模式（推举/夹胸/下拉/划船/侧平举/弯举/臂屈伸）双侧对称连续动画
      final head = Offset(cx, cy - scale * 0.78);
      final neck = Offset(cx, cy - scale * 0.52);
      final hip = Offset(cx, cy + scale * 0.35);
      final lShoulder = Offset(cx - scale * 0.34, cy - scale * 0.48);
      final rShoulder = Offset(cx + scale * 0.34, cy - scale * 0.48);

      late Offset lElbow, rElbow, lHand, rHand;
      if (pattern == MotionPattern.pressUp) {
        lElbow = Offset(cx - scale * (0.62 - 0.14 * t), cy - scale * (0.34 + 0.38 * t));
        rElbow = Offset(cx + scale * (0.62 - 0.14 * t), cy - scale * (0.34 + 0.38 * t));
        lHand = Offset(cx - scale * (0.56 - 0.16 * t), cy - scale * (0.52 + 0.62 * t));
        rHand = Offset(cx + scale * (0.56 - 0.16 * t), cy - scale * (0.52 + 0.62 * t));
      } else if (pattern == MotionPattern.flyIn) {
        lElbow = Offset(cx - scale * (0.78 - 0.45 * t), cy - scale * (0.42 - 0.08 * t));
        rElbow = Offset(cx + scale * (0.78 - 0.45 * t), cy - scale * (0.42 - 0.08 * t));
        lHand = Offset(cx - scale * (0.98 - 0.86 * t), cy - scale * (0.36 + 0.08 * t));
        rHand = Offset(cx + scale * (0.98 - 0.86 * t), cy - scale * (0.36 + 0.08 * t));
      } else if (pattern == MotionPattern.pullDown || pattern == MotionPattern.rowBack) {
        lElbow = Offset(cx - scale * (0.66 - 0.14 * t), cy - scale * (0.85 - 0.72 * t));
        rElbow = Offset(cx + scale * (0.66 - 0.14 * t), cy - scale * (0.85 - 0.72 * t));
        lHand = Offset(cx - scale * (0.72 - 0.20 * t), cy - scale * (1.12 - 0.68 * t));
        rHand = Offset(cx + scale * (0.72 - 0.20 * t), cy - scale * (1.12 - 0.68 * t));
      } else if (pattern == MotionPattern.raiseSide || pattern == MotionPattern.raiseFront) {
        final a = 0.25 + t * 1.25;
        lElbow = Offset(lShoulder.dx - math.sin(a) * scale * 0.42, lShoulder.dy + math.cos(a) * scale * 0.42);
        rElbow = Offset(rShoulder.dx + math.sin(a) * scale * 0.42, rShoulder.dy + math.cos(a) * scale * 0.42);
        lHand = Offset(lShoulder.dx - math.sin(a) * scale * 0.78, lShoulder.dy + math.cos(a) * scale * 0.78);
        rHand = Offset(rShoulder.dx + math.sin(a) * scale * 0.78, rShoulder.dy + math.cos(a) * scale * 0.78);
      } else {
        // curlUp / pushDown / extOverhead
        final bool isPush = pattern == MotionPattern.pushDown;
        final double armT = isPush ? (1.0 - t) : t;
        lElbow = Offset(cx - scale * 0.42, cy - scale * 0.04);
        rElbow = Offset(cx + scale * 0.42, cy - scale * 0.04);
        lHand = Offset(cx - scale * 0.44, cy + scale * (0.38 - 0.76 * armT));
        rHand = Offset(cx + scale * 0.44, cy + scale * (0.38 - 0.76 * armT));
      }

      // 发光目标肌群热区
      canvas.drawCircle(Offset(cx, cy - scale * 0.26), 28, muscleGlow);

      // 躯干 & 头部
      canvas.drawLine(lShoulder, rShoulder, bonePaint);
      canvas.drawLine(neck, hip, bonePaint);
      canvas.drawCircle(head, scale * 0.16, bonePaint);

      // 双臂
      canvas.drawLine(lShoulder, lElbow, bonePaint);
      canvas.drawLine(lElbow, lHand, bonePaint);
      canvas.drawLine(rShoulder, rElbow, bonePaint);
      canvas.drawLine(rElbow, rHand, bonePaint);

      // 器械/哑铃高亮端点
      canvas.drawCircle(lHand, 8, Paint()..color = accentColor);
      canvas.drawCircle(rHand, 8, Paint()..color = accentColor);
      if (pattern == MotionPattern.pressUp || pattern == MotionPattern.pullDown) {
        canvas.drawLine(lHand, rHand, barPaint);
      }
      for (final p in [lShoulder, rShoulder, lElbow, rElbow]) {
        canvas.drawCircle(p, 4.2, jointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant OfflineBiomechanicalPainter oldDelegate) {
    return oldDelegate.motionT != motionT ||
        oldDelegate.pattern != pattern ||
        oldDelegate.accentColor != accentColor;
  }
}

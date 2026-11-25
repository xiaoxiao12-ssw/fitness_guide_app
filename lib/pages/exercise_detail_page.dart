import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/exercise.dart';
import '../data/exercise_repository.dart';
import '../services/favorite_service.dart';
import '../widgets/animated_exercise_image.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await FavoriteService.isFavorite(widget.exercise.id);
    if (mounted) {
      setState(() => _isFavorite = fav);
    }
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    final nowFav = await FavoriteService.toggleFavorite(widget.exercise.id);
    if (mounted) {
      setState(() => _isFavorite = nowFav);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nowFav ? '已收藏「${widget.exercise.name}」' : '已取消收藏'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchBilibiliTutorial() async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(widget.exercise.bilibiliSearchUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法打开 B站 链接: $e')),
      );
    }
  }

  void _showSubstitutesSheet(BuildContext context, List<Exercise> substitutes) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, color: Color(0xFF10B981), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "同肌群哑铃/徒手平替推荐",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "没有「${widget.exercise.name}」器械或排队太久？直接换练以下动作，同样精准刺激${widget.exercise.targetMuscle}：",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              ...substitutes.map((altEx) {
                final altCue = ExerciseRepository.getQuickCue(altEx);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.35),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        child: Image.network(
                          altEx.imageUrl0,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center_rounded),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            altEx.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.16),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            altEx.equipment,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "💡 ${altCue.action}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Color(0xFF10B981)),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ExerciseDetailPage(exercise: altEx),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ex = widget.exercise;
    final cue = ExerciseRepository.getQuickCue(ex);
    final substitutes = ExerciseRepository.getSubstitutes(ex);

    return Scaffold(
      appBar: AppBar(
        title: Text(ex.name),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isFavorite ? const Color(0xFFEA580C) : null,
            ),
            tooltip: _isFavorite ? "取消收藏" : "加入收藏",
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 置顶放大动图（支持双指缩放查看发力细节）
            AnimatedExerciseImage(
              exercise: ex,
              height: 300,
              enablePinchZoom: true,
            ),
            const SizedBox(height: 14),

            // 2. 顶部醒目 B站 30秒教学直达按钮（自动搜“动作名 + 教学 避坑”）
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFB7299), Color(0xFFE11D48)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFB7299).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _launchBilibiliTutorial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "📺 30秒看懂标准动作（B站精讲）",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.open_in_new_rounded, size: 17),
                  ],
                ),
              ),
            ),

            // 3. 一键器械平替按钮（器械被占/没有器械时直达同肌群哑铃/徒手平替）
            if (ex.needsEquipmentSwap && substitutes.isNotEmpty) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _showSubstitutesSheet(context, substitutes),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.4),
                  backgroundColor: const Color(0xFF10B981).withOpacity(isDark ? 0.12 : 0.08),
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "🔄 器械被占/没有器械？点我看平替",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 18),

            // 4. 3 句大白话极简口诀卡片（扫一眼就能练）
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFEA580C), size: 20),
                const SizedBox(width: 6),
                const Text(
                  "3 句大白话口诀 · 扫一眼就能练",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${ex.bodyPart} · ${ex.equipment}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildCueCard(
              stepTag: "准备姿势",
              cueText: cue.setup,
              icon: Icons.accessibility_new_rounded,
              accentColor: const Color(0xFF0284C7),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildCueCard(
              stepTag: "发力动作",
              cueText: cue.action,
              icon: Icons.local_fire_department_rounded,
              accentColor: const Color(0xFFEA580C),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildCueCard(
              stepTag: "避坑提醒",
              cueText: cue.warning,
              icon: Icons.warning_amber_rounded,
              accentColor: const Color(0xFFE11D48),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // 5. 紧凑训练参数与目标肌群卡
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _kpiBox("组数", ex.recommendedSets, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _kpiBox("次数", ex.repRange, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _kpiBox("强度", ex.rpe, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _kpiBox("组休", "${ex.restSeconds}秒", isDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _miniTag("主练：${ex.targetMuscle}", const Color(0xFFEA580C), isDark),
                      ...ex.subMuscles.take(3).map(
                            (s) => _miniTag(s, const Color(0xFF0284C7), isDark),
                          ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.air_rounded, size: 15, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          "呼吸口诀：下放吸气稳核心，发力推拉吐气",
                          style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCueCard({
    required String stepTag,
    required String cueText,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(isDark ? 0.45 : 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.08 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: accentColor, size: 16),
                const SizedBox(width: 5),
                Text(
                  stepTag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cueText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.25,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiBox(String title, String val, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEA580C),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? color.withOpacity(0.95) : color,
        ),
      ),
    );
  }
}

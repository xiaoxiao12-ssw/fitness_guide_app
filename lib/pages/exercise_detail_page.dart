import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/exercise.dart';
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
          content: Text(nowFav ? '已将「${widget.exercise.name}」加入我的训练收藏！' : '已取消收藏'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchBilibiliTutorial() async {
    HapticFeedback.mediumImpact();
    final urlStr = widget.exercise.bilibiliSearchUrl;
    final uri = Uri.parse(urlStr);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法唤起浏览器或B站客户端: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ex = widget.exercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(ex.name),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isFavorite ? const Color(0xFFEA580C) : null,
            ),
            tooltip: _isFavorite ? "取消收藏" : "加入我的训练库",
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 真实动作双图动图轮播切换器
            AnimatedExerciseImage(exercise: ex, height: 260),
            const SizedBox(height: 14),

            // 2. 醒目的「观看 B站高清动作教学视频」按钮
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
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _launchBilibiliTutorial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.play_circle_filled_rounded, size: 22),
                label: const Text(
                  "观看 B站真人高清标准动作教学",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 3. 基础标签与核心参数卡片
            _buildBasicTagsCard(isDark, ex),
            const SizedBox(height: 16),

            // 4. 黄金准备姿态
            _buildSectionCard(
              isDark: isDark,
              icon: Icons.accessibility_new_rounded,
              iconColor: const Color(0xFF0284C7),
              title: "黄金准备姿态",
              child: Column(
                children: [
                  _infoRow("握距与手型", ex.gripWidth, isDark),
                  const Divider(height: 16),
                  _infoRow("站距与足底", ex.stance, isDark),
                  const Divider(height: 16),
                  _infoRow("身体倾角/椅背", ex.benchAngle, isDark),
                  const Divider(height: 16),
                  _infoRow("肩胛骨与核心", ex.scapularAndCore, isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. 动作全流程精准拆解
            _buildSectionCard(
              isDark: isDark,
              icon: Icons.sync_alt_rounded,
              iconColor: const Color(0xFFEA580C),
              title: "动作全流程精准拆解",
              child: Column(
                children: [
                  _flowStepItem(
                    stepNum: "1",
                    title: "离心阶段 (下放节奏与控制)",
                    desc: ex.eccentric,
                    badgeText: "2~3秒 极慢下放",
                    badgeColor: const Color(0xFF0284C7),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _flowStepItem(
                    stepNum: "2",
                    title: "底部停顿 (拉伸与蓄力)",
                    desc: ex.bottomPause,
                    badgeText: "0.5秒 消除惯性",
                    badgeColor: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _flowStepItem(
                    stepNum: "3",
                    title: "向心阶段 (发力轨迹与驱动)",
                    desc: ex.concentric,
                    badgeText: "爆发力主导推进",
                    badgeColor: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _flowStepItem(
                    stepNum: "4",
                    title: "顶峰收缩 (意念发力挤压)",
                    desc: ex.peakContraction,
                    badgeText: "1~1.5秒 强力挤压",
                    badgeColor: const Color(0xFFE11D48),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. 呼吸配合秘诀
            _buildSectionCard(
              isDark: isDark,
              icon: Icons.air_rounded,
              iconColor: const Color(0xFF10B981),
              title: "精准呼吸配合",
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ex.breathingTip,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? Colors.grey[200] : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 7. 科学增肌训练参数
            _buildSectionCard(
              isDark: isDark,
              icon: Icons.timer_outlined,
              iconColor: const Color(0xFF8B5CF6),
              title: "科学训练参数建议",
              child: Row(
                children: [
                  Expanded(
                    child: _kpiBox("建议组数", ex.recommendedSets, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kpiBox("次数区间", ex.repRange, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kpiBox("RPE 强度", ex.rpe, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kpiBox("组间休息", "${ex.restSeconds}秒", isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 8. 避坑与防受伤指南 (3个代偿错误)
            _buildSectionCard(
              isDark: isDark,
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFEF4444),
              title: "避坑与防受伤指南 (常见代偿剖析)",
              child: Column(
                children: ex.commonMistakes.map((m) => _mistakeTile(m, isDark)).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 9. 进阶/退阶替代方案
            _buildSectionCard(
              isDark: isDark,
              icon: Icons.swap_horiz_rounded,
              iconColor: const Color(0xFF0D9488),
              title: "进阶 / 退阶替代方案 (器械被占时替换)",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ex.alternatives.map((alt) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(
                          child: Text(
                            alt,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- 卡片构件 ---
  Widget _buildBasicTagsCard(bool isDark, Exercise ex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ex.bodyPart,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ex.equipment,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < ex.difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: const Color(0xFFF59E0B),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "主目标肌群: ${ex.targetMuscle}",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ex.subMuscles.map((sub) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  sub,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            "协同肌群: ${ex.secondaryMuscles.join('、')}",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.grey[200] : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _flowStepItem({
    required String stepNum,
    required String title,
    required String desc,
    required String badgeText,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: badgeColor,
                    child: Text(
                      stepNum,
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark ? Colors.grey[300] : const Color(0xFF334155),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5CF6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _mistakeTile(ExerciseMistake mistake, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D1818) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE11D48).withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Color(0xFFE11D48), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "常见错误: ${mistake.mistake}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("✅ 纠正: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981))),
              Expanded(
                child: Text(
                  mistake.correction,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[200] : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("⚠️ 风险: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF59E0B))),
              Expanded(
                child: Text(
                  mistake.risk,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

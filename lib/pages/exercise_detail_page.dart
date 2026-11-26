import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/exercise.dart';
import '../data/exercise_repository.dart';
import '../services/favorite_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_exercise_image.dart';
import '../widgets/inline_tutorial_webview.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  bool _isFavorite = false;
  bool _showInlineVideo = false;

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
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.mintEmerald.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: AppTheme.mintEmerald,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '同肌群哑铃 / 徒手平替推荐',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '器械排队或现场没有？直接切换以下动作，同样精准刺激「${widget.exercise.targetMuscle}」：',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(isDark),
                ),
              ),
              const SizedBox(height: 14),
              ...substitutes.map((altEx) {
                final altCue = ExerciseRepository.getQuickCue(altEx);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: AppTheme.innerTileDecoration(isDark, radius: 16),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFFF4F7FC),
                        padding: const EdgeInsets.all(3),
                        child: Image.network(
                          altEx.thumbUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.fitness_center_rounded),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            altEx.name,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppTheme.mintEmerald.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            altEx.equipment,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.mintEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        altCue.action,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary(isDark),
                        ),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppTheme.mintEmerald,
                    ),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ex.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            Text(
              '${ex.bodyPart} · ${ex.equipment} · ${ex.targetMuscle}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary(isDark),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: _isFavorite ? AppTheme.electroOrange : null,
            ),
            tooltip: _isFavorite ? '取消收藏' : '加入收藏',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 全新连续多帧 GIF + 发力轨迹层 + 4阶段节奏节拍器组件
            AnimatedExerciseImage(
              exercise: ex,
              height: 300,
              enablePinchZoom: true,
            ),
            const SizedBox(height: 14),

            // 2. 双模式视频精讲栏：应用内直接预览 WebView + B站 App 一键精讲
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFB7299), AppTheme.emberRed],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.emberRed.withOpacity(0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _showInlineVideo = !_showInlineVideo);
                      },
                      icon: Icon(
                        _showInlineVideo
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 19,
                      ),
                      label: Text(
                        _showInlineVideo ? '收起应用内视频' : '应用内看精讲视频',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _launchBilibiliTutorial,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: AppTheme.cardDecoration(isDark, radius: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.open_in_new_rounded,
                                size: 16, color: Color(0xFFFB7299)),
                            const SizedBox(width: 5),
                            Text(
                              'B站App看',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 展开后的应用内嵌精简教学 WebView
            if (_showInlineVideo) ...[
              const SizedBox(height: 12),
              InlineTutorialWebView(
                url: ex.bilibiliMobileSearchUrl,
                title: ex.name,
                onOpenExternal: _launchBilibiliTutorial,
              ),
            ],

            // 3. 器械被占一键平替入口
            if (ex.needsEquipmentSwap && substitutes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showSubstitutesSheet(context, substitutes),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.mintEmerald.withOpacity(isDark ? 0.14 : 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded,
                            color: AppTheme.mintEmerald, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '器械被占 / 没有器械？点我看哑铃或徒手平替',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.mintEmerald,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.mintEmerald, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 4. 3 句大白话极简口诀（左侧色条高级卡片，零生硬边框）
            Row(
              children: [
                const Icon(Icons.bolt_rounded,
                    color: AppTheme.electroOrange, size: 20),
                const SizedBox(width: 6),
                Text(
                  '3 句大白话口诀 · 扫一眼就能练',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildCueCard(
              stepTag: '准备姿势',
              cueText: cue.setup,
              icon: Icons.accessibility_new_rounded,
              accentColor: AppTheme.iceCyan,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildCueCard(
              stepTag: '发力动作',
              cueText: cue.action,
              icon: Icons.local_fire_department_rounded,
              accentColor: AppTheme.electroOrange,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildCueCard(
              stepTag: '避坑提醒',
              cueText: cue.warning,
              icon: Icons.warning_amber_rounded,
              accentColor: AppTheme.emberRed,
              isDark: isDark,
            ),
            const SizedBox(height: 18),

            // 5. 科学训练参数 + 目标肌群 + 呼吸要领
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration(isDark, radius: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _kpiBox('推荐组数', ex.recommendedSets, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _kpiBox('次数区间', ex.repRange, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _kpiBox('目标强度', ex.rpe, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _kpiBox('组间休息', '${ex.restSeconds}秒', isDark)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _miniTag('主练：${ex.targetMuscle}', AppTheme.electroOrange, isDark),
                      ...ex.subMuscles.map(
                        (s) => _miniTag(s, AppTheme.iceCyan, isDark),
                      ),
                      ...ex.secondaryMuscles.take(2).map(
                        (s) => _miniTag('协同：$s', AppTheme.mintEmerald, isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: AppTheme.innerTileDecoration(isDark, radius: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.air_rounded,
                            size: 16, color: AppTheme.mintEmerald),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '呼吸配合：${ex.breathingTip}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.mintEmerald,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 6. 常见代偿错误与防受伤纠正指南
            if (ex.commonMistakes.isNotEmpty) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      color: AppTheme.emberRed, size: 19),
                  const SizedBox(width: 6),
                  Text(
                    '常见代偿避坑与防伤指南',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...ex.commonMistakes.map(
                (m) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.cardDecoration(isDark, radius: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppTheme.emberRed.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '易错',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.emberRed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m.mistake,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '✅ 纠正：${m.correction}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mintEmerald,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '⚠️ 风险：${m.risk}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
      decoration: AppTheme.cardDecoration(isDark, radius: 18),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4.5, color: accentColor),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(isDark ? 0.16 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: accentColor, size: 15),
                          const SizedBox(width: 4),
                          Text(
                            stepTag,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
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
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: AppTheme.textPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiBox(String title, String val, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
      decoration: AppTheme.innerTileDecoration(isDark, radius: 14),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            val,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.neonLime : AppTheme.electroOrange,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

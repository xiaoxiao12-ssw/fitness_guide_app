import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../data/exercise_repository.dart';
import '../services/favorite_service.dart';
import '../theme/app_theme.dart';
import 'exercise_detail_page.dart';

class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  String _selectedBodyPart = '全部';
  String _selectedEquipment = '全部';
  String _selectedSubMuscle = '全部细分';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  List<String> _favIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    FavoriteService.version.addListener(_loadFavorites);
  }

  @override
  void dispose() {
    FavoriteService.version.removeListener(_loadFavorites);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final ids = await FavoriteService.getFavoriteIds();
    if (mounted) {
      setState(() => _favIds = ids);
    }
  }

  Future<void> _toggleFav(String id) async {
    HapticFeedback.lightImpact();
    await FavoriteService.toggleFavorite(id);
  }

  IconData _equipmentIcon(String eq) {
    switch (eq) {
      case '哑铃':
        return Icons.fitness_center_rounded;
      case '杠铃':
        return Icons.sports_gymnastics_rounded;
      case '龙门架/绳索':
        return Icons.cable_rounded;
      case '徒手/单双杠':
        return Icons.accessibility_new_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  Color _bodyPartColor(String part) {
    switch (part) {
      case '胸部':
        return AppTheme.electroOrange;
      case '背部':
        return AppTheme.iceCyan;
      case '肩部':
        return const Color(0xFFA855F7);
      case '手臂':
        return AppTheme.emberRed;
      case '腿臀':
        return AppTheme.mintEmerald;
      case '核心':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.electroOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.accentPrimary(isDark);

    final filteredList = ExerciseRepository.filterExercises(
      bodyPart: _selectedBodyPart,
      equipment: _selectedEquipment,
      subMuscle: _selectedSubMuscle,
      query: _searchQuery,
    );

    final subMuscles = ExerciseRepository.getSubMusclesForPart(_selectedBodyPart);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. 现代运动质感品牌顶部 Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 62, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.electroOrange, Color(0xFFFF8A00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electroOrange.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '少伟健身通',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                    color: AppTheme.textPrimary(isDark),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.neonLime
                                        : AppTheme.electroOrange,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'PRO 3.0',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? AppTheme.neonLimeDarkText
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '精选 ${ExerciseRepository.totalCount} 个黄金动作 · 完整连续动图 + 4阶段发力节拍',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary(isDark),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. 无边框悬浮搜索栏
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Container(
                  decoration: AppTheme.cardDecoration(isDark, radius: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: '搜索动作、肌群或器械（如 卧推、深蹲、引体、龙门架）',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary(isDark),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppTheme.textSecondary(isDark),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                ),
              ),
            ),

            // 3. 黄金器械筛选胶囊栏（全部 / 哑铃 / 杠铃 / 龙门架绳索 / 徒手单双杠）
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ExerciseRepository.getEquipments().map((eq) {
                    final isSel = _selectedEquipment == eq;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedEquipment = eq);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (isDark
                                    ? AppTheme.neonLime
                                    : AppTheme.electroOrange)
                                : (isDark
                                    ? AppTheme.darkSurface
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: (isDark
                                              ? AppTheme.neonLime
                                              : AppTheme.electroOrange)
                                          .withOpacity(0.28),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _equipmentIcon(eq),
                                size: 15,
                                color: isSel
                                    ? (isDark
                                        ? AppTheme.neonLimeDarkText
                                        : Colors.white)
                                    : AppTheme.textSecondary(isDark),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                eq,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight:
                                      isSel ? FontWeight.w900 : FontWeight.w600,
                                  color: isSel
                                      ? (isDark
                                          ? AppTheme.neonLimeDarkText
                                          : Colors.white)
                                      : AppTheme.textPrimary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 4. 六大部位（胸/背/肩/臂/腿臀/核心）+ 细分肌束筛选
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ExerciseRepository.getBodyParts().map((part) {
                          final isSelected = _selectedBodyPart == part;
                          final count = ExerciseRepository.filterExercises(
                            bodyPart: part,
                            equipment: _selectedEquipment,
                          ).length;
                          final partColor = part == '全部'
                              ? AppTheme.electroOrange
                              : _bodyPartColor(part);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedBodyPart = part;
                                  _selectedSubMuscle = '全部细分';
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? partColor.withOpacity(isDark ? 0.22 : 0.14)
                                      : (isDark
                                          ? AppTheme.darkSurface
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$part $count',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? partColor
                                        : AppTheme.textSecondary(isDark),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (subMuscles.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: subMuscles.map((sub) {
                              final isSel = _selectedSubMuscle == sub;
                              return Padding(
                                padding: const EdgeInsets.only(right: 7),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedSubMuscle =
                                        isSel ? '全部细分' : sub);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? AppTheme.iceCyan
                                              .withOpacity(isDark ? 0.22 : 0.14)
                                          : (isDark
                                              ? AppTheme.darkSurfaceElevated
                                              : AppTheme.lightSurfaceElevated),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      sub,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSel
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                        color: isSel
                                            ? AppTheme.iceCyan
                                            : AppTheme.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 5. 列表计数与说明
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '全动作配备完整 GIF 轨迹演示',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '共 ${filteredList.length} 个黄金动作',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 6. 黄金动作卡片列表
            if (filteredList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 54, color: AppTheme.textSecondary(isDark)),
                      const SizedBox(height: 12),
                      Text(
                        '未找到符合条件的动作',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '试试切换部位、器械标签或清空搜索词',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ex = filteredList[index];
                      final isFav = _favIds.contains(ex.id);
                      return _buildExerciseCard(ex, isFav, isDark);
                    },
                    childCount: filteredList.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ex, bool isFav, bool isDark) {
    final cue = ExerciseRepository.getQuickCue(ex);
    final partColor = _bodyPartColor(ex.bodyPart);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(isDark, radius: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExerciseDetailPage(exercise: ex),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 动作高清缩略图 + GIF 动态标识角标
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 82,
                        height: 82,
                        color: const Color(0xFFF4F7FC),
                        padding: const EdgeInsets.all(4),
                        child: Image.network(
                          ex.thumbUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.network(
                            ex.thumbFallbackUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.fitness_center_rounded,
                              color: partColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0E17).withOpacity(0.82),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                size: 10, color: AppTheme.neonLime),
                            Text(
                              'GIF',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.neonLime,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 13),

                // 中间信息区
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _miniBadge(ex.bodyPart, partColor, isDark),
                          const SizedBox(width: 6),
                          _miniBadge(ex.equipment, AppTheme.mintEmerald, isDark),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (i) {
                              final filled = i < ex.difficulty;
                              return Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(left: 2.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: filled
                                      ? AppTheme.electroOrange
                                      : (isDark
                                          ? Colors.white12
                                          : Colors.black12),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ex.name,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cue.action,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.iceCyan
                              : const Color(0xFF0284C7),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${ex.targetMuscle} · ${ex.recommendedSets} · ${ex.repRange}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // 收藏按钮
                IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: isFav
                        ? AppTheme.electroOrange
                        : AppTheme.textSecondary(isDark),
                    size: 22,
                  ),
                  onPressed: () => _toggleFav(ex.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

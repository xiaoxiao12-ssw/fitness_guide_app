import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../data/exercise_repository.dart';
import '../services/favorite_service.dart';
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
  }

  @override
  void dispose() {
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
    _loadFavorites();
  }

  IconData _equipmentIcon(String eq) {
    switch (eq) {
      case '哑铃/杠铃':
        return Icons.fitness_center_rounded;
      case '龙门架/绳索':
        return Icons.cable_rounded;
      case '徒手/单双杠':
        return Icons.accessibility_new_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = ExerciseRepository.filterExercises(
      bodyPart: _selectedBodyPart,
      equipment: _selectedEquipment,
      subMuscle: _selectedSubMuscle,
      query: _searchQuery,
    );

    final subMuscles = ExerciseRepository.getSubMusclesForPart(_selectedBodyPart);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.fitness_center_rounded, color: Color(0xFFEA580C), size: 22),
            SizedBox(width: 8),
            Text(
              "少伟健身通",
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. 搜索框
          Container(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "搜动作/器械（如 哑铃卧推、引体、龙门架）",
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // 2. 顶部普通健身房器械筛选栏（全部 / 哑铃/杠铃 / 龙门架/绳索 / 徒手/单双杠）
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ExerciseRepository.getEquipments().map((eq) {
                  final isSel = _selectedEquipment == eq;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(
                        _equipmentIcon(eq),
                        size: 15,
                        color: isSel
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      label: Text(eq),
                      selected: isSel,
                      showCheckmark: false,
                      selectedColor: const Color(0xFF10B981).withOpacity(0.18),
                      side: BorderSide(
                        color: isSel
                            ? const Color(0xFF10B981)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        color: isSel
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
                      ),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedEquipment = eq);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 3. 部位分类 + 细分肌束筛选栏
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
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

                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text("$part ($count)"),
                          selected: isSelected,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          selectedColor: const Color(0xFFEA580C).withOpacity(0.2),
                          labelStyle: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFFEA580C)
                                : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
                          ),
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedBodyPart = part;
                              _selectedSubMuscle = '全部细分';
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (subMuscles.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: subMuscles.map((sub) {
                          final isSel = _selectedSubMuscle == sub;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(sub, style: const TextStyle(fontSize: 11)),
                              selected: isSel,
                              visualDensity: VisualDensity.compact,
                              selectedColor: const Color(0xFF0284C7).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF0284C7),
                              onSelected: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedSubMuscle = val ? sub : '全部细分');
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 顶部排序说明条
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "普通健身房优先：哑铃 / 杠铃 / 龙门架 / 徒手前置",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  "共 ${filteredList.length} 个",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEA580C),
                  ),
                ),
              ],
            ),
          ),

          // 4. 动作列表展示
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text("未找到符合条件的动作", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("试试切换器械标签或清除关键词", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final ex = filteredList[index];
                      final isFav = _favIds.contains(ex.id);
                      return _buildExerciseListItem(ex, isFav, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseListItem(Exercise ex, bool isFav, bool isDark) {
    final cue = ExerciseRepository.getQuickCue(ex);
    final eqColor = ex.isCommonGymFriendly ? const Color(0xFF10B981) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ExerciseDetailPage(exercise: ex),
            ),
          ).then((_) => _loadFavorites());
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 动作缩略图
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 78,
                  height: 78,
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  child: Image.network(
                    ex.imageUrl0,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => Center(
                      child: Icon(Icons.fitness_center_rounded, color: Colors.grey[400], size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 动作名 + 器械标签 + 1 句核心口诀
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C).withOpacity(0.14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ex.bodyPart,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: eqColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ex.equipment,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: eqColor,
                            ),
                          ),
                        ),
                        if (!ex.isCommonGymFriendly) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.14),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "可平替",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: List.generate(ex.difficulty, (i) {
                            return const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B));
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ex.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "💡 ${cue.action}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${ex.recommendedSets} · ${ex.repRange} · 休${ex.restSeconds}秒",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 收藏按钮（保留原有 FavoriteService）
              IconButton(
                icon: Icon(
                  isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isFav ? const Color(0xFFEA580C) : Colors.grey[400],
                  size: 22,
                ),
                onPressed: () => _toggleFav(ex.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

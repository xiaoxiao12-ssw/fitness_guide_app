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
        title: Row(
          children: const [
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "搜索 58+ 真实动作（如 卧推、引体向上、哑铃、三角肌）",
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

          // 2. 部位主分类标签栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ExerciseRepository.getBodyParts().map((part) {
                  final isSelected = _selectedBodyPart == part;
                  final count = part == '全部'
                      ? ExerciseRepository.getAllExercises().length
                      : ExerciseRepository.filterExercises(bodyPart: part).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text("$part ($count)"),
                      selected: isSelected,
                      selectedColor: const Color(0xFFEA580C).withOpacity(0.2),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFFEA580C)
                            : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
                      ),
                      onSelected: (val) {
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
          ),

          // 3. 细分肌束 & 器械多维筛选栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            child: Column(
              children: [
                // 细分肌束
                if (subMuscles.length > 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: subMuscles.map((sub) {
                        final isSel = _selectedSubMuscle == sub;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(sub, style: const TextStyle(fontSize: 11)),
                            selected: isSel,
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
                // 器械类型筛选
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ExerciseRepository.getEquipments().map((eq) {
                      final isSel = _selectedEquipment == eq;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(eq, style: const TextStyle(fontSize: 11)),
                          selected: isSel,
                          selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF10B981),
                          onSelected: (val) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedEquipment = val ? eq : '全部');
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

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
                        Text("请尝试切换分类或精简搜索关键词", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
              // 缩略图
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  child: Image.network(
                    ex.imageUrl0,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => Center(
                      child: Icon(Icons.fitness_center_rounded, color: Colors.grey[400], size: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 文本与标签信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C).withOpacity(0.12),
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
                            color: const Color(0xFF0284C7).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ex.equipment,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(ex.difficulty, (i) {
                            return const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B));
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
                    const SizedBox(height: 2),
                    Text(
                      ex.englishName,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "目标: ${ex.subMuscles.join(' · ')}",
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        fontWeight: FontWeight.w500,
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/diet_entry.dart';
import '../models/fat_loss_profile.dart';
import '../services/diet_service.dart';
import '../services/fat_loss_service.dart';
import '../theme/app_theme.dart';

class DietEstimatorPage extends StatefulWidget {
  const DietEstimatorPage({super.key});

  @override
  State<DietEstimatorPage> createState() => _DietEstimatorPageState();
}

class _DietEstimatorPageState extends State<DietEstimatorPage> {
  final ImagePicker _picker = ImagePicker();
  List<DietEntry> _todayEntries = [];
  FatLossProfile _profile = const FatLossProfile();
  String _selectedFoodCategory = '全部';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    DietService.version.addListener(_loadData);
    FatLossService.version.addListener(_loadData);
  }

  @override
  void dispose() {
    DietService.version.removeListener(_loadData);
    FatLossService.version.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final entries = await DietService.getEntriesForDate(DietService.todayDateKey());
    final profile = await FatLossService.loadProfile();
    if (!mounted) return;
    setState(() {
      _todayEntries = entries;
      _profile = profile;
      _isLoading = false;
    });
  }

  int get _todayCalories => _todayEntries.fold<int>(0, (sum, e) => sum + e.calories);
  double get _todayProtein => _todayEntries.fold<double>(0.0, (sum, e) => sum + e.protein);

  String _autoGuessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return '早餐';
    if (hour < 15) return '午餐';
    if (hour < 21) return '晚餐';
    return '加餐';
  }

  Future<void> _pickMealPhoto(ImageSource source) async {
    HapticFeedback.mediumImpact();
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      _openPhotoEstimateSheet(File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('无法调起${source == ImageSource.camera ? "相机" : "相册"}：$e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openPhotoEstimateSheet(File imageFile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String selectedMeal = _autoGuessMealType();
    String selectedPortion = '正常家常';
    var est = DietService.estimateByMealAndPortion(selectedMeal, selectedPortion);
    int calories = est.calories;
    double protein = est.protein;
    bool isCallingAi = false;
    String? aiTip;
    final nameCtrl = TextEditingController(text: '$selectedMeal · $selectedPortion');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void recalc() {
              final next = DietService.estimateByMealAndPortion(selectedMeal, selectedPortion);
              calories = next.calories;
              protein = next.protein;
              nameCtrl.text = '$selectedMeal · $selectedPortion';
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      const SizedBox(height: 12),
                      const Text(
                        "📷 餐食照片热量估算",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),

                      // 餐食照片预览 + AI 识图预留入口
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              imageFile,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: nameCtrl,
                                  decoration: InputDecoration(
                                    labelText: "餐食备注",
                                    isDense: true,
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: isCallingAi
                                        ? null
                                        : () async {
                                            setSheetState(() {
                                              isCallingAi = true;
                                              aiTip = null;
                                            });
                                            final aiRes = await DietService.estimateMealWithVisionAI(imageFile);
                                            if (!ctx.mounted) return;
                                            setSheetState(() {
                                              isCallingAi = false;
                                              if (aiRes != null) {
                                                calories = aiRes.estimatedCalories;
                                                protein = aiRes.estimatedProtein;
                                                nameCtrl.text = aiRes.foodName;
                                                aiTip = aiRes.confidenceNote;
                                              } else {
                                                aiTip = '多模态 AI 识图接口已就绪（未配置云端 Key，已自动使用下方标签估算）';
                                              }
                                            });
                                          },
                                    icon: isCallingAi
                                        ? const SizedBox(
                                            width: 13,
                                            height: 13,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.auto_awesome_rounded, size: 15),
                                    label: const Text("AI 识图估算（已预留）", style: TextStyle(fontSize: 11.5)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF38BDF8),
                                      side: BorderSide(color: const Color(0xFF38BDF8).withOpacity(0.5)),
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (aiTip != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            aiTip!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // 1. 餐食类型
                      const Text("选择餐次", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: DietService.mealTypes.map((m) {
                          final on = selectedMeal == m;
                          return ChoiceChip(
                            label: Text(m),
                            selected: on,
                            showCheckmark: false,
                            selectedColor: const Color(0xFFEA580C).withOpacity(0.2),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: on ? FontWeight.bold : FontWeight.normal,
                              color: on ? const Color(0xFFEA580C) : null,
                            ),
                            onSelected: (_) {
                              setSheetState(() {
                                selectedMeal = m;
                                recalc();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // 2. 份量/油盐标签
                      const Text("选择份量与油盐程度（自动算热量）", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.35,
                        children: DietService.portionPresets.map((p) {
                          final on = selectedPortion == p.tag;
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setSheetState(() {
                                selectedPortion = p.tag;
                                recalc();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: on
                                    ? const Color(0xFF10B981).withOpacity(0.16)
                                    : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: on
                                      ? const Color(0xFF10B981)
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  width: on ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    p.tag,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: on ? const Color(0xFF10B981) : null,
                                    ),
                                  ),
                                  Text(
                                    p.desc,
                                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // 3. 热量与蛋白微调展示
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "预估热量：$calories kcal",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFEA580C),
                                  ),
                                ),
                                Text(
                                  "蛋白质：${protein.toStringAsFixed(1)} g",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: calories.toDouble().clamp(100, 1400),
                              min: 100,
                              max: 1400,
                              divisions: 26,
                              activeColor: const Color(0xFFEA580C),
                              onChanged: (v) {
                                setSheetState(() => calories = v.round());
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      ElevatedButton(
                        onPressed: () async {
                          final entry = DietEntry(
                            id: 'diet_${DateTime.now().millisecondsSinceEpoch}',
                            dateKey: DietService.todayDateKey(),
                            name: nameCtrl.text.trim().isEmpty ? '$selectedMeal · $selectedPortion' : nameCtrl.text.trim(),
                            mealType: selectedMeal,
                            calories: calories,
                            protein: protein,
                            portionTag: selectedPortion,
                            imagePath: imageFile.path,
                            timestamp: DateTime.now().millisecondsSinceEpoch,
                          );
                          await DietService.addEntry(entry);
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('已记录「${entry.name}」 +${entry.calories} kcal'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          "确认记入今日饮食",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(nameCtrl.dispose);
  }

  Future<void> _quickAddFood(QuickFoodItem item) async {
    HapticFeedback.lightImpact();
    final entry = DietEntry(
      id: 'diet_${DateTime.now().millisecondsSinceEpoch}',
      dateKey: DietService.todayDateKey(),
      name: '${item.emoji} ${item.name} (${item.unit})',
      mealType: _autoGuessMealType(),
      calories: item.calories,
      protein: item.protein,
      portionTag: '快捷点选',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await DietService.addEntry(entry);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已加 ${item.name}：+${item.calories} kcal / +${item.protein}g 蛋白'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '撤销',
          onPressed: () => DietService.deleteEntry(entry.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final proj = FatLossService.calculateProjection(
      _profile,
      todayDietCalories: _todayCalories,
    );
    final int dailyTdee = proj.dailyTdee.round();
    final int currentDeficit = dailyTdee - _todayCalories;
    final double ratio = dailyTdee > 0 ? (_todayCalories / dailyTdee).clamp(0.0, 1.2) : 0.0;

    final categories = ['全部', '蛋白', '主食', '常见餐', '饮品'];
    final displayFoods = _selectedFoodCategory == '全部'
        ? DietService.quickFoods
        : DietService.quickFoods.where((f) => f.category == _selectedFoodCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("饮食估算 · 热量缺口"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 今日摄入与实时热量缺口看板
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF141B29), Color(0xFF0C1018)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (currentDeficit >= 0
                                  ? AppTheme.neonLime
                                  : AppTheme.emberRed)
                              .withOpacity(0.16),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "今日已摄入总热量",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: currentDeficit >= 0
                                    ? AppTheme.neonLime.withOpacity(0.18)
                                    : AppTheme.emberRed.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentDeficit >= 0
                                    ? "当前缺口 $currentDeficit kcal"
                                    : "已超出 ${currentDeficit.abs()} kcal",
                                style: TextStyle(
                                  color: currentDeficit >= 0
                                      ? AppTheme.neonLime
                                      : const Color(0xFFFCA5A5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "$_todayCalories",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "/ 预估总消耗 $dailyTdee kcal",
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: ratio.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              currentDeficit < 0
                                  ? AppTheme.emberRed
                                  : ratio > 0.85
                                      ? AppTheme.electroOrange
                                      : AppTheme.neonLime,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "🥩 今日蛋白质：${_todayProtein.toStringAsFixed(1)} g",
                              style: const TextStyle(
                                color: AppTheme.iceCyan,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "建议蛋白 ≥ ${(_profile.currentWeightKg * 1.4).round()}g",
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. 方式一：拍照 / 相册选图记录
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.electroOrange, Color(0xFFFF8A00)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electroOrange.withOpacity(0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _pickMealPhoto(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded, size: 19),
                            label: const Text("拍照估算热量", style: TextStyle(fontWeight: FontWeight.w900)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _pickMealPhoto(ImageSource.gallery),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: AppTheme.cardDecoration(isDark, radius: 16),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library_rounded, size: 19, color: AppTheme.mintEmerald),
                                  SizedBox(width: 6),
                                  Text(
                                    "相册选图记录",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.mintEmerald,
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
                  const SizedBox(height: 18),

                  // 3. 方式二：常见食物快捷点选（点一下累加）
                  Row(
                    children: [
                      const Icon(Icons.touch_app_rounded, color: Color(0xFFEA580C), size: 19),
                      const SizedBox(width: 6),
                      const Text(
                        "常见食物点一下就记",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      Text(
                        "点选直接累加",
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final on = _selectedFoodCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: on,
                            showCheckmark: false,
                            visualDensity: VisualDensity.compact,
                            selectedColor: const Color(0xFFEA580C).withOpacity(0.2),
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: on ? FontWeight.bold : FontWeight.normal,
                              color: on ? const Color(0xFFEA580C) : null,
                            ),
                            onSelected: (_) => setState(() => _selectedFoodCategory = cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: displayFoods.length,
                    itemBuilder: (context, idx) {
                      final item = displayFoods[idx];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _quickAddFood(item),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: AppTheme.cardDecoration(isDark, radius: 18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.emoji, style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.unit,
                                style: TextStyle(fontSize: 9.5, color: Colors.grey[500]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "${item.calories}千卡 · ${item.protein.toStringAsFixed(0)}g蛋",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEA580C),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. 今日已记录餐食清单
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "今日饮食明细 (${_todayEntries.length} 条)",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      if (_todayEntries.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await DietService.clearTodayEntries();
                          },
                          child: const Text("清空今日", style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (_todayEntries.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                      decoration: AppTheme.cardDecoration(isDark, radius: 20),
                      child: Column(
                        children: [
                          Icon(Icons.restaurant_menu_rounded, size: 36, color: Colors.grey[500]),
                          const SizedBox(height: 8),
                          const Text("今天还没有记录饮食", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "点上方食物卡片或拍一张餐食照，自动计算每日热量缺口",
                            style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._todayEntries.map((entry) {
                      final hasPhoto = entry.imagePath != null &&
                          entry.imagePath!.isNotEmpty &&
                          File(entry.imagePath!).existsSync();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: AppTheme.cardDecoration(isDark, radius: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: hasPhoto
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(entry.imagePath!),
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEA580C).withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    entry.mealType,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEA580C),
                                    ),
                                  ),
                                ),
                          title: Text(
                            entry.name,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "${entry.mealType} · 蛋白 ${entry.protein.toStringAsFixed(1)}g${entry.portionTag != null ? ' · ${entry.portionTag}' : ''}",
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${entry.calories} kcal",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Colors.grey),
                                onPressed: () => DietService.deleteEntry(entry.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

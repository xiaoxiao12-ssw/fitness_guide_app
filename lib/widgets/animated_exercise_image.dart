import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';

class AnimatedExerciseImage extends StatefulWidget {
  final Exercise exercise;
  final double height;

  const AnimatedExerciseImage({
    super.key,
    required this.exercise,
    this.height = 240,
  });

  @override
  State<AnimatedExerciseImage> createState() => _AnimatedExerciseImageState();
}

class _AnimatedExerciseImageState extends State<AnimatedExerciseImage> {
  int _currentStep = 0; // 0 = 起始位, 1 = 顶峰位
  bool _isPlaying = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer?.cancel();
    if (!_isPlaying) return;
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (t) {
      if (!mounted) return;
      setState(() {
        _currentStep = _currentStep == 0 ? 1 : 0;
      });
    });
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startAnimation();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _selectStep(int step) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentStep = step;
      _isPlaying = false; // 手动切换时暂停自动循环
      _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ex = widget.exercise;
    final currentUrl = _currentStep == 0 ? ex.imageUrl0 : ex.imageUrl1;
    final fallbackUrl = _currentStep == 0 ? ex.rawUrl0 : ex.rawUrl1;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 示范动作图片（带淡入动画与多源降级）
            GestureDetector(
              onTap: _togglePlayPause,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Image.network(
                  currentUrl,
                  key: ValueKey<String>("$currentUrl-$_currentStep"),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFFEA580C),
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // 二级尝试 GitHub raw 或本地离线占位图
                    return Image.network(
                      fallbackUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (ctx, err, trace) => _buildOfflinePlaceholder(ex, isDark),
                    );
                  },
                ),
              ),
            ),

            // 顶部左侧状态药丸徽章 (起始位 / 顶峰收缩位)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _currentStep == 0
                        ? const Color(0xFF38BDF8).withOpacity(0.6)
                        : const Color(0xFFEA580C).withOpacity(0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _currentStep == 0
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFFEA580C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _currentStep == 0 ? "阶段 1: 起始准备位" : "阶段 2: 顶峰收缩位",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 顶部右侧播放/暂停控制按钮
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                onTap: _togglePlayPause,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isPlaying ? "循环中" : "已暂停",
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 底部位置指示器与切换标签
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepChip("1 起始位", 0),
                    const SizedBox(width: 8),
                    _stepChip("2 顶峰位", 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepChip(String label, int stepIndex) {
    final isSelected = _currentStep == stepIndex;
    return InkWell(
      onTap: () => _selectStep(stepIndex),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEA580C) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOfflinePlaceholder(Exercise ex, bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center_rounded,
              size: 54,
              color: Color(0xFFEA580C),
            ),
            const SizedBox(height: 10),
            Text(
              ex.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ex.englishName,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _currentStep == 0 ? "示范动作 · 起始准备位" : "示范动作 · 顶峰挤压位",
                style: const TextStyle(color: Color(0xFFFB923C), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

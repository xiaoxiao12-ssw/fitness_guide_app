import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';

class AnimatedExerciseImage extends StatefulWidget {
  final Exercise exercise;
  final double height;
  final bool enablePinchZoom;

  const AnimatedExerciseImage({
    super.key,
    required this.exercise,
    this.height = 300,
    this.enablePinchZoom = true,
  });

  @override
  State<AnimatedExerciseImage> createState() => _AnimatedExerciseImageState();
}

class _AnimatedExerciseImageState extends State<AnimatedExerciseImage> {
  int _currentStep = 0; // 0 = 起始位, 1 = 顶峰位
  bool _isPlaying = true;
  bool _isZoomed = false;
  Timer? _timer;
  final TransformationController _transformCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _transformCtrl.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final scale = _transformCtrl.value.getMaxScaleOnAxis();
    final zoomedNow = scale > 1.05;
    if (zoomedNow != _isZoomed && mounted) {
      setState(() => _isZoomed = zoomedNow);
    }
  }

  void _resetZoom() {
    HapticFeedback.lightImpact();
    _transformCtrl.value = Matrix4.identity();
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
      _isPlaying = false;
      _timer?.cancel();
    });
  }

  void _openFullScreenZoom(BuildContext context) {
    HapticFeedback.lightImpact();
    final ex = widget.exercise;
    final url = _currentStep == 0 ? ex.imageUrl0 : ex.imageUrl1;
    final fallback = _currentStep == 0 ? ex.rawUrl0 : ex.rawUrl1;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.5,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.network(
                  fallback,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(ctx).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${ex.name} · 双指放大看发力细节",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Material(
                  color: Colors.white12,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _transformCtrl.removeListener(_onTransformChanged);
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ex = widget.exercise;
    final currentUrl = _currentStep == 0 ? ex.imageUrl0 : ex.imageUrl1;
    final fallbackUrl = _currentStep == 0 ? ex.rawUrl0 : ex.rawUrl1;

    final imageWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
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
              strokeWidth: 2.5,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            fallbackUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (ctx, err, trace) => _buildOfflinePlaceholder(ex, isDark),
          );
        },
      ),
    );

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 支持双指缩放查看发力细节的动图区域
            Positioned.fill(
              child: widget.enablePinchZoom
                  ? InteractiveViewer(
                      transformationController: _transformCtrl,
                      minScale: 1.0,
                      maxScale: 3.5,
                      panEnabled: true,
                      scaleEnabled: true,
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        onDoubleTap: _isZoomed ? _resetZoom : () => _openFullScreenZoom(context),
                        child: imageWidget,
                      ),
                    )
                  : GestureDetector(
                      onTap: _togglePlayPause,
                      child: imageWidget,
                    ),
            ),

            // 顶部左侧阶段状态药丸
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.68),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _currentStep == 0
                        ? const Color(0xFF38BDF8).withOpacity(0.65)
                        : const Color(0xFFEA580C).withOpacity(0.7),
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
                      _currentStep == 0 ? "1 起始位" : "2 顶峰位",
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

            // 顶部右侧：播放/暂停 + 全屏放大
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isZoomed)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: _resetZoom,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "还原",
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: _togglePlayPause,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.68),
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
                          const SizedBox(width: 3),
                          Text(
                            _isPlaying ? "动图" : "暂停",
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _openFullScreenZoom(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.68),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.zoom_out_map_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),

            // 底部控制条：起始位/顶峰位切换 + 双指放大提示
            Positioned(
              bottom: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.58),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pinch_rounded, color: Colors.white70, size: 12),
                        SizedBox(width: 4),
                        Text(
                          "双指放大看细节",
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _stepChip("起始位", 0),
                        const SizedBox(width: 6),
                        _stepChip("顶峰位", 1),
                      ],
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center_rounded, size: 54, color: Color(0xFFEA580C)),
            const SizedBox(height: 10),
            Text(
              ex.name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
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

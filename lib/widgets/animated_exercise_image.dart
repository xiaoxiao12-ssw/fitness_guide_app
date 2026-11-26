import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../theme/app_theme.dart';
import 'motion_overlay_painters.dart';

/// 轻量级内存 GIF 字节缓存（最多缓存 30 个动作 GIF，避免重复下载，切换秒开）
class _GifBytesCache {
  static const int _maxEntries = 30;
  static final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();

  static Uint8List? get(String key) {
    final val = _cache.remove(key);
    if (val != null) {
      _cache[key] = val;
    }
    return val;
  }

  static void put(String key, Uint8List bytes) {
    _cache.remove(key);
    _cache[key] = bytes;
    while (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}

class _DecodedGifFrame {
  final ui.Image image;
  final Duration duration;

  const _DecodedGifFrame(this.image, this.duration);
}

/// 少伟健身通 v3.0 全新动作演示播放器
/// - 完整连续多帧 GIF 动图解码播放（三层 CDN 自动容灾 + 内存秒开缓存）
/// - 支持 0.5x 慢动作 / 1.0x 标准 / 1.5x 加速 + 精准帧暂停 + 双指缩放/全屏看细节
/// - 离线优雅回退：60fps 本地生物力学连续动画（彻底告别两张静态图硬切）
/// - 可开关“发力轨迹箭头 + 目标肌群高亮”动态叠加层
/// - 4 阶段发力拆解进度条 + 实时呼吸节奏节拍器（支持震动节拍）
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

class _AnimatedExerciseImageState extends State<AnimatedExerciseImage>
    with TickerProviderStateMixin {
  // GIF 解码帧状态
  List<_DecodedGifFrame> _frames = [];
  int _frameIndex = 0;
  bool _isLoadingGif = true;
  bool _gifFailed = false;
  Timer? _frameTimer;

  // 播放与交互控制
  bool _isPlaying = true;
  double _playbackSpeed = 1.0; // 0.5x / 1.0x / 1.5x
  bool _showOverlay = true; // 发力轨迹 + 目标肌群高亮开关
  bool _metronomeHaptic = false; // 节拍器震动提示开关
  bool _isZoomed = false;

  // 4 阶段周期动画控制器
  late AnimationController _phaseCtrl;
  MotionPhase _lastNotifiedPhase = MotionPhase.prep;
  int _lastSecondTick = -1;

  final TransformationController _transformCtrl = TransformationController();

  int get _prepSec => 1;
  int get _concentricSec => widget.exercise.concentricSec.clamp(1, 4);
  int get _peakSec => widget.exercise.peakSec.clamp(1, 3);
  int get _eccentricSec => widget.exercise.eccentricSec.clamp(2, 5);
  int get _totalCycleSec => _prepSec + _concentricSec + _peakSec + _eccentricSec;

  @override
  void initState() {
    super.initState();
    _phaseCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_totalCycleSec * 1000 / _playbackSpeed).round()),
    )..addListener(_onPhaseTick);
    _phaseCtrl.repeat();

    _transformCtrl.addListener(_onTransformChanged);
    _loadGifWithFallback();
  }

  @override
  void didUpdateWidget(covariant AnimatedExerciseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _disposeFrames();
      _phaseCtrl.duration =
          Duration(milliseconds: (_totalCycleSec * 1000 / _playbackSpeed).round());
      _phaseCtrl.reset();
      if (_isPlaying) _phaseCtrl.repeat();
      _loadGifWithFallback();
    }
  }

  void _onTransformChanged() {
    final zoomedNow = _transformCtrl.value.getMaxScaleOnAxis() > 1.05;
    if (zoomedNow != _isZoomed && mounted) {
      setState(() => _isZoomed = zoomedNow);
    }
  }

  void _onPhaseTick() {
    if (!_isPlaying) return;
    final info = _computePhaseInfo(_phaseCtrl.value);
    if (_metronomeHaptic) {
      if (info.phase != _lastNotifiedPhase) {
        HapticFeedback.mediumImpact();
      } else if (info.remainingSec != _lastSecondTick) {
        HapticFeedback.selectionClick();
      }
    }
    _lastNotifiedPhase = info.phase;
    _lastSecondTick = info.remainingSec;
  }

  Future<void> _loadGifWithFallback() async {
    final ex = widget.exercise;
    final cacheKey = ex.gifPath;
    if (mounted) {
      setState(() {
        _isLoadingGif = true;
        _gifFailed = false;
      });
    }

    Uint8List? bytes = _GifBytesCache.get(cacheKey);
    if (bytes == null) {
      final urls = [ex.gifUrl, ex.gifFallbackUrl, ex.gifRawUrl];
      for (final url in urls) {
        bytes = await _downloadBytes(url);
        if (bytes != null && bytes.length > 1024) {
          _GifBytesCache.put(cacheKey, bytes);
          break;
        }
      }
    }

    if (!mounted || widget.exercise.id != ex.id) return;

    if (bytes == null) {
      setState(() {
        _isLoadingGif = false;
        _gifFailed = true;
      });
      return;
    }

    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frameCount = codec.frameCount;
      final decoded = <_DecodedGifFrame>[];
      for (int i = 0; i < frameCount; i++) {
        final frameInfo = await codec.getNextFrame();
        final dur = frameInfo.duration.inMilliseconds > 20
            ? frameInfo.duration
            : const Duration(milliseconds: 90);
        decoded.add(_DecodedGifFrame(frameInfo.image, dur));
      }
      codec.dispose();

      if (!mounted || widget.exercise.id != ex.id) {
        for (final f in decoded) {
          f.image.dispose();
        }
        return;
      }

      _disposeFrames();
      setState(() {
        _frames = decoded;
        _frameIndex = 0;
        _isLoadingGif = false;
        _gifFailed = decoded.isEmpty;
      });
      if (_isPlaying && decoded.length > 1) {
        _scheduleNextFrame();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingGif = false;
        _gifFailed = true;
      });
    }
  }

  Future<Uint8List?> _downloadBytes(String url) async {
    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 7);
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.userAgentHeader, 'ShaoweiFitnessApp/3.0');
      final res = await req.close().timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return await consolidateHttpClientResponseBytes(res);
      }
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
    return null;
  }

  void _scheduleNextFrame() {
    _frameTimer?.cancel();
    if (!_isPlaying || _frames.length <= 1) return;
    final baseMs = _frames[_frameIndex].duration.inMilliseconds;
    final scaledMs = (baseMs / _playbackSpeed).round().clamp(35, 600);
    _frameTimer = Timer(Duration(milliseconds: scaledMs), () {
      if (!mounted || !_isPlaying || _frames.isEmpty) return;
      setState(() {
        _frameIndex = (_frameIndex + 1) % _frames.length;
      });
      _scheduleNextFrame();
    });
  }

  void _disposeFrames() {
    _frameTimer?.cancel();
    for (final f in _frames) {
      f.image.dispose();
    }
    _frames = [];
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _phaseCtrl.repeat();
        _scheduleNextFrame();
      } else {
        _phaseCtrl.stop();
        _frameTimer?.cancel();
      }
    });
  }

  void _cycleSpeed() {
    HapticFeedback.selectionClick();
    final nextSpeed = _playbackSpeed == 1.0
        ? 0.5
        : (_playbackSpeed == 0.5 ? 1.5 : 1.0);
    final currentProgress = _phaseCtrl.value;
    setState(() {
      _playbackSpeed = nextSpeed;
      _phaseCtrl.duration =
          Duration(milliseconds: (_totalCycleSec * 1000 / _playbackSpeed).round());
      _phaseCtrl.value = currentProgress;
      if (_isPlaying) {
        _phaseCtrl.repeat();
        _scheduleNextFrame();
      }
    });
  }

  void _jumpToPhase(MotionPhase target) {
    HapticFeedback.selectionClick();
    final total = _totalCycleSec.toDouble();
    double startProgress = 0.0;
    double targetFrameRatio = 0.0;

    switch (target) {
      case MotionPhase.prep:
        startProgress = 0.02;
        targetFrameRatio = 0.0;
        break;
      case MotionPhase.concentric:
        startProgress = (_prepSec + 0.1) / total;
        targetFrameRatio = 0.30;
        break;
      case MotionPhase.peak:
        startProgress = (_prepSec + _concentricSec + 0.1) / total;
        targetFrameRatio = 0.52;
        break;
      case MotionPhase.eccentric:
        startProgress = (_prepSec + _concentricSec + _peakSec + 0.1) / total;
        targetFrameRatio = 0.78;
        break;
    }

    _phaseCtrl.value = startProgress.clamp(0.0, 0.99);
    if (_frames.isNotEmpty) {
      setState(() {
        _frameIndex = (_frames.length * targetFrameRatio).floor().clamp(0, _frames.length - 1);
      });
    }
    if (_isPlaying) {
      _phaseCtrl.repeat();
      _scheduleNextFrame();
    }
  }

  void _resetZoom() {
    HapticFeedback.lightImpact();
    _transformCtrl.value = Matrix4.identity();
  }

  void _openFullScreenZoom(BuildContext context) {
    HapticFeedback.lightImpact();
    final ex = widget.exercise;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.5,
              child: Image.network(
                ex.gifUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.network(
                  ex.gifFallbackUrl,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${ex.name} · 双指放大看发力轨迹",
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

  _PhaseInfo _computePhaseInfo(double progress) {
    final total = _totalCycleSec.toDouble();
    final elapsed = progress * total;
    final p1 = _prepSec.toDouble();
    final p2 = p1 + _concentricSec;
    final p3 = p2 + _peakSec;

    if (elapsed < p1) {
      final frac = (elapsed / _prepSec).clamp(0.0, 1.0);
      return _PhaseInfo(
        phase: MotionPhase.prep,
        phaseIndex: 0,
        phaseProgress: frac,
        remainingSec: (_prepSec - elapsed).ceil().clamp(1, _prepSec),
        label: '1 准备起始',
        breathTag: '稳住核心',
        cue: widget.exercise.prepCue,
        color: const Color(0xFF94A3B8),
        offlineMotionT: 0.0,
      );
    } else if (elapsed < p2) {
      final frac = ((elapsed - p1) / _concentricSec).clamp(0.0, 1.0);
      return _PhaseInfo(
        phase: MotionPhase.concentric,
        phaseIndex: 1,
        phaseProgress: frac,
        remainingSec: (p2 - elapsed).ceil().clamp(1, _concentricSec),
        label: '2 发力向心',
        breathTag: '呼气发力',
        cue: widget.exercise.concentricCue,
        color: AppTheme.electroOrange,
        offlineMotionT: frac,
      );
    } else if (elapsed < p3) {
      final frac = ((elapsed - p2) / _peakSec).clamp(0.0, 1.0);
      return _PhaseInfo(
        phase: MotionPhase.peak,
        phaseIndex: 2,
        phaseProgress: frac,
        remainingSec: (p3 - elapsed).ceil().clamp(1, _peakSec),
        label: '3 顶峰控制',
        breathTag: '挤压停顿',
        cue: widget.exercise.peakCue,
        color: AppTheme.neonLime,
        offlineMotionT: 1.0,
      );
    } else {
      final frac = ((elapsed - p3) / _eccentricSec).clamp(0.0, 1.0);
      return _PhaseInfo(
        phase: MotionPhase.eccentric,
        phaseIndex: 3,
        phaseProgress: frac,
        remainingSec: (total - elapsed).ceil().clamp(1, _eccentricSec),
        label: '4 慢速离心',
        breathTag: '吸气慢放',
        cue: widget.exercise.eccentricCue,
        color: AppTheme.iceCyan,
        offlineMotionT: 1.0 - frac,
      );
    }
  }

  @override
  void dispose() {
    _phaseCtrl.removeListener(_onPhaseTick);
    _phaseCtrl.dispose();
    _disposeFrames();
    _transformCtrl.removeListener(_onTransformChanged);
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ex = widget.exercise;

    return AnimatedBuilder(
      animation: _phaseCtrl,
      builder: (context, _) {
        final info = _computePhaseInfo(_phaseCtrl.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 核心连续动作演示舞台
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: const Color(0xFF0D111A),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: info.color.withOpacity(isDark ? 0.16 : 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 舞台柔光背景（GIF 为白底人体解剖图时，用柔光居中展示无割裂感）
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.9,
                            colors: _gifFailed
                                ? const [Color(0xFF1A2234), Color(0xFF090D16)]
                                : const [Color(0xFFFFFFFF), Color(0xFFEFF3F9)],
                          ),
                        ),
                      ),
                    ),

                    // 连续动图画布 / 离线 60fps 生物力学动画回退
                    Positioned.fill(
                      child: _buildMotionStage(info, ex),
                    ),

                    // 可开关：动态发力轨迹箭头 + 目标肌群脉冲层
                    if (_showOverlay)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: MotionTrajectoryPainter(
                              pattern: ex.motionPattern,
                              phase: info.phase,
                              phaseProgress: info.phaseProgress,
                              cycleProgress: _phaseCtrl.value,
                            ),
                          ),
                        ),
                      ),

                    // 顶部左：发力轨迹开关 + 目标肌群脉冲徽章
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _glassPill(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _showOverlay = !_showOverlay);
                            },
                            active: _showOverlay,
                            activeColor: AppTheme.neonLime,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.track_changes_rounded,
                                  size: 13,
                                  color: _showOverlay
                                      ? AppTheme.neonLime
                                      : Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _showOverlay ? '轨迹+肌群 开' : '轨迹层 关',
                                  style: TextStyle(
                                    color: _showOverlay
                                        ? AppTheme.neonLime
                                        : Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 顶部右：倍速 / 播放暂停 / 全屏缩放
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isZoomed) ...[
                            _glassPill(
                              onTap: _resetZoom,
                              active: true,
                              activeColor: AppTheme.electroOrange,
                              child: const Text(
                                '还原',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          _glassPill(
                            onTap: _cycleSpeed,
                            child: Text(
                              '${_playbackSpeed}x',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _glassPill(
                            onTap: _togglePlayPause,
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _glassPill(
                            onTap: () => _openFullScreenZoom(context),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 底部叠加栏：实时目标肌群脉冲提示 + 实时呼吸节拍倒计时
                    Positioned(
                      bottom: 10,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          if (_showOverlay)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A0E17).withOpacity(0.82),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: info.color,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: info.color.withOpacity(0.7),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        '发力肌群：${ex.targetMuscle}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: info.color.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${info.breathTag} · ${info.remainingSec}s',
                              style: TextStyle(
                                color: info.phase == MotionPhase.peak
                                    ? AppTheme.neonLimeDarkText
                                    : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2. 四阶段发力拆解进度条 + 呼吸节拍器控制台
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.cardDecoration(isDark, radius: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部：节奏总览 + 节拍震动开关
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: info.color.withOpacity(isDark ? 0.18 : 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          info.label,
                          style: TextStyle(
                            color: info.phase == MotionPhase.peak && !isDark
                                ? AppTheme.mintEmerald
                                : info.color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ex.tempoSummary,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _metronomeHaptic = !_metronomeHaptic);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _metronomeHaptic
                                ? AppTheme.electroOrange.withOpacity(0.18)
                                : (isDark
                                    ? AppTheme.darkSurfaceElevated
                                    : AppTheme.lightSurfaceElevated),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.vibration_rounded,
                                size: 13,
                                color: _metronomeHaptic
                                    ? AppTheme.electroOrange
                                    : AppTheme.textSecondary(isDark),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _metronomeHaptic ? '节拍震动开' : '节拍震动',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: _metronomeHaptic
                                      ? AppTheme.electroOrange
                                      : AppTheme.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4 段式可点击进度条
                  Row(
                    children: [
                      _phaseSegment(
                        title: '1 准备',
                        phase: MotionPhase.prep,
                        activeInfo: info,
                        color: const Color(0xFF94A3B8),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _phaseSegment(
                        title: '2 向心',
                        phase: MotionPhase.concentric,
                        activeInfo: info,
                        color: AppTheme.electroOrange,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _phaseSegment(
                        title: '3 顶峰',
                        phase: MotionPhase.peak,
                        activeInfo: info,
                        color: isDark ? AppTheme.neonLime : AppTheme.mintEmerald,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _phaseSegment(
                        title: '4 离心',
                        phase: MotionPhase.eccentric,
                        activeInfo: info,
                        color: AppTheme.iceCyan,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 当前阶段动作要领 + 呼吸引导文字
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: AppTheme.innerTileDecoration(isDark, radius: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.air_rounded,
                          size: 16,
                          color: info.phase == MotionPhase.peak && !isDark
                              ? AppTheme.mintEmerald
                              : info.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            info.cue,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(isDark),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMotionStage(_PhaseInfo info, Exercise ex) {
    if (_isLoadingGif) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: OfflineBiomechanicalPainter(
              pattern: ex.motionPattern,
              motionT: info.offlineMotionT,
              accentColor: info.color,
            ),
          ),
          Positioned(
            bottom: 44,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.neonLime,
                    ),
                  ),
                  SizedBox(width: 7),
                  Text(
                    '正在加载高清连续动图...',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_gifFailed || _frames.isEmpty) {
      // 优雅的 60fps 本地矢量生物力学回退动画 + 重试按钮
      return Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: OfflineBiomechanicalPainter(
              pattern: ex.motionPattern,
              motionT: info.offlineMotionT,
              accentColor: info.color,
            ),
          ),
          Positioned(
            bottom: 46,
            child: InkWell(
              onTap: _loadGifWithFallback,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: AppTheme.neonLime, size: 14),
                    SizedBox(width: 5),
                    Text(
                      '离线生物力学演示 · 点击重试在线 GIF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final frameImage = _frames[_frameIndex.clamp(0, _frames.length - 1)].image;
    final rawFrame = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: RawImage(
        image: frameImage,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      ),
    );

    if (!widget.enablePinchZoom) {
      return GestureDetector(onTap: _togglePlayPause, child: rawFrame);
    }

    return InteractiveViewer(
      transformationController: _transformCtrl,
      minScale: 1.0,
      maxScale: 3.5,
      child: GestureDetector(
        onTap: _togglePlayPause,
        onDoubleTap: _isZoomed ? _resetZoom : () => _openFullScreenZoom(context),
        child: rawFrame,
      ),
    );
  }

  Widget _phaseSegment({
    required String title,
    required MotionPhase phase,
    required _PhaseInfo activeInfo,
    required Color color,
    required bool isDark,
  }) {
    final isCurrent = activeInfo.phase == phase;
    final isPassed = activeInfo.phaseIndex > phase.index;
    final fillFraction = isCurrent
        ? activeInfo.phaseProgress
        : (isPassed ? 1.0 : 0.0);

    return Expanded(
      child: GestureDetector(
        onTap: () => _jumpToPhase(phase),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 6,
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fillFraction.clamp(0.0, 1.0),
                  child: Container(color: color),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                color: isCurrent ? color : AppTheme.textSecondary(isDark),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassPill({
    required VoidCallback onTap,
    required Widget child,
    bool active = false,
    Color activeColor = AppTheme.electroOrange,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF0A0E17).withOpacity(0.86)
                : const Color(0xFF0A0E17).withOpacity(0.68),
            borderRadius: BorderRadius.circular(20),
            border: active
                ? Border.all(color: activeColor.withOpacity(0.65), width: 1)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PhaseInfo {
  final MotionPhase phase;
  final int phaseIndex;
  final double phaseProgress;
  final int remainingSec;
  final String label;
  final String breathTag;
  final String cue;
  final Color color;
  final double offlineMotionT;

  const _PhaseInfo({
    required this.phase,
    required this.phaseIndex,
    required this.phaseProgress,
    required this.remainingSec,
    required this.label,
    required this.breathTag,
    required this.cue,
    required this.color,
    required this.offlineMotionT,
  });
}

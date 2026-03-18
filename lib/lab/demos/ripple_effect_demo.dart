import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../lab_container.dart';

/// 水波纹效果 Demo
class RippleEffectDemo extends DemoPage {
  @override
  String get title => '水波纹';

  @override
  String get description => '点击屏幕产生水波纹扩散动画';

  @override
  Widget buildPage(BuildContext context) {
    return const _RippleEffectPage();
  }
}

class _RippleEffectPage extends StatefulWidget {
  const _RippleEffectPage();

  @override
  State<_RippleEffectPage> createState() => _RippleEffectPageState();
}

class _RippleEffectPageState extends State<_RippleEffectPage>
    with TickerProviderStateMixin {
  final List<Ripple> _ripples = [];
  int _rippleCount = 0;
  bool _autoMode = false;

  @override
  void dispose() {
    for (var ripple in _ripples) {
      ripple.controller.dispose();
    }
    super.dispose();
  }

  void _addRipple(Offset position) {
    setState(() {
      _rippleCount++;
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );

      final ripple = Ripple(
        position: position,
        controller: controller,
        id: _rippleCount,
      );

      _ripples.add(ripple);

      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _ripples.remove(ripple);
          });
          controller.dispose();
        }
      });

      controller.forward();
    });
  }

  void _toggleAutoMode() {
    setState(() {
      _autoMode = !_autoMode;
    });

    if (_autoMode) {
      _startAutoRipple();
    }
  }

  void _startAutoRipple() {
    if (!_autoMode) return;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_autoMode && mounted) {
        final random = math.Random();
        final screenSize = MediaQuery.of(context).size;
        final x = random.nextDouble() * screenSize.width * 0.8 + screenSize.width * 0.1;
        final y = random.nextDouble() * screenSize.height * 0.6 + screenSize.height * 0.2;
        _addRipple(Offset(x, y));
        _startAutoRipple();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '水波纹效果',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      '波纹数: ${_ripples.length}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _autoMode,
                      onChanged: (v) => _toggleAutoMode(),
                    ),
                    Text('自动', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
          // 水波纹区域
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                _addRipple(details.localPosition);
              },
              child: Container(
                color: theme.colorScheme.surface,
                child: Stack(
                  children: [
                    // 背景装饰
                    ...List.generate(5, (index) {
                      return Positioned(
                        left: 30 + index * 70.0,
                        top: 80 + (index % 2) * 100.0,
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            Icons.water_drop,
                            size: 60,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }),
                    // 水波纹
                    ..._ripples.map((ripple) => _RippleWidget(ripple: ripple)),
                    // 提示文字
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 64,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '点击屏幕产生水波纹',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '或开启自动模式',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Ripple {
  final Offset position;
  final AnimationController controller;
  final int id;

  Ripple({
    required this.position,
    required this.controller,
    required this.id,
  });
}

class _RippleWidget extends StatelessWidget {
  final Ripple ripple;

  const _RippleWidget({required this.ripple});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ripple.controller,
      builder: (context, child) {
        final progress = ripple.controller.value;
        final opacity = (1 - progress).clamp(0.0, 1.0);
        final scale = 0.3 + progress * 0.7;
        final maxRadius = 150.0;

        return Positioned(
          left: ripple.position.dx - maxRadius * scale,
          top: ripple.position.dy - maxRadius * scale,
          child: Opacity(
            opacity: opacity * 0.6,
            child: Container(
              width: maxRadius * 2 * scale,
              height: maxRadius * 2 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.withOpacity(0.8),
                  width: 3 * (1 - progress) + 1,
                ),
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void registerRippleEffectDemo() {
  demoRegistry.register(RippleEffectDemo());
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../lab_container.dart';

/// 自由绘制画布 Demo
class CanvasDemo extends DemoPage {
  @override
  String get title => '画布';

  @override
  String get description => '自由绘制与创作';

  @override
  Widget buildPage(BuildContext context) {
    return const _CanvasPage();
  }
}

class _CanvasPage extends StatefulWidget {
  const _CanvasPage();

  @override
  State<_CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<_CanvasPage> {
  // 存储所有笔画路径
  final List<DrawingPath> _paths = [];
  // 当前正在绘制的路径
  DrawingPath? _currentPath;

  // 当前画笔设置
  Color _strokeColor = Colors.black;
  double _strokeWidth = 4.0;
  bool _isEraser = false;

  // 预设颜色
  static const List<Color> _colorPalette = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  // 预设粗细
  static const List<double> _strokeWidths = [2.0, 4.0, 8.0, 12.0, 20.0];

  int _selectedColorIndex = 0;
  int _selectedWidthIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部工具栏
            _buildToolbar(),
            // 画布区域
            Expanded(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: CanvasPainter(
                    paths: _paths,
                    currentPath: _currentPath,
                    backgroundColor: Colors.white,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
            // 底部工具栏
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 橡皮擦按钮
          _buildToolButton(
            icon: Icons.auto_fix_high,
            label: '橡皮',
            isSelected: _isEraser,
            onTap: () {
              setState(() {
                _isEraser = !_isEraser;
                if (_isEraser) {
                  _strokeColor = Colors.white;
                } else {
                  _strokeColor = _colorPalette[_selectedColorIndex];
                }
              });
            },
          ),
          const SizedBox(width: 8),
          // 撤销按钮
          _buildToolButton(
            icon: Icons.undo,
            label: '撤销',
            onTap: _paths.isEmpty ? null : () {
              setState(() {
                _paths.removeLast();
              });
            },
          ),
          const Spacer(),
          // 清除全部
          _buildToolButton(
            icon: Icons.delete_outline,
            label: '清除',
            onTap: _paths.isEmpty ? null : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('清除画布'),
                  content: const Text('确定要清除所有绘制内容吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _paths.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: onTap == null
                  ? Colors.grey[400]
                  : (isSelected ? Colors.white : Colors.black87),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: onTap == null
                    ? Colors.grey[400]
                    : (isSelected ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 颜色选择器
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_colorPalette.length, (index) {
              final color = _colorPalette[index];
              final isSelected = !_isEraser && _selectedColorIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _isEraser = false;
                    _selectedColorIndex = index;
                    _strokeColor = color;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // 粗细选择器
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_strokeWidths.length, (index) {
              final width = _strokeWidths[index];
              final isSelected = _selectedWidthIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedWidthIndex = index;
                    _strokeWidth = width;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[100] : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: width * 2,
                      height: width * 2,
                      decoration: BoxDecoration(
                        color: _isEraser ? Colors.grey : Colors.black87,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final point = details.localPosition;
    _currentPath = DrawingPath(
      points: [point],
      color: _strokeColor,
      strokeWidth: _strokeWidth,
      isEraser: _isEraser,
    );
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentPath == null) return;

    final point = details.localPosition;
    setState(() {
      _currentPath!.points.add(point);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPath != null && _currentPath!.points.isNotEmpty) {
      _paths.add(_currentPath!);
      _currentPath = null;
      setState(() {});
    }
  }
}

/// 单条笔画路径
class DrawingPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.isEraser,
  });
}

/// 画布Painter
class CanvasPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final DrawingPath? currentPath;
  final Color backgroundColor;

  CanvasPainter({
    required this.paths,
    this.currentPath,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // 绘制所有已完成的路径
    for (final path in paths) {
      _drawPath(canvas, path);
    }

    // 绘制当前正在绘制的路径
    if (currentPath != null) {
      _drawPath(canvas, currentPath!);
    }
  }

  void _drawPath(Canvas canvas, DrawingPath drawingPath) {
    if (drawingPath.points.isEmpty) return;

    final paint = Paint()
      ..color = drawingPath.color
      ..strokeWidth = drawingPath.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (drawingPath.isEraser) {
      paint.blendMode = BlendMode.clear;
    }

    if (drawingPath.points.length == 1) {
      // 单点绘制圆点
      canvas.drawCircle(
        drawingPath.points.first,
        drawingPath.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    // 使用贝塞尔曲线绘制平滑路径
    final path = Path();
    path.moveTo(drawingPath.points.first.dx, drawingPath.points.first.dy);

    for (int i = 1; i < drawingPath.points.length - 1; i++) {
      final p0 = drawingPath.points[i];
      final p1 = drawingPath.points[i + 1];
      final midPoint = Offset(
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    // 连接最后一个点
    if (drawingPath.points.length > 1) {
      final last = drawingPath.points.last;
      path.lineTo(last.dx, last.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.currentPath != currentPath ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

void registerCanvasDemo() {
  demoRegistry.register(CanvasDemo());
}

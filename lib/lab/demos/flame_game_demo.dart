import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../lab_container.dart';

/// Flame 游戏 Demo
class FlameGameDemo extends DemoPage {
  @override
  String get title => '接星星';

  @override
  String get description => 'Flame 引擎小游戏';

  @override
  Widget buildPage(BuildContext context) {
    return const _FlameGamePage();
  }
}

class _FlameGamePage extends StatefulWidget {
  const _FlameGamePage();

  @override
  State<_FlameGamePage> createState() => _FlameGamePageState();
}

class _FlameGamePageState extends State<_FlameGamePage> {
  late final CatchTheStarsGame _game;
  int _score = 0;
  int _lives = 3;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _game = CatchTheStarsGame(
      onScore: _onScore,
      onMiss: _onMiss,
    );
  }

  void _onScore() {
    if (!mounted) return;
    setState(() => _score++);
  }

  void _onMiss() {
    if (!mounted) return;
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _gameOver = true;
        _game.setGameOver();
      }
    });
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _gameOver = false;
    });
    _game.restartGame();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 状态栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.blue.shade800,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '得分: $_score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(3, (i) {
                  return Icon(
                    i < _lives ? Icons.favorite : Icons.favorite_border,
                    color: i < _lives ? Colors.red : Colors.grey,
                    size: 24,
                  );
                }),
              ),
            ],
          ),
        ),
        // 游戏区域
        Expanded(
          child: _gameOver
              ? _buildGameOver()
              : GameWidget(
                  game: _game,
                  backgroundBuilder: (_) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.indigo.shade900,
                          Colors.purple.shade900,
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildGameOver() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.indigo.shade900,
            Colors.purple.shade900,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_very_dissatisfied, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              '游戏结束!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '最终得分: $_score',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _restartGame,
              icon: const Icon(Icons.refresh),
              label: const Text('重新开始'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 接星星游戏
class CatchTheStarsGame extends FlameGame {
  final VoidCallback onScore;
  final VoidCallback onMiss;

  Player? _player;
  final List<Star> _stars = [];
  final Random _random = Random();

  bool gameOver = false;
  double _starSpawnTimer = 0;
  static const double starSpawnInterval = 0.8;

  CatchTheStarsGame({
    required this.onScore,
    required this.onMiss,
  });

  @override
  Future<void> onMount() async {
    super.onMount();
    // 添加玩家（篮子）
    _player = Player(position: Vector2(size.x / 2, size.y - 50));
    add(_player!);
  }

  @override
  void update(double dt) {
    if (gameOver) return;

    super.update(dt);

    // 生成星星
    _starSpawnTimer += dt;
    if (_starSpawnTimer >= starSpawnInterval) {
      _starSpawnTimer = 0;
      _spawnStar();
    }

    // 更新星星位置
    for (final star in _stars.toList()) {
      star.position.y += 150 * dt;

      // 检查是否被接住
      if (_player != null && _player!.checkCollision(star)) {
        _catchStar(star);
      }
      // 检查是否掉出屏幕
      else if (star.position.y > size.y) {
        _missStar(star);
      }
    }
  }

  void _spawnStar() {
    final x = _random.nextDouble() * (size.x - 40) + 20;
    final star = Star(position: Vector2(x, -20));
    _stars.add(star);
    add(star);
  }

  void _catchStar(Star star) {
    _stars.remove(star);
    star.removeFromParent();
    onScore();
  }

  void _missStar(Star star) {
    _stars.remove(star);
    star.removeFromParent();
    onMiss();
  }

  void restartGame() {
    gameOver = false;
    _starSpawnTimer = 0;

    // 清除所有星星
    for (final star in _stars.toList()) {
      star.removeFromParent();
    }
    _stars.clear();

    // 重置玩家位置
    _player?.position = Vector2(size.x / 2, size.y - 50);
  }

  void setGameOver() {
    gameOver = true;
  }

  void onPointerMove(PointerMoveEvent event) {
    if (gameOver || _player == null) return;
    _player!.position.x = event.localPosition.dx.clamp(20, size.x - 20);
  }

  void onPointerDown(PointerDownEvent event) {
    if (gameOver || _player == null) return;
    _player!.position.x = event.localPosition.dx.clamp(20, size.x - 20);
  }
}

/// 玩家（篮子）
class Player extends PositionComponent {
  Player({required super.position});

  @override
  void render(Canvas canvas) {
    // 绘制篮子形状
    final path = Path();
    path.moveTo(-20, -15);
    path.lineTo(20, -15);
    path.lineTo(15, 15);
    path.lineTo(-15, 15);
    path.close();

    canvas.drawPath(path, Paint()..color = Colors.orange);
    canvas.drawCircle(Offset.zero, 10, Paint()..color = Colors.orange.shade700);
  }

  bool checkCollision(Star star) {
    final playerRect = Rect.fromCenter(
      center: position.toOffset(),
      width: 40,
      height: 30,
    );
    final starRect = Rect.fromCenter(
      center: star.position.toOffset(),
      width: 24,
      height: 24,
    );
    return playerRect.overlaps(starRect);
  }
}

/// 星星
class Star extends PositionComponent {
  Star({required super.position}) : super(size: Vector2.all(24));

  @override
  void render(Canvas canvas) {
    // 绘制五角星
    final path = _createStarPath(12.0, 5.0);
    canvas.drawPath(path, Paint()..color = Colors.yellow);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  Path _createStarPath(double outerRadius, double innerRadius) {
    final path = Path();
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final x = radius * _cos(angle);
      final y = radius * _sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  double _cos(double angle) {
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -angle * angle / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sin(double angle) {
    double result = angle;
    double term = angle;
    for (int i = 1; i <= 10; i++) {
      term *= -angle * angle / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}

void registerFlameGameDemo() {
  demoRegistry.register(FlameGameDemo());
}

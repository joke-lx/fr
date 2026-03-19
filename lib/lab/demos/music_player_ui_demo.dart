import 'package:flutter/material.dart';
import '../lab_container.dart';

/// 音乐播放器 UI Demo
class MusicPlayerUIDemo extends DemoPage {
  @override
  String get title => '音乐播放器';

  @override
  String get description => '精美的音乐播放器界面';

  @override
  Widget buildPage(BuildContext context) {
    return const _MusicPlayerUIPage();
  }
}

class _MusicPlayerUIPage extends StatefulWidget {
  const _MusicPlayerUIPage();

  @override
  State<_MusicPlayerUIPage> createState() => _MusicPlayerUIPageState();
}

class _MusicPlayerUIPageState extends State<_MusicPlayerUIPage> {
  bool _isPlaying = false;
  double _progress = 0.35;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // 颜色定义
    const darkShadowColor = Color(0xFF2d2d3a);
    const lightShadowColor = Color(0xFF6b6b7a);
    const myTextColor = Color(0xFF3e3e4a);
    const myBackgroundColor = Color(0xFFe6e6e8);

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
                  '音乐播放器',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // 播放器主体
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    myBackgroundColor,
                    Colors.grey.shade300,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  // 圆形专辑封面
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 外圈阴影
                      Container(
                        width: size.width / 1.3,
                        height: size.width / 1.3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [lightShadowColor, darkShadowColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkShadowColor,
                              offset: const Offset(10, 8),
                              blurRadius: 15,
                            ),
                            BoxShadow(
                              color: lightShadowColor,
                              offset: const Offset(-10, -8),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                      // 专辑封面
                      Container(
                        width: size.width / 1.3 - 20,
                        height: size.width / 1.3 - 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://img.freepik.com/premium-photo/guitar-headphone-music-cartoon-vector-icon-illustration-music-holiday-icon-concept-isolated_839035-1114282.jpg?w=1480',
                            ),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      // 播放按钮覆盖层
                      if (!_isPlaying)
                        GestureDetector(
                          onTap: () => setState(() => _isPlaying = true),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // 歌曲信息
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'I Never Loved a Man',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: myTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aretha Franklin',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // 进度条
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            // 背景条
                            Container(
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Colors.grey.shade300,
                              ),
                            ),
                            // 进度条
                            Container(
                              height: 6,
                              width: size.width * _progress,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                              ),
                            ),
                            // 滑块
                            Positioned(
                              left: size.width * _progress - 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // 时间显示
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '1:02',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: myTextColor,
                                ),
                              ),
                              Text(
                                '3:22',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 控制按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MusicControlButton(
                          icon: Icons.arrow_back_ios,
                          size: 35,
                          onTap: () {},
                        ),
                        _MusicControlButton(
                          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 65,
                          isPrimary: true,
                          onTap: () => setState(() => _isPlaying = !_isPlaying),
                        ),
                        _MusicControlButton(
                          icon: Icons.arrow_forward_ios,
                          size: 35,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isPrimary;
  final VoidCallback onTap;

  const _MusicControlButton({
    required this.icon,
    required this.size,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkShadowColor = Color(0xFF2d2d3a);
    const lightShadowColor = Color(0xFF6b6b7a);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white : const Color(0xFFe6e6e8),
              borderRadius: BorderRadius.circular(size / 3),
              boxShadow: [
                BoxShadow(
                  color: darkShadowColor,
                  offset: Offset(isPrimary ? 6.0 : 4.0, isPrimary ? 5.0 : 3.0),
                  blurRadius: isPrimary ? 12 : 8,
                ),
                BoxShadow(
                  color: lightShadowColor,
                  offset: Offset(-(isPrimary ? 6.0 : 4.0), -(isPrimary ? 5.0 : 3.0)),
                  blurRadius: isPrimary ? 12 : 8,
                ),
              ],
            ),
          ),
          Icon(
            icon,
            size: isPrimary ? size * 0.5 : size * 0.5,
            color: isPrimary ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
          ),
        ],
      ),
    );
  }
}

void registerMusicPlayerUIDemo() {
  demoRegistry.register(MusicPlayerUIDemo());
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../lab_container.dart';

/// 游戏中心 Demo - 液态玻璃风格游戏集合入口
class GameHubDemo extends DemoPage {
  @override
  String get title => '游戏中心';

  @override
  String get description => '小游戏集合，液态玻璃风格';

  @override
  Widget buildPage(BuildContext context) {
    return const _GameHubPage();
  }
}

/// 游戏数据模型
class GameItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String? route;
  final bool isLocked;

  const GameItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.route,
    this.isLocked = false,
  });
}

/// 初始游戏列表
const List<GameItem> initialGames = [
  // 第一页 - 可玩游戏
  GameItem(
    id: 'piano_tile',
    title: '钢琴块',
    icon: Icons.piano,
    color: Color(0xFF1C1C1E),
    route: '/piano-tile',
  ),
  GameItem(
    id: 'game_2048',
    title: '2048',
    icon: Icons.grid_on,
    color: Color(0xFFEDC22E),
  ),
  GameItem(
    id: 'coming_soon_1',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'coming_soon_2',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'coming_soon_3',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'coming_soon_4',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  // 第二页 - 预留槽位
  GameItem(
    id: 'slot_2_1',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'slot_2_2',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'slot_2_3',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'slot_2_4',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'slot_2_5',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'slot_2_6',
    title: '即将推出',
    icon: Icons.more_horiz,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
];

/// 游戏中心主页面
class _GameHubPage extends StatefulWidget {
  const _GameHubPage();

  @override
  State<_GameHubPage> createState() => _GameHubPageState();
}

class _GameHubPageState extends State<_GameHubPage> {
  @override
  Widget build(BuildContext context) {
    return const _GameHubCard();
  }
}

/// 游戏中心缩略卡片 - 与其他 Demo 卡片尺寸一致
class _GameHubCard extends StatelessWidget {
  const _GameHubCard();

  void _openOverlay(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _GameHubOverlay(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
        opaque: false,
        barrierColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openOverlay(context),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.08),
                theme.colorScheme.primary.withValues(alpha: 0.03),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.videogame_asset,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                '游戏中心',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  '液态玻璃风格游戏集合',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              // 游戏预览图标
              Row(
                children: [
                  _buildPreviewIcon(context, Icons.piano, const Color(0xFF1C1C1E)),
                  const SizedBox(width: 6),
                  _buildPreviewIcon(context, Icons.grid_on, const Color(0xFFEDC22E)),
                  const SizedBox(width: 6),
                  _buildPreviewIcon(context, Icons.more_horiz, const Color(0xFF8E8E93), isSmall: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewIcon(BuildContext context, IconData icon, Color color, {bool isSmall = false}) {
    return Container(
      width: isSmall ? 28 : 32,
      height: isSmall ? 28 : 32,
      decoration: BoxDecoration(
        color: color.withOpacity(isSmall ? 0.5 : 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        color: color,
        size: isSmall ? 14 : 18,
      ),
    );
  }
}

/// 液态玻璃容器组件
class _GlassGameCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const _GlassGameCard({
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: child,
        ),
      ),
    );
  }
}

/// 游戏图标组件
class _GameIconWidget extends StatelessWidget {
  final GameItem game;
  final VoidCallback? onTap;

  const _GameIconWidget({
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = game.isLocked;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isLocked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isLocked
                ? const Color(0xFFF2F2F7)
                : game.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLocked
                  ? const Color(0xFFE5E5EA)
                  : game.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isLocked
                      ? const Color(0xFFE5E5EA)
                      : game.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : game.icon,
                  color: isLocked ? const Color(0xFF8E8E93) : Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isLocked
                      ? const Color(0xFF8E8E93)
                      : const Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 游戏中心展开弹窗
class _GameHubOverlay extends StatefulWidget {
  const _GameHubOverlay();

  @override
  State<_GameHubOverlay> createState() => _GameHubOverlayState();
}

class _GameHubOverlayState extends State<_GameHubOverlay> {
  late PageController _pageController;
  int _currentPage = 0;

  // 每页显示的游戏数量
  static const int gamesPerPage = 6;
  static const int gridColumns = 3;

  late List<List<GameItem>> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = _paginateGames(initialGames, gamesPerPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 将游戏列表分页
  List<List<GameItem>> _paginateGames(List<GameItem> games, int perPage) {
    List<List<GameItem>> pages = [];
    for (int i = 0; i < games.length; i += perPage) {
      final end = (i + perPage < games.length) ? i + perPage : games.length;
      pages.add(games.sublist(i, end));
    }
    return pages;
  }

  void _closeOverlay() {
    Navigator.of(context).pop();
  }

  void _handleGameTap(GameItem game) {
    if (game.isLocked || game.route == null) {
      // 显示"即将推出"提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎮 敬请期待！'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 根据路由导航到对应游戏
    // 这里暂时显示提示，等待具体游戏实现
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎮 启动游戏：${game.title}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 背景模糊遮罩
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeOverlay,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          // 液态玻璃弹窗
          Center(
            child: _GlassGameCard(
              width: screenSize.width * 0.85,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题栏
                      Row(
                        children: [
                          Icon(
                            Icons.videogame_asset,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '游戏中心',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1C1C1E),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _closeOverlay,
                            icon: const Icon(Icons.close),
                            color: const Color(0xFF8E8E93),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 游戏网格
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemCount: _pages.length,
                          itemBuilder: (context, pageIndex) {
                            return _buildGameGrid(_pages[pageIndex]);
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 页码指示器
                      _buildPageIndicator(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建游戏网格
  Widget _buildGameGrid(List<GameItem> games) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return _GameIconWidget(
          game: games[index],
          onTap: () => _handleGameTap(games[index]),
        );
      },
    );
  }

  /// 构建页码指示器
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFE5E5EA),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

void registerGameHubDemo() {
  demoRegistry.register(GameHubDemo());
}

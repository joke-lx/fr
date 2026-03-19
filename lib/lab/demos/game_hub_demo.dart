import 'dart:ui';
import 'package:flutter/material.dart';
import '../lab_container.dart';

/// 游戏中心 Demo - 液态玻璃风格可拖拽游戏集合
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

  GameItem copyWith({
    String? id,
    String? title,
    IconData? icon,
    Color? color,
    String? route,
    bool? isLocked,
  }) {
    return GameItem(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      route: route ?? this.route,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

/// 文件夹模型
class GameFolder {
  final String id;
  final List<GameItem> games;
  final Color color;

  const GameFolder({
    required this.id,
    required this.games,
    required this.color,
  });

  GameFolder copyWith({String? id, List<GameItem>? games, Color? color}) {
    return GameFolder(
      id: id ?? this.id,
      games: games ?? this.games,
      color: color ?? this.color,
    );
  }
}

/// 桌面元素 - 可以是游戏或文件夹
class DesktopItem {
  final String id;
  final GameItem? game;
  final GameFolder? folder;
  final Offset position;

  const DesktopItem({
    required this.id,
    this.game,
    this.folder,
    required this.position,
  });

  DesktopItem copyWith({
    String? id,
    GameItem? game,
    GameFolder? folder,
    Offset? position,
  }) {
    return DesktopItem(
      id: id ?? this.id,
      game: game ?? this.game,
      folder: folder ?? this.folder,
      position: position ?? this.position,
    );
  }

  bool get isFolder => folder != null;
}

/// 初始游戏列表
const List<GameItem> allGames = [
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
    id: 'game_snake',
    title: '贪吃蛇',
    icon: Icons.nature,
    color: Color(0xFF34C759),
  ),
  GameItem(
    id: 'game_tetris',
    title: '俄罗斯方块',
    icon: Icons.view_column,
    color: Color(0xFF5856D6),
  ),
  GameItem(
    id: 'game_minesweeper',
    title: '扫雷',
    icon: Icons.grid_3x3,
    color: Color(0xFFFF9500),
  ),
  GameItem(
    id: 'coming_soon_1',
    title: '即将推出',
    icon: Icons.extension,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'coming_soon_2',
    title: '即将推出',
    icon: Icons.extension,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
  GameItem(
    id: 'coming_soon_3',
    title: '即将推出',
    icon: Icons.extension,
    color: Color(0xFF8E8E93),
    isLocked: true,
  ),
];

/// 默认桌面布局
List<DesktopItem> createDefaultDesktop() {
  return [
    DesktopItem(id: 'pos_0_0', game: allGames[0], position: const Offset(0, 0)),
    DesktopItem(id: 'pos_1_0', game: allGames[1], position: const Offset(1, 0)),
    DesktopItem(id: 'pos_2_0', game: allGames[2], position: const Offset(2, 0)),
    DesktopItem(id: 'pos_0_1', game: allGames[3], position: const Offset(0, 1)),
    DesktopItem(id: 'pos_1_1', game: allGames[4], position: const Offset(1, 1)),
    DesktopItem(
      id: 'pos_2_1',
      folder: GameFolder(
        id: 'folder_1',
        games: [allGames[5], allGames[6]],
        color: Color(0xFF8E8E93),
      ),
      position: const Offset(2, 1),
    ),
  ];
}

/// 格子大小
const double gridSpacing = 16.0;

/// 游戏中心主页面
class _GameHubPage extends StatefulWidget {
  const _GameHubPage();

  @override
  State<_GameHubPage> createState() => _GameHubPageState();
}

class _GameHubPageState extends State<_GameHubPage> {
  late List<DesktopItem> desktopItems;
  DesktopItem? draggingItem;

  // 使用 ValueNotifier 避免每帧 setState
  final ValueNotifier<Offset> _dragOffsetNotifier = ValueNotifier(Offset.zero);

  // 预计算的可见项目，避免每帧重新过滤
  late List<DesktopItem> _visibleItems;

  @override
  void initState() {
    super.initState();
    desktopItems = createDefaultDesktop();
    _visibleItems = [];
    _updateVisibleItems(9);
  }

  @override
  void dispose() {
    _dragOffsetNotifier.dispose();
    super.dispose();
  }

  void _updateVisibleItems(int visibleRowCount) {
    _visibleItems = desktopItems
        .where((item) => item.position.dy.toInt() < visibleRowCount)
        .toList();
  }

  void _openFolderOverlay(GameFolder folder) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _GameFolderOverlay(folder: folder),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          var fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: curve));

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

  void _handleGameTap(GameItem game) {
    if (game.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text('${game.title} 敬请期待'),
            ],
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(game.icon, color: Colors.white),
            const SizedBox(width: 8),
            Text('启动游戏：${game.title}'),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onDragStart(DesktopItem item) {
    setState(() {
      draggingItem = item;
      dragOffset = Offset.zero; // 立即初始化，使占位符立即显示
    });
  }

  void _onDragUpdate(Offset delta) {
    // 直接更新 dragOffset，不触发 setState
    dragOffset = (dragOffset ?? Offset.zero) + delta;
    // 只重建拖动项和占位符，使用 markNeedsPaint 而非 setState
    setState(() {});
  }

  void _onDragEnd(Offset position, double cellWidth, double cellHeight, int visibleRowCount) {
    // 计算放置位置
    final col = ((position.dx + cellWidth / 2) / (cellWidth + gridSpacing))
        .floor();
    final row = ((position.dy + cellHeight / 2) / (cellHeight + gridSpacing))
        .floor();

    // 限制在可视区域内（0 到 visibleRowCount-1）
    final clampedCol = col.clamp(0, 5); // 6列，索引0-5
    final clampedRow = row.clamp(0, visibleRowCount - 1);

    // 检查是否与现有项目重叠
    DesktopItem? targetItem;
    for (var item in desktopItems) {
      if (item.id != draggingItem?.id) {
        final itemCol = item.position.dx.toInt();
        final itemRow = item.position.dy.toInt();
        if (itemCol == clampedCol && itemRow == clampedRow) {
          targetItem = item;
          break;
        }
      }
    }

    if (targetItem != null && draggingItem != null) {
      // 合并到文件夹
      _mergeToFolder(draggingItem!, targetItem);
    } else {
      // 更新位置
      setState(() {
        final index = desktopItems.indexWhere(
          (item) => item.id == draggingItem?.id,
        );
        if (index != -1) {
          desktopItems[index] = desktopItems[index].copyWith(
            position: Offset(clampedCol.toDouble(), clampedRow.toDouble()),
          );
        }
        draggingItem = null;
        dragOffset = null;
      });
    }
  }

  void _mergeToFolder(DesktopItem source, DesktopItem target) {
    setState(() {
      List<GameItem> folderGames = [];

      if (source.game != null) folderGames.add(source.game!);
      if (target.game != null) folderGames.add(target.game!);

      // 如果目标是文件夹，添加其内容
      if (target.folder != null) {
        folderGames.addAll(target.folder!.games);
      }

      // 如果源是文件夹，添加其内容
      if (source.folder != null) {
        folderGames.addAll(source.folder!.games);
      }

      // 创建新文件夹
      final newFolder = GameFolder(
        id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
        games: folderGames,
        color: const Color(0xFF8E8E93),
      );

      // 移除源项目和目标项目，添加新文件夹
      desktopItems.removeWhere(
        (item) => item.id == source.id || item.id == target.id,
      );
      desktopItems.add(
        DesktopItem(
          id: newFolder.id,
          folder: newFolder,
          position: target.position,
        ),
      );

      draggingItem = null;
      dragOffset = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
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
            // 游戏桌面 - 填满剩余空间
            Expanded(flex: 1, child: _buildDesktop()),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktop() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据容器宽度计算格子大小
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // 使用可视区域行数（根据可用高度动态计算）
        final spacing = 16.0;
        final colCount = 6;

        // 先计算单列宽度
        final totalHorizontalSpacing = spacing * (colCount - 1);
        final cellWidth = (availableWidth - totalHorizontalSpacing) / colCount;

        // 根据高度计算能显示多少行（每行高度 = 格子宽度，保持正方形）
        final usableHeight = availableHeight * 0.9;
        final visibleRowCount = ((usableHeight + spacing) / (cellWidth + spacing)).floor().clamp(2, 9);

        final cellHeight = cellWidth;

        // 计算可视区域总高度
        final visibleGridHeight = visibleRowCount * cellHeight + spacing * (visibleRowCount - 1);

        // 检查是否有超出可视区域的项目
        final hasOverflowItems = desktopItems.any(
          (item) => item.position.dy.toInt() >= visibleRowCount,
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            // 网格和桌面项目（有高度限制）
            Center(
              child: SizedBox(
                width: colCount * cellWidth + totalHorizontalSpacing,
                height: visibleGridHeight,
                child: Stack(
                  children: [
                    // 网格背景 - 只在拖动时显示
                    if (draggingItem != null)
                      ..._buildGridBackground(
                        cellWidth,
                        cellHeight,
                        visibleRowCount,
                        colCount,
                      ),
                    // 桌面项目 - 只显示可视区域内的（拖动中的项目隐藏原位置）
                    ...desktopItems
                        .where((item) =>
                            item.position.dy.toInt() < visibleRowCount &&
                            item.id != draggingItem?.id)
                        .map(
                          (item) => _buildDesktopItem(item, cellWidth, cellHeight),
                        ),
                    // 占位符 - 拖动时显示在原位置
                    if (draggingItem != null && dragOffset != null)
                      _buildPlaceholder(draggingItem!, cellWidth, cellHeight),
                    // 超出可视区域的项目指示器
                    if (hasOverflowItems)
                      _buildOverflowIndicator(cellWidth, cellHeight, colCount),
                  ],
                ),
              ),
            ),
            // 拖动项 - 在 Stack 顶部渲染，不受高度限制
            if (draggingItem != null && dragOffset != null)
              _buildDraggingItem(cellWidth, cellHeight),
          ],
        );
      },
    );
  }

  /// 网格背景 - 根据行列数生成
  List<Widget> _buildGridBackground(
    double cellWidth,
    double cellHeight,
    int rowCount,
    int colCount,
  ) {
    List<Widget> widgets = [];
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < colCount; col++) {
        widgets.add(
          Positioned(
            left: col * (cellWidth + gridSpacing),
            top: row * (cellHeight + gridSpacing),
            child: Container(
              width: cellWidth,
              height: cellHeight,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  /// 拖动时的占位符
  Widget _buildPlaceholder(
    DesktopItem item,
    double cellWidth,
    double cellHeight,
  ) {
    // 占位符显示在项目原位置
    return Positioned(
      left: item.position.dx * (cellWidth + gridSpacing),
      top: item.position.dy * (cellHeight + gridSpacing),
      child: Container(
        width: cellWidth,
        height: cellHeight,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.5),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
      ),
    );
  }

  /// 超出可视区域的指示器
  Widget _buildOverflowIndicator(
    double cellWidth,
    double cellHeight,
    int colCount,
  ) {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: cellWidth * colCount + gridSpacing * (colCount - 1),
        height: cellHeight * 2 + gridSpacing,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '更多游戏',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopItem(
    DesktopItem item,
    double cellWidth,
    double cellHeight,
  ) {
    final isDragging = draggingItem?.id == item.id;

    return Positioned(
      left: item.position.dx * (cellWidth + gridSpacing),
      top: item.position.dy * (cellHeight + gridSpacing),
      child: GestureDetector(
        onPanStart: (_) => _onDragStart(item),
        onPanUpdate: (details) {
          if (draggingItem?.id == item.id) {
            _onDragUpdate(details.delta);
          }
        },
        onPanEnd: (_) {
          if (draggingItem?.id == item.id) {
            _onDragEnd(
              Offset(
                item.position.dx * (cellWidth + gridSpacing),
                item.position.dy * (cellHeight + gridSpacing),
              ) +
                  (dragOffset ?? Offset.zero),
              cellWidth,
              cellHeight,
              9,
            );
          }
        },
        onTap: item.isFolder ? () => _openFolderOverlay(item.folder!) : null,
        child: Opacity(
          opacity: isDragging ? 0.5 : 1.0,
          child: item.isFolder
              ? _buildFolderIcon(item.folder!, cellWidth, cellHeight)
              : _buildGameIcon(item.game!, cellWidth, cellHeight),
        ),
      ),
    );
  }

  Widget _buildDraggingItem(double cellWidth, double cellHeight) {
    if (draggingItem == null) return const SizedBox();

    return Positioned(
      left:
          (draggingItem!.position.dx * (cellWidth + gridSpacing)) +
          (dragOffset?.dx ?? 0),
      top:
          (draggingItem!.position.dy * (cellHeight + gridSpacing)) +
          (dragOffset?.dy ?? 0),
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.8,
          child: draggingItem!.isFolder
              ? _buildFolderIcon(draggingItem!.folder!, cellWidth, cellHeight)
              : _buildGameIcon(draggingItem!.game!, cellWidth, cellHeight),
        ),
      ),
    );
  }

  Widget _buildGameIcon(GameItem game, double cellWidth, double cellHeight) {
    return Container(
      width: cellWidth,
      height: cellHeight,
      decoration: BoxDecoration(
        color: game.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: game.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Icon(
        game.isLocked ? Icons.lock_outline : game.icon,
        color: game.isLocked
            ? const Color(0xFF8E8E93)
            : game.color.withValues(alpha: 0.8),
        size: cellWidth * 0.5,
      ),
    );
  }

  Widget _buildFolderIcon(
    GameFolder folder,
    double cellWidth,
    double cellHeight,
  ) {
    // 纯色玻璃效果（移除 BackdropFilter，Web 性能优化）
    return Container(
      width: cellWidth,
      height: cellHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: _buildFolderPreview(folder.games, cellWidth),
    );
  }

  Widget _buildFolderPreview(List<GameItem> games, double cellWidth) {
    final displayGames = games.take(4).toList();
    final rows = (displayGames.length / 2).ceil();

    return Column(
      children: List.generate(rows, (row) {
        final start = row * 2;
        final end = (start + 2).clamp(0, displayGames.length);
        final rowGames = displayGames.sublist(start, end);

        return Expanded(
          child: Row(
            children: rowGames.map((game) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: game.color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    game.icon,
                    color: game.color.withValues(alpha: 0.8),
                    size: cellWidth * 0.2,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}

/// 液态玻璃容器组件
class _GlassGameCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const _GlassGameCard({required this.child, this.width, this.height});

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

/// 文件夹弹窗
class _GameFolderOverlay extends StatefulWidget {
  final GameFolder folder;

  const _GameFolderOverlay({required this.folder});

  @override
  State<_GameFolderOverlay> createState() => _GameFolderOverlayState();
}

class _GameFolderOverlayState extends State<_GameFolderOverlay> {
  late PageController _pageController;
  late List<List<GameItem>> _pages;
  int _currentPage = 0;

  static const int gamesPerPage = 9;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = _paginateGames(widget.folder.games, gamesPerPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    if (game.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('敬请期待'),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(game.icon, color: Colors.white),
            const SizedBox(width: 8),
            Text('启动游戏：${game.title}'),
          ],
        ),
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
          // 纯透明模糊遮罩
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeOverlay,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(color: Colors.transparent),
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
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: widget.folder.color.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.folder,
                              color: widget.folder.color.withValues(alpha: 0.8),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${widget.folder.games.length} 个游戏',
                            style: theme.textTheme.titleLarge?.copyWith(
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

                      // 九宫格游戏网格
                      SizedBox(
                        height: 320,
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

  Widget _buildGameGrid(List<GameItem> games) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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

/// 游戏图标组件
class _GameIconWidget extends StatelessWidget {
  final GameItem game;
  final VoidCallback? onTap;

  const _GameIconWidget({required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = game.isLocked;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isLocked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: game.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: game.color.withValues(alpha: 0.2),
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
                  color: isLocked ? const Color(0xFFE5E5EA) : game.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : game.icon,
                  color: isLocked ? const Color(0xFF8E8E93) : Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void registerGameHubDemo() {
  demoRegistry.register(GameHubDemo());
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_item.dart';

/// Bookmark Controller/Provider
class BookmarkProvider with ChangeNotifier {
  static const String _storageKey = 'web_bookmarks';
  static const String _settingsKey = 'web_bookmark_settings';

  List<BookmarkItem> _items = [];
  bool _useExternalBrowser = false;
  BookmarkItem? _draggingItem;
  int? _hoverIndex;

  // Tile key 管理，用于位置计算
  final Map<String, GlobalKey> _tileKeys = {};

  List<BookmarkItem> get items => _items;
  bool get useExternalBrowser => _useExternalBrowser;
  BookmarkItem? get draggingItem => _draggingItem;
  int? get hoverIndex => _hoverIndex;

  List<BookmarkItem> get displayItems {
    if (_draggingItem != null && _hoverIndex != null) {
      final list = <BookmarkItem>[];
      final folders = <BookmarkFolder>[];
      final bookmarks = <BookmarkItem>[];

      // Separate folders and bookmarks
      for (final item in _items) {
        if (item is BookmarkFolder) {
          folders.add(item);
        } else if (item is SingleBookmark) {
          bookmarks.add(item);
        }
      }

      // Insert placeholder at hover position
      final clamped = _hoverIndex!.clamp(0, bookmarks.length);
      bookmarks.insert(clamped, BookmarkPlaceholder());

      // Rebuild with folders at their positions
      int bookmarkIdx = 0;
      for (final item in _items) {
        if (item is BookmarkFolder) {
          list.add(item);
        } else {
          if (bookmarkIdx < bookmarks.length) {
            list.add(bookmarks[bookmarkIdx]);
            bookmarkIdx++;
          }
        }
      }
      return list;
    }
    return _items;
  }

  BookmarkProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _useExternalBrowser = prefs.getBool(_settingsKey) ?? false;

      final itemsJson = prefs.getString(_storageKey);
      if (itemsJson != null) {
        final List<dynamic> decoded = jsonDecode(itemsJson);
        _items = decoded.map((e) {
          final json = e as Map<String, dynamic>;
          final type = json['type'] as String? ?? 'bookmark';
          if (type == 'folder') {
            return BookmarkFolder.fromJson(json);
          } else {
            return SingleBookmark.fromJson(json);
          }
        }).toList();
      } else {
        _items = _getDefaultBookmarks();
      }
    } catch (e) {
      debugPrint('加载收藏失败: $e');
      _items = _getDefaultBookmarks();
    }
    notifyListeners();
  }

  List<BookmarkItem> _getDefaultBookmarks() {
    return [
      SingleBookmark(
        id: '1',
        name: 'Google',
        url: 'https://www.google.com',
        iconName: 'search',
        color: const Color(0xFF4285F4),
      ),
      SingleBookmark(
        id: '2',
        name: 'GitHub',
        url: 'https://github.com',
        iconName: 'code',
        color: const Color(0xFF24292E),
      ),
      BookmarkFolder(
        id: 'folder_default',
        name: 'Videos',
        children: [
          SingleBookmark(
            id: '3',
            name: 'Bilibili',
            url: 'https://www.bilibili.com',
            iconName: 'play_circle_filled',
            color: const Color(0xFF00A1D6),
          ),
          SingleBookmark(
            id: '4',
            name: 'YouTube',
            url: 'https://www.youtube.com',
            iconName: 'video_library',
            color: const Color(0xFFFF0000),
          ),
        ],
      ),
      SingleBookmark(
        id: '5',
        name: 'Flutter',
        url: 'https://flutter.dev',
        iconName: 'flutter_dash',
        color: const Color(0xFF02569B),
      ),
    ];
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = jsonEncode(_items.map((e) {
        if (e is BookmarkFolder) {
          return e.toJson();
        } else if (e is SingleBookmark) {
          return e.toJson();
        }
        return null;
      }).where((e) => e != null).toList());
      await prefs.setString(_storageKey, itemsJson);
    } catch (e) {
      debugPrint('保存收藏失败: $e');
    }
  }

  void startDrag(BookmarkItem item) {
    _draggingItem = item;
    _hoverIndex = null;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void updateHoverIndex(int index) {
    _hoverIndex = index;
    notifyListeners();
  }

  void cancelDrag() {
    _draggingItem = null;
    _hoverIndex = null;
    notifyListeners();
  }

  void commitReorder(int oldIndex, int newIndex) {
    if (_draggingItem == null || _hoverIndex == null) {
      cancelDrag();
      return;
    }

    final item = _draggingItem!;
    final clampedIndex = _hoverIndex!.clamp(0, _items.length);

    _items.removeWhere((e) => e.id == item.id);
    _items.insert(clampedIndex, item);

    _draggingItem = null;
    _hoverIndex = null;

    _saveToStorage();
    notifyListeners();
  }

  void commitMergeToFolder(String targetId) {
    if (_draggingItem == null) return;

    final dragging = _draggingItem!;
    if (dragging.id == targetId || dragging is! SingleBookmark) {
      cancelDrag();
      return;
    }

    final targetIndex = _items.indexWhere((e) => e.id == targetId);
    if (targetIndex < 0) {
      cancelDrag();
      return;
    }

    final target = _items[targetIndex];

    List<BookmarkItem> newItems = List.from(_items);
    newItems.removeWhere((e) => e.id == dragging.id);

    if (target is SingleBookmark) {
      // Create new folder from two bookmarks
      final folder = BookmarkFolder(
        id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Folder',
        children: [target, dragging as SingleBookmark],
      );
      newItems[targetIndex] = folder;
    } else if (target is BookmarkFolder) {
      // Add to existing folder
      final updatedFolder = BookmarkFolder(
        id: target.id,
        name: target.name,
        children: [...target.children, dragging as SingleBookmark],
      );
      newItems[targetIndex] = updatedFolder;
    }

    _items = newItems;
    _saveToStorage();
    cancelDrag();
  }

  Future<void> setUseExternalBrowser(bool value) async {
    _useExternalBrowser = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_settingsKey, value);
    notifyListeners();
  }

  Future<void> addItem(BookmarkItem item) async {
    _items.add(item);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> editItem(String id, BookmarkItem newItem) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = newItem;
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> removeFromFolder(String folderId, String bookmarkId) async {
    final index = _items.indexWhere((e) => e.id == folderId);
    if (index >= 0 && _items[index] is BookmarkFolder) {
      final folder = _items[index] as BookmarkFolder;
      final newChildren = folder.children.where((c) => c.id != bookmarkId).toList();

      if (newChildren.isEmpty) {
        _items.removeAt(index);
      } else if (newChildren.length == 1) {
        _items[index] = newChildren.first;
      } else {
        _items[index] = folder.copyWith(children: newChildren);
      }
      await _saveToStorage();
      notifyListeners();
    }
  }

  List<SingleBookmark> getSingleBookmarks() {
    return _items.whereType<SingleBookmark>().toList();
  }

  /// 注册 tile 的 GlobalKey
  void registerTileKey(String itemId, GlobalKey key) {
    _tileKeys[itemId] = key;
  }

  /// 获取 tile 的 GlobalKey
  GlobalKey getTileKey(String itemId) {
    if (!_tileKeys.containsKey(itemId)) {
      _tileKeys[itemId] = GlobalKey();
    }
    return _tileKeys[itemId]!;
  }

  /// 清除所有 tile keys
  void clearTileKeys() {
    _tileKeys.clear();
  }
}

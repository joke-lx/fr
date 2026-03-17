import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../lab_container.dart';

/// 时钟桌面小组件 Demo
class HomeWidgetDemo extends DemoPage {
  @override
  String get title => '桌面时钟';

  @override
  String get description => '创建 Android 桌面小组件';

  @override
  Widget buildPage(BuildContext context) {
    return const _HomeWidgetPage();
  }
}

class _HomeWidgetPage extends StatefulWidget {
  const _HomeWidgetPage();

  @override
  State<_HomeWidgetPage> createState() => _HomeWidgetPageState();
}

class _HomeWidgetPageState extends State<_HomeWidgetPage> {
  String _currentTime = '';
  String _currentDate = '';
  String _widgetTitle = '时钟小组件';
  Timer? _timer;
  bool _isWidgetRegistered = false;

  // Widget 配置
  static const String _appGroupId = 'group.com.example.flutter_application_1';
  static const String _androidWidgetName = 'ClockWidgetProvider';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _initWidget();
    // 每秒更新时间
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  Future<void> _initWidget() async {
    try {
      // 初始化 widget 数据
      setState(() => _isWidgetRegistered = true);
      await _updateWidgetData();
    } catch (e) {
      debugPrint('初始化 widget 失败: $e');
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('yyyy-MM-dd');

    setState(() {
      _currentTime = timeFormat.format(now);
      _currentDate = dateFormat.format(now);
    });

    // 更新 widget 数据
    _updateWidgetData();
  }

  Future<void> _updateWidgetData() async {
    try {
      // 保存数据到 widget
      await HomeWidget.saveWidgetData('widget_time', _currentTime);
      await HomeWidget.saveWidgetData('widget_date', _currentDate);
      await HomeWidget.saveWidgetData('widget_title', _widgetTitle);

      // 更新 widget
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      debugPrint('更新 widget 失败: $e');
    }
  }

  Future<void> _addWidgetToHomeScreen() async {
    try {
      // 跳转到添加 widget 的页面
      await HomeWidget.setAppGroupId(_appGroupId);

      // 显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请在桌面长按添加小组件'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('添加 widget 失败: $e');
    }
  }

  void _showEditTitleDialog() {
    final controller = TextEditingController(text: _widgetTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改标题'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Widget 标题',
            hintText: '请输入标题',
          ),
          onChanged: (value) => _widgetTitle = value,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateWidgetData();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 当前时间显示
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.access_time, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    _currentTime,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Widget 状态
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '小组件状态',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusRow('Widget 可用', _isWidgetRegistered),
                  const Divider(),
                  _buildStatusRow('当前标题', _widgetTitle),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 操作按钮
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '操作',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addWidgetToHomeScreen,
                    icon: const Icon(Icons.add),
                    label: const Text('添加到桌面'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _showEditTitleDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('修改 Widget 标题'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _updateWidgetData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('强制刷新 Widget'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 使用说明
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        '使用说明',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInstruction('1. 点击"添加到桌面"按钮'),
                  _buildInstruction('2. 在手机桌面空白处 长按'),
                  _buildInstruction('3. 选择"小组件"'),
                  _buildInstruction('4. 找到"聊天应用"并添加'),
                  _buildInstruction('5. 桌面将显示实时时钟'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              color: value is bool
                  ? (value ? Colors.green : Colors.red)
                  : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

void registerHomeWidgetDemo() {
  demoRegistry.register(HomeWidgetDemo());
}

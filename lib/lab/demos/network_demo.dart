import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../lab_container.dart';

/// 网络测试 Demo
class NetworkDemo extends DemoPage {
  @override
  String get title => '网络测试';

  @override
  String get description => 'HTTP请求和WebSocket测试工具';

  @override
  Widget buildPage(BuildContext context) {
    return const _NetworkDemoPage();
  }
}

class _NetworkDemoPage extends StatefulWidget {
  const _NetworkDemoPage();

  @override
  State<_NetworkDemoPage> createState() => _NetworkDemoPageState();
}

class _NetworkDemoPageState extends State<_NetworkDemoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _httpUrlController = TextEditingController(text: 'https://jsonplaceholder.typicode.com/posts/1');
  final _httpMethodController = TextEditingController(text: 'GET');
  final _httpHeadersController = TextEditingController(text: 'Content-Type: application/json');
  final _httpBodyController = TextEditingController();
  final _wsUrlController = TextEditingController(text: 'wss://echo.websocket.org');
  final _wsMessageController = TextEditingController(text: 'Hello WebSocket');

  String _httpResult = '';
  bool _httpLoading = false;
  int _httpStatusCode = 0;
  Duration? _httpDuration;

  WebSocketChannel? _wsChannel;
  final List<String> _wsMessages = [];
  bool _wsConnected = false;
  String _wsConnectionStatus = '未连接';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _httpUrlController.dispose();
    _httpMethodController.dispose();
    _httpHeadersController.dispose();
    _httpBodyController.dispose();
    _wsUrlController.dispose();
    _wsMessageController.dispose();
    _wsChannel?.sink.close();
    super.dispose();
  }

  // HTTP请求
  Future<void> _sendHttpRequest() async {
    setState(() {
      _httpLoading = true;
      _httpResult = '';
      _httpStatusCode = 0;
    });

    final stopwatch = Stopwatch()..start();

    try {
      final uri = Uri.parse(_httpUrlController.text);
      final method = _httpMethodController.text.toUpperCase();

      // 解析headers
      final headers = <String, String>{};
      final headerLines = _httpHeadersController.text.split('\n');
      for (final line in headerLines) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          headers[parts[0].trim()] = parts.sublist(1).join(':').trim();
        }
      }

      // 发起请求
      final client = http.Client();
      http.Response response;

      if (method == 'GET') {
        response = await client.get(uri, headers: headers);
      } else if (method == 'POST') {
        response = await client.post(uri, headers: headers, body: _httpBodyController.text);
      } else if (method == 'PUT') {
        response = await client.put(uri, headers: headers, body: _httpBodyController.text);
      } else if (method == 'DELETE') {
        response = await client.delete(uri, headers: headers);
      } else if (method == 'PATCH') {
        response = await client.patch(uri, headers: headers, body: _httpBodyController.text);
      } else {
        response = await client.get(uri, headers: headers);
      }

      stopwatch.stop();

      setState(() {
        _httpStatusCode = response.statusCode;
        _httpDuration = stopwatch.elapsed;
        _httpResult = response.body;
        _httpLoading = false;
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _httpStatusCode = 0;
        _httpDuration = stopwatch.elapsed;
        _httpResult = 'Error: $e';
        _httpLoading = false;
      });
    }
  }

  // WebSocket连接
  void _connectWebSocket() {
    try {
      final uri = Uri.parse(_wsUrlController.text);
      _wsChannel = WebSocketChannel.connect(uri);

      setState(() {
        _wsConnectionStatus = '连接中...';
      });

      _wsChannel!.ready.then((_) {
        setState(() {
          _wsConnected = true;
          _wsConnectionStatus = '已连接';
          _wsMessages.add('[${DateTime.now().toIso8601String().substring(11, 19)}] 连接成功');
        });
      }).catchError((e) {
        setState(() {
          _wsConnected = false;
          _wsConnectionStatus = '连接失败: $e';
        });
      });

      _wsChannel!.stream.listen((message) {
        setState(() {
          _wsMessages.add('[${DateTime.now().toIso8601String().substring(11, 19)}] 收到: $message');
        });
      }, onError: (error) {
        setState(() {
          _wsConnected = false;
          _wsConnectionStatus = '连接断开: $error';
        });
      }, onDone: () {
        setState(() {
          _wsConnected = false;
          _wsConnectionStatus = '连接已关闭';
        });
      });
    } catch (e) {
      setState(() {
        _wsConnectionStatus = '连接失败: $e';
      });
    }
  }

  // 发送WebSocket消息
  void _sendWebSocketMessage() {
    if (_wsChannel != null && _wsConnected) {
      final message = _wsMessageController.text;
      _wsChannel!.sink.add(message);
      setState(() {
        _wsMessages.add('[${DateTime.now().toIso8601String().substring(11, 19)}] 发送: $message');
      });
    }
  }

  // 断开WebSocket
  void _disconnectWebSocket() {
    _wsChannel?.sink.close();
    setState(() {
      _wsConnected = false;
      _wsConnectionStatus = '已断开';
      _wsMessages.add('[${DateTime.now().toIso8601String().substring(11, 19)}] 连接已断开');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'HTTP', icon: Icon(Icons.http)),
          Tab(text: 'WebSocket', icon: Icon(Icons.cable)),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHttpTab(),
          _buildWebSocketTab(),
        ],
      ),
    );
  }

  Widget _buildHttpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL输入
          TextField(
            controller: _httpUrlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              border: OutlineInputBorder(),
              hintText: 'https://api.example.com/endpoint',
            ),
          ),
          const SizedBox(height: 12),
          // 方法和Headers
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _httpMethodController,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _httpHeadersController,
                  decoration: const InputDecoration(
                    labelText: 'Headers (每行一个)',
                    border: OutlineInputBorder(),
                    hintText: 'Content-Type: application/json',
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 请求体
          TextField(
            controller: _httpBodyController,
            decoration: const InputDecoration(
              labelText: 'Request Body (JSON)',
              border: OutlineInputBorder(),
              hintText: '{"key": "value"}',
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          // 发送按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _httpLoading ? null : _sendHttpRequest,
              icon: _httpLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_httpLoading ? '请求中...' : '发送请求'),
            ),
          ),
          const SizedBox(height: 16),
          // 响应结果
          if (_httpStatusCode > 0 || _httpResult.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _httpStatusCode >= 200 && _httpStatusCode < 300
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _httpStatusCode >= 200 && _httpStatusCode < 300
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _httpStatusCode >= 200 && _httpStatusCode < 300
                        ? Icons.check_circle
                        : Icons.error,
                    color: _httpStatusCode >= 200 && _httpStatusCode < 300
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: $_httpStatusCode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _httpStatusCode >= 200 && _httpStatusCode < 300
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const Spacer(),
                  if (_httpDuration != null)
                    Text(
                      '${_httpDuration!.inMilliseconds}ms',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // 响应体
          if (_httpResult.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _httpResult,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebSocketTab() {
    return Column(
      children: [
        // 连接配置
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _wsUrlController,
                decoration: const InputDecoration(
                  labelText: 'WebSocket URL',
                  border: OutlineInputBorder(),
                  hintText: 'wss://example.com/ws',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _wsConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _wsConnected ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _wsConnected ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: _wsConnected ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _wsConnectionStatus,
                            style: TextStyle(
                              color: _wsConnected ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!_wsConnected)
                    ElevatedButton.icon(
                      onPressed: _connectWebSocket,
                      icon: const Icon(Icons.link),
                      label: const Text('连接'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _disconnectWebSocket,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      icon: const Icon(Icons.link_off),
                      label: const Text('断开'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // 发送消息
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wsMessageController,
                      decoration: const InputDecoration(
                        labelText: '发送消息',
                        border: OutlineInputBorder(),
                        hintText: '输入要发送的消息',
                      ),
                      enabled: _wsConnected,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _wsConnected ? _sendWebSocketMessage : null,
                    icon: const Icon(Icons.send),
                    label: const Text('发送'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 消息列表
        Expanded(
          child: _wsMessages.isEmpty
              ? Center(
                  child: Text(
                    '暂无消息',
                    style: TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _wsMessages.length,
                  itemBuilder: (context, index) {
                    final msg = _wsMessages[index];
                    final isSent = msg.contains('发送:');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSent
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        msg,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: isSent ? Colors.blue : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

void registerNetworkDemo() {
  demoRegistry.register(NetworkDemo());
}

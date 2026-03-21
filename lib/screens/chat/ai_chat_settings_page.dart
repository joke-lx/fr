import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ai_chat_message.dart';
import '../../providers/ai_chat_provider.dart';

/// AI 聊天设置页面
class AIChatSettingsPage extends StatefulWidget {
  const AIChatSettingsPage({super.key});

  @override
  State<AIChatSettingsPage> createState() => _AIChatSettingsPageState();
}

class _AIChatSettingsPageState extends State<AIChatSettingsPage> {
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _baseURLController;
  String _selectedType = 'claude';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AIChatProvider>().settings;
    _apiKeyController = TextEditingController(text: settings.apiKey);
    _modelController = TextEditingController(text: settings.model);
    _baseURLController = TextEditingController(text: settings.baseURL);
    _selectedType = settings.type;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseURLController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    final settings = AISettings(
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
      baseURL: _baseURLController.text.trim(),
      type: _selectedType,
    );

    await context.read<AIChatProvider>().updateSettings(settings);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入 API Key')),
      );
      return;
    }

    // 临时保存设置用于测试
    final tempSettings = AISettings(
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
      baseURL: _baseURLController.text.trim(),
      type: _selectedType,
    );

    // 显示测试中提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('测试连接中...'),
          ],
        ),
      ),
    );

    // 创建一个临时 Provider 测试连接
    final tempProvider = AIChatProvider();
    await tempProvider.updateSettings(tempSettings);
    await tempProvider.sendMessage('你好');
    final error = tempProvider.error;
    tempProvider.dispose();

    // 关闭测试对话框
    if (mounted) {
      Navigator.pop(context);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('连接成功!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('连接失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 聊天设置'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveSettings,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Key
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key *',
              hintText: '请输入您的 API Key',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),

          // 模型类型
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: '模型类型',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.model_training),
            ),
            items: const [
              DropdownMenuItem(value: 'claude', child: Text('Claude')),
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
              DropdownMenuItem(value: 'gemini', child: Text('Gemini')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value ?? 'claude';
              });
            },
          ),
          const SizedBox(height: 16),

          // Model
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(
              labelText: '模型名称 (可选)',
              hintText: '如: claude-3-5-sonnet-20241022',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.psychology),
            ),
          ),
          const SizedBox(height: 16),

          // Base URL
          TextField(
            controller: _baseURLController,
            decoration: const InputDecoration(
              labelText: '自定义 Base URL (可选)',
              hintText: '如: https://api.anthropic.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 24),

          // 测试连接按钮
          OutlinedButton.icon(
            onPressed: _testConnection,
            icon: const Icon(Icons.wifi_tethering),
            label: const Text('测试连接'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 32),

          // 说明
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '使用说明',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTip('1. 请输入有效的 API Key'),
                _buildTip('2. 模型类型默认为 Claude'),
                _buildTip('3. 模型名称和 Base URL 为可选配置'),
                _buildTip('4. 点击"测试连接"验证配置'),
                _buildTip('5. 保存设置后可开始 AI 聊天'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}

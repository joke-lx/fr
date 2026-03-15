import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/media_service.dart';

/// 媒体功能测试页面
/// 用于在Web和移动端验证摄像头和图库访问功能
class MediaTestPage extends StatefulWidget {
  const MediaTestPage({super.key});

  @override
  State<MediaTestPage> createState() => _MediaTestPageState();
}

class _MediaTestPageState extends State<MediaTestPage> {
  String _selectedImagePath = '';
  String _testResult = '';
  MediaCapability? _capability;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCapabilities();
  }

  Future<void> _checkCapabilities() async {
    setState(() {
      _isLoading = true;
    });

    final capability = await MediaService.checkWebCapabilities();

    setState(() {
      _capability = capability;
      _isLoading = false;
      _testResult = capability.toString();
    });
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在打开图库...';
    });

    try {
      final path = await MediaService.pickImageFromGallery();
      if (path != null) {
        setState(() {
          _selectedImagePath = path;
          _testResult = '成功选择图片\n\n路径: ${path.length > 100 ? path.substring(0, 100) + '...' : path}\n\n'
              '图片格式: ${kIsWeb ? "Base64 (Web)" : "文件路径"}';
        });
      } else {
        setState(() {
          _testResult = '未选择图片';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '选择图片失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _takePicture() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在启动相机...';
    });

    try {
      final path = await MediaService.takePicture();
      if (path != null) {
        setState(() {
          _selectedImagePath = path;
          _testResult = '成功拍照\n\n路径: ${path.length > 100 ? path.substring(0, 100) + '...' : path}\n\n'
              '图片格式: ${kIsWeb ? "Base64 (Web)" : "文件路径"}';
        });
      } else {
        setState(() {
          _testResult = '未拍照';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '拍照失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在选择视频...';
    });

    try {
      final path = await MediaService.pickVideoFromGallery();
      if (path != null) {
        setState(() {
          _testResult = '成功选择视频\n\n路径: $path';
        });
      } else {
        setState(() {
          _testResult = '未选择视频';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '选择视频失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在选择文件...';
    });

    try {
      final result = await MediaService.pickFile();
      if (result != null && result.files.isNotEmpty) {
        final file = result.files;
        setState(() {
          _testResult = '成功选择文件\n\n'
              '文件名: ${file.map((f) => f.name).join(', ')}\n'
              '大小: ${file.map((f) => f.size).join(' bytes, ')}';
        });
      } else {
        setState(() {
          _testResult = '未选择文件';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '选择文件失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('媒体功能测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkCapabilities,
            tooltip: '重新检测',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 平台信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '运行环境',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('平台: ${kIsWeb ? 'Web' : 'Native'}'),
                    if (kIsWeb) Text('浏览器: ${defaultTargetPlatform}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 功能检测
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '功能检测',
                          style: theme.textTheme.titleMedium,
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_capability != null) ...[
                      _buildCapabilityItem('摄像头访问', _capability!.canAccessCamera),
                      _buildCapabilityItem('图库访问', _capability!.canAccessGallery),
                      _buildCapabilityItem('视频录制', _capability!.canRecordVideo),
                      const SizedBox(height: 8),
                      Text(
                        '支持的图片格式: ${_capability!.supportedImageFormats.join(', ')}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '支持的视频格式: ${_capability!.supportedVideoFormats.join(', ')}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ] else if (!_isLoading) ...[
                      const Text('点击右上角刷新按钮检测功能'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 测试按钮
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '功能测试',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('从图库选择图片'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('拍照'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text('选择视频'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('选择文件'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 测试结果
            if (_testResult.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '测试结果',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_testResult),
                    ],
                  ),
                ),
              ),

            // 图片预览
            if (_selectedImagePath.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '图片预览',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                _selectedImagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Text('图片加载失败'),
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                // Native implementation would use File(_selectedImagePath)
                                // For now, just show placeholder
                                null as dynamic,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text(_selectedImagePath),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityItem(String label, bool value) {
    return Row(
      children: [
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

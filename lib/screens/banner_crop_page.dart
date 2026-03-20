import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BannerCropPage extends StatefulWidget {
  const BannerCropPage({super.key});

  @override
  State<BannerCropPage> createState() => _BannerCropPageState();
}

class _BannerCropPageState extends State<BannerCropPage> {
  String? _selectedPath;
  double _targetRatio = 16 / 9; // 默认值，会在initState中更新为实际值

  @override
  void initState() {
    super.initState();
    // 计算实际的Banner显示比例
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenWidth = MediaQuery.of(context).size.width;
        // Banner实际显示高度为expandedHeight: 200
        // 但需要考虑SafeArea和状态栏，实际可见高度会略有不同
        const bannerHeight = 200.0;
        setState(() {
          _targetRatio = screenWidth / bannerHeight;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedPath = image.path;
      });
    }
  }

  void _saveAndReturn() {
    if (_selectedPath != null) {
      Navigator.pop(context, _selectedPath);
    }
  }

  String _getRatioString() {
    // 转换为最接近的常见比例描述
    final ratio = _targetRatio;
    if ((ratio - 16 / 9).abs() < 0.1) return '16:9';
    if ((ratio - 4 / 3).abs() < 0.1) return '4:3';
    if ((ratio - 21 / 9).abs() < 0.1) return '21:9';
    if ((ratio - 1).abs() < 0.1) return '1:1';
    return '${ratio.toStringAsFixed(1)}:1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置Banner'),
        centerTitle: true,
        actions: [
          if (_selectedPath != null)
            TextButton(
              onPressed: _saveAndReturn,
              child: const Text('完成'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 预览区域
          Expanded(
            child: _selectedPath != null
                ? _buildPreview()
                : _buildEmptyState(),
          ),
          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: Text(_selectedPath != null ? '重新选择' : '选择图片'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // 实际比例预览区域
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 使用实际显示比例
                  AspectRatio(
                    aspectRatio: _targetRatio,
                    child: Image.file(
                      File(_selectedPath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 半透明边框
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  // 提示
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '将裁剪为${_getRatioString()}比例',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 图片信息
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '根据屏幕宽度自动计算裁剪比例',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '选择图片作为Banner',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '将自动适配为显示比例',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }
}

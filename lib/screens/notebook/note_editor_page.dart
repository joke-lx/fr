import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/note.dart';
import '../../providers/note_provider.dart';

/// 笔记编辑器页面
class NoteEditorPage extends StatefulWidget {
  final String noteId;

  const NoteEditorPage({super.key, required this.noteId});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isPreview = false;
  bool _hasChanges = false;

  // 笔记颜色选项
  static const List<String> _colors = [
    '#FFFFFF', // 白色
    '#FFEBEE', // 浅红
    '#E3F2FD', // 浅蓝
    '#E8F5E9', // 浅绿
    '#FFF3E0', // 浅橙
    '#F3E5F5', // 浅紫
    '#FFFDE7', // 浅黄
    '#ECEFF1', // 浅灰
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    // 加载笔记内容
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final note = context.read<NoteProvider>().getNoteById(widget.noteId);
      if (note != null) {
        _titleController.text = note.title == '新笔记' ? '' : note.title;
        _contentController.text = note.content;
      }
    });

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    await context.read<NoteProvider>().updateNote(
          id: widget.noteId,
          title: _titleController.text.isEmpty ? '新笔记' : _titleController.text,
          content: _contentController.text,
        );
    _hasChanges = false;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('笔记已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _showColorPicker() {
    final noteProvider = context.read<NoteProvider>();
    final note = noteProvider.getNoteById(widget.noteId);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择笔记颜色', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final isSelected = note?.color == color;
                return GestureDetector(
                  onTap: () {
                    noteProvider.updateNote(id: widget.noteId, color: color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑笔记'),
        actions: [
          // 预览/编辑切换
          IconButton(
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            onPressed: () {
              setState(() {
                _isPreview = !_isPreview;
              });
            },
            tooltip: _isPreview ? '编辑' : '预览',
          ),
          // 颜色选择
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showColorPicker,
            tooltip: '颜色',
          ),
          // 保存
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _hasChanges ? _saveNote : null,
            tooltip: '保存',
          ),
        ],
      ),
      body: _isPreview ? _buildPreview(theme) : _buildEditor(theme),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    return Column(
      children: [
        // 标题输入
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: '标题',
              border: InputBorder.none,
            ),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
        ),
        const Divider(),

        // Markdown 工具栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolbarButton(icon: Icons.format_bold, tooltip: '粗体', onTap: () => _insertMarkdown('**', '**')),
                _buildToolbarButton(icon: Icons.format_italic, tooltip: '斜体', onTap: () => _insertMarkdown('*', '*')),
                _buildToolbarButton(icon: Icons.format_strikethrough, tooltip: '删除线', onTap: () => _insertMarkdown('~~', '~~')),
                const SizedBox(width: 8),
                _buildToolbarButton(icon: Icons.title, tooltip: '标题', onTap: () => _insertMarkdown('## ', '')),
                _buildToolbarButton(icon: Icons.format_list_bulleted, tooltip: '列表', onTap: () => _insertMarkdown('- ', '')),
                _buildToolbarButton(icon: Icons.format_list_numbered, tooltip: '有序列表', onTap: () => _insertMarkdown('1. ', '')),
                _buildToolbarButton(icon: Icons.check_box, tooltip: '任务', onTap: () => _insertMarkdown('- [ ] ', '')),
                const SizedBox(width: 8),
                _buildToolbarButton(icon: Icons.code, tooltip: '代码', onTap: () => _insertMarkdown('`', '`')),
                _buildToolbarButton(icon: Icons.data_object, tooltip: '代码块', onTap: () => _insertMarkdown('```\n', '\n```')),
                _buildToolbarButton(icon: Icons.format_quote, tooltip: '引用', onTap: () => _insertMarkdown('> ', '')),
                const SizedBox(width: 8),
                _buildToolbarButton(icon: Icons.link, tooltip: '链接', onTap: () => _insertMarkdown('[', '](url)')),
                _buildToolbarButton(icon: Icons.image, tooltip: '图片', onTap: () => _insertMarkdown('![alt](', ')')),
              ],
            ),
          ),
        ),

        // 内容输入
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '开始写笔记...（支持 Markdown）',
                border: InputBorder.none,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(8),
    );
  }

  void _insertMarkdown(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (selection.isValid && selection.start != selection.end) {
      // 选中了文字
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + prefix.length + selectedText.length + suffix.length,
        ),
      );
    } else {
      // 没有选中文字，在光标位置插入
      final newText = text.substring(0, selection.start) +
          prefix +
          suffix +
          text.substring(selection.start);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + prefix.length,
        ),
      );
    }
  }

  Widget _buildPreview(ThemeData theme) {
    final content = _contentController.text;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题预览
          if (_titleController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _titleController.text,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Markdown 预览
          if (content.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  '暂无内容',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            )
          else
            MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                h1: theme.textTheme.headlineMedium,
                h2: theme.textTheme.headlineSmall,
                h3: theme.textTheme.titleLarge,
                h4: theme.textTheme.titleMedium,
                h5: theme.textTheme.titleSmall,
                h6: theme.textTheme.labelLarge,
                p: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                code: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                codeblockDecoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 4,
                    ),
                  ),
                ),
                listBullet: theme.textTheme.bodyLarge,
              ),
              selectable: true,
            ),
        ],
      ),
    );
  }
}

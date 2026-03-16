import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../services/chat_response_service.dart';

class ChatDetailPage extends StatefulWidget {
  final User friend;

  const ChatDetailPage({super.key, required this.friend});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late MessageProvider _messageProvider;
  bool _isTyping = false;
  bool _isSending = false;  // 添加本地发送状态

  @override
  void initState() {
    super.initState();
    _messageProvider = context.read<MessageProvider>();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser!;

    await _messageProvider.loadChatMessages(currentUser.id, widget.friend.id);
    await _messageProvider.markAsRead(widget.friend.id, currentUser.id);

    _scrollToBottom();
  }

  Future<void> _scrollToBottom() async {
    if (_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend(String content) async {
    if (_isSending) return;  // 防止重复发送

    setState(() {
      _isSending = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final currentUser = userProvider.currentUser!;
      final sessionProvider = context.read<ChatSessionProvider>();

      // 发送用户消息
      await _messageProvider.sendMessage(
        senderId: currentUser.id,
        receiverId: widget.friend.id,
        content: content,
      );

      await sessionProvider.refreshSessions(currentUser.id);
      await _scrollToBottom();

      // 显示"正在输入"状态
      setState(() {
        _isTyping = true;
      });

      // 模拟延迟后回复
      await Future.delayed(const Duration(milliseconds: 800));

      // 获取智能回复
      final response = ChatResponseService.getResponse(content);

      // 发送回复消息
      await _messageProvider.sendMessage(
        senderId: widget.friend.id,
        receiverId: currentUser.id,
        content: response,
      );

      setState(() {
        _isTyping = false;
      });

      await sessionProvider.refreshSessions(currentUser.id);
      await _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _handleImageSend(String? imagePath, {MessageType type = MessageType.text}) async {
    if (imagePath == null) return;

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser!;
    final sessionProvider = context.read<ChatSessionProvider>();

    // 发送图片/文件/语音消息
    await _messageProvider.sendMessage(
      senderId: currentUser.id,
      receiverId: widget.friend.id,
      content: imagePath,
      type: type,
    );

    await sessionProvider.refreshSessions(currentUser.id);
    await _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser!;
    final isMe = (User u) => u.id == currentUser.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: widget.friend.avatar != null
                      ? NetworkImage(widget.friend.avatar!)
                      : null,
                  child: widget.friend.avatar == null
                      ? Text(widget.friend.nickname.substring(0, 1))
                      : null,
                ),
                if (widget.friend.status == 'online')
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.friend.nickname,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    _isTyping ? '正在输入...' : (widget.friend.status == 'online' ? '在线' : '离线'),
                    style: TextStyle(
                      fontSize: 12,
                      color: _isTyping ? Colors.blue : (widget.friend.status == 'online' ? Colors.green : Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final userProvider = context.read<UserProvider>();
                final currentUser = userProvider.currentUser!;
                final messages = messageProvider.getChatMessages(currentUser.id, widget.friend.id);

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: widget.friend.avatar != null
                              ? NetworkImage(widget.friend.avatar!)
                              : null,
                          child: widget.friend.avatar == null
                              ? Text(widget.friend.nickname.substring(0, 1),
                                  style: const TextStyle(fontSize: 32))
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.friend.nickname,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '试着说点什么吧！',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8,
                          children: [
                            _QuickReply(
                              text: '你好',
                              onTap: () => _handleSend('你好'),
                            ),
                            _QuickReply(
                              text: '在吗',
                              onTap: () => _handleSend('在吗'),
                            ),
                            _QuickReply(
                              text: '今天天气怎么样',
                              onTap: () => _handleSend('今天天气怎么样'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final senderId = message.senderId;
                    final sender = senderId == currentUser.id
                        ? currentUser
                        : widget.friend;

                    return MessageBubble(
                      message: message,
                      isMe: isMe(sender),
                      sender: sender,
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(
            onSend: _handleSend,
            onImageSend: _handleImageSend,
            isLoading: _isSending,
          ),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('搜索聊天记录'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services),
              title: const Text('清空聊天记录'),
              onTap: () {
                Navigator.pop(context);
                _showClearChatDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('拉黑'),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: Text('确定要清空与 ${widget.friend.nickname} 的聊天记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拉黑'),
        content: Text('确定要拉黑 ${widget.friend.nickname} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('拉黑', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _QuickReply extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickReply({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

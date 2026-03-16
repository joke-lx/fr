import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final User? sender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.sender,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final difference = now.difference(message.createdAt);

    String timeText;
    if (difference.inMinutes < 1) {
      timeText = '刚刚';
    } else if (difference.inHours < 1) {
      timeText = '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      timeText = DateFormat('HH:mm').format(message.createdAt);
    } else {
      timeText = DateFormat('MM/dd HH:mm').format(message.createdAt);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && sender != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 12),
                child: Text(
                  sender!.nickname,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe && sender?.avatar != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(sender!.avatar!),
                  ),
                if (!isMe) const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      gradient: isMe
                          ? LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.8),
                              ],
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMessageContent(context, theme),
                        const SizedBox(height: 4),
                        Text(
                          timeText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isMe
                                ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildStatusIcon(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    if (!isMe) return const SizedBox.shrink();

    switch (message.status) {
      case MessageStatus.sending:
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        );
      case MessageStatus.sent:
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            Icons.done,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        );
      case MessageStatus.read:
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            Icons.done_all,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        );
      case MessageStatus.failed:
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            Icons.error_outline,
            size: 16,
            color: theme.colorScheme.error,
          ),
        );
    }
  }

  Widget _buildMessageContent(BuildContext context, ThemeData theme) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageMessage(context, theme);
      case MessageType.video:
        return _buildVideoMessage(context, theme);
      case MessageType.audio:
        return _buildAudioMessage(context, theme);
      case MessageType.file:
        return _buildFileMessage(context, theme);
      case MessageType.text:
      case MessageType.system:
        return Text(
          message.content,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isMe
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        );
    }
  }

  Widget _buildImageMessage(BuildContext context, ThemeData theme) {
    final filePath = message.content;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: kIsWeb
          ? (filePath.startsWith('data:') == true
              ? Image.network(
                  filePath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageError(theme);
                  },
                )
              : Image.file(
                  File(filePath),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageError(theme);
                  },
                ))
          : Image.file(
              File(filePath),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError(theme);
              },
            ),
    );
  }

  Widget _buildImageError(ThemeData theme) {
    return Container(
      width: 200,
      height: 200,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoMessage(BuildContext context, ThemeData theme) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 视频封面（如果有本地文件，显示第一帧）
          if (kIsWeb)
            const Icon(Icons.videocam, size: 48, color: Colors.white70)
          else
            Image.file(
              File(message.content),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.videocam, size: 48, color: Colors.white70);
              },
            ),
          const Icon(
            Icons.play_circle_filled,
            color: Colors.white70,
            size: 48,
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '视频消息',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe
            ? theme.colorScheme.primary.withOpacity(0.2)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: isMe
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 8),
          // 模拟音频波形
          _buildAudioWave(theme),
          const SizedBox(width: 8),
          Text(
            '语音',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isMe
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioWave(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Container(
          width: 3,
          height: 12 + (index * 4).toDouble() % 12,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: (isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary)
                .withOpacity(0.6),
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }

  Widget _buildFileMessage(BuildContext context, ThemeData theme) {
    final fileName = message.content.split('/').last;

    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        color: isMe
            ? theme.colorScheme.primary.withOpacity(0.2)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(fileName),
            color: isMe
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  '文件',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: (isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface)
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'txt':
        return Icons.text_snippet;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.music_note;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Icons.video_library;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

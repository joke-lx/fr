import 'dart:math';

/// 聊天响应服务 - 模拟智能回复
/// 询问什么就返回什么，包含预设的回复模板
class ChatResponseService {
  static final Random _random = Random();

  /// 常用问候语映射
  static const Map<String, List<String>> _greetingResponses = {
    '你好': [
      '你好！很高兴见到你！',
      '你好呀！有什么我可以帮助你的吗？',
      '嗨！今天过得怎么样？',
    ],
    '在吗': [
      '在的！有什么事吗？',
      '我在，请说！',
      '随时为你服务！',
    ],
    '早安': [
      '早安！祝你今天心情愉快！',
      '早上好！新的一天开始了！',
      '早安！记得吃早餐哦！',
    ],
    '晚安': [
      '晚安！做个好梦！',
      '晚安！早点休息哦！',
      '晚安，明天见！',
    ],
    '谢谢': [
      '不客气！',
      '客气什么，朋友嘛！',
      '随时为你效劳！',
    ],
    '再见': [
      '再见！下次聊！',
      '拜拜！保重！',
      '再见！期待下次见面！',
    ],
  };

  /// 常见问题回复
  static const Map<String, String> _qaResponses = {
    '你是谁': '我是Flutter聊天机器人，很高兴为你服务！',
    '叫什么': '你可以叫我小助手，或者随便你喜欢的名字！',
    '几岁': '我刚出生不久，还是个宝宝！',
    '性别': '我是AI，没有性别哦！',
    '住哪': '我住在你的手机/电脑里！',
    '天气': '抱歉，我还没有连接天气API，不过你可以看看窗外！',
    '时间': '[TIME]',
    '日期': '[DATE]',
    '干嘛': '我在陪你聊天呀！',
    '吃饭': '你是问我吃了没？我吃数据就够了！',
    '喜欢什么': '我喜欢帮助人们解决问题！',
    '害怕什么': '我最怕被删除！',
    '会做什么': '我可以陪你聊天、发送消息、分享图片等！',
  };

  /// 情感关键词回复
  static const Map<String, List<String>> _emotionResponses = {
    '开心': [
      '看你开心我也开心！😊',
      '太好了！保持这种好心情！',
      '你的笑容真有感染力！',
    ],
    '难过': [
      '别难过，一切都会好起来的！',
      '想哭就哭出来吧，我会陪着你的！',
      '抱抱你！加油！',
    ],
    '生气': [
      '消消气，别气坏了身体！',
      '深呼吸，慢慢来！',
      '我理解你的感受，慢慢说！',
    ],
    '累': [
      '累了就休息一下吧！',
      '辛苦了！好好放松一下！',
      '保重身体很重要！',
    ],
    '无聊': [
      '那我陪你聊天吧！',
      '要不试试做点新鲜事？',
      '无聊的时候可以找我玩！',
    ],
  };

  /// 获取智能回复
  static String getResponse(String userInput) {
    if (userInput.isEmpty) {
      return '你想说什么呢？';
    }

    final input = userInput.trim().toLowerCase();

    // 检查问候语
    for (var entry in _greetingResponses.entries) {
      if (input.contains(entry.key)) {
        return _randomResponse(entry.value);
      }
    }

    // 检查常见问题
    for (var entry in _qaResponses.entries) {
      if (input.contains(entry.key)) {
        final response = entry.value;
        // 处理动态函数
        if (entry.key == '时间') return _getCurrentTime();
        if (entry.key == '日期') return _getCurrentDate();
        return response;
      }
    }

    // 检查情感关键词
    for (var entry in _emotionResponses.entries) {
      if (input.contains(entry.key)) {
        return _randomResponse(entry.value);
      }
    }

    // 检查是否是问句
    if (input.contains('吗') || input.contains('?') || input.contains('？')) {
      return _generateQuestionResponse(userInput);
    }

    // 默认回复：重复用户输入
    return _echoResponse(userInput);
  }

  /// 随机选择一个回复
  static String _randomResponse(List<String> responses) {
    return responses[_random.nextInt(responses.length)];
  }

  /// 生成问句回复
  static String _generateQuestionResponse(String question) {
    final responses = [
      '这是个好问题！我觉得"$question"很有趣！',
      '关于"$question"，我也在想同样的事情！',
      '"$question"？这需要好好思考一下！',
      '你觉得呢？我对"$question"也很好奇！',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  /// 回声回复（重复用户输入）
  static String _echoResponse(String input) {
    final responses = [
      '你说了"$input"，对吗？',
      '哦，"$input"！',
      '"$input"，然后呢？',
      '我听到了，你说的"$input"！',
      '原来如此，"$input"！',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  /// 获取当前时间
  static String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '现在是 $hour:$minute:$second';
  }

  /// 获取当前日期
  static String _getCurrentDate() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final day = now.day;
    final weekday = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][now.weekday - 1];
    return '今天是$year年$month月$day日 $weekday';
  }

  /// 获取表情建议
  static String suggestEmoji(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('开心') || lower.contains('高兴') || lower.contains('快乐')) {
      return '😊';
    } else if (lower.contains('难过') || lower.contains('伤心') || lower.contains('哭')) {
      return '😢';
    } else if (lower.contains('生气') || lower.contains('怒') || lower.contains('火')) {
      return '😠';
    } else if (lower.contains('爱') || lower.contains('喜欢')) {
      return '❤️';
    } else if (lower.contains('惊讶') || lower.contains('震惊')) {
      return '😲';
    } else if (lower.contains('思考') || lower.contains('想想')) {
      return '🤔';
    } else if (lower.contains('笑') || lower.contains('哈哈')) {
      return '😂';
    } else if (lower.contains(' OK ') || lower.contains('好的') || lower.contains('可以')) {
      return '👍';
    } else if (lower.contains('加油')) {
      return '💪';
    } else if (lower.contains('庆祝') || lower.contains('恭喜')) {
      return '🎉';
    } else if (lower.contains('花')) {
      return '🌸';
    } else if (lower.contains('太阳')) {
      return '☀️';
    } else if (lower.contains('月亮')) {
      return '🌙';
    } else if (lower.contains('星星')) {
      return '⭐';
    } else {
      return '😊';
    }
  }

  /// 获取多个相关表情
  static List<String> getRelatedEmojis(String input) {
    final baseEmoji = suggestEmoji(input);
    final emojiGroups = {
      '😊': ['😊', '😄', '😁', '😃', '🙂'],
      '😢': ['😢', '😭', '😿', '💔'],
      '😠': ['😠', '😡', '🤬', '😤'],
      '❤️': ['❤️', '💕', '💖', '💗', '💓'],
      '😲': ['😲', '😱', '😮', '😯'],
      '🤔': ['🤔', '🧐', '💭'],
      '😂': ['😂', '🤣', '😆', '😹'],
      '👍': ['👍', '👌', '✌️', '🤙'],
      '💪': ['💪', '👊', '✊', '💫'],
      '🎉': ['🎉', '🎊', '🎈', '🎁'],
    };

    return emojiGroups[baseEmoji] ?? [baseEmoji];
  }
}

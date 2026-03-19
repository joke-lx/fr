import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../lab_container.dart';

/// 日历 Demo
class CalendarDemo extends DemoPage {
  @override
  String get title => '日历';

  @override
  String get description => '日期范围选择日历';

  @override
  Widget buildPage(BuildContext context) {
    return const _CalendarDemoPage();
  }
}

class _CalendarDemoPage extends StatefulWidget {
  const _CalendarDemoPage();

  @override
  State<_CalendarDemoPage> createState() => _CalendarDemoPageState();
}

class _CalendarDemoPageState extends State<_CalendarDemoPage> {
  // 主题颜色 - 与原版一致
  static const Color _primaryColor = Color(0xFF54D3C2);

  List<DateTime> dateList = <DateTime>[];
  DateTime currentMonthDate = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    setListOfDate(currentMonthDate);
  }

  void setListOfDate(DateTime monthDate) {
    dateList.clear();
    final DateTime newDate = DateTime(monthDate.year, monthDate.month, 0);
    int previousMothDay = 0;
    if (newDate.weekday < 7) {
      previousMothDay = newDate.weekday;
      for (int i = 1; i <= previousMothDay; i++) {
        dateList.add(newDate.subtract(Duration(days: previousMothDay - i)));
      }
    }
    for (int i = 0; i < (42 - previousMothDay); i++) {
      dateList.add(newDate.add(Duration(days: i + 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '选择日期',
          style: TextStyle(
            color: Color(0xFF000000),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 显示选中的日期范围
            if (startDate != null || endDate != null)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (startDate != null)
                      Text(
                        DateFormat('yyyy-MM-dd').format(startDate!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _primaryColor,
                        ),
                      ),
                    if (startDate != null && endDate != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('→', style: TextStyle(color: Colors.grey)),
                      ),
                    if (endDate != null)
                      Text(
                        DateFormat('yyyy-MM-dd').format(endDate!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _primaryColor,
                        ),
                      ),
                    if (startDate != null && endDate != null)
                      Text(
                        ' (${endDate!.difference(startDate!).inDays + 1}天)',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            // 日历组件
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // 月份导航
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 4),
                      child: Row(
                        children: <Widget>[
                          // 上一月按钮
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                                  onTap: () {
                                    setState(() {
                                      currentMonthDate = DateTime(currentMonthDate.year, currentMonthDate.month, 0);
                                      setListOfDate(currentMonthDate);
                                    });
                                  },
                                  child: const Icon(Icons.keyboard_arrow_left, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          // 当前月份标题
                          Expanded(
                            child: Center(
                              child: Text(
                                DateFormat('MMMM, yyyy').format(currentMonthDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          // 下一月按钮
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                                  onTap: () {
                                    setState(() {
                                      currentMonthDate = DateTime(currentMonthDate.year, currentMonthDate.month + 2, 0);
                                      setListOfDate(currentMonthDate);
                                    });
                                  },
                                  child: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 星期名称
                    Padding(
                      padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
                      child: Row(
                        children: getDaysNameUI(),
                      ),
                    ),
                    // 日期网格
                    Padding(
                      padding: const EdgeInsets.only(right: 8, left: 8),
                      child: Column(
                        children: getDaysNoUI(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getDaysNameUI() {
    final List<Widget> listUI = <Widget>[];
    for (int i = 0; i < 7; i++) {
      listUI.add(
        Expanded(
          child: Center(
            child: Text(
              DateFormat('EEE').format(dateList[i]),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _primaryColor,
              ),
            ),
          ),
        ),
      );
    }
    return listUI;
  }

  List<Widget> getDaysNoUI() {
    final List<Widget> noList = <Widget>[];
    int count = 0;
    for (int i = 0; i < dateList.length / 7; i++) {
      final List<Widget> listUI = <Widget>[];
      for (int j = 0; j < 7; j++) {
        final DateTime date = dateList[count];
        listUI.add(
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  // 范围背景
                  Padding(
                    padding: const EdgeInsets.only(top: 3, bottom: 3),
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 2,
                          bottom: 2,
                          left: isStartDateRadius(date) ? 4 : 0,
                          right: isEndDateRadius(date) ? 4 : 0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: startDate != null && endDate != null
                                ? getIsItStartAndEndDate(date) || getIsInRange(date)
                                    ? _primaryColor.withOpacity(0.4)
                                    : Colors.transparent
                                : Colors.transparent,
                            borderRadius: BorderRadius.only(
                              bottomLeft: isStartDateRadius(date) ? const Radius.circular(24.0) : const Radius.circular(0.0),
                              topLeft: isStartDateRadius(date) ? const Radius.circular(24.0) : const Radius.circular(0.0),
                              topRight: isEndDateRadius(date) ? const Radius.circular(24.0) : const Radius.circular(0.0),
                              bottomRight: isEndDateRadius(date) ? const Radius.circular(24.0) : const Radius.circular(0.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 日期点击区域
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                      onTap: () => onDateClick(date),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: getIsItStartAndEndDate(date) ? _primaryColor : Colors.transparent,
                            borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                            border: Border.all(
                              color: getIsItStartAndEndDate(date) ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: getIsItStartAndEndDate(date)
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      blurRadius: 4,
                                      offset: const Offset(0, 0),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: getIsItStartAndEndDate(date)
                                    ? Colors.white
                                    : currentMonthDate.month == date.month
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.6),
                                fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
                                fontWeight: getIsItStartAndEndDate(date) ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 今日标记点
                  Positioned(
                    bottom: 9,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: DateTime.now().day == date.day &&
                                DateTime.now().month == date.month &&
                                DateTime.now().year == date.year
                            ? getIsInRange(date)
                                ? Colors.white
                                : _primaryColor
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        count += 1;
      }
      noList.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: listUI,
      ));
    }
    return noList;
  }

  bool getIsInRange(DateTime date) {
    if (startDate != null && endDate != null) {
      return date.isAfter(startDate!) && date.isBefore(endDate!);
    }
    return false;
  }

  bool getIsItStartAndEndDate(DateTime date) {
    if (startDate != null &&
        startDate!.day == date.day &&
        startDate!.month == date.month &&
        startDate!.year == date.year) {
      return true;
    } else if (endDate != null &&
        endDate!.day == date.day &&
        endDate!.month == date.month &&
        endDate!.year == date.year) {
      return true;
    }
    return false;
  }

  bool isStartDateRadius(DateTime date) {
    if (startDate != null &&
        startDate!.day == date.day &&
        startDate!.month == date.month) {
      return true;
    } else if (date.weekday == 1) {
      return true;
    }
    return false;
  }

  bool isEndDateRadius(DateTime date) {
    if (endDate != null &&
        endDate!.day == date.day &&
        endDate!.month == date.month) {
      return true;
    } else if (date.weekday == 7) {
      return true;
    }
    return false;
  }

  void onDateClick(DateTime date) {
    // 只允许选择当月日期
    if (currentMonthDate.month != date.month) return;

    if (startDate == null) {
      startDate = date;
    } else if (startDate != date && endDate == null) {
      endDate = date;
    } else if (startDate!.day == date.day && startDate!.month == date.month) {
      startDate = null;
    } else if (endDate != null && endDate!.day == date.day && endDate!.month == date.month) {
      endDate = null;
    }

    if (startDate == null && endDate != null) {
      startDate = endDate;
      endDate = null;
    }

    if (startDate != null && endDate != null) {
      if (!endDate!.isAfter(startDate!)) {
        final DateTime d = startDate!;
        startDate = endDate;
        endDate = d;
      }
      if (date.isBefore(startDate!)) {
        startDate = date;
      }
      if (date.isAfter(endDate!)) {
        endDate = date;
      }
    }

    setState(() {});
  }
}

void registerCalendarDemo() {
  demoRegistry.register(CalendarDemo());
}

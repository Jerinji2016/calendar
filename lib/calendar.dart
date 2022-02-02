import 'package:calendar/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class Calendar {
  static int getNoOfDaysInMonth(int month, int year) {
    bool isLeapYear = year % 4 == 0;
    switch (month) {
      case DateTime.january:
      case DateTime.march:
      case DateTime.may:
      case DateTime.july:
      case DateTime.august:
      case DateTime.october:
      case DateTime.december:
        return 31;
      case DateTime.february:
        return isLeapYear ? 29 : 28;
      default:
        return 30;
    }
  }
}

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _Calendar(
      month: DateTime.february,
      year: 2022,
    );
  }
}

class _Calendar extends StatefulWidget {
  final int month;
  final int year;

  final double? width;

  const _Calendar({
    Key? key,
    required this.month,
    required this.year,
    this.width,
  }) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> with TickerProviderStateMixin {
  static const int infinitePageOffset = 999;
  static const double _widgetControllerHeight = 45.0;
  static const int nextMonth = 1, prevMonth = -1;

  late final PageController _monthPageController = PageController(
    initialPage: infinitePageOffset,
  );
  final DateTime dateTime = DateTime(2021, 10, 2);

  double _newHeight = 500;

  late ValueNotifier<String> titleTime;

  @override
  void initState() {
    super.initState();
    titleTime = ValueNotifier(DateFormat("MMMM d, EEEE yyyy").format(dateTime));
  }

  @override
  Widget build(BuildContext context) {
    double calendarWidth = widget.width ?? MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ValueListenableBuilder<String>(
            valueListenable: titleTime,
            builder: (context, value, child) => Text(
              value,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFF26292E),
            child: SizedBox(
              // color: Colors.red,
              child: PageView.builder(
                controller: _monthPageController,
                itemBuilder: (context, index) {
                  int pageIndex = index - infinitePageOffset;
                  debugPrint('_CalendarState.build: $pageIndex');
                  DateTime dateDelegate = DateTime(dateTime.year, dateTime.month + pageIndex, dateTime.day);

                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Stack(
                      children: [
                        //  Change month buttons
                        Container(
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                color: Colors.black45,
                                width: 1.0,
                              ),
                            ),
                            color: Color(0xFF202123),
                          ),
                          height: _widgetControllerHeight,
                          child: Center(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: InkWell(
                                      onTap: () => _changeMonth(prevMonth),
                                      highlightColor: Colors.transparent,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(22.5),
                                      ),
                                      child: const SizedBox(
                                        height: _widgetControllerHeight,
                                        width: _widgetControllerHeight,
                                        child: Icon(
                                          Icons.keyboard_arrow_left,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                Expanded(
                                  child: Center(
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      onTap: () => _changeMonth(nextMonth),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(22.5),
                                      ),
                                      child: const SizedBox(
                                        height: _widgetControllerHeight,
                                        width: _widgetControllerHeight,
                                        child: Icon(
                                          Icons.keyboard_arrow_right,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        //  Calendar body
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: _widgetControllerHeight,
                              child: Center(
                                child: Text(
                                  DateFormat("MMMM").format(dateDelegate),
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: calendarWidth,
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: _CalendarMonth(
                                dateTime: dateDelegate,
                                width: widget.width ?? MediaQuery.of(context).size.width,
                                showFooter: false,
                                postBuildCallback: (Size widgetSize) {
                                  if (_newHeight != widgetSize.height) {
                                    setState(() {
                                      _newHeight = widgetSize.height;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  void _onMonthChanged(int index) {}

  void _changeMonth(int action) {
    if (action == nextMonth) {
    } else {}
  }
}

class _CalendarMonth extends StatelessWidget {
  static const double weekHeaderHeight = 36.0;
  static const int weekIterator = 6;

  final DateTime dateTime;
  final double width;
  final bool showFooter;
  final Function(Size widgetSize)? postBuildCallback;

  final int weekStart = DateTime.monday;

  final List<String> weekHeaders = [];
  final List<int> weekIndex = [];
  late final int firstDayOffset;

  late final int noOfDaysInMonth;

  _CalendarMonth({
    Key? key,
    required this.dateTime,
    required this.width,
    this.showFooter = false,
    this.postBuildCallback,
  }) : super(key: key) {
    switch (weekStart) {
      case DateTime.monday:
        weekHeaders.addAll(["M", "T", "W", "T", "F", "S", "S"]);
        weekIndex.addAll([1, 2, 3, 4, 5, 6, 7]);
        break;
      case DateTime.sunday:
        weekHeaders.addAll(["S", "M", "T", "W", "T", "F", "S"]);
        weekIndex.addAll([7, 1, 2, 3, 4, 5, 6]);
        break;
      default:
        weekHeaders.addAll(["S", "S", "M", "T", "W", "T", "F"]);
        weekIndex.addAll([6, 7, 1, 2, 3, 4, 5]);
    }

    noOfDaysInMonth = Calendar.getNoOfDaysInMonth(dateTime.month, dateTime.year);

    DateTime firstDayOfMonth = dateTime.firstDayOfMonth;
    firstDayOffset = weekIndex.indexWhere((element) => element == firstDayOfMonth.weekday);
  }

  @override
  Widget build(BuildContext context) {
    double cellWidth = width / 7;
    int totalDateTiles = (Calendar.getNoOfDaysInMonth(dateTime.month, dateTime.year) + firstDayOffset + 1);
    int requiredRows = (totalDateTiles / 7).ceil();

    if (postBuildCallback != null) {
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        try {
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          postBuildCallback!.call(renderBox.size);
        } catch (e) {
          debugPrint('_CalendarMonth.build: call back error');
        }
      });
    }

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: weekHeaderHeight,
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: weekHeaders
                  .map(
                    (e) => SizedBox(
                      width: cellWidth,
                      child: Center(
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Color(0xFF989DB3),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          for (int i = 0; i < requiredRows; i++)
            Row(
              children: [
                for (int j = 0; j < 7; j++)
                  Builder(
                    builder: (context) {
                      int index = weekIterator * i + j;
                      int date = index - firstDayOffset + 1;
                      bool isValid = date > 0 && date <= noOfDaysInMonth;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: cellWidth,
                            height: cellWidth,
                            child: isValid
                                ? Center(
                                    child: Text(
                                      "$date",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(
                            height: 6.0,
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          if (showFooter)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: const BoxDecoration(
                color: Color(0xFF7C828D),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: const SizedBox(
                width: 32,
                height: 3,
              ),
            ),
        ],
      ),
    );
  }
}

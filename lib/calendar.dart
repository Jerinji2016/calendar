import 'package:calendar/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  static void showDatePickerDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Size size = MediaQuery.of(context).size;
        debugPrint('Calendar.showDatePickerDialog: $size');
        return Center(
          child: Wrap(
            children: [
              Builder(
                builder: (context) {
                  Orientation orientation = MediaQuery.of(context).orientation;
                  bool isPortrait = orientation == Orientation.portrait;
                  debugPrint('Calendar.showDatePickerDialog: $orientation');
                  Size size = MediaQuery.of(context).size;
                  double width = isPortrait ? size.width - 60 : size.height - 100;
                  double? height = isPortrait ? null : (size.height - 60);
                  debugPrint('Calendar.showDatePickerDialog: $width');
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Material(
                      color: Colors.red,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: width,
                            height: height,
                            child: _Calendar(
                              width: width,
                              month: DateTime.february,
                              year: 2022,
                              showMonthInHeader: true,
                              showMonthActionButtons: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
  final void Function(int index, DateTime date)? onMonthChanged;
  final bool showMonthActionButtons;
  final bool showMonthInHeader;

  final double? width;

  const _Calendar({
    Key? key,
    required this.month,
    required this.year,
    this.width,
    this.onMonthChanged,
    this.showMonthInHeader = false,
    this.showMonthActionButtons = false,
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
    keepPage: true,
  );
  final DateTime dateTime = DateTime(2021, 10, 2);

  //  caches height value on changing page
  double _newHeight = 300;

  //  actual height to which the container will adjust.. derived from [_newHeight]
  double _dynamicCalendarHeight = 301;

  late ValueNotifier<String> titleTime;

  @override
  void initState() {
    super.initState();
    titleTime = ValueNotifier(DateFormat("MMMM d, EEEE yyyy").format(dateTime));

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        debugPrint('_CalendarState.initState: ');
        _onPageChanged(_monthPageController.page!.toInt());
      });
    });
  }

  DateTime _getDateTimeFromIndex(int index) {
    int pageIndex = index - infinitePageOffset;
    return DateTime(dateTime.year, dateTime.month + pageIndex, dateTime.day);
  }

  double _getDefaultWidth() {
    Orientation orientation = MediaQuery.of(context).orientation;
    Size size = MediaQuery.of(context).size;
    if (orientation == Orientation.portrait) return size.width;
    return size.height;
  }

  @override
  Widget build(BuildContext context) {
    double calendarWidth = widget.width ?? _getDefaultWidth();

    return Container(
      color: const Color(0xFF26292E),
      child: SizedBox(
        height: _dynamicCalendarHeight + (widget.showMonthInHeader ? _widgetControllerHeight : 0.0) + 10,
        child: Stack(
          children: [
            //  Actual calendar
            PageView.builder(
              controller: _monthPageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                // debugPrint('_CalendarState.build: $pageIndex');
                DateTime dateDelegate = _getDateTimeFromIndex(index);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showMonthInHeader)
                      SizedBox(
                        height: _widgetControllerHeight,
                        child: Center(
                          child: Text(
                            DateFormat("MMMM").format(dateDelegate),
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Container(
                        width: calendarWidth,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: _CalendarMonth(
                            dateTime: dateDelegate,
                            width: calendarWidth,
                            postBuildCallback: (Size widgetSize) {
                              debugPrint('_CalendarState.build: post call: $_newHeight == ${widgetSize.height}');
                              if (_newHeight != widgetSize.height) {
                                _newHeight = widgetSize.height;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            //  Change month buttons
            if (widget.showMonthActionButtons)
              Container(
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.black45,
                      width: 1.0,
                    ),
                  ),
                  // color: Color(0xFF202123),
                ),
                height: _widgetControllerHeight,
                child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onMonthChanged(prevMonth),
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
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Expanded(
                        child: Center(
                          child: InkWell(
                            highlightColor: Colors.transparent,
                            onTap: () => _onMonthChanged(nextMonth),
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
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    debugPrint('_CalendarState._onPageChanged: $index');
    DateTime date = _getDateTimeFromIndex(index);
    widget.onMonthChanged?.call(index - infinitePageOffset, date);

    //  to optimise rendering
    if (_dynamicCalendarHeight != _newHeight) {
      setState(() => _dynamicCalendarHeight = _newHeight);
    }
  }

  void _onMonthChanged(int action) => (action == nextMonth)
      ? _monthPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        )
      : _monthPageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
}

class _CalendarMonth extends StatelessWidget {
  static const double weekHeaderHeight = 36.0;
  static const int weekIterator = 7;

  final DateTime dateTime;
  final double width;
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
    double cellWidth = width / weekIterator;
    int totalDateTiles = (noOfDaysInMonth + firstDayOffset);
    int requiredRows = (totalDateTiles / weekIterator).ceil();
    Orientation orientation = MediaQuery.of(context).orientation;
    bool showExtendedDate = orientation == Orientation.portrait;

    if (postBuildCallback != null) {
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        try {
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          postBuildCallback!.call(renderBox.size);
          debugPrint('_CalendarMonth.build: ${renderBox.size}');
        } catch (e) {
          //  ignore catch block
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
                for (int j = 0; j < weekIterator; j++)
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
                            height: cellWidth - (showExtendedDate ? 0 : 8),
                            child: isValid
                                ? Center(
                                    child: Text(
                                      date.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          if (showExtendedDate)
                            const SizedBox(
                              height: 6.0,
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

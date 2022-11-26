import 'dart:ui';

import 'package:calendar/extensions.dart';
import 'package:calendar/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

part 'calendar_month.dart';
part 'calendar_picker_widget.dart';
part 'datetime_title.dart';
part 'page_controller_buttons.dart';

const double _widgetControllerHeight = 45.0;
const Duration _pageTransitionDuration = Duration(milliseconds: 300);

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

  static Future<DateTime?> showDatePickerDialog(BuildContext context, DateTime initialDateTime) async =>
      await showDialog<DateTime?>(
        context: context,
        barrierColor: Colors.black45,
        barrierDismissible: true,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: _CalendarPickerWidget(
            initialDateTime: initialDateTime,
          ),
        ),
      );
}

class CalendarWidget extends StatelessWidget {
  final DateTime? selectedDateTime;
  final void Function(int pageIndex, DateTime dateTime)? onMonthChanged;

  const CalendarWidget({
    Key? key,
    this.selectedDateTime,
    this.onMonthChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _CalendarWrapper(
      month: DateTime.february,
      year: 2022,
      selectedDateTime: selectedDateTime,
      onMonthChanged: onMonthChanged,
    );
  }
}

/// Abstract class: should not be imported!
class _CalendarWrapper extends StatefulWidget {
  final int month;
  final int year;

  final bool showMonthActionButtons;
  final bool showMonthInHeader;

  final void Function(int index, DateTime date)? onMonthChanged;
  final void Function(DateTime pickedDate)? onDatePicked;

  final DateTime? selectedDateTime;
  final DateTime? disableDateBefore;

  final double? width;

  const _CalendarWrapper({
    Key? key,
    required this.month,
    required this.year,
    this.width,
    this.selectedDateTime,
    this.disableDateBefore,
    this.onMonthChanged,
    this.onDatePicked,
    this.showMonthInHeader = false,
    this.showMonthActionButtons = false,
  }) : super(key: key);

  @override
  _CalendarWrapperState createState() => _CalendarWrapperState();
}

class _CalendarWrapperState extends State<_CalendarWrapper> with TickerProviderStateMixin {
  static const int infinitePageOffset = 999;
  static const int _nextMonth = 1, _prevMonth = -1;

  final PageController _monthPageController = PageController(
    initialPage: infinitePageOffset,
    keepPage: true,
  );
  late DateTime dateTime;
  late DateTime? _selectedDateTime;

  final Map<int, double> _monthHeightsMap = {};

  //  actual height to which the container will adjust.. derived from [_newHeight]
  double _currentCalendarHeight = 301;

  void refreshWidget() => (mounted) ? _onPageChanged(_monthPageController.page!.toInt(), false) : null;

  @override
  void initState() {
    super.initState();

    _selectedDateTime = widget.selectedDateTime;
    (widget.selectedDateTime != null) ? dateTime = _selectedDateTime! : DateTime(widget.year, widget.month, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50)).then(
        (_) => _onPageChanged(_monthPageController.page!.toInt(), false),
      );
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

    return Material(
      color: Colors.transparent,
      child: ValueListenableBuilder<int>(
        valueListenable: weekStart,
        builder: (context, value, child) => SizedBox(
          height: _currentCalendarHeight + (widget.showMonthInHeader ? _widgetControllerHeight : 0.0) + 10,
          child: Stack(
            children: [
              //  Actual calendar
              PageView.builder(
                controller: _monthPageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  DateTime dateDelegate = _getDateTimeFromIndex(index);
                  DateFormat headerMonthFormat =
                      DateFormat(dateDelegate.year == DateTime.now().year ? "MMMM" : "MMMM y");

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showMonthInHeader)
                        SizedBox(
                          height: _widgetControllerHeight,
                          child: Center(
                            child: Text(
                              headerMonthFormat.format(dateDelegate),
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
                              weekStart: value,
                              selectedDateTime: _selectedDateTime,
                              onDatePicked: widget.onDatePicked != null
                                  ? (date) {
                                      _selectedDateTime = date;
                                      widget.onDatePicked?.call(date);
                                      setState(() {});
                                    }
                                  : null,
                              disableDateBefore: widget.disableDateBefore,
                              postBuildCallback: (Size widgetSize) =>
                                  _monthHeightsMap[index - infinitePageOffset] = widgetSize.height,
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
                _PageControllerButtons(
                  buttonSize: _widgetControllerHeight,
                  onBackwardButtonTap: () => _onMonthChanged(_prevMonth),
                  onForwardButtonTap: () => _onMonthChanged(_nextMonth),
                  backgroundColor: Colors.black45,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPageChanged(int index, [bool notify = true]) {
    DateTime date = _getDateTimeFromIndex(index);
    if (notify) widget.onMonthChanged?.call(index - infinitePageOffset, date);

    //  to optimise rendering
    debugPrint("_CalendarWrapperState._onPageChanged: $index");
    double monthHeight = _monthHeightsMap[index - infinitePageOffset]!;
    if (_currentCalendarHeight != monthHeight) {
      setState(() => _currentCalendarHeight = monthHeight);
    }
  }

  void _onMonthChanged(int action) => (action == _nextMonth)
      ? _monthPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        )
      : _monthPageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
}

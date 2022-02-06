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

  static void showDatePickerDialog(BuildContext context, DateTime initialDateTime) async {
    await showDialog(
      context: context,
      barrierColor: const Color(0xFF131934),
      barrierDismissible: true,
      builder: (context) => _CalendarPickerWidget(
        initialDateTime: initialDateTime,
        selectedDateTime: DateTime.now(),
      ),
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

  void refreshWidget() => (mounted) ? _onPageChanged(_monthPageController.page!.toInt(), false) : null;

  @override
  void initState() {
    super.initState();
    titleTime = ValueNotifier(DateFormat("MMMM d, EEEE yyyy").format(dateTime));

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        debugPrint('_CalendarState.initState: ');
        _onPageChanged(_monthPageController.page!.toInt(), false);
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

    return SizedBox(
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
                            // debugPrint('_CalendarState.build: post call: $_newHeight == ${widgetSize.height}');
                            if (_newHeight != widgetSize.height) _newHeight = widgetSize.height;
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
    );
  }

  void _onPageChanged(int index, [bool notify = false]) {
    DateTime date = _getDateTimeFromIndex(index);
    if (notify) widget.onMonthChanged?.call(index - infinitePageOffset, date);

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
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
                            height: cellWidth - (showExtendedDate ? 0 : 12),
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

class _CalendarPickerWidget extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime selectedDateTime;
  final void Function(DateTime)? onDatePicked;

  const _CalendarPickerWidget({
    Key? key,
    required this.initialDateTime,
    required this.selectedDateTime,
    this.onDatePicked,
  }) : super(key: key);

  @override
  State<_CalendarPickerWidget> createState() => _CalendarPickerWidgetState();
}

class _CalendarPickerWidgetState extends State<_CalendarPickerWidget> {
  late DateTime dateTime;
  late DateTime _selectedDate;
  final GlobalKey<_CalendarState> _calendarKey = GlobalKey();

  Orientation currentOrientation = Orientation.portrait;

  @override
  void initState() {
    super.initState();

    dateTime = widget.initialDateTime;
    _selectedDate = widget.selectedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    Orientation newOrientation = MediaQuery.of(context).orientation;
    if (newOrientation != currentOrientation) {
      SchedulerBinding.instance?.addPostFrameCallback(
        (_) => Future.delayed(const Duration(milliseconds: 600)).then(
          (__) => setState(
            () {
              currentOrientation = newOrientation;
              _calendarKey.currentState?.refreshWidget();
            },
          ),
        ),
      );
    }

    bool isPortrait = newOrientation == Orientation.portrait;
    Size size = MediaQuery.of(context).size;
    double width = isPortrait ? size.width - 60 : size.height - 100;

    return Center(
      child: Wrap(
        children: [
          Container(
            color: const Color(0xFF26292E),
            child: Flex(
              direction: isPortrait ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 20.0,
                    top: (!isPortrait ? 30.0 : 0.0),
                  ),
                  child: isPortrait
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            DateFormat("MMMM d, EEEE yyyy").format(dateTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            text: DateFormat("yyyy\n").format(dateTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                            children: [
                              TextSpan(
                                text: DateFormat("EEEE\n").format(dateTime),
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: DateFormat("d MMMM").format(dateTime),
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: width,
                        child: Material(
                          color: Colors.transparent,
                          child: _Calendar(
                            key: _calendarKey,
                            width: width,
                            month: DateTime.february,
                            year: 2022,
                            showMonthInHeader: true,
                            showMonthActionButtons: true,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          bottom: 15.0,
                          right: 15.0,
                          top: (isPortrait ? 0.0 : 10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(2.0)),
                                side: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey,
                                ),
                              ),
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context, widget.selectedDateTime),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 20.0,
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Material(
                              color: Colors.grey,
                              child: InkWell(
                                onTap: () => Navigator.pop(context, _selectedDate),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 20.0,
                                  ),
                                  child: Text(
                                    'Ok',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:calendar/extensions.dart';
import 'package:flutter/material.dart';

class Calendar {
  static int getNoOfDaysInMonth(int month, int year) {
    bool isLeapYear = year % 4 == 0;
    debugPrint('Calendar.getNoOfDaysInMonth: $isLeapYear');
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

class _CalendarState extends State<_Calendar> {
  @override
  Widget build(BuildContext context) {
    double calendarWidth = widget.width ?? MediaQuery.of(context).size.width;
    return Container(
      width: calendarWidth,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF26292E),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: _CalendarMonth(
        dateTime: DateTime(2021, 10, 20),
        width: widget.width ?? MediaQuery.of(context).size.width,
      ),
    );
  }
}

class _CalendarMonth extends StatelessWidget {
  static const double weekHeaderHeight = 36.0;
  static const int weekIterator = 6;
  final DateTime dateTime;
  final double width;
  final int weekStart = DateTime.monday;

  final List<String> weekHeaders = [];
  final List<int> weekIndex = [];
  late final int firstDayOffset;

  late final int noOfDaysInMonth;

  _CalendarMonth({
    Key? key,
    required this.dateTime,
    required this.width,
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

  int _getRequiredRows() => ((Calendar.getNoOfDaysInMonth(dateTime.month, dateTime.year) + firstDayOffset) / 7).ceil();

  @override
  Widget build(BuildContext context) {
    debugPrint('_CalendarMonth.build: $dateTime');
    double cellWidth = width / 7;
    debugPrint('_CalendarMonth.build: $weekHeaders');
    int requiredRows = _getRequiredRows();
    debugPrint('_CalendarMonth.build: requiredRows: $requiredRows');

    return Column(
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
          Container(
            child: Row(
              children: [
                for (int j = 0; j < 7; j++)
                  Builder(
                    builder: (context) {
                      int index = weekIterator * i + j;
                      int date = index - firstDayOffset + 1;
                      bool isValid = date > 0 && date <= noOfDaysInMonth;
                      return SizedBox(
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
                      );
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

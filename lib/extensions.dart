import 'calendar/calendar.dart';

extension DateTimeExtension on DateTime {
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  DateTime get lastDayOfMonth => DateTime(year, month, Calendar.getNoOfDaysInMonth(month, year));

  DateTime get absolute => DateTime(year, month, day);
}

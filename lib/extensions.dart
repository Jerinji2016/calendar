import 'calendar.dart';

extension DateTimeExtension on DateTime {
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  DateTime get lastDayOfMonth => DateTime(year, month, Calendar.getNoOfDaysInMonth(month, year));
}

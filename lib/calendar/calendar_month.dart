part of 'calendar.dart';

/// Abstract class: should not be imported!
class _CalendarMonth extends StatelessWidget {
  static const double weekHeaderHeight = 36.0;
  static const int weekIterator = 7;

  final DateTime dateTime;
  final DateTime? selectedDateTime;
  final DateTime? disableDateBefore;

  final double width;
  final int weekStart;

  final Function(Size widgetSize)? postBuildCallback;
  final Function(DateTime datePicked)? onDatePicked;

  final List<String> _weekHeaders = [];
  final List<int> _weekIndex = [];

  late final int _firstDayOffset;
  late final int noOfDaysInMonth;

  _CalendarMonth({
    Key? key,
    required this.dateTime,
    required this.width,
    required this.weekStart,
    this.selectedDateTime,
    this.disableDateBefore,
    this.postBuildCallback,
    this.onDatePicked,
  }) : super(key: key) {
    switch (weekStart) {
      case DateTime.monday:
        _weekHeaders.addAll(["M", "T", "W", "T", "F", "S", "S"]);
        _weekIndex.addAll([1, 2, 3, 4, 5, 6, 7]);
        break;
      case DateTime.sunday:
        _weekHeaders.addAll(["S", "M", "T", "W", "T", "F", "S"]);
        _weekIndex.addAll([7, 1, 2, 3, 4, 5, 6]);
        break;
      default:
        _weekHeaders.addAll(["S", "S", "M", "T", "W", "T", "F"]);
        _weekIndex.addAll([6, 7, 1, 2, 3, 4, 5]);
    }

    noOfDaysInMonth = Calendar.getNoOfDaysInMonth(dateTime.month, dateTime.year);

    DateTime firstDayOfMonth = dateTime.firstDayOfMonth;
    _firstDayOffset = _weekIndex.indexWhere((element) => element == firstDayOfMonth.weekday);
  }

  @override
  Widget build(BuildContext context) {
    double cellWidth = width / weekIterator;
    int totalDateTiles = (noOfDaysInMonth + _firstDayOffset);
    int requiredRows = (totalDateTiles / weekIterator).ceil();

    Orientation orientation = MediaQuery.of(context).orientation;
    bool showExtendedDate = (orientation == Orientation.portrait);

    if (postBuildCallback != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
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
                children: _weekHeaders
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
                      int date = index - _firstDayOffset + 1;
                      bool isValid = date > 0 && date <= noOfDaysInMonth;

                      DateTime thisDay = DateTime(dateTime.year, dateTime.month, date);
                      bool isSelected =
                          selectedDateTime != null && (thisDay.compareTo(selectedDateTime!.absolute) == 0);
                      bool isDisabled = disableDateBefore != null && thisDay.compareTo(disableDateBefore!.absolute) < 0;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(
                            builder: (context) {
                              return SizedBox(
                                width: cellWidth,
                                height: cellWidth - (showExtendedDate ? 0 : 18),
                                child: isValid
                                    ? Center(
                                        child: Material(
                                          color: isSelected ? Colors.grey : Colors.transparent,
                                          shape: const ContinuousRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                          ),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            customBorder: const ContinuousRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                            ),
                                            onTap: isDisabled ? null : () => onDatePicked?.call(thisDay),
                                            child: SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: Center(
                                                child: Text(
                                                  date.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: isDisabled ? Colors.grey : Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
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

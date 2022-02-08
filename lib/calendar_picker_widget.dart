part of 'calendar.dart';

class _CalendarPickerWidget extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime selectedDateTime;
  final DateTime? disableDatesBefore;

  const _CalendarPickerWidget({
    Key? key,
    required this.initialDateTime,
    required this.selectedDateTime,
    this.disableDatesBefore,
  }) : super(key: key);

  @override
  State<_CalendarPickerWidget> createState() => _CalendarPickerWidgetState();
}

class _CalendarPickerWidgetState extends State<_CalendarPickerWidget> {
  late ValueNotifier<DateTime> _dateTime;
  final GlobalKey<_CalendarWrapperState> _calendarKey = GlobalKey();

  Orientation currentOrientation = Orientation.portrait;

  @override
  void initState() {
    super.initState();

    _dateTime = ValueNotifier(widget.initialDateTime);
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
            decoration: const BoxDecoration(
              color: Color(0xFF26292E),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
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
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: _dateTime,
                    builder: (context, value, child) => isPortrait
                        ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        DateFormat("MMMM d, EEEE yyyy").format(value),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : RichText(
                      text: TextSpan(
                        text: DateFormat("yyyy\n").format(value),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                        children: [
                          TextSpan(
                            text: DateFormat("EEEE\n").format(value),
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: DateFormat("d MMMM").format(value),
                            style: const TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
                          child: _CalendarWrapper(
                            key: _calendarKey,
                            width: width,
                            month: DateTime.february,
                            disableDateBefore: DateTime(2021, 09, 22),
                            year: 2022,
                            showMonthInHeader: true,
                            showMonthActionButtons: true,
                            onDatePicked: _onDatePicked,
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
                                onTap: () => Navigator.pop(context, _dateTime.value),
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

  void _onDatePicked(DateTime pickedDate) {
    _dateTime.value = pickedDate;
  }
}
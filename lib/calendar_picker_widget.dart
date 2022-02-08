part of 'calendar.dart';

/// Abstract class: should not be imported!
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
    double width = isPortrait ? size.width - 80 : size.height - 100;

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
                  child: _DateTimeTitle(
                    _dateTime,
                    onMonthTapped: _onMonthTapped,
                    onYearTapped: _onYearTapped,
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
                      if (isPortrait) const SizedBox(height: 10.0),
                      Container(
                        padding: EdgeInsets.only(
                          bottom: 15.0,
                          right: 15.0,
                          top: (isPortrait ? 0.0 : 10.0),
                        ),
                        child: _FooterButton(
                          onOKTapped: () => Navigator.pop(context, _dateTime.value),
                          onCancelTapped: () => Navigator.pop(context, widget.selectedDateTime),
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

  void _onMonthTapped() {
    debugPrint('_CalendarPickerWidgetState._onMonthTapped: ');
  }

  void _onYearTapped() {
    debugPrint('_CalendarPickerWidgetState._onYearTapped: ');
  }

  void _onDatePicked(DateTime pickedDate) {
    _dateTime.value = pickedDate;
  }
}

class _FooterButton extends StatelessWidget {
  final void Function() onOKTapped;
  final void Function() onCancelTapped;

  const _FooterButton({
    Key? key,
    required this.onCancelTapped,
    required this.onOKTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onTap: onCancelTapped,
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
            onTap: onOKTapped,
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
    );
  }
}

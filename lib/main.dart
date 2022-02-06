import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    const MaterialApp(
      home: BaseWidget(),
      themeMode: ThemeMode.dark,
    ),
  );
}

class BaseWidget extends StatefulWidget {
  const BaseWidget({Key? key}) : super(key: key);

  @override
  State<BaseWidget> createState() => _BaseWidgetState();
}

class _BaseWidgetState extends State<BaseWidget> {
  late ValueNotifier<DateTime> _dateTime;

  @override
  void initState() {
    super.initState();
    _dateTime = ValueNotifier(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202123),
      appBar: AppBar(
        title: const Text(
          "Calendar",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFAA2020),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
            return Flex(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              direction: isPortrait ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: ValueListenableBuilder<DateTime>(
                            valueListenable: _dateTime,
                            builder: (context, value, child) {
                              return _DateText(value);
                            }
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Material(
                            color: const Color(0xFF263238),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              side: BorderSide(
                                color: Color(0xFF29434e),
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              onTap: () => _showCalendarDialog(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 15.0,
                                ),
                                child: const Text(
                                  "Show Dialog",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: CalendarWidget(
                    selectedDateTime: _dateTime.value,
                    onMonthChanged: (index, dateTime) => _dateTime.value = dateTime,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) async {
    DateTime? date = await Calendar.showDatePickerDialog(context, DateTime.now());
    debugPrint('_BaseWidgetState._showCalendarDialog: pickedDate: $date');
  }
}

class _DateText extends StatelessWidget {
  final DateTime dateTime;

  const _DateText(this.dateTime, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RichText(
        text: TextSpan(
          text: DateFormat("yyyy\n").format(dateTime),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.0,
            color: Colors.grey,
          ),
          children: [
            TextSpan(
              text: DateFormat("MMMM").format(dateTime),
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

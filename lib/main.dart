import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

ValueNotifier<int> weekStart = ValueNotifier(DateTime.monday);

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
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: isPortrait
                            ? const BorderSide(
                                color: Colors.grey,
                                width: 2.0,
                              )
                            : const BorderSide(),
                        right: !isPortrait
                            ? const BorderSide(
                                color: Colors.grey,
                                width: 2.0,
                              )
                            : const BorderSide(),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isPortrait)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                              child: ValueListenableBuilder<DateTime>(
                                valueListenable: _dateTime,
                                builder: (context, value, child) => _DateText(value, isPortrait: false),
                              ),
                            ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: isPortrait ? 50.0 : 30.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Week Start: ",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 20.0),
                                  Expanded(
                                    child: ValueListenableBuilder<int>(
                                      valueListenable: weekStart,
                                      builder: (context, value, child) => DropdownButton<int>(
                                        value: weekStart.value,
                                        isDense: false,
                                        isExpanded: true,
                                        dropdownColor: Colors.grey[800]!,
                                        onChanged: (value) {
                                          if (value != null) weekStart.value = value;
                                        },
                                        items: [
                                          _dropDownMenuItemTile(DateTime.sunday, "Sunday"),
                                          _dropDownMenuItemTile(DateTime.saturday, "Saturday"),
                                          _dropDownMenuItemTile(DateTime.monday, "Monday"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
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
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPortrait)
                        Container(
                          margin: const EdgeInsets.all(20.0),
                          child: ValueListenableBuilder<DateTime>(
                            valueListenable: _dateTime,
                            builder: (context, value, child) => _DateText(value),
                          ),
                        ),
                      Container(
                        decoration: isPortrait
                            ? const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              )
                            : null,
                        child: ValueListenableBuilder(
                          valueListenable: weekStart,
                          builder: (context, value, child) => CalendarWidget(
                            selectedDateTime: _dateTime.value,
                            onMonthChanged: (index, dateTime) => _dateTime.value = dateTime,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  DropdownMenuItem<int> _dropDownMenuItemTile(int value, String text) => DropdownMenuItem<int>(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        value: value,
      );

  void _showCalendarDialog(BuildContext context) async {
    DateTime? date = await Calendar.showDatePickerDialog(context, DateTime.now());
    debugPrint('_BaseWidgetState._showCalendarDialog: pickedDate: $date');
  }
}

class _DateText extends StatelessWidget {
  final DateTime dateTime;
  final bool isPortrait;

  const _DateText(
    this.dateTime, {
    Key? key,
    this.isPortrait = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: isPortrait ? TextAlign.start : TextAlign.end,
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
    );
  }
}

import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: BaseWidget(),
      themeMode: ThemeMode.dark,
    ),
  );
}

class BaseWidget extends StatelessWidget {
  const BaseWidget({Key? key}) : super(key: key);

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
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.125,
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
                ),
                const Expanded(
                  flex: 2,
                  child: Center(child: CalendarWidget()),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) async {
    Calendar.showDatePickerDialog(context, DateTime.now());
  }
}

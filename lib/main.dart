import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) => const BaseWidget(),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.125,
              child: Center(
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      border: Border.all(
                        color: const Color(0xFF29434e),
                        width: 2,
                      ),
                      color: const Color(0xFF263238),
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
            const Expanded(
              child: CalendarWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

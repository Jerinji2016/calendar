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
      body: const Center(
        child: CalendarWidget(),
      ),
    );
  }
}

part of calendar;

/// Abstract class: should not be imported!
class _DateTimeTitle extends StatelessWidget {
  final ValueNotifier<DateTime> dateTime;
  final void Function() onMonthTapped;
  final void Function() onYearTapped;

  const _DateTimeTitle(
    this.dateTime, {
    Key? key,
    required this.onMonthTapped,
    required this.onYearTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return ValueListenableBuilder<DateTime>(
      valueListenable: dateTime,
      builder: (context, value, child) => isPortrait ? _portraitTitle(value) : _landscapeTitle(value),
    );
  }

  Widget _portraitTitle(DateTime value) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onMonthTapped,
              child: Text(
                DateFormat("MMMM").format(value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(
              DateFormat("d").format(value),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat(", EEEE").format(value),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 5.0),
            GestureDetector(
              onTap: onYearTapped,
              child: Text(
                DateFormat("yyyy").format(value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _landscapeTitle(DateTime value) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onYearTapped,
            child: Text(
              DateFormat("yyyy").format(value),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            DateFormat("EEEE").format(value),
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat("d ").format(value),
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: onMonthTapped,
                child: Text(
                  DateFormat("MMMM").format(value),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      );
}

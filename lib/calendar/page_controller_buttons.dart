part of 'calendar.dart';

class _PageControllerButtons extends StatelessWidget {
  final void Function() onForwardButtonTap;
  final void Function() onBackwardButtonTap;
  final double buttonSize;
  final Color backgroundColor;

  const _PageControllerButtons({
    Key? key,
    required this.buttonSize,
    required this.onBackwardButtonTap,
    required this.onForwardButtonTap,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: backgroundColor,
            width: 1.0,
          ),
        ),
      ),
      height: buttonSize,
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBackwardButtonTap,
                    highlightColor: Colors.transparent,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(22.5),
                    ),
                    child: SizedBox(
                      height: buttonSize,
                      width: buttonSize,
                      child: const Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Expanded(
              child: Center(
                child: InkWell(
                  highlightColor: Colors.transparent,
                  onTap: onForwardButtonTap,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(22.5),
                  ),
                  child: SizedBox(
                    height: buttonSize,
                    width: buttonSize,
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

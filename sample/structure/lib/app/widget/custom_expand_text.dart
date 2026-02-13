import '../utils/import.dart';

class ExpandableText extends StatelessWidget {
  final String text;
  final int trimLines;
  final TextStyle style;
  final ExpandableTextController controller;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLines = 3,
    required this.style,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: trimLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = tp.didExceedMaxLines;

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final loc = AppLocalizations.of(context)!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: style,
                  maxLines: controller.isExpanded ? null : trimLines,
                  overflow: controller.isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                if (isOverflowing)
                  GestureDetector(
                    onTap: controller.toggle,
                    child: Text(
                      controller.isExpanded ? loc.showLess : loc.readMore,
                      style: AppTextStyle.bold(
                        size: 14,
                        color: AppColor.k161A25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class ExpandableTextController extends ChangeNotifier {
  bool isExpanded = false;

  void toggle() {
    isExpanded = !isExpanded;
    notifyListeners();
  }
}
